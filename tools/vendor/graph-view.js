// Dialogue graph view — Phase 1 (read-only minimap).
//
// Renders json.states + derived edges (from findChoiceConsequences /
// computeExcludedForChoice in the main editor scope) as a layered graph.
// Reuses theme CSS variables, never writes to JSON.
//
// Architectural rule: the JSON is the source of truth. This file READS:
//   - files[currentFile].json (states + structure)
//   - findChoiceConsequences, computeExcludedForChoice, findStateById
//   - pinnedConsequences (for excluded-edge rendering)
//   - body.classList (light/dark theme)
//
// And WRITES only in-memory UI state (selection, pan/zoom, search, view mode).
//
// Layout: custom Sugiyama-style layered layout in §LAYOUT below.
// Drop-in for dagre — if window.dagre exists, we'd prefer it, but the spec
// allows a hand-rolled minimal alternative because the graphs are small.

(function () {
  'use strict';

  // ===== STATE =====
  const NODE_W = 240;
  const NODE_H = 108;
  const EXT_W = 150;
  const EXT_H = 48;
  const NODE_SEP = 56;
  const RANK_SEP = 90;
  const ZOOM_MIN = 0.25;
  const ZOOM_MAX = 3;

  const State = {
    rootEl: null,
    nodesLayer: null,
    edgesSvg: null,
    overlayLayer: null,
    selectedNodeId: null,
    hoveredNodeId: null,
    // panX/panY removed — pan is now driven by canvas.scrollLeft/scrollTop.
    zoom: 1,
    viewMode: 'split',          // 'linear' | 'graph' | 'split'
    searchFilter: '',
    nodes: [],                  // [{id, kind, role, x, y, w, h, state, external?}]
    edges: [],                  // [{source, target, choiceIdx, choice, kind, label, delta}]
    needsRecompute: true,
    isPanning: false,
    panStart: null,
    suppressNextClick: false,
    raf: null,
    // Phase 2 — pin-drag state. Set on pointerdown on a .gnode-pin;
    // cleared on pointerup or cancel. While non-null, document-level
    // pointermove / pointerup / Escape redirect through the drag pipeline.
    activeDrag: null,
    activePopover: null,
  };

  // ===== PUBLIC API =====
  window.GraphView = {
    init() { boot(); },
    recompute() { State.needsRecompute = true; scheduleRender(); },
    setMode(mode) { setViewMode(mode); },
    getMode() { return State.viewMode; },
    selectStateId(id, opts) { selectNode(id, opts || {}); },
    flashStateId(id) { flashNode(id); },
    onThemeChange() { scheduleRender(); },
  };

  // ===== BOOT =====
  function boot() {
    State.rootEl = document.getElementById('graph-pane');
    if (!State.rootEl) return;

    // SVG layer (edges) sits beneath, nodes layer (HTML) on top.
    // Both transformed together via .graph-viewport.
    State.rootEl.innerHTML = `
      <div class="graph-canvas">
        <div class="graph-viewport">
          <svg class="graph-edges" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <marker id="arrow-reach" viewBox="0 0 10 10" refX="9" refY="5"
                      markerWidth="6" markerHeight="6" orient="auto-start-reverse">
                <path d="M 0 0 L 10 5 L 0 10 z" fill="currentColor"/>
              </marker>
            </defs>
            <g class="edges-group"></g>
            <g class="edge-labels-group"></g>
          </svg>
          <div class="graph-nodes"></div>
        </div>
      </div>
      <!-- Overlay layer is OUTSIDE the scrollable canvas so its children
           (hint, search, tooltip, empty-state) stay anchored to the pane's
           viewport while the canvas scrolls. -->
      <div class="graph-overlay">
        <div class="graph-hint">drag/scroll to pan · ⌘/Ctrl + wheel to zoom · <kbd>f</kbd> fit · <kbd>0</kbd> reset · <kbd>/</kbd> search</div>
        <div class="graph-search" hidden>
          <input type="text" placeholder="filter by state id…" autocomplete="off" />
          <span class="graph-search-close">esc</span>
        </div>
        <div class="graph-tooltip" hidden></div>
        <div class="graph-empty" hidden>
          <div class="graph-empty-icon">◇</div>
          <div class="graph-empty-text">no states in this file</div>
        </div>
      </div>
    `;

    const canvas = State.rootEl.querySelector('.graph-canvas');
    State.nodesLayer = State.rootEl.querySelector('.graph-nodes');
    State.edgesSvg = State.rootEl.querySelector('.graph-edges');
    State.overlayLayer = State.rootEl.querySelector('.graph-overlay');

    bindCanvasEvents(canvas);
    bindSearchEvents();

    // Restore last view mode
    let stored = null;
    try { stored = localStorage.getItem('dialogue_editor_view_mode'); } catch (e) {}
    setViewMode(stored && ['linear', 'graph', 'split'].includes(stored) ? stored : 'split', { skipFit: true });

    // Initial paint
    State.needsRecompute = true;
    scheduleRender();
  }

  // ===== VIEW MODE =====
  function setViewMode(mode, opts) {
    opts = opts || {};
    // Narrow viewports can't host split.
    const isNarrow = window.innerWidth < 880;
    if (mode === 'split' && isNarrow) mode = State.viewMode === 'graph' ? 'graph' : 'linear';
    State.viewMode = mode;
    try { localStorage.setItem('dialogue_editor_view_mode', mode); } catch (e) {}
    const main = document.getElementById('main');
    if (main) {
      main.classList.toggle('view-linear', mode === 'linear');
      main.classList.toggle('view-graph', mode === 'graph');
      main.classList.toggle('view-split', mode === 'split');
    }
    // Sync toggle buttons in topbar
    document.querySelectorAll('.view-toggle-btn').forEach(b => {
      b.classList.toggle('active', b.dataset.mode === mode);
    });
    // Reset initial-fit flag so re-entering graph re-fits.
    State._didInitialFit = false;
    if ((mode === 'graph' || mode === 'split') && !opts.skipFit) {
      State.needsRecompute = true;
      // Wait one frame so the grid template settles and the pane has its width.
      setTimeout(() => scheduleRender(() => fitToView()), 80);
    } else {
      scheduleRender();
    }
  }

  // ===== EDGE / NODE DERIVATION =====
  function deriveGraph() {
    const wasNonEmpty = State.nodes.length > 0;
    State.nodes = [];
    State.edges = [];
    if (typeof currentFile === 'undefined' || !currentFile) return;
    const f = files[currentFile];
    if (!f || !f.json || !Array.isArray(f.json.states)) return;
    // If we're moving from empty -> non-empty, reset the initial-fit flag so
    // the next render auto-fits.
    if (!wasNonEmpty) State._didInitialFit = false;

    const nodeById = new Map();
    const externalById = new Map();
    const incomingCount = new Map();

    // First pass: real state nodes
    for (const state of f.json.states) {
      if (!state.id) continue;
      const node = {
        id: state.id,
        state,
        external: false,
        role: 'junction',  // refined below
        w: NODE_W,
        h: NODE_H,
        x: 0, y: 0,
        rank: 0, order: 0,
      };
      State.nodes.push(node);
      nodeById.set(state.id, node);
      incomingCount.set(state.id, 0);
    }

    // Second pass: edges
    for (const state of f.json.states) {
      if (!state.options || !Array.isArray(state.options.choices)) continue;
      const pinnedSibling = (typeof pinnedConsequences !== 'undefined')
        ? pinnedConsequences.find(p => p.stateId === state.id)
        : null;

      state.options.choices.forEach((choice, choiceIdx) => {
        // findChoiceConsequences returns every state whose trigger COULD match
        // post-commit. The runtime, however, picks the FIRST match in
        // declaration order and stops. For the graph view we mirror that
        // semantics so the diagram reflects what actually plays at runtime.
        // The "all candidates" view is preserved in the linear pane's chips
        // — that's still informational; the graph is structural.
        const allTargets = findChoiceConsequences(state, choice, state.options);
        const targets = allTargets.length > 0 ? [allTargets[0]] : [];
        for (const tid of targets) {
          let target = nodeById.get(tid);
          if (!target) {
            // External placeholder — create once, reuse for repeated references.
            if (!externalById.has(tid)) {
              target = {
                id: tid,
                state: null,
                external: true,
                role: 'external',
                w: EXT_W,
                h: EXT_H,
                x: 0, y: 0,
                rank: 0, order: 0,
              };
              externalById.set(tid, target);
              State.nodes.push(target);
              incomingCount.set(tid, 0);
            } else {
              target = externalById.get(tid);
            }
          }
          incomingCount.set(tid, (incomingCount.get(tid) || 0) + 1);
          State.edges.push({
            source: state.id,
            target: tid,
            choiceIdx,
            choice,
            kind: classifyEdgeKind(state, choice, target),
            label: (choice.text || '').slice(0, 28) + ((choice.text || '').length > 28 ? '…' : ''),
            delta: (typeof choice.trust_delta === 'number' && choice.trust_delta !== 0) ? choice.trust_delta : null,
          });
        }

        // Excluded edges only drawn when a sibling choice in this state is pinned.
        if (pinnedSibling && pinnedSibling.choiceIdx !== choiceIdx) {
          const excluded = computeExcludedForChoice(state, state.options, choiceIdx);
          for (const tid of excluded) {
            if (!nodeById.has(tid)) continue;
            State.edges.push({
              source: state.id,
              target: tid,
              choiceIdx,
              choice,
              kind: 'excluded',
              label: (choice.text || '').slice(0, 24) + ((choice.text || '').length > 24 ? '…' : ''),
              delta: null,
            });
          }
        }
      });
    }

    // Third pass: inferred chain edges. A state with `chain: true` at the
    // top level (NOT under options) re-fires the state walk on dismiss.
    // The graph view doesn't see those edges from the choice-edge pass
    // above, so the chain target sits at the same rank as its siblings
    // instead of one rank deeper. Walk the json states in declaration order
    // and add a soft edge from each chain-state to the FIRST subsequent
    // state whose trigger isn't contradicted by the chain-state's own
    // trigger — matches the runtime's "first match wins" semantics.
    const statesList = f.json.states.filter(s => s && s.id);
    for (let i = 0; i < statesList.length; i++) {
      const src = statesList[i];
      if (src.chain !== true) continue;
      // Skip states with options — those use options.chain and the choice
      // edges already model their downstream paths.
      if (src.options && Array.isArray(src.options.choices) && src.options.choices.length > 0) continue;
      for (let j = i + 1; j < statesList.length; j++) {
        const cand = statesList[j];
        if (!cand.id || !nodeById.has(cand.id)) continue;
        if (triggersContradict(src.trigger || '', cand.trigger || '')) continue;
        const tid = cand.id;
        incomingCount.set(tid, (incomingCount.get(tid) || 0) + 1);
        State.edges.push({
          source: src.id,
          target: tid,
          choiceIdx: -1, // sentinel: not from a choice
          choice: null,
          kind: 'chain',
          label: 'chain',
          delta: null,
        });
        break; // first match only
      }
    }

    // Refine roles
    for (const node of State.nodes) {
      if (node.external) { node.role = 'external'; continue; }
      const s = node.state;
      const hasChoices = !!(s.options && Array.isArray(s.options.choices) && s.options.choices.length);
      const hasOutgoing = State.edges.some(e => e.source === node.id);
      const hasIncoming = (incomingCount.get(node.id) || 0) > 0;
      if (hasChoices) node.role = 'question';
      else if (!hasIncoming && hasOutgoing) node.role = 'entry';
      else if (!hasIncoming && !hasOutgoing) node.role = 'entry';
      else if (hasIncoming && !hasOutgoing) node.role = 'terminal';
      else node.role = 'response';
    }

    layoutNodes();
  }

  // triggersContradict — fast structural check for the chain-edge inference.
  // We only catch direct == / != contradictions on the same path:
  //   A: `foo == 'x'`, B: `foo == 'y'` → contradiction.
  //   A: `!foo`,       B: `foo == 'x'` → contradiction (false is "" which is != 'x' — sort of; we treat presence-clauses as contradicting).
  //   A: `foo == 'x'`, B: `foo != 'x'` → contradiction.
  // Anything more subtle (numeric ranges, multi-clause AND/OR) is treated as
  // compatible. The intent is "would B silently fail if we walked into it
  // after A just committed" — false positives here would HIDE a chain edge
  // the runtime would actually take, which is worse than showing an extra
  // tentative edge. So we err on the side of NOT declaring contradiction.
  function triggersContradict(triggerA, triggerB) {
    if (!triggerA || !triggerB) return false; // empty trigger matches anything
    if (typeof parseTrigger !== 'function') return false;
    const aClauses = parseTrigger(triggerA);
    const bClauses = parseTrigger(triggerB);
    for (const a of aClauses) {
      for (const b of bClauses) {
        if (a.path !== b.path) continue;
        // path matches — check for contradiction by op/value
        if (a.op === '==' && b.op === '==' && String(a.value) !== String(b.value)) return true;
        if (a.op === '==' && b.op === '!=' && String(a.value) === String(b.value)) return true;
        if (a.op === '!=' && b.op === '==' && String(a.value) === String(b.value)) return true;
        // falsy (negated truthiness, e.g. `!met_asia`) vs == 'something' on
        // the same path: the chain state asserts the flag is falsy, but the
        // candidate compares it to a specific value. Treat as compatible —
        // a flag could be unset (falsy) while the candidate's clause is
        // checking equality, which would fail at runtime. We catch that
        // case as "compatible" so the edge IS drawn but the user can read
        // the trigger and judge. False-positive contradictions hide edges;
        // we'd rather show one than hide one.
      }
    }
    return false;
  }

  // Edge classification — matches the linear editor's full trust-precision
  // logic (Phase 2.5). If the target's trigger references trust_path:
  //   • at the trust-meter ENTRY state (the first state in the file that
  //     declares this options.trust_path AND whose own trigger doesn't
  //     reference trust_path), findChoiceConsequences was precise — any
  //     surviving edge is guaranteed reachable. Classify 'reachable'.
  //   • at any other state, post-trust depends on prior runs we don't
  //     simulate, so the edge is uncertain. Classify 'trust-gated' (dashed).
  // Edges without a trust-path clause on the target trigger are always
  // 'reachable'.
  function classifyEdgeKind(sourceState, choice, targetNode) {
    if (targetNode.external) return 'reachable';
    const target = targetNode.state;
    if (!target || !target.trigger) return 'reachable';
    const trustPath = sourceState.options ? sourceState.options.trust_path : null;
    if (!trustPath) return 'reachable';
    if (typeof parseTrigger !== 'function') return 'reachable';
    const targetClauses = parseTrigger(target.trigger);
    const hasTrustClause = targetClauses.some(c =>
      c.path === trustPath && (c.op === '>=' || c.op === '<='));
    if (!hasTrustClause) return 'reachable';
    // Check entry-state precision: source must not assert trust_path itself,
    // and must be the FIRST state in json.states declaring this trust_path.
    if (typeof currentFile !== 'undefined' && currentFile && files[currentFile]) {
      const json = files[currentFile].json;
      const sourceClauses = parseTrigger(sourceState.trigger || '');
      const sourceTouchesTrust = sourceClauses.some(c => c.path === trustPath);
      if (!sourceTouchesTrust && Array.isArray(json.states)) {
        let firstEntry = null;
        for (const s of json.states) {
          if (s.options && s.options.trust_path === trustPath) { firstEntry = s; break; }
        }
        if (firstEntry === sourceState) return 'reachable';
      }
    }
    return 'trust-gated';
  }

  // ===== §LAYOUT — minimal layered graph layout =====
  // Steps:
  //   1. Build adjacency from State.edges, detecting back-edges via DFS.
  //   2. Assign ranks via longest-path (BFS forward from roots).
  //   3. Order within ranks: median heuristic, 2 sweeps.
  //   4. Compute (x, y) from rank index and within-rank order, centering each rank.
  function layoutNodes() {
    if (State.nodes.length === 0) return;
    const byId = new Map(State.nodes.map(n => [n.id, n]));
    const out = new Map();    // id -> [targetId]
    const incoming = new Map(); // id -> [sourceId]
    for (const n of State.nodes) {
      out.set(n.id, []);
      incoming.set(n.id, []);
    }
    for (const e of State.edges) {
      if (!byId.has(e.source) || !byId.has(e.target)) continue;
      if (e.kind === 'excluded') continue; // don't influence layout
      out.get(e.source).push(e.target);
      incoming.get(e.target).push(e.source);
    }

    // Detect back-edges via DFS; ignore them for ranking so cycles don't trap us.
    const color = new Map(); // 0 white, 1 gray, 2 black
    const backEdges = new Set();
    for (const n of State.nodes) color.set(n.id, 0);
    function dfs(id) {
      color.set(id, 1);
      for (const t of out.get(id)) {
        const c = color.get(t);
        if (c === 0) dfs(t);
        else if (c === 1) backEdges.add(id + '\u0000' + t);
      }
      color.set(id, 2);
    }
    for (const n of State.nodes) if (color.get(n.id) === 0) dfs(n.id);

    // Longest-path ranking (DAG of forward edges).
    const rank = new Map();
    function rankOf(id) {
      if (rank.has(id)) return rank.get(id);
      const preds = incoming.get(id).filter(s => !backEdges.has(s + '\u0000' + id));
      if (preds.length === 0) { rank.set(id, 0); return 0; }
      let r = 0;
      for (const p of preds) r = Math.max(r, rankOf(p) + 1);
      rank.set(id, r);
      return r;
    }
    for (const n of State.nodes) rankOf(n.id);

    // Group nodes by rank.
    const ranks = [];
    for (const n of State.nodes) {
      const r = rank.get(n.id) || 0;
      n.rank = r;
      while (ranks.length <= r) ranks.push([]);
      ranks[r].push(n);
    }

    // Initial within-rank order: keep declaration order (mostly matches the
    // author's mental model since dialogue JSON is hand-ordered).
    for (let r = 0; r < ranks.length; r++) {
      ranks[r].forEach((n, i) => { n.order = i; });
    }

    // Median heuristic: 2 forward sweeps to reduce crossings.
    for (let pass = 0; pass < 4; pass++) {
      for (let r = 1; r < ranks.length; r++) {
        const row = ranks[r];
        row.forEach(n => {
          const preds = incoming.get(n.id)
            .filter(s => !backEdges.has(s + '\u0000' + n.id))
            .map(s => byId.get(s))
            .filter(p => p && p.rank === r - 1)
            .map(p => p.order);
          n._key = preds.length ? median(preds) : n.order;
        });
        row.sort((a, b) => a._key - b._key || a.order - b.order);
        row.forEach((n, i) => { n.order = i; });
      }
      for (let r = ranks.length - 2; r >= 0; r--) {
        const row = ranks[r];
        row.forEach(n => {
          const succs = out.get(n.id)
            .map(t => byId.get(t))
            .filter(p => p && p.rank === r + 1)
            .map(p => p.order);
          n._key = succs.length ? median(succs) : n.order;
        });
        row.sort((a, b) => a._key - b._key || a.order - b.order);
        row.forEach((n, i) => { n.order = i; });
      }
    }

    // Assign coords (VERTICAL layout). Each rank becomes a horizontal row;
    // within-rank ordering flows left-to-right. Rows are centered horizontally
    // relative to the widest row so short branches sit in the middle of the
    // canvas instead of glued to the left. A fixed PAD is added so all coords
    // are strictly > 0 — required because the scrollable viewport sizes
    // itself to (maxNode + PAD) and clipped negative coords would push
    // content off the scroll surface.
    const widest = ranks.reduce((m, r) => Math.max(m, totalRankWidth(r)), 0);
    const PAD = 40;
    for (let r = 0; r < ranks.length; r++) {
      const rowWidth = totalRankWidth(ranks[r]);
      let x = PAD + (widest - rowWidth) / 2;
      const y = PAD + r * (NODE_H + RANK_SEP);
      for (const n of ranks[r]) {
        n.x = x;
        n.y = y;
        x += n.w + NODE_SEP;
      }
    }
  }

  function totalRankWidth(row) {
    if (row.length === 0) return 0;
    let w = 0;
    for (const n of row) w += n.w;
    return w + NODE_SEP * (row.length - 1);
  }

  function median(arr) {
    const s = arr.slice().sort((a, b) => a - b);
    const m = Math.floor(s.length / 2);
    return s.length % 2 ? s[m] : (s[m - 1] + s[m]) / 2;
  }

  // ===== RENDER =====
  function scheduleRender(after) {
    if (State.raf) cancelAnimationFrame(State.raf);
    State.raf = requestAnimationFrame(() => {
      State.raf = null;
      if (State.needsRecompute) {
        deriveGraph();
        State.needsRecompute = false;
      }
      render();
      if (after) {
        after();
      } else if (!State._didInitialFit && State.nodes.length > 0) {
        // Auto-fit once after the first non-empty render so the graph isn't
        // crammed into the top-left at 1× zoom on file load.
        State._didInitialFit = true;
        fitToView();
      }
    });
  }

  function render() {
    if (!State.rootEl) return;
    const empty = State.rootEl.querySelector('.graph-empty');
    if (empty) empty.hidden = State.nodes.length > 0;

    renderNodes();
    renderEdges();
    applyTransform();
    applySearchFilter();
  }

  function renderNodes() {
    const layer = State.nodesLayer;
    if (!layer) return;
    const ids = new Set(State.nodes.map(n => n.id));
    // Remove stale
    [...layer.children].forEach(el => { if (!ids.has(el.dataset.nodeId)) el.remove(); });
    // Build/update
    for (const n of State.nodes) {
      let el = layer.querySelector(`[data-node-id="${cssEscape(n.id)}"]`);
      if (!el) {
        el = document.createElement('div');
        el.className = 'gnode';
        el.dataset.nodeId = n.id;
        el.addEventListener('click', (ev) => {
          if (State.suppressNextClick) { State.suppressNextClick = false; return; }
          ev.stopPropagation();
          selectNode(n.id, { scrollLinear: true, flashLinear: true });
        });
        // Double-click on a node switches to linear view and scrolls to it.
        // Single-click still flashes the linear card; double-click commits.
        el.addEventListener('dblclick', (ev) => {
          ev.stopPropagation();
          if (n.external) return;
          setViewMode('linear');
          selectNode(n.id, { scrollLinear: true, flashLinear: true });
        });
        el.addEventListener('mouseenter', () => showNodeTooltip(n, el));
        el.addEventListener('mouseleave', () => hideTooltip());
        layer.appendChild(el);
      }
      el.classList.toggle('selected', n.id === State.selectedNodeId);
      el.classList.toggle('external', !!n.external);
      el.classList.toggle('once', !n.external && n.state && n.state.once === true);
      el.dataset.role = n.role;
      el.style.transform = `translate(${n.x}px, ${n.y}px)`;
      el.style.width = n.w + 'px';
      el.style.height = n.h + 'px';
      el.innerHTML = nodeInnerHtml(n);
      attachPins(el, n);
      attachDeleteButton(el, n);
    }
  }

  // Append a .gnode-delete (✕) per non-external node. The button lives on
  // the card itself; CSS handles hover visibility. Click confirms then calls
  // the host's deleteStateById which mirrors the linear pane's delete logic.
  function attachDeleteButton(el, n) {
    if (n.external) return;
    const btn = document.createElement('button');
    btn.className = 'gnode-delete';
    btn.type = 'button';
    btn.textContent = '✕';
    btn.title = 'delete this state';
    // The button sits inside the .gnode element. mouseenter on the button
    // bubbles to the node and would re-show the node tooltip — give the
    // button its own tooltip and stop the propagation.
    btn.addEventListener('mouseenter', (ev) => {
      ev.stopPropagation();
      showTooltip('delete state', btn);
    });
    btn.addEventListener('mouseleave', (ev) => {
      ev.stopPropagation();
      showNodeTooltip(n, el);
    });
    // Stop pointerdown so node-drag (if added later) and node-click selection
    // don't fire when the user is aiming for the button.
    btn.addEventListener('pointerdown', (ev) => { ev.stopPropagation(); });
    btn.addEventListener('click', (ev) => {
      ev.stopPropagation();
      const lineCount = n.state && Array.isArray(n.state.lines) ? n.state.lines.length : 0;
      const choiceCount = (n.state && n.state.options && Array.isArray(n.state.options.choices))
        ? n.state.options.choices.length : 0;
      const msg = `Delete state '${n.id}'?\n\n` +
        `Lines: ${lineCount}   Choices: ${choiceCount}\n\n` +
        `Edges referencing this state will become stale (the engine simply won't reach it).\n` +
        `This action is undoable only via undo on the next save.`;
      if (!window.confirm(msg)) return;
      hideTooltip();
      if (typeof window.deleteStateById === 'function') {
        window.deleteStateById(n.id);
      }
    });
    el.appendChild(btn);
  }

  // Phase 2 — append a .gnode-pin per choice on question nodes. innerHTML
  // wipes previous children so this runs after the innerHTML assignment.
  // Pins are absolutely positioned children; their CSS handles bottom-edge
  // distribution. We only wire pointerdown here — pointermove/up live at
  // the document level (see ensureDragHandlers).
  function attachPins(el, n) {
    if (n.external) return;
    const s = n.state;
    if (!s || !s.options || !Array.isArray(s.options.choices) || s.options.choices.length === 0) return;
    const choices = s.options.choices;
    const total = choices.length;
    for (let i = 0; i < total; i++) {
      const pin = document.createElement('div');
      pin.className = 'gnode-pin';
      pin.dataset.choiceIdx = String(i);
      // Vertical layout: pins distribute horizontally along the bottom edge.
      pin.style.left = `${((i + 1) / (total + 1)) * 100}%`;
      const choice = choices[i];
      const choiceTxt = (choice && choice.text) ? String(choice.text) : `choice ${i}`;
      const choiceVal = (choice && choice.value != null) ? `'${choice.value}'` : '';
      const tipText = `${choiceTxt}${choiceVal ? '  ' + choiceVal : ''}`;
      // Override the node's first-line tooltip with the choice text while
      // the cursor is on the pin. mouseenter on the pin fires AFTER the
      // node's mouseenter (which already set the node tip), so showTooltip
      // overwrites the same overlay element.
      pin.addEventListener('mouseenter', (ev) => {
        ev.stopPropagation();
        showTooltip(tipText, pin);
      });
      pin.addEventListener('mouseleave', () => {
        // Cursor is leaving the pin but is probably still inside the node.
        // Re-show the node's preview tooltip so the panel doesn't go blank.
        showNodeTooltip(n, el);
      });
      pin.addEventListener('pointerdown', (ev) => {
        if (ev.button !== 0) return;
        ev.stopPropagation();
        ev.preventDefault();
        startPinDrag(pin, n, i, ev);
      });
      // Prevent the node's click handler from firing on plain click/release.
      pin.addEventListener('click', (ev) => { ev.stopPropagation(); });
      el.appendChild(pin);
    }
  }

  function nodeInnerHtml(n) {
    if (n.external) {
      return `
        <div class="gnode-id">${escapeHtmlSafe(n.id)}</div>
        <div class="gnode-ext-badge">↗ ext</div>
      `;
    }
    const s = n.state;
    const lineCount = Array.isArray(s.lines) ? s.lines.length : (typeof s.line === 'string' ? 1 : 0);
    const choiceCount = (s.options && Array.isArray(s.options.choices)) ? s.options.choices.length : 0;
    let trustThreshold = null;
    if (s.trigger && typeof parseTrigger === 'function' && s.options && s.options.trust_path) {
      const clauses = parseTrigger(s.trigger);
      for (const c of clauses) {
        if (c.path === s.options.trust_path && c.op === '>=' && c.value > 0) {
          trustThreshold = c.value; break;
        }
      }
    }
    const meta = [];
    if (lineCount) meta.push(`<span class="gnode-meta-item">≡ ${lineCount}</span>`);
    if (choiceCount) meta.push(`<span class="gnode-meta-item">→ ${choiceCount}</span>`);
    if (s.once === true) meta.push(`<span class="gnode-meta-item gnode-meta-once">1×</span>`);
    if (trustThreshold !== null) meta.push(`<span class="gnode-meta-item">↑ ${trustThreshold}</span>`);
    return `
      <div class="gnode-row">
        <div class="gnode-id">${escapeHtmlSafe(n.id)}</div>
        <div class="gnode-role">${n.role}</div>
      </div>
      <div class="gnode-preview">${escapeHtmlSafe(firstLineText(s))}</div>
      <div class="gnode-meta">${meta.join('')}</div>
    `;
  }

  function firstLineText(s) {
    let txt = '';
    if (Array.isArray(s.lines) && s.lines.length) {
      const l = s.lines[0];
      txt = (typeof l === 'string') ? l : (l && l.text) || '';
    } else if (typeof s.line === 'string') {
      txt = s.line;
    }
    txt = txt.replace(/\[\/?i\]/g, '').trim();
    if (txt.length > 90) txt = txt.slice(0, 88) + '…';
    return txt || '—';
  }

  // ===== PIN DRAG (Phase 2) =====
  // Pins drag from a choice on a question node to either empty canvas
  // (scaffold a new target state) or another node (amend its trigger so the
  // choice's commit reaches it). All authoring goes through the host's
  // factored helpers (scaffoldTargetStateForChoice / amendTargetTriggerForChoice)
  // so a single code path serves the linear pane's +→ button and the graph.

  function ensureDragHandlers() {
    if (State._dragHandlersBound) return;
    State._dragHandlersBound = true;
    document.addEventListener('pointermove', onDragMove);
    document.addEventListener('pointerup', onDragEnd);
    document.addEventListener('pointercancel', onDragCancel);
  }

  function startPinDrag(pinEl, node, choiceIdx, ev) {
    if (State.activeDrag) cancelActiveDrag();
    closePopover();
    hideTooltip();
    ensureDragHandlers();
    const canvas = State.rootEl.querySelector('.graph-canvas');
    if (!canvas) return;
    const canvasRect = canvas.getBoundingClientRect();
    const pinRect = pinEl.getBoundingClientRect();
    const px = pinRect.left + pinRect.width / 2 - canvasRect.left;
    const py = pinRect.top + pinRect.height / 2 - canvasRect.top;

    // Drag visuals live in .graph-overlay (outside the scrollable canvas) so
    // their canvas-relative cursor coords stay correct when the canvas is
    // scrolled. The overlay has pointer-events:none on the root so it doesn't
    // intercept the drag's mousemove.
    const overlay = State.overlayLayer || State.rootEl.querySelector('.graph-overlay');
    let dragSvg = overlay && overlay.querySelector('.graph-drag-svg');
    if (!dragSvg) {
      dragSvg = document.createElementNS('http://www.w3.org/2000/svg', 'svg');
      dragSvg.setAttribute('class', 'graph-drag-svg');
      if (overlay) overlay.appendChild(dragSvg);
    }
    dragSvg.innerHTML = '';
    const line = document.createElementNS('http://www.w3.org/2000/svg', 'line');
    line.setAttribute('class', 'pin-drag-line');
    line.setAttribute('x1', String(px));
    line.setAttribute('y1', String(py));
    line.setAttribute('x2', String(px));
    line.setAttribute('y2', String(py));
    dragSvg.appendChild(line);

    let ghost = overlay && overlay.querySelector('.scaffold-ghost');
    if (!ghost) {
      ghost = document.createElement('div');
      ghost.className = 'scaffold-ghost';
      ghost.textContent = '+ new state here';
      if (overlay) overlay.appendChild(ghost);
    }
    ghost.style.display = 'none';

    pinEl.classList.add('dragging');
    document.body.classList.add('pin-dragging');
    State.activeDrag = {
      sourceNode: node,
      choiceIdx,
      choice: node.state.options.choices[choiceIdx],
      pinEl,
      lineEl: line,
      ghostEl: ghost,
      pinX: px,
      pinY: py,
    };
    // Capture the pointer so pointermove/up keep firing on the pin even when
    // the cursor leaves it. ev may be undefined for synthetic invocations.
    if (ev && typeof ev.pointerId !== 'undefined') {
      try { pinEl.setPointerCapture(ev.pointerId); } catch (_) {}
    }
  }

  function onDragMove(e) {
    if (!State.activeDrag) return;
    const drag = State.activeDrag;
    const canvas = State.rootEl.querySelector('.graph-canvas');
    if (!canvas) return;
    const canvasRect = canvas.getBoundingClientRect();
    const cx = e.clientX - canvasRect.left;
    const cy = e.clientY - canvasRect.top;
    drag.lineEl.setAttribute('x2', String(cx));
    drag.lineEl.setAttribute('y2', String(cy));
    // Hit-test the target
    const el = document.elementFromPoint(e.clientX, e.clientY);
    const nodeEl = el && el.closest ? el.closest('.gnode') : null;
    updateDragCandidates(nodeEl);
    // Ghost label when over empty canvas (still inside the graph pane)
    const overCanvas = el && el.closest && el.closest('.graph-canvas');
    if (!nodeEl && overCanvas) {
      drag.ghostEl.style.display = '';
      drag.ghostEl.style.left = (cx + 12) + 'px';
      drag.ghostEl.style.top = (cy + 12) + 'px';
    } else {
      drag.ghostEl.style.display = 'none';
    }
  }

  function updateDragCandidates(nodeEl) {
    const drag = State.activeDrag;
    if (!drag) return;
    State.rootEl.querySelectorAll('.gnode.candidate-drop, .gnode.invalid-drop').forEach(n => {
      n.classList.remove('candidate-drop', 'invalid-drop');
    });
    if (!nodeEl) return;
    const targetId = nodeEl.dataset.nodeId;
    const target = State.nodes.find(n => n.id === targetId);
    if (!target) return;
    const reason = invalidDropReason(drag.sourceNode, drag.choiceIdx, target);
    nodeEl.classList.add(reason === null ? 'candidate-drop' : 'invalid-drop');
  }

  // Returns null if the drop is valid; otherwise a short reason string for a
  // toast. Keep messages short — they go through the existing host toast.
  function invalidDropReason(sourceNode, choiceIdx, targetNode) {
    if (!targetNode || targetNode === sourceNode) return 'self';
    if (targetNode.external) return 'external reference; cannot wire from here';
    const opts = sourceNode.state.options;
    if (!opts || !opts.write_path) return 'this options block has no write_path';
    if (typeof findChoiceConsequences === 'function') {
      const targets = findChoiceConsequences(sourceNode.state, opts.choices[choiceIdx], opts);
      if (targets.includes(targetNode.id)) return 'choice already reaches this state';
    }
    return null;
  }

  function onDragEnd(e) {
    if (!State.activeDrag) return;
    const drag = State.activeDrag;
    const el = document.elementFromPoint(e.clientX, e.clientY);
    const nodeEl = el && el.closest ? el.closest('.gnode') : null;
    const overCanvas = el && el.closest && el.closest('.graph-canvas');
    // Cleanup before any toast/popover so the visual state is sane.
    cleanupActiveDrag();
    if (nodeEl) {
      const targetId = nodeEl.dataset.nodeId;
      const target = State.nodes.find(n => n.id === targetId);
      handleDropOnNode(drag, target);
    } else if (overCanvas) {
      handleDropOnCanvas(drag);
    }
    // Else: dropped outside the graph pane — silent cancel.
  }

  function onDragCancel() {
    if (!State.activeDrag) return;
    cleanupActiveDrag();
  }

  function cancelActiveDrag() {
    cleanupActiveDrag();
  }

  function cleanupActiveDrag() {
    const drag = State.activeDrag;
    if (!drag) return;
    State.activeDrag = null;
    document.body.classList.remove('pin-dragging');
    drag.pinEl.classList.remove('dragging');
    if (drag.lineEl && drag.lineEl.parentNode) drag.lineEl.remove();
    if (drag.ghostEl) drag.ghostEl.style.display = 'none';
    State.rootEl.querySelectorAll('.gnode.candidate-drop, .gnode.invalid-drop').forEach(n => {
      n.classList.remove('candidate-drop', 'invalid-drop');
    });
  }

  function handleDropOnCanvas(drag) {
    if (typeof window.scaffoldTargetStateForChoice !== 'function') {
      hostToast('scaffoldTargetStateForChoice missing on host', true);
      return;
    }
    const newId = window.scaffoldTargetStateForChoice(
      drag.sourceNode.state, drag.sourceNode.state.options, drag.choiceIdx
    );
    if (newId) selectNode(newId, { pan: true });
  }

  function handleDropOnNode(drag, target) {
    if (!target) return;
    if (target === drag.sourceNode) return;  // silent self-drop
    const reason = invalidDropReason(drag.sourceNode, drag.choiceIdx, target);
    if (reason === 'self') return;
    if (reason) { hostToast(reason); return; }
    showAmendPopover(drag, target);
  }

  function showAmendPopover(drag, target) {
    closePopover();
    const opts = drag.sourceNode.state.options;
    const choice = opts.choices[drag.choiceIdx];
    const currentTrigger = target.state.trigger || '';
    const clauses = parseTrigger(currentTrigger);
    const filtered = clauses.filter(c => c.path !== opts.write_path);
    filtered.push({
      path: opts.write_path,
      op: '==',
      value: (choice.value != null) ? String(choice.value) : ''
    });
    const proposedTrigger = serializeTrigger(filtered);

    const overlay = State.rootEl.querySelector('.graph-overlay');
    if (!overlay) return;
    const popover = document.createElement('div');
    popover.className = 'amend-popover';
    popover.innerHTML = `
      <div class="popover-title">Wire choice to <code>${escapeHtmlSafe(target.id)}</code>?</div>
      <div class="popover-row"><span class="popover-label">Current</span><code class="popover-trigger">${escapeHtmlSafe(currentTrigger || '(empty)')}</code></div>
      <div class="popover-row"><span class="popover-label">Proposed</span><code class="popover-trigger popover-trigger-new">${escapeHtmlSafe(proposedTrigger)}</code></div>
      <div class="popover-help">
        <strong>Amend</strong> adds the value clause to <code>${escapeHtmlSafe(target.id)}</code> so this choice also reaches it.
        <strong>Branch off</strong> duplicates the target with the value clause as the gate (drops trust-path clauses) — for when the answer should be question-specific, not trust-tier.
      </div>
      <div class="popover-actions">
        <button class="popover-btn" data-action="cancel">Cancel</button>
        <button class="popover-btn" data-action="branch">Branch off</button>
        <button class="popover-btn popover-btn-primary" data-action="confirm">Amend</button>
      </div>
    `;
    overlay.appendChild(popover);
    // Anchor above the target node.
    const canvas = State.rootEl.querySelector('.graph-canvas');
    const canvasRect = canvas.getBoundingClientRect();
    const nodeEl = State.rootEl.querySelector(`.gnode[data-node-id="${cssEscape(target.id)}"]`);
    if (nodeEl) {
      const rect = nodeEl.getBoundingClientRect();
      const x = rect.left + rect.width / 2 - canvasRect.left;
      const y = rect.top - canvasRect.top - 8;
      popover.style.left = x + 'px';
      popover.style.top = y + 'px';
      popover.style.transform = 'translate(-50%, -100%)';
    }
    State.activePopover = popover;
    const cancelBtn = popover.querySelector('[data-action="cancel"]');
    const branchBtn = popover.querySelector('[data-action="branch"]');
    const confirmBtn = popover.querySelector('[data-action="confirm"]');
    cancelBtn.addEventListener('click', closePopover);
    confirmBtn.addEventListener('click', () => {
      if (typeof window.amendTargetTriggerForChoice === 'function') {
        const ok = window.amendTargetTriggerForChoice(
          drag.sourceNode.state, opts, drag.choiceIdx, target.state
        );
        if (!ok) hostToast('no trigger change applied');
        else selectNode(target.id, { scrollLinear: true, flashLinear: true });
      } else {
        hostToast('amendTargetTriggerForChoice missing on host', true);
      }
      closePopover();
    });
    branchBtn.addEventListener('click', () => {
      if (typeof window.branchOffTargetForChoice === 'function') {
        const newId = window.branchOffTargetForChoice(
          drag.sourceNode.state, opts, drag.choiceIdx, target.state
        );
        if (!newId) hostToast('branch off failed (no write_path or other guard)');
        else selectNode(newId, { scrollLinear: true, flashLinear: true });
      } else {
        hostToast('branchOffTargetForChoice missing on host', true);
      }
      closePopover();
    });
    // Default focus on Cancel so an accidental Enter is harmless.
    setTimeout(() => cancelBtn.focus(), 0);
    setTimeout(() => {
      document.addEventListener('pointerdown', onPopoverOutsideClick, true);
    }, 0);
  }

  function onPopoverOutsideClick(e) {
    if (!State.activePopover) return;
    if (!State.activePopover.contains(e.target)) closePopover();
  }

  function closePopover() {
    if (!State.activePopover) return;
    State.activePopover.remove();
    State.activePopover = null;
    document.removeEventListener('pointerdown', onPopoverOutsideClick, true);
  }

  function hostToast(msg, isError) {
    if (typeof window.showToast === 'function') {
      try { window.showToast(msg, !!isError); return; } catch (_) {}
    }
    // Fallback: best-effort console hint so the message isn't lost silently.
    console.warn('[GraphView]', msg);
  }

  // ===== EDGES =====
  function renderEdges() {
    if (!State.edgesSvg) return;
    const edgesGroup = State.edgesSvg.querySelector('.edges-group');
    const labelsGroup = State.edgesSvg.querySelector('.edge-labels-group');
    edgesGroup.innerHTML = '';
    labelsGroup.innerHTML = '';
    const byId = new Map(State.nodes.map(n => [n.id, n]));
    let bounds = { minX: Infinity, minY: Infinity, maxX: -Infinity, maxY: -Infinity };
    for (const n of State.nodes) {
      bounds.minX = Math.min(bounds.minX, n.x);
      bounds.minY = Math.min(bounds.minY, n.y);
      bounds.maxX = Math.max(bounds.maxX, n.x + n.w);
      bounds.maxY = Math.max(bounds.maxY, n.y + n.h);
    }
    if (!isFinite(bounds.minX)) bounds = { minX: 0, minY: 0, maxX: 0, maxY: 0 };
    const pad = 40;
    const vbX = bounds.minX - pad;
    const vbY = bounds.minY - pad;
    const vbW = (bounds.maxX - bounds.minX) + pad * 2;
    const vbH = (bounds.maxY - bounds.minY) + pad * 2;
    State.edgesSvg.setAttribute('viewBox', `${vbX} ${vbY} ${vbW} ${vbH}`);
    State.edgesSvg.style.width = vbW + 'px';
    State.edgesSvg.style.height = vbH + 'px';
    State.edgesSvg.style.left = vbX + 'px';
    State.edgesSvg.style.top = vbY + 'px';

    for (const e of State.edges) {
      const a = byId.get(e.source);
      const b = byId.get(e.target);
      if (!a || !b) continue;
      // Source X anchors at the corresponding pin's position so each choice's
      // edge starts where its pin sits on the node's BOTTOM edge — matches
      // pins distributed at ((i+1) / (n+1)) * width. Falls back to bottom-
      // center when the source has no choices (defensive; shouldn't happen
      // because only question nodes produce edges).
      const sChoiceCount = (a.state && a.state.options && Array.isArray(a.state.options.choices))
        ? a.state.options.choices.length : 0;
      const sx = (sChoiceCount > 0 && Number.isFinite(e.choiceIdx))
        ? a.x + a.w * ((e.choiceIdx + 1) / (sChoiceCount + 1))
        : a.x + a.w / 2;
      const sy = a.y + a.h;
      const tx = b.x + b.w / 2;
      const ty = b.y;
      const isBackward = ty < sy; // back-edge / loop: bend wider
      const dy = Math.max(40, Math.abs(ty - sy) / 2);
      const c1y = sy + dy;
      const c2y = ty - dy;
      const d = isBackward
        ? `M ${sx} ${sy} C ${sx + 80} ${sy + 80}, ${tx - 80} ${ty - 80}, ${tx} ${ty}`
        : `M ${sx} ${sy} C ${sx} ${c1y}, ${tx} ${c2y}, ${tx} ${ty}`;
      const path = document.createElementNS('http://www.w3.org/2000/svg', 'path');
      path.setAttribute('d', d);
      path.setAttribute('class', 'gedge gedge-' + e.kind);
      path.setAttribute('marker-end', 'url(#arrow-reach)');
      path.dataset.source = e.source;
      path.dataset.target = e.target;
      path.dataset.choiceIdx = String(e.choiceIdx);
      // Chain edges are inferred (not declared in JSON), so no delete UI —
      // to remove one, the user edits the source's trigger / chain flag.
      const deletable = e.kind !== 'excluded' && e.kind !== 'chain';
      path.addEventListener('mouseenter', () => {
        showEdgeTooltip(e, path);
        if (deletable) showEdgeDeleteBtn(e.source, e.target, e.choiceIdx);
      });
      path.addEventListener('mouseleave', () => {
        hideTooltip();
        if (deletable) scheduleHideEdgeDeleteBtn(e.source, e.target, e.choiceIdx);
      });
      path.addEventListener('click', (ev) => {
        ev.stopPropagation();
        focusChoiceInLinear(e.source, e.choiceIdx);
      });
      edgesGroup.appendChild(path);

      // Label pill at midpoint of curve (t=0.5 of cubic bezier).
      // Vertical layout: control points are (sx, c1y) and (tx, c2y), so
      // mx weights sx/sx/tx/tx and my weights sy/c1y/c2y/ty.
      const mx = 0.125 * sx + 0.375 * sx + 0.375 * tx + 0.125 * tx; // simplifies to (sx+tx)/2
      const my = 0.125 * sy + 0.375 * c1y + 0.375 * c2y + 0.125 * ty;

      // ✕ delete button at midpoint. Skipped for `excluded` (pin-mode preview)
      // edges since those don't represent a real wired connection. The button
      // is hidden by default and shown via JS while the edge or button is
      // hovered. Self-contained — its own mouseenter cancels the hide timer.
      if (deletable) {
        const dbtn = document.createElementNS('http://www.w3.org/2000/svg', 'g');
        dbtn.setAttribute('class', 'gedge-delete-btn');
        // Slight offset above midpoint so it doesn't sit ON the label pill.
        const offset = e.label ? -18 : 0;
        dbtn.setAttribute('transform', `translate(${mx}, ${my + offset})`);
        dbtn.setAttribute('data-source', e.source);
        dbtn.setAttribute('data-target', e.target);
        dbtn.setAttribute('data-choice-idx', String(e.choiceIdx));
        const dCircle = document.createElementNS('http://www.w3.org/2000/svg', 'circle');
        dCircle.setAttribute('r', '9');
        dCircle.setAttribute('cx', '0');
        dCircle.setAttribute('cy', '0');
        dbtn.appendChild(dCircle);
        const dText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        dText.setAttribute('text-anchor', 'middle');
        dText.setAttribute('y', '3');
        dText.textContent = '✕';
        dbtn.appendChild(dText);
        const edgeKey = e.source + '|' + e.target + '|' + e.choiceIdx;
        dbtn.dataset.edgeKey = edgeKey;
        dbtn.addEventListener('mouseenter', () => {
          cancelHideEdgeDeleteBtn();
        });
        dbtn.addEventListener('mouseleave', () => {
          scheduleHideEdgeDeleteBtn();
        });
        // Stop pointerdown from kicking off canvas pan; click handles delete.
        dbtn.addEventListener('pointerdown', (ev) => { ev.stopPropagation(); });
        dbtn.addEventListener('click', (ev) => {
          ev.stopPropagation();
          confirmDeleteEdge(e);
        });
        labelsGroup.appendChild(dbtn);
      }
      if (e.label) {
        const g = document.createElementNS('http://www.w3.org/2000/svg', 'g');
        g.setAttribute('transform', `translate(${mx}, ${my})`);
        g.setAttribute('class', 'gedge-label');
        // measure approx: 6.2px per char + padding
        const labelText = e.label;
        const w = Math.min(220, Math.max(40, labelText.length * 6.2 + 14));
        const h = 18;
        const rect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
        rect.setAttribute('x', -w / 2);
        rect.setAttribute('y', -h / 2);
        rect.setAttribute('width', w);
        rect.setAttribute('height', h);
        rect.setAttribute('rx', 3);
        g.appendChild(rect);
        const text = document.createElementNS('http://www.w3.org/2000/svg', 'text');
        text.setAttribute('y', 3);
        text.setAttribute('text-anchor', 'middle');
        text.textContent = labelText;
        g.appendChild(text);
        if (e.delta !== null) {
          const dg = document.createElementNS('http://www.w3.org/2000/svg', 'g');
          dg.setAttribute('transform', `translate(${w / 2 + 4}, 0)`);
          dg.setAttribute('class', 'gedge-delta');
          const dRect = document.createElementNS('http://www.w3.org/2000/svg', 'rect');
          const dW = 26;
          dRect.setAttribute('x', 0);
          dRect.setAttribute('y', -h / 2);
          dRect.setAttribute('width', dW);
          dRect.setAttribute('height', h);
          dRect.setAttribute('rx', 3);
          dg.appendChild(dRect);
          const dText = document.createElementNS('http://www.w3.org/2000/svg', 'text');
          dText.setAttribute('x', dW / 2);
          dText.setAttribute('y', 3);
          dText.setAttribute('text-anchor', 'middle');
          dText.textContent = (e.delta > 0 ? '+' : '') + e.delta;
          dg.appendChild(dText);
          g.appendChild(dg);
        }
        labelsGroup.appendChild(g);
      }
    }
  }

  // ===== PAN / ZOOM (scroll-as-pan model) =====
  // The canvas has overflow:auto. Panning is driven by canvas.scrollLeft /
  // canvas.scrollTop (native scrollbars give the user predictable navigation
  // when zoomed in). The viewport contains the rendered content; its width
  // and height = scaled content bounds, so scrollbars span the right range.
  // Zoom is applied via transform: scale(zoom) on the viewport with origin
  // 0,0. Mouse-drag pan adjusts scrollLeft/scrollTop directly. Wheel-zoom
  // adjusts the scroll position so the world point under the cursor stays
  // put across the zoom step.
  function applyTransform() {
    const vp = State.rootEl && State.rootEl.querySelector('.graph-viewport');
    if (!vp) return;
    vp.style.transform = `scale(${State.zoom})`;
    vp.style.transformOrigin = '0 0';
    // Size the viewport to the scaled content extent so scrollbars track
    // the real bounds. Nodes are positioned at strictly-positive coords
    // post-layout (see layoutNodes), so we can ignore negative content.
    let maxX = 0, maxY = 0;
    for (const n of State.nodes) {
      const r = n.x + n.w;
      const b = n.y + n.h;
      if (r > maxX) maxX = r;
      if (b > maxY) maxY = b;
    }
    const pad = 40;
    vp.style.width = ((maxX + pad) * State.zoom) + 'px';
    vp.style.height = ((maxY + pad) * State.zoom) + 'px';
  }

  function bindCanvasEvents(canvas) {
    canvas.addEventListener('pointerdown', (e) => {
      if (e.target.closest('.gnode') || e.target.closest('.gedge') || e.target.closest('.gedge-delete-btn') || e.target.closest('.graph-search')) return;
      // Ignore clicks on the native scrollbar gutters — clientWidth/Height
      // exclude scrollbars, so a hit beyond those bounds is on the bar
      // itself and the browser handles it natively.
      const rect = canvas.getBoundingClientRect();
      const xInCanvas = e.clientX - rect.left;
      const yInCanvas = e.clientY - rect.top;
      if (xInCanvas >= canvas.clientWidth || yInCanvas >= canvas.clientHeight) return;
      State.isPanning = true;
      // Capture current scroll position; the drag handler nudges scrollLeft/
      // scrollTop in inverse proportion to cursor movement so content tracks
      // the cursor (drag-right shows more right-content via scrollLeft -=…).
      State.panStart = {
        x: e.clientX,
        y: e.clientY,
        scrollLeft: canvas.scrollLeft,
        scrollTop: canvas.scrollTop
      };
      canvas.setPointerCapture(e.pointerId);
      canvas.classList.add('panning');
    });
    canvas.addEventListener('pointermove', (e) => {
      if (!State.isPanning) return;
      // Drag direction = content direction. Dragging right reveals content
      // to the LEFT of the visible area, so scrollLeft decreases.
      canvas.scrollLeft = State.panStart.scrollLeft - (e.clientX - State.panStart.x);
      canvas.scrollTop = State.panStart.scrollTop - (e.clientY - State.panStart.y);
      hideTooltip();
    });
    canvas.addEventListener('pointerup', (e) => {
      if (State.isPanning) {
        State.isPanning = false;
        canvas.classList.remove('panning');
        try { canvas.releasePointerCapture(e.pointerId); } catch (err) {}
      }
    });
    canvas.addEventListener('click', (e) => {
      // Click on empty canvas: deselect. Skip if the click landed on the
      // scrollbar gutter so deselecting doesn't trigger as a side-effect
      // of scrollbar interaction.
      const rect = canvas.getBoundingClientRect();
      const xInCanvas = e.clientX - rect.left;
      const yInCanvas = e.clientY - rect.top;
      if (xInCanvas >= canvas.clientWidth || yInCanvas >= canvas.clientHeight) return;
      selectNode(null, {});
    });

    canvas.addEventListener('wheel', (e) => {
      // Only intercept for zoom (Ctrl/Cmd modifier); plain scroll-wheel
      // should let the canvas scroll natively. Most users have a mouse
      // wheel without ctrl-modifier preference, so we treat plain wheel
      // as scroll and Ctrl-wheel as zoom (matches the existing app/IDE
      // convention).
      if (!e.ctrlKey && !e.metaKey) return; // let native scroll happen
      e.preventDefault();
      const rect = canvas.getBoundingClientRect();
      // Cursor position inside the canvas viewport (visible area).
      const mx = e.clientX - rect.left;
      const my = e.clientY - rect.top;
      // World coords of the cursor BEFORE the zoom change.
      const wx = (canvas.scrollLeft + mx) / State.zoom;
      const wy = (canvas.scrollTop + my) / State.zoom;
      const dir = e.deltaY < 0 ? 1.12 : 1 / 1.12;
      const newZoom = Math.max(ZOOM_MIN, Math.min(ZOOM_MAX, State.zoom * dir));
      State.zoom = newZoom;
      applyTransform();
      // Restore the world point under the cursor: scrollLeft so that
      // (wx * newZoom) lands at the same visible mx pixel.
      canvas.scrollLeft = wx * newZoom - mx;
      canvas.scrollTop = wy * newZoom - my;
      hideTooltip();
    }, { passive: false });

    document.addEventListener('keydown', onKey);
    window.addEventListener('resize', () => {
      if (State.viewMode === 'split' && window.innerWidth < 880) {
        setViewMode('linear');
      }
    });
  }

  function onKey(e) {
    // Escape cancels an in-flight pin drag or an open amend-popover before
    // anything else, regardless of focus location.
    if (e.key === 'Escape') {
      if (State.activeDrag) { e.preventDefault(); cancelActiveDrag(); return; }
      if (State.activePopover) { e.preventDefault(); closePopover(); return; }
    }
    // Ignore keys when focus is in an editable field.
    const target = e.target;
    const inEditable = target && (
      target.tagName === 'INPUT' || target.tagName === 'TEXTAREA' || target.tagName === 'SELECT' ||
      target.isContentEditable
    );
    if (inEditable) return;
    // Only when graph is visible
    if (State.viewMode === 'linear') return;
    if (e.key === 'f' || e.key === 'F') {
      e.preventDefault();
      fitToView();
    } else if (e.key === '0') {
      e.preventDefault();
      State.zoom = 1;
      applyTransform();
      const canvas = State.rootEl && State.rootEl.querySelector('.graph-canvas');
      if (canvas) { canvas.scrollLeft = 0; canvas.scrollTop = 0; }
    } else if (e.key === '/') {
      e.preventDefault();
      openSearch();
    } else if (e.key === 'Escape') {
      closeSearch();
    }
  }

  function fitToView() {
    if (State.nodes.length === 0) return;
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    for (const n of State.nodes) {
      minX = Math.min(minX, n.x);
      minY = Math.min(minY, n.y);
      maxX = Math.max(maxX, n.x + n.w);
      maxY = Math.max(maxY, n.y + n.h);
    }
    const canvas = State.rootEl.querySelector('.graph-canvas');
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    const pad = 40;
    const w = maxX - minX + pad * 2;
    const h = maxY - minY + pad * 2;
    const scale = Math.min(rect.width / w, rect.height / h, 1);
    State.zoom = Math.max(ZOOM_MIN, scale);
    applyTransform();
    // Center content within the visible canvas via scrollLeft/scrollTop.
    const centerX = (minX + maxX) / 2;
    const centerY = (minY + maxY) / 2;
    canvas.scrollLeft = Math.max(0, centerX * State.zoom - rect.width / 2);
    canvas.scrollTop = Math.max(0, centerY * State.zoom - rect.height / 2);
  }

  // ===== SELECTION + INTEROP =====
  function selectNode(id, opts) {
    State.selectedNodeId = id;
    // Update DOM classes
    if (State.nodesLayer) {
      State.nodesLayer.querySelectorAll('.gnode').forEach(el => {
        el.classList.toggle('selected', el.dataset.nodeId === id);
      });
    }
    if (id && opts.scrollLinear) scrollLinearToState(id, !!opts.flashLinear);
    // Pan to bring node into view if requested
    if (id && opts.pan) panToNode(id);
    // Notify the host so it can sync .state-card.selected on linear cards.
    // Hook is optional — host wires this up to persist selection across the
    // linear/split/graph view modes.
    if (typeof window.onGraphSelectionChanged === 'function') {
      try { window.onGraphSelectionChanged(id); } catch (e) {}
    }
  }

  function scrollLinearToState(id, flash) {
    const sel = `.state-card[data-state-id="${cssEscape(id)}"]`;
    const card = document.querySelector(sel);
    if (!card) return;
    const contentEl = document.getElementById('content');
    if (contentEl) {
      const cardRect = card.getBoundingClientRect();
      const contentRect = contentEl.getBoundingClientRect();
      contentEl.scrollTop += (cardRect.top - contentRect.top) - 60;
    }
    if (flash) {
      card.classList.add('consequence-flash');
      setTimeout(() => card.classList.remove('consequence-flash'), 900);
    }
  }

  function panToNode(id) {
    const node = State.nodes.find(n => n.id === id);
    if (!node) return;
    const canvas = State.rootEl.querySelector('.graph-canvas');
    if (!canvas) return;
    const rect = canvas.getBoundingClientRect();
    canvas.scrollLeft = Math.max(0, (node.x + node.w / 2) * State.zoom - rect.width / 2);
    canvas.scrollTop = Math.max(0, (node.y + node.h / 2) * State.zoom - rect.height / 2);
  }

  function flashNode(id) {
    if (!State.nodesLayer) return;
    const el = State.nodesLayer.querySelector(`[data-node-id="${cssEscape(id)}"]`);
    if (!el) return;
    el.classList.remove('flash');
    void el.offsetWidth;
    el.classList.add('flash');
  }

  function focusChoiceInLinear(stateId, choiceIdx) {
    const sel = `.state-card[data-state-id="${cssEscape(stateId)}"]`;
    const card = document.querySelector(sel);
    if (!card) return;
    scrollLinearToState(stateId, false);
    const choiceRows = card.querySelectorAll('.choice-row');
    const row = choiceRows[choiceIdx];
    if (!row) return;
    const ta = row.querySelector('textarea, input');
    if (ta) ta.focus();
    row.classList.add('consequence-flash');
    setTimeout(() => row.classList.remove('consequence-flash'), 900);
  }

  // ===== SEARCH =====
  function bindSearchEvents() {
    const wrap = State.rootEl.querySelector('.graph-search');
    if (!wrap) return;
    const input = wrap.querySelector('input');
    const close = wrap.querySelector('.graph-search-close');
    input.addEventListener('input', () => {
      State.searchFilter = input.value.trim().toLowerCase();
      applySearchFilter();
    });
    input.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') { e.preventDefault(); closeSearch(); }
    });
    close.addEventListener('click', () => closeSearch());
  }

  function openSearch() {
    const wrap = State.rootEl.querySelector('.graph-search');
    if (!wrap) return;
    wrap.hidden = false;
    wrap.querySelector('input').focus();
  }
  function closeSearch() {
    const wrap = State.rootEl.querySelector('.graph-search');
    if (!wrap) return;
    wrap.hidden = true;
    wrap.querySelector('input').value = '';
    State.searchFilter = '';
    applySearchFilter();
  }

  function applySearchFilter() {
    if (!State.nodesLayer) return;
    const q = State.searchFilter;
    const matchedIds = new Set();
    State.nodesLayer.querySelectorAll('.gnode').forEach(el => {
      const id = el.dataset.nodeId || '';
      const match = !q || id.toLowerCase().includes(q);
      el.classList.toggle('dim', !match);
      if (match) matchedIds.add(id);
    });
    if (!State.edgesSvg) return;
    State.edgesSvg.querySelectorAll('.gedge').forEach(p => {
      const src = p.dataset.source;
      const tgt = p.dataset.target;
      const dim = q && (!matchedIds.has(src) || !matchedIds.has(tgt));
      p.classList.toggle('dim', !!dim);
    });
    State.edgesSvg.querySelectorAll('.gedge-label').forEach((g, i) => {
      // Match labels to edges by index (same iteration order)
      const edges = State.edgesSvg.querySelectorAll('.gedge');
      const edge = edges[i];
      if (!edge) return;
      g.classList.toggle('dim', edge.classList.contains('dim'));
    });
  }

  // ===== TOOLTIP =====
  function showNodeTooltip(node, el) {
    if (node.external) {
      showTooltip(`${node.id} — external reference`, el);
      return;
    }
    showTooltip(firstLineText(node.state) || node.id, el);
  }
  function showEdgeTooltip(e, pathEl) {
    const target = e.target;
    let text;
    if (e.kind === 'chain') {
      text = 'state.chain → next-matching state';
    } else {
      text = e.choice && e.choice.text ? e.choice.text : '(empty choice)';
    }
    showTooltip(`${text}  →  ${target}`, pathEl);
  }

  // ===== EDGE DELETE BUTTON VISIBILITY =====
  // Shared timer so that moving the cursor from path → button (and vice versa)
  // doesn't flicker the button off. Each visibility-trigger cancels any
  // pending hide; mouseleave on both schedules one.
  var _edgeDelHideT = null;
  function showEdgeDeleteBtn(sourceId, targetId, choiceIdx) {
    cancelHideEdgeDeleteBtn();
    if (!State.edgesSvg) return;
    const key = sourceId + '|' + targetId + '|' + choiceIdx;
    State.edgesSvg.querySelectorAll('.gedge-delete-btn').forEach(g => {
      g.classList.toggle('visible', g.dataset.edgeKey === key);
    });
  }
  function scheduleHideEdgeDeleteBtn() {
    cancelHideEdgeDeleteBtn();
    _edgeDelHideT = setTimeout(() => {
      if (!State.edgesSvg) return;
      State.edgesSvg.querySelectorAll('.gedge-delete-btn.visible').forEach(g => g.classList.remove('visible'));
    }, 140);
  }
  function cancelHideEdgeDeleteBtn() {
    if (_edgeDelHideT) { clearTimeout(_edgeDelHideT); _edgeDelHideT = null; }
  }

  // Remove the trigger clause that makes the target state reachable from
  // this choice. Specifically: parse target.trigger, drop the clause where
  // `path === options.write_path && op === '=='  && value === choice.value`,
  // re-serialize. Trust-gated edges retain their trust clause (the author
  // can clean that up manually if the target becomes orphaned).
  function confirmDeleteEdge(e) {
    if (!currentFile || !files[currentFile]) return;
    const json = files[currentFile].json;
    const sourceState = json.states.find(s => s && s.id === e.source);
    const targetState = json.states.find(s => s && s.id === e.target);
    if (!sourceState || !targetState) {
      console.warn('[GraphView] delete-edge: source or target not found', e);
      return;
    }
    if (!sourceState.options || !sourceState.options.write_path) {
      console.warn('[GraphView] delete-edge: source has no write_path', e);
      return;
    }
    const writePath = sourceState.options.write_path;
    const choice = (sourceState.options.choices || [])[e.choiceIdx];
    if (!choice) return;
    const choiceValue = (choice.value != null) ? String(choice.value) : '';

    const clauses = (typeof parseTrigger === 'function')
      ? parseTrigger(targetState.trigger || '')
      : [];
    // Drop the specific value clause; leave any trust comparisons or other
    // clauses in place. Match on path + op '==' + value-string equality.
    const matchIdx = clauses.findIndex(c =>
      c.path === writePath && c.op === '==' && String(c.value) === choiceValue);
    if (matchIdx < 0) {
      // Defensive: classifier produced an edge but there's no exact value
      // clause to drop. Tell the user instead of silently no-op'ing.
      window.alert(
        `Can't delete this edge automatically.\n\n` +
        `Target '${targetState.id}' has no '${writePath} == ${choiceValue}' clause in its trigger — ` +
        `the edge may come from a compound condition. Edit the trigger manually in the linear view.`
      );
      return;
    }

    // Build the confirmation message including any trust clause that would
    // remain so the user knows what's left.
    const remaining = clauses.filter((_, i) => i !== matchIdx);
    const trustPath = sourceState.options.trust_path || null;
    const trustClauseLeft = trustPath ? remaining.find(c => c.path === trustPath && (c.op === '>=' || c.op === '<=')) : null;
    let msg = `Delete edge '${sourceState.id}' → '${targetState.id}'?\n\n` +
      `This will remove the clause:\n    ${writePath} == ${choiceValue ? "'" + choiceValue + "'" : "''"}\n\n` +
      `from '${targetState.id}'.trigger.`;
    if (trustClauseLeft) {
      msg += `\n\nNote: a trust gate (${trustClauseLeft.path} ${trustClauseLeft.op} ${trustClauseLeft.value}) will remain on the target.`;
    }
    if (!window.confirm(msg)) return;

    const newTrigger = (typeof serializeTrigger === 'function')
      ? serializeTrigger(remaining)
      : '';
    targetState.trigger = newTrigger;
    if (typeof markDirty === 'function') markDirty();
    if (typeof renderContent === 'function') {
      renderContent();
    } else if (window.GraphView) {
      window.GraphView.recompute();
    }
  }
  function showTooltip(text, anchorEl) {
    const tt = State.rootEl.querySelector('.graph-tooltip');
    if (!tt) return;
    tt.textContent = text;
    tt.hidden = false;
    const rect = anchorEl.getBoundingClientRect();
    const rootRect = State.rootEl.getBoundingClientRect();
    tt.style.left = (rect.left - rootRect.left + 12) + 'px';
    tt.style.top = (rect.bottom - rootRect.top + 6) + 'px';
  }
  function hideTooltip() {
    const tt = State.rootEl && State.rootEl.querySelector('.graph-tooltip');
    if (tt) tt.hidden = true;
  }

  // ===== UTIL =====
  function cssEscape(s) {
    if (window.CSS && typeof window.CSS.escape === 'function') return window.CSS.escape(String(s));
    return String(s).replace(/(["\\])/g, '\\$1');
  }
  function escapeHtmlSafe(s) {
    return String(s).replace(/[&<>"']/g, c => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[c]));
  }

})();
