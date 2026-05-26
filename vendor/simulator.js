// In-editor dialogue simulator. Read-only over `files[currentFile].json`.
// Mirrors the runtime engine in `godot/scripts/autoload/dialogue_runner.gd`:
//   - walks states top-down, fires the first whose trigger evaluates true
//   - commits options.write_path = choice.value
//   - increments options.trust_path by choice.trust_delta
//   - applies on_dismiss { set, value } / award_badge / unlock_route to shadow state
//   - chains via options.chain (re-fires dialogue without closing)
//   - skips states.once = true that have already fired (tracked in shadow.dialogue_states_seen)
//
// Shadow state is a plain object initialised empty. Unresolved paths fall back to
// type-inferred defaults at evaluation time (matches the linear editor's
// consequence engine: bool→false, number→0, string→'').
//
// Public surface (set on window):
//   Simulator.open(startStateId?)   — open the modal; optional explicit start
//   Simulator.close()
//   Simulator.reset()

(function () {
  'use strict';

  const State = {
    modalEl: null,
    scenePane: null,
    observerPane: null,
    shadow: {},
    path: [],           // every state id we've fired this session
    activeState: null,
    activeChoices: null,
    activeWritePath: '',
    activeTrustPath: '',
    activeChain: false,
    activeStateChain: false,
    activeOnDismiss: [],
    activeOnceId: '',
    startStateId: null, // optional explicit start; null = engine-pick
    selectedChoiceIdx: 0,
    // Snapshot stack — one entry per "user action" (choice commit or
    // Continue press). Previous pops one and restores. Cleared on reset.
    history: [],
  };

  window.Simulator = {
    open(startStateId) { open(startStateId); },
    close() { close(); },
    reset() { reset(); },
    prev() { prev(); },
  };

  function open(startStateId) {
    if (State.modalEl) close();
    if (typeof currentFile === 'undefined' || !currentFile || !files[currentFile]) {
      alert('Simulator: no file open');
      return;
    }
    State.startStateId = startStateId || null;
    buildModal();
    document.addEventListener('keydown', onKey);
    reset();
  }

  function close() {
    document.removeEventListener('keydown', onKey);
    if (State.modalEl && State.modalEl.parentNode) {
      State.modalEl.parentNode.removeChild(State.modalEl);
    }
    State.modalEl = null;
    State.scenePane = null;
    State.observerPane = null;
    if (window.GraphView && window.GraphView.recompute) {
      // Clear any simulator-trail classes on the graph nodes.
      document.querySelectorAll('.gnode.sim-visited, .gnode.sim-current').forEach(el => {
        el.classList.remove('sim-visited', 'sim-current');
      });
    }
  }

  // Scan all trigger clauses in the file and return a {path: defaultValue} map
  // so reset() can pre-seed the shadow. Type is inferred from each clause's op
  // and value: >= / <= or numeric literal → 0; bool literal or truthy/falsy → false;
  // plain string literal → ''. Numeric type wins over bool if the same path
  // appears in both kinds of clause. Paths already reserved by the simulator
  // itself (dialogue_states_seen) are excluded.
  function extractTriggerFlags(states) {
    if (!Array.isArray(states) || typeof parseTrigger !== 'function') return {};
    const typeMap = {}; // path → 'bool' | 'num' | 'str'
    for (const s of states) {
      if (!s || !s.trigger) continue;
      let clauses;
      try { clauses = parseTrigger(s.trigger); } catch (_) { continue; }
      for (const c of (clauses || [])) {
        if (!c || !c.path || c.path === 'dialogue_states_seen') continue;
        let t = 'bool';
        if (c.op === '>=' || c.op === '<=' || typeof c.value === 'number') t = 'num';
        else if (typeof c.value === 'boolean' || c.op === 'truthy' || c.op === 'falsy') t = 'bool';
        else if (typeof c.value === 'string' && c.value !== 'true' && c.value !== 'false') t = 'str';
        const prev = typeMap[c.path];
        // num wins over bool wins over str
        if (!prev || (prev === 'bool' && t === 'num') || (prev === 'str' && t !== 'str')) {
          typeMap[c.path] = t;
        }
      }
    }
    const out = {};
    for (const [path, t] of Object.entries(typeMap)) {
      out[path] = t === 'num' ? 0 : t === 'str' ? '' : false;
    }
    return out;
  }

  function reset() {
    State.shadow = { dialogue_states_seen: [] };
    // Pre-seed every flag path referenced in any trigger so the Flags panel
    // is populated on open and all flags are immediately interactive.
    const json = (files[currentFile] && files[currentFile].json) || {};
    const seed = extractTriggerFlags(json.states || []);
    for (const [path, val] of Object.entries(seed)) {
      setShadowPath(State.shadow, path, val);
    }
    State.path = [];
    State.activeState = null;
    State.activeChoices = null;
    State.activeWritePath = '';
    State.activeTrustPath = '';
    State.activeChain = false;
    State.activeOnDismiss = [];
    State.activeOnceId = '';
    State.selectedChoiceIdx = 0;
    State.history = [];
    paintGraphTrail();
    advance();
  }

  // Snapshot the data layer before a user action so prev() can roll back.
  // The active* fields are derived from path[last] on restore, so we don't
  // need to capture them.
  function pushSnapshot() {
    State.history.push({
      shadow: deepClone(State.shadow),
      path: State.path.slice(),
      selectedChoiceIdx: State.selectedChoiceIdx,
    });
  }

  function deepClone(obj) {
    try { return JSON.parse(JSON.stringify(obj)); }
    catch (_) { return obj; }
  }

  function prev() {
    if (State.history.length === 0) return;
    const snap = State.history.pop();
    State.shadow = snap.shadow;
    State.path = snap.path;
    State.selectedChoiceIdx = snap.selectedChoiceIdx;
    // Re-derive activeState (and its options) from the last path entry, so
    // dialogue lines and choices come from the live JSON (post any inline
    // edits the user made).
    const lastId = State.path[State.path.length - 1];
    if (lastId && files[currentFile] && files[currentFile].json && Array.isArray(files[currentFile].json.states)) {
      const s = files[currentFile].json.states.find(x => x.id === lastId);
      if (s) loadActiveFrom(s);
      else clearActive();
    } else {
      clearActive();
    }
    paintGraphTrail();
    render();
  }

  function loadActiveFrom(s) {
    State.activeState = s;
    State.activeChoices = (s.options && Array.isArray(s.options.choices)) ? s.options.choices : null;
    State.activeWritePath = (s.options && s.options.write_path) || '';
    State.activeTrustPath = (s.options && s.options.trust_path) || '';
    State.activeChain = !!(s.options && s.options.chain);
    // State-level chain (s.chain) re-walks on dismiss for non-choice states.
    // Distinct from options.chain which fires on commit.
    State.activeStateChain = s.chain === true;
    State.activeOnDismiss = Array.isArray(s.on_dismiss) ? s.on_dismiss : [];
    State.activeOnceId = (s.once === true && s.id) ? s.id : '';
  }

  function clearActive() {
    State.activeState = null;
    State.activeChoices = null;
    State.activeWritePath = '';
    State.activeTrustPath = '';
    State.activeChain = false;
    State.activeStateChain = false;
    State.activeOnDismiss = [];
    State.activeOnceId = '';
  }

  // ===== ENGINE LOOP =====

  function advance() {
    const json = files[currentFile].json;
    if (!Array.isArray(json.states) || json.states.length === 0) {
      State.activeState = null;
      render();
      return;
    }
    let candidate = null;
    if (State.path.length === 0 && State.startStateId) {
      // Honour the explicit start the user picked, regardless of trigger.
      candidate = json.states.find(s => s.id === State.startStateId) || null;
    }
    if (!candidate) {
      for (const s of json.states) {
        if (!s) continue;
        if (s.once === true && State.shadow.dialogue_states_seen.includes(s.id)) continue;
        if (evalTrigger(s.trigger || '', State.shadow)) { candidate = s; break; }
      }
    }
    if (!candidate) {
      State.activeState = null;
      render();
      return;
    }
    State.activeState = candidate;
    State.activeChoices = (candidate.options && Array.isArray(candidate.options.choices))
      ? candidate.options.choices : null;
    State.activeWritePath = (candidate.options && candidate.options.write_path) || '';
    State.activeTrustPath = (candidate.options && candidate.options.trust_path) || '';
    State.activeChain = !!(candidate.options && candidate.options.chain);
    State.activeStateChain = candidate.chain === true;
    State.activeOnDismiss = Array.isArray(candidate.on_dismiss) ? candidate.on_dismiss : [];
    State.activeOnceId = (candidate.once === true && candidate.id) ? candidate.id : '';
    State.selectedChoiceIdx = 0;
    State.lineIdx = 0;
    State.path.push(candidate.id);
    paintGraphTrail();
    render();
  }

  // Called when the user dismisses a state without options, or commits a choice.
  function dismissActive() {
    if (!State.activeState) return;
    // on_dismiss mutations
    for (const action of State.activeOnDismiss) {
      if (!action || typeof action !== 'object') continue;
      if ('set' in action && 'value' in action) {
        setShadowPath(State.shadow, action.set, action.value);
      } else if ('award_badge' in action) {
        State.shadow.__badges = State.shadow.__badges || {};
        State.shadow.__badges[action.award_badge] = true;
      } else if ('unlock_route' in action) {
        State.shadow.__routes = State.shadow.__routes || {};
        State.shadow.__routes[action.unlock_route] = true;
      }
    }
    // once-state bookkeeping
    if (State.activeOnceId) {
      if (!State.shadow.dialogue_states_seen.includes(State.activeOnceId)) {
        State.shadow.dialogue_states_seen.push(State.activeOnceId);
      }
    }
    State.activeOnDismiss = [];
    State.activeOnceId = '';
  }

  function commitChoice(choiceIdx) {
    if (!State.activeState || !State.activeChoices) return;
    const choice = State.activeChoices[choiceIdx];
    if (!choice) return;
    // Snapshot BEFORE any mutation so Previous returns us to this exact state.
    pushSnapshot();
    // Apply write_path
    if (State.activeWritePath) {
      setShadowPath(State.shadow, State.activeWritePath, choice.value);
    }
    // Apply trust_delta
    if (State.activeTrustPath && typeof choice.trust_delta === 'number' && choice.trust_delta !== 0) {
      const cur = resolveShadowPath(State.shadow, State.activeTrustPath);
      const delta = choice.trust_delta;
      const next = (typeof cur === 'number' ? cur : 0) + delta;
      setShadowPath(State.shadow, State.activeTrustPath, next);
    }
    // Fire dismiss (on_dismiss + once mark)
    dismissActive();
    // Chain or end
    if (State.activeChain) {
      advance();
    } else {
      // No chain — runtime would close the box here. Simulator stops at this
      // state (matches in-game: the next dialogue request would re-walk states).
      State.activeState = null;
      State.activeChoices = null;
      render();
    }
  }

  // ===== TRIGGER + PATH HELPERS =====

  function evalTrigger(trigger, shadow) {
    if (!trigger || !trigger.trim()) return true;
    if (typeof parseTrigger !== 'function') return true;
    const clauses = parseTrigger(trigger);
    for (const c of clauses) {
      if (!evalClause(c, shadow)) return false;
    }
    return true;
  }

  function evalClause(c, shadow) {
    let actual = resolveShadowPath(shadow, c.path);
    if (actual === undefined) actual = defaultFor(c);
    switch (c.op) {
      case '==': return looseStr(actual) === looseStr(c.value);
      case '!=': return looseStr(actual) !== looseStr(c.value);
      case '>=': return toInt(actual) >= toInt(c.value);
      case '<=': return toInt(actual) <= toInt(c.value);
      case 'truthy': return !!actual && actual !== 'false' && actual !== '0';
      case 'falsy': return !actual || actual === 'false' || actual === '0';
    }
    return false;
  }

  function defaultFor(c) {
    if (c.op === '>=' || c.op === '<=') return 0;
    if (typeof c.value === 'boolean') return false;
    if (typeof c.value === 'number') return 0;
    return '';
  }

  function looseStr(v) {
    if (typeof v === 'boolean') return v ? 'true' : 'false';
    if (v == null) return '';
    return String(v);
  }
  function toInt(v) {
    if (typeof v === 'number') return Math.trunc(v);
    const n = parseInt(String(v), 10);
    return Number.isFinite(n) ? n : 0;
  }

  function resolveShadowPath(data, path) {
    if (!path) return undefined;
    const segs = path.split('.');
    let cur = data;
    for (const seg of segs) {
      if (cur == null || typeof cur !== 'object') return undefined;
      cur = cur[seg];
    }
    return cur;
  }
  function setShadowPath(data, path, value) {
    if (!path) return;
    const segs = path.split('.');
    let cur = data;
    for (let i = 0; i < segs.length - 1; i++) {
      const seg = segs[i];
      if (cur[seg] == null || typeof cur[seg] !== 'object') cur[seg] = {};
      cur = cur[seg];
    }
    cur[segs[segs.length - 1]] = value;
  }

  // ===== RENDER =====

  function buildModal() {
    const root = document.createElement('div');
    root.className = 'sim-modal';
    root.innerHTML = `
      <div class="sim-backdrop"></div>
      <div class="sim-shell">
        <div class="sim-titlebar">
          <span class="sim-title">▶ Simulator — <span class="sim-file"></span></span>
          <span class="sim-hint">↑/↓ choose · Enter commit · ← prev · R reset · Esc close · click line to edit</span>
          <button class="sim-btn sim-btn-prev" title="previous step (Backspace)" disabled>← Prev</button>
          <button class="sim-btn sim-btn-reset" title="reset (R)">Reset</button>
          <button class="sim-btn sim-btn-close" title="close (Esc)">×</button>
        </div>
        <div class="sim-body">
          <div class="sim-scene"></div>
          <div class="sim-observer"></div>
        </div>
      </div>
    `;
    document.body.appendChild(root);
    root.querySelector('.sim-btn-close').addEventListener('click', close);
    root.querySelector('.sim-btn-reset').addEventListener('click', reset);
    root.querySelector('.sim-btn-prev').addEventListener('click', prev);
    root.querySelector('.sim-backdrop').addEventListener('click', close);
    root.querySelector('.sim-file').textContent = currentFile || '';
    State.modalEl = root;
    State.scenePane = root.querySelector('.sim-scene');
    State.observerPane = root.querySelector('.sim-observer');
  }

  function render() {
    renderScene();
    renderObserver();
    if (State.modalEl) {
      const prevBtn = State.modalEl.querySelector('.sim-btn-prev');
      if (prevBtn) prevBtn.disabled = State.history.length === 0;
    }
  }

  function renderScene() {
    if (!State.scenePane) return;
    const s = State.activeState;
    if (!s) {
      State.scenePane.innerHTML = `
        <div class="sim-empty">
          <div class="sim-empty-h">no state matched</div>
          <div class="sim-empty-sub">runtime would fall back to idle_flavor or the "..." sentinel. press R to reset.</div>
        </div>
      `;
      return;
    }
    const owner = (files[currentFile].json && files[currentFile].json.npc_id) || 'npc';
    const linesHtml = renderLinesHtml(s, owner);
    const choicesHtml = State.activeChoices ? renderChoicesHtml(State.activeChoices) : '';
    const advanceHint = State.activeChoices
      ? ''
      : `<div class="sim-advance"><button class="sim-btn sim-btn-primary sim-btn-advance">Continue ▸</button></div>`;
    State.scenePane.innerHTML = `
      <div class="sim-state-head">
        <code class="sim-state-id">${escapeHtml(s.id || '(unnamed)')}</code>
      </div>
      <div class="sim-lines">${linesHtml}</div>
      ${choicesHtml}
      ${advanceHint}
    `;
    const advBtn = State.scenePane.querySelector('.sim-btn-advance');
    if (advBtn) {
      advBtn.addEventListener('click', () => {
        // Snapshot before the action so Previous can roll back the dismiss.
        pushSnapshot();
        dismissActive();
        advance();
      });
      advBtn.focus();
    }
    State.scenePane.querySelectorAll('.sim-choice').forEach((el, i) => {
      el.addEventListener('click', () => commitChoice(i));
      el.addEventListener('mouseenter', () => {
        State.selectedChoiceIdx = i;
        updateChoiceSelection();
      });
    });
    updateChoiceSelection();
    attachLineEditors();
  }

  // Click-to-edit on speaker / text spans inside the lines list. Explicit
  // confirm/revert via ✓ / ✗ buttons that appear next to the line while
  // editing. Blur (clicking elsewhere) reverts silently — only ✓ or Enter
  // commits. This matches the host's line editor in spirit but is stricter
  // about accidental commits.
  function attachLineEditors() {
    if (!State.scenePane) return;
    State.scenePane.querySelectorAll('.sim-line[data-line-idx]').forEach(lineRow => {
      const lineIdx = parseInt(lineRow.dataset.lineIdx, 10);
      if (!Number.isFinite(lineIdx)) return;
      lineRow.querySelectorAll('.sim-editable').forEach(el => {
        const field = el.dataset.editField;
        if (!field) return;
        el.addEventListener('click', (e) => {
          e.stopPropagation();
          // Speaker uses a <select>; if one is already mounted, ignore re-clicks.
          if (field === 'speaker' && el.querySelector('select')) return;
          if (el.isContentEditable) return;
          if (field === 'speaker') beginSpeakerEdit(el, lineRow, lineIdx);
          else beginEdit(el, lineRow);
        });
        // Blur on the text field = silent commit (matches a normal text input).
        // The speaker <select> manages its own blur revert in beginSpeakerEdit.
        el.addEventListener('blur', () => {
          if (field === 'speaker') return;
          if (!el.isContentEditable) return;
          commitLineEdit(el, lineIdx, field, /*silent*/true);
        });
        el.addEventListener('keydown', (e) => {
          if (field === 'speaker') return;
          if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            commitLineEdit(el, lineIdx, field);
            // Drop focus so the next keystrokes aren't trapped in the line.
            el.blur();
          } else if (e.key === 'Escape') {
            e.preventDefault();
            cancelLineEdit(el, lineIdx, field);
          }
        });
      });
    });
  }

  function beginEdit(el, lineRow) {
    el.contentEditable = 'true';
    el.classList.add('sim-editing');
    if (lineRow) lineRow.dataset.editing = '1';
    el.focus();
    try {
      const range = document.createRange();
      range.selectNodeContents(el);
      const sel = window.getSelection();
      sel.removeAllRanges();
      sel.addRange(range);
    } catch (_) {}
  }

  // Speaker edit uses a <select> populated from the host's collectSpeakers()
  // call. We replace the .sim-speaker element's inner text with the select,
  // commit on `change` (no ✓ needed — picking is a deliberate action), and
  // revert on blur if no change was made. Esc cancels. The element keeps
  // its .sim-editing class so the surrounding visuals stay consistent with
  // text-field editing.
  function beginSpeakerEdit(el, lineRow, lineIdx) {
    const original = el.textContent || '';
    const speakers = (typeof window.collectSpeakers === 'function')
      ? window.collectSpeakers()
      : [];
    // Ensure the current speaker is in the list so the select shows it
    // selected even if it's not in the known set yet.
    const opts = new Set(speakers);
    if (original) opts.add(original);
    const select = document.createElement('select');
    select.className = 'sim-speaker-select';
    for (const s of Array.from(opts).sort()) {
      const o = document.createElement('option');
      o.value = s;
      o.textContent = s;
      if (s === original) o.selected = true;
      select.appendChild(o);
    }
    // Stop the bubbling click from re-firing beginSpeakerEdit on the parent
    // .sim-editable while the user is interacting with the select.
    select.addEventListener('click', (e) => e.stopPropagation());
    select.addEventListener('mousedown', (e) => e.stopPropagation());
    el.innerHTML = '';
    el.appendChild(select);
    el.classList.add('sim-editing');
    if (lineRow) lineRow.dataset.editing = '1';
    let committed = false;
    select.addEventListener('change', () => {
      committed = true;
      const newVal = select.value;
      // Commit by mutating the JSON entry directly, then restore the text
      // node so the row layout returns to normal.
      const s = State.activeState;
      if (!s || !Array.isArray(s.lines)) { revertSpeaker(); return; }
      const entry = s.lines[lineIdx];
      const ownerSpeaker = (files[currentFile] && files[currentFile].json && files[currentFile].json.npc_id) || 'npc';
      if (typeof entry === 'string') {
        // String → upgrade to object iff the new speaker differs from owner.
        if (newVal !== ownerSpeaker) {
          s.lines[lineIdx] = { speaker: newVal, text: entry };
        }
      } else if (entry && typeof entry === 'object') {
        if (newVal === ownerSpeaker) {
          // Owner = default; drop the explicit speaker field so the file
          // stays minimal (matches the linear editor's serialization rules).
          delete entry.speaker;
        } else {
          entry.speaker = newVal;
        }
      }
      if (typeof markDirty === 'function') markDirty();
      el.innerHTML = escapeHtml(newVal);
      el.classList.remove('sim-editing');
      if (lineRow) delete lineRow.dataset.editing;
      showSavedCaption();
      if (typeof renderContent === 'function') renderContent();
      // Re-render the simulator scene so the .sim-line-modified class is
      // applied (or cleared) after the speaker change. commitLineEdit for
      // the text field already calls render() at the end — keep parity here.
      render();
    });
    select.addEventListener('blur', () => {
      if (committed) return;
      revertSpeaker();
    });
    select.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') { e.preventDefault(); revertSpeaker(); }
    });
    function revertSpeaker() {
      el.innerHTML = escapeHtml(original);
      el.classList.remove('sim-editing');
      if (lineRow) delete lineRow.dataset.editing;
    }
    // Open the dropdown right away — saves a click.
    select.focus();
    if (typeof select.showPicker === 'function') {
      try { select.showPicker(); } catch (_) {}
    }
  }

  function cancelLineEdit(el, lineIdx, field) {
    if (!el.isContentEditable) return;
    el.textContent = originalEditText(lineIdx, field);
    finalizeEdit(el);
  }

  function finalizeEdit(el) {
    el.contentEditable = 'false';
    el.classList.remove('sim-editing');
    const lineRow = el.closest('.sim-line');
    if (lineRow) delete lineRow.dataset.editing;
  }

  function originalEditText(lineIdx, field) {
    const s = State.activeState;
    if (!s || !Array.isArray(s.lines)) return '';
    const entry = s.lines[lineIdx];
    const ownerSpeaker = (files[currentFile] && files[currentFile].json && files[currentFile].json.npc_id) || 'npc';
    if (typeof entry === 'string') {
      return field === 'text' ? entry : ownerSpeaker;
    }
    if (entry && typeof entry === 'object') {
      return field === 'speaker' ? (entry.speaker || ownerSpeaker) : (entry.text || '');
    }
    return '';
  }

  function commitLineEdit(el, lineIdx, field) {
    if (!el.isContentEditable) return;
    const newVal = (el.textContent || '').trim();
    const s = State.activeState;
    if (!s || !Array.isArray(s.lines)) return;
    const entry = s.lines[lineIdx];
    const ownerSpeaker = (files[currentFile] && files[currentFile].json && files[currentFile].json.npc_id) || 'npc';
    let changed = false;
    if (typeof entry === 'string') {
      if (field === 'text') {
        if (newVal !== entry) { s.lines[lineIdx] = newVal; changed = true; }
      } else if (field === 'speaker') {
        // Promote to {speaker, text} object only if speaker is non-empty AND
        // different from the file's default. Otherwise the entry stays a
        // plain string (the engine treats those as "owner speaks").
        if (newVal && newVal !== ownerSpeaker) {
          s.lines[lineIdx] = { speaker: newVal, text: entry };
          changed = true;
        }
      }
    } else if (entry && typeof entry === 'object') {
      if (field === 'text') {
        if (newVal !== entry.text) { entry.text = newVal; changed = true; }
      } else if (field === 'speaker') {
        if (newVal && newVal !== entry.speaker) { entry.speaker = newVal; changed = true; }
      }
    }
    finalizeEdit(el);
    if (changed) {
      if (typeof markDirty === 'function') markDirty();
      showSavedCaption();
      // Refresh the linear pane (state card) so the edit shows there too.
      if (typeof renderContent === 'function') renderContent();
      // Line text edits don't change topology, so the graph doesn't need a
      // structural recompute. Skipping notifyGraphStructuralChange().
    }
    render();
  }

  // Tiny transient banner inside the simulator titlebar. Fades after ~1.2s.
  // The element is created lazily on the first commit; subsequent commits
  // reset the timer so rapid edits don't multiply captions.
  var _savedCaptionTimer = null;
  function showSavedCaption() {
    if (!State.rootEl) return;
    let cap = State.rootEl.querySelector('.sim-saved-caption');
    if (!cap) {
      const titlebar = State.rootEl.querySelector('.sim-titlebar');
      if (!titlebar) return;
      cap = document.createElement('span');
      cap.className = 'sim-saved-caption';
      cap.textContent = 'saved';
      titlebar.appendChild(cap);
    }
    cap.classList.remove('sim-saved-show');
    // Force reflow so re-adding the class restarts the CSS transition.
    void cap.offsetWidth;
    cap.classList.add('sim-saved-show');
    if (_savedCaptionTimer) clearTimeout(_savedCaptionTimer);
    _savedCaptionTimer = setTimeout(() => {
      if (cap) cap.classList.remove('sim-saved-show');
      _savedCaptionTimer = null;
    }, 1200);
  }

  function renderLinesHtml(s, owner) {
    let arr = [];
    let usesArrayLines = false;
    if (Array.isArray(s.lines)) { arr = s.lines; usesArrayLines = true; }
    else if (typeof s.line === 'string') arr = [s.line];
    if (arr.length === 0) return `<div class="sim-line sim-line-empty">(no lines)</div>`;
    return arr.map((entry, i) => {
      let speaker = owner;
      let text = '';
      if (typeof entry === 'string') text = entry;
      else if (entry && typeof entry === 'object') {
        speaker = (entry.speaker || owner);
        text = entry.text || '';
      }
      // Mirror the linear editor's modified-line highlight inside the sim.
      // For array-form states, ask the host's identity-based `isLineModified`;
      // for single-line states, fall back to `isSingleLineModified`.
      let modified = false;
      if (typeof window.isLineModified === 'function' && usesArrayLines) {
        try { modified = !!window.isLineModified(s, i); } catch (_) {}
      } else if (!usesArrayLines && typeof window.isSingleLineModified === 'function') {
        try { modified = !!window.isSingleLineModified(s); } catch (_) {}
      }
      const modClass = modified ? ' sim-line-modified' : '';
      return `
        <div class="sim-line${modClass}" data-line-idx="${i}">
          <div class="sim-speaker sim-editable" data-edit-field="speaker" title="click to edit speaker">${escapeHtml(speaker)}</div>
          <div class="sim-text sim-editable" data-edit-field="text" title="click to edit text (Enter saves, Esc reverts)">${formatInline(text)}</div>
        </div>
      `;
    }).join('');
  }

  function renderChoicesHtml(choices) {
    const items = choices.map((c, i) => {
      const delta = (typeof c.trust_delta === 'number' && c.trust_delta !== 0)
        ? `<span class="sim-choice-delta">Δ${c.trust_delta > 0 ? '+' : ''}${c.trust_delta}</span>`
        : '';
      const val = (c.value != null) ? `<span class="sim-choice-val">${escapeHtml(String(c.value))}</span>` : '';
      return `
        <button class="sim-choice" data-idx="${i}">
          <span class="sim-choice-marker">▶</span>
          <span class="sim-choice-text">${formatInline(c.text || '')}</span>
          ${delta}
          ${val}
        </button>
      `;
    }).join('');
    return `<div class="sim-choices">${items}</div>`;
  }

  function updateChoiceSelection() {
    const list = State.scenePane ? State.scenePane.querySelectorAll('.sim-choice') : [];
    list.forEach((el, i) => el.classList.toggle('sim-choice-selected', i === State.selectedChoiceIdx));
  }

  function renderObserver() {
    if (!State.observerPane) return;
    const trustPath = inferTrustPath();
    const trust = trustPath ? resolveShadowPath(State.shadow, trustPath) : null;
    const visited = State.path.map((id, i) => {
      const cur = (i === State.path.length - 1) ? ' sim-visited-current' : '';
      return `<li class="sim-visited-item${cur}"><span class="sim-visited-step">${i + 1}</span><code>${escapeHtml(id)}</code></li>`;
    }).join('');
    const flagsHtml = renderFlagsHtml(State.shadow);
    State.observerPane.innerHTML = `
      <div class="sim-obs-section">
        <div class="sim-obs-h">Step ${State.path.length}</div>
        ${trustPath ? `<div class="sim-obs-trust"><span>trust</span><b>${trust == null ? '0' : trust}</b><small>${escapeHtml(trustPath)}</small></div>` : ''}
      </div>
      <div class="sim-obs-section">
        <div class="sim-obs-h">Visited</div>
        <ol class="sim-visited">${visited || '<li class="sim-visited-empty">—</li>'}</ol>
      </div>
      <div class="sim-obs-section">
        <div class="sim-obs-h">Flags</div>
        <div class="sim-flags">${flagsHtml || '<div class="sim-flags-empty">—</div>'}</div>
        <form class="sim-flag-inject" title="inject a flag into shadow state (e.g. chapter1.met_pig=true)">
          <input class="sim-flag-inject-input" placeholder="path=value" spellcheck="false" autocomplete="off">
          <button type="submit" class="sim-btn sim-flag-inject-btn">Set</button>
        </form>
      </div>
    `;
    // Wire bool-flag click-to-toggle
    State.observerPane.querySelectorAll('.sim-flag-bool[data-flag-path]').forEach(el => {
      el.addEventListener('click', () => {
        const path = el.dataset.flagPath;
        const cur = resolveShadowPath(State.shadow, path);
        setShadowPath(State.shadow, path, !cur);
        if (!State.activeState) advance(); else render();
      });
    });
    // Wire non-bool flag click-to-edit (inline input)
    State.observerPane.querySelectorAll('.sim-flag-editable[data-flag-path]').forEach(el => {
      el.addEventListener('click', (e) => {
        if (el.querySelector('input')) return; // already editing
        const path = el.dataset.flagPath;
        const type = el.dataset.flagType || 'str';
        const valEl = el.querySelector('.sim-flag-val');
        const cur = resolveShadowPath(State.shadow, path);
        const input = document.createElement('input');
        input.className = 'sim-flag-inline-input';
        input.value = (cur == null ? '' : String(cur));
        input.type = type === 'num' ? 'number' : 'text';
        valEl.replaceWith(input);
        input.focus();
        input.select();
        const commit = () => {
          let v = input.value.trim();
          let parsed;
          if (type === 'num') parsed = parseInt(v, 10) || 0;
          else if (v === 'true') parsed = true;
          else if (v === 'false') parsed = false;
          else parsed = v;
          setShadowPath(State.shadow, path, parsed);
          if (!State.activeState) advance(); else render();
        };
        const revert = () => render();
        input.addEventListener('keydown', (e) => {
          if (e.key === 'Enter') { e.preventDefault(); commit(); }
          if (e.key === 'Escape') { e.preventDefault(); revert(); }
        });
        input.addEventListener('blur', commit);
        e.stopPropagation();
      });
    });
    // Wire flag-inject form
    const injectForm = State.observerPane.querySelector('.sim-flag-inject');
    if (injectForm) {
      const injectInput = injectForm.querySelector('.sim-flag-inject-input');
      injectForm.addEventListener('submit', (e) => {
        e.preventDefault();
        const raw = (injectInput.value || '').trim();
        const eq = raw.indexOf('=');
        if (eq < 1) return;
        const path = raw.slice(0, eq).trim();
        const valStr = raw.slice(eq + 1).trim();
        let value;
        if (valStr === 'true') value = true;
        else if (valStr === 'false') value = false;
        else if (/^-?\d+$/.test(valStr)) value = parseInt(valStr, 10);
        else value = valStr;
        setShadowPath(State.shadow, path, value);
        injectInput.value = '';
        if (!State.activeState) advance(); else render();
      });
    }
  }

  // Best-effort trust path lookup: the first options block with a trust_path
  // declaration. Good enough for halina-style files; if a file uses multiple
  // trust paths the user can still read the Flags panel.
  function inferTrustPath() {
    const json = files[currentFile] && files[currentFile].json;
    if (!json || !Array.isArray(json.states)) return null;
    for (const s of json.states) {
      if (s.options && s.options.trust_path) return s.options.trust_path;
    }
    return null;
  }

  function renderFlagsHtml(obj, prefix) {
    prefix = prefix || '';
    const rows = [];
    for (const key of Object.keys(obj || {})) {
      if (key.startsWith('__')) continue;  // simulator-private buckets
      const val = obj[key];
      const path = prefix ? `${prefix}.${key}` : key;
      if (val && typeof val === 'object' && !Array.isArray(val)) {
        rows.push(renderFlagsHtml(val, path));
      } else {
        const isBool = typeof val === 'boolean';
        const isNum = typeof val === 'number';
        const cls = isBool ? 'sim-flag sim-flag-bool' : 'sim-flag sim-flag-editable';
        const pathAttr = ` data-flag-path="${escapeHtml(path)}"`;
        const typeAttr = isBool ? ' data-flag-type="bool"' : (isNum ? ' data-flag-type="num"' : ' data-flag-type="str"');
        rows.push(`<div class="${cls}"${pathAttr}${typeAttr}><code>${escapeHtml(path)}</code><b class="sim-flag-val">${escapeHtml(formatVal(val))}</b></div>`);
      }
    }
    return rows.join('');
  }

  function formatVal(v) {
    if (v === undefined || v === null) return '—';
    if (Array.isArray(v)) return `[${v.length}]`;
    return String(v);
  }

  // ===== GRAPH TRAIL =====

  function paintGraphTrail() {
    // Soft integration: if the graph view is mounted, mark visited nodes.
    document.querySelectorAll('.gnode.sim-visited, .gnode.sim-current').forEach(el => {
      el.classList.remove('sim-visited', 'sim-current');
    });
    if (!State.path.length) return;
    const last = State.path[State.path.length - 1];
    for (const id of State.path) {
      const sel = `.gnode[data-node-id="${cssEscapeId(id)}"]`;
      document.querySelectorAll(sel).forEach(el => el.classList.add('sim-visited'));
    }
    const curSel = `.gnode[data-node-id="${cssEscapeId(last)}"]`;
    document.querySelectorAll(curSel).forEach(el => el.classList.add('sim-current'));
  }

  function cssEscapeId(s) {
    if (window.CSS && typeof window.CSS.escape === 'function') return window.CSS.escape(String(s));
    return String(s).replace(/(["\\])/g, '\\$1');
  }

  // ===== KEYBOARD =====

  function onKey(e) {
    if (!State.modalEl) return;
    if (e.target && (e.target.tagName === 'INPUT' || e.target.tagName === 'TEXTAREA' || e.target.isContentEditable)) {
      // Inside a line editor — only Escape should exit, and it's handled by
      // the editor's own keydown to revert. Don't hijack other keys.
      return;
    }
    if (e.key === 'Escape') { e.preventDefault(); close(); return; }
    if (e.key === 'r' || e.key === 'R') { e.preventDefault(); reset(); return; }
    if (e.key === 'Backspace' || e.key === 'ArrowLeft') { e.preventDefault(); prev(); return; }
    if (State.activeChoices && State.activeChoices.length) {
      if (e.key === 'ArrowDown' || e.key === 'j') {
        e.preventDefault();
        State.selectedChoiceIdx = (State.selectedChoiceIdx + 1) % State.activeChoices.length;
        updateChoiceSelection();
        return;
      }
      if (e.key === 'ArrowUp' || e.key === 'k') {
        e.preventDefault();
        State.selectedChoiceIdx = (State.selectedChoiceIdx - 1 + State.activeChoices.length) % State.activeChoices.length;
        updateChoiceSelection();
        return;
      }
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        commitChoice(State.selectedChoiceIdx);
        return;
      }
    } else if (State.activeState) {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        dismissActive();
        advance();
        return;
      }
    }
  }

  // ===== UTIL =====

  function escapeHtml(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, c => ({
      '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;'
    }[c]));
  }

  // Render `[i]…[/i]` italic tags from line text. Anything else stays escaped.
  function formatInline(s) {
    const safe = escapeHtml(s);
    return safe.replace(/\[i\]/g, '<em>').replace(/\[\/i\]/g, '</em>');
  }

})();
