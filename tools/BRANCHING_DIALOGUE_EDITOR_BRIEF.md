# Branching Dialogue Editor — Phase 1 Design Brief

**For:** Claude Design (visual + interaction implementer)
**Status:** Phase 1 only (read-only graph minimap). Phases 2 and 3 are sketched at the end; do not implement them yet.
**Target file:** extend `tools/Dialogue Editor.html` in place. No new HTML files, no framework, no build step.

---

## 1. Context for the implementer

The current editor is a single-file HTML/CSS/JS tool authoring Pig & Swine RPG dialogue JSON files at `godot/data/dialogues/*.json`. States render as a linear list, top to bottom. Each state has `id`, `trigger`, `lines`, optional `options` (with `choices`), and optional `on_dismiss`. The runtime engine (Godot, GDScript) walks `states` in JSON order and fires the first whose `trigger` evaluates true. Choice commits a value to `options.write_path` and optionally increments `options.trust_path` by `choice.trust_delta`; if `options.chain == true`, dialogue immediately re-fires for the same NPC.

Authoring pain points the graph view solves:

1. The shape of a dialogue is implicit — you trace triggers manually to see what leads where.
2. Splitting a response into per-choice variants requires hand-authored trigger boilerplate that is typo-prone (e.g. one author shipped `halina_met == true` instead of `false` and lost an hour to it).
3. Navigating a 12-state file is scroll-and-grep.

The existing editor already exposes two derivation functions you will reuse — do not reimplement them:

- `findChoiceConsequences(state, choice, opts)` returns the set of state ids reachable by this choice.
- `computeExcludedForChoice(state, opts, choiceIdx)` returns the set of state ids that *other* choices in the same options block would reach but this one would not.

There is also a global `pinnedConsequences` array of `{stateId, choiceIdx, targets}` that the user populates by clicking the `→ N` badges. The graph view should reflect pinning.

---

## 2. The architectural rule (do not violate)

The JSON is the source of truth. The linear editor is the primary authoring surface. The graph view is a *derived view* that reads `files[currentFile].json` and the two functions above to compute edges. Graph state — layout positions, zoom, pan, selection — is in-memory only and is never written to JSON.

The graph never invents an edge the runtime engine would not actually walk. If you find yourself wanting to draw an edge that `findChoiceConsequences` doesn't produce, the bug is in the engine or its inputs; fix it there, not in the graph layer.

Phase 1 performs zero JSON writes. The only side effects are scroll position in the linear pane and which node the user has selected.

---

## 3. Layout

Topbar adds one new control: a three-way view toggle reading `linear | graph | split`. Default `split`. Persist the choice in `localStorage.dialogue_editor_view_mode`.

- **Linear** — existing list, full width. No change.
- **Graph** — pannable, zoomable canvas, full width.
- **Split** — linear pane on the left (~55%), graph pane on the right (~45%), draggable center divider. At viewport widths below 880px, force `graph` or `linear` (whichever was last selected); the split is unusable below that.

Selection is shared. Clicking a node in graph scrolls the linear pane to that state and adds a brief `.consequence-flash` class to its card. Clicking a state card in linear marks the corresponding node selected in the graph and pans to bring it into view.

---

## 4. Node design

Each `state` is one node. Compact, roughly 200×80px at 1× zoom. Wider than tall so labels read at a glance.

Anatomy, top to bottom:

1. **State id** — top of the node, monospace, `var(--accent)` color, truncate with ellipsis past ~24 chars.
2. **Role badge** — small uppercase tag, role inferred from the state's structure (see rules below). Right-aligned on the same row as the id.
3. **Metadata strip** — bottom row, small icons and counts: `≡ N` (line count), `→ N` (choice count), `1×` (when `state.once === true`), `↑ N` (when the state's trigger contains a `trust_path >= N` clause, surface N).

Role inference (deterministic, computed at render):

- `entry` — node has no incoming edges.
- `question` — `state.options.choices.length > 0`.
- `response` — no options block, has incoming edges from at least one `question` node.
- `terminal` — has incoming edges, no outgoing edges, no options.
- `junction` — everything else (conditional state with no options used as a structural hop).

Selected node: 2px border (instead of 1px), in `var(--accent)`, plus a 4px outer offset shadow at 30% alpha.

---

## 5. Edge design

One edge per `(source state, choice, target)` triple where the target appears in `findChoiceConsequences(source, choice, source.options)`. If a single choice has multiple plausible targets (e.g. `r0_response_high` *and* `r0_response_low`), draw one edge per target — do not bundle. Edges that `computeExcludedForChoice` reports get a distinct style only when the user has *pinned* a choice; otherwise they are not drawn.

Geometry: cubic Bezier from the bottom of the source node to the top of the target. Use dagre for layout; let it choose anchor offsets so multiple edges from the same source fan out cleanly.

Edge stroke and styling:

- **Reachable**: 1.5px solid `var(--accent)`, 70% alpha.
- **Trust-gated** (the target trigger asserts `trust_path >= N` and this choice's Δ cannot deterministically clear N from observable pre-trust): 1.5px dashed `var(--accent)`, 70% alpha.
- **Excluded** (only drawn when a sibling choice is pinned): 1px dotted `var(--highlight-excl-stripe)`, 50% alpha.
- **Selected / hovered**: stroke width steps up to 2.5px, alpha to 100%.

Edge labels: choice text truncated to ~28 chars, rendered in a small pill (`var(--bg)` fill, `var(--divider)` 0.5px border, `var(--text)` text, font-ui at 10px). Centered along the curve. Δ trust badge appears to the right of the label if non-zero, in `var(--modified)` (the same yellow as the dirty indicator).

Arrowheads: 5px wide × 6px tall, same color as the stroke, anchored at the target node's top edge.

---

## 6. Color and typography tokens

Reuse exclusively. No new colors. All theme-aware via the existing CSS variables.

```
node id text:        var(--accent), monospace, 11px
node role badge:     var(--dim), font-ui, 9px, uppercase, letter-spacing 0.08em
node metadata:       var(--dim), font-ui, 10px
node fill (default): var(--bg)
node fill (reach):   var(--highlight-reach-bg)
node fill (excl):    var(--highlight-excl-bg)
node border:         var(--divider), 1px (or 2px when selected, in var(--accent))
node accent stripe:  var(--highlight-reach-stripe) | var(--highlight-excl-stripe), 4px on the left

edge stroke:         var(--accent), 70% alpha
edge label fill:     var(--bg)
edge label border:   var(--divider), 0.5px
edge label text:     var(--text), font-ui, 10px
edge Δ badge:        var(--modified)

canvas bg:           var(--bg)
gridlines (subtle):  var(--divider) at 30% alpha, 1px, 24px spacing
```

If a variable you need is missing, add it to both `:root` and `body.light` in the existing `<style>` block. Don't introduce hard-coded hex.

---

## 7. Interactions (Phase 1 only)

| Action | Result |
| --- | --- |
| Click node | Select node. In `split` or `linear`, scroll linear pane to that state and flash its card. |
| Hover node | Tooltip: first line of `state.lines` truncated to 80 chars. |
| Click edge | Highlight the source choice in the linear editor (apply the existing `:focus` style on its choice-row). Do not change selection. |
| Hover edge | Tooltip: full choice text and target state id. |
| Drag canvas empty area | Pan. |
| Mouse wheel | Zoom centered on cursor. Clamp to 0.25× – 3×. |
| Drag node body | Reposition the node cosmetically; lost on next layout recompute. |
| Double-click empty canvas | Append a new empty state to `json.states` and place the new node at the click position (cosmetically, until next layout). Existing `+ add state` logic applies. |
| `f` (keyboard) | Fit-to-view: zoom and pan so all nodes fit. |
| `0` (keyboard) | Reset zoom to 1×, center on canvas origin. |
| `/` (keyboard) | Focus a small search overlay in the graph pane that filters nodes by id substring (dims unmatched nodes to 30% alpha; edges with at least one dimmed endpoint also dim). |

Phase 1 does not include drag-to-wire, edge editing, node deletion from the graph, or any text editing in the graph pane. Deletion still happens in the linear view via the existing `✕`.

---

## 8. Edge-derivation algorithm

Pseudocode. Implement once on every layout pass; cache between passes if profiling shows it's needed.

```
edges = []
for state in json.states:
  if not state.options or not state.options.choices: continue
  for (choiceIdx, choice) in enumerate(state.options.choices):
    targets = findChoiceConsequences(state, choice, state.options)
    for tid in targets:
      target = findStateById(tid)
      if target == null:
        target = makeExternalPlaceholder(tid)  // see §11
      kind = resolveEdgeKind(state, choice, target)
      edges.push({source: state, target, choice, choiceIdx, kind})

  // Only draw excluded edges when a sibling choice in this state is pinned.
  pinned_sibling = pinnedConsequences.find(p => p.stateId == state.id)
  if pinned_sibling and pinned_sibling.choiceIdx != choiceIdx:
    excluded = computeExcludedForChoice(state, state.options, choiceIdx)
    for tid in excluded:
      target = findStateById(tid)
      if target == null: continue
      edges.push({source: state, target, choice, choiceIdx, kind: 'excluded'})

function resolveEdgeKind(state, choice, target):
  // Reuse the trust-precision logic that findChoiceConsequences already applies.
  // If the target's trigger has a trust_path >= N clause and the source's
  // Δ alone cannot guarantee clearing N (given observable pre-trust from
  // the source's trigger), the edge is 'trust-gated'. Otherwise 'reachable'.
  ...
```

Do not write a new precision algorithm. Read `findChoiceConsequences` and its `isFirstStateUsingTrustPath` helper — they encode the existing rules.

---

## 9. Layout algorithm

Use **dagre** (MIT, ~30KB minified). Top-down rank direction (`rankdir: 'TB'`), `nodesep: 60`, `ranksep: 80`. Add the library as `tools/vendor/dagre.min.js` and load via a `<script>` tag at the top of the editor's HTML. Pin to v0.8.5.

Recompute layout on:

- File load.
- Any structural change in `json.states` (add, delete, reorder, +↑, +→). The existing editor calls `markDirty()` plus a render hook after every such change — subscribe there.
- Window resize.

Do **not** recompute while the user is dragging a node. Lock layout until `dragend`, then recompute and animate from old positions to new ones (~250ms ease-out is plenty).

For files exceeding ~50 states, plan for a "collapse subgraphs by id prefix" mode using dagre's compound graph support. Defer to Phase 2 unless it falls out of the layout call trivially.

---

## 10. Data binding contract

Phase 1 graph performs **zero JSON writes**. Every interaction in §7 is either UI-only or routes through an existing linear-editor function (which already calls `markDirty()` correctly).

The graph reads:

- `files[currentFile].json.states`
- `findChoiceConsequences()`, `computeExcludedForChoice()`, `findStateById()`
- `pinnedConsequences` (for excluded-edge rendering)
- Theme classes on `<body>` (for light/dark)

The graph writes only to its own in-memory state:

- Selected node id (single).
- Pan/zoom transform.
- Node layout positions (computed; not persisted).
- View mode (persisted to `localStorage`).
- Search filter string (lost on file switch).

When the user adds a new state via double-click on empty canvas, that *is* a JSON write — but funnel it through the existing `+ add state` button logic (do not reach into `json.states` directly).

---

## 11. External / cross-file references

A choice can reference a state id that does not exist in the current file — either an authoring mistake or a deliberate cross-file reference (these are loaded by the runtime but not by the editor, which is single-file). When `findChoiceConsequences` returns an id with no matching state in `json.states`, render a small placeholder node at the canvas edge:

- Compact, ~120×40px.
- Fill: `var(--bg)`, dashed `var(--divider)` border.
- Text: the missing id, in `var(--dim)`.
- A small `↗ ext` badge to flag it as external.

Phase 1 does not load other dialogue files into the graph. The placeholder is a "this exists somewhere else, here's the reference" indicator only.

---

## 12. View-toggle state machine

Three modes: `linear`, `graph`, `split`. Default `split`. Stored in `localStorage.dialogue_editor_view_mode`.

```
       click linear              click graph
linear ─────────────► split ─────────────► graph
  ▲                       │                  │
  │      click linear      │      click split │
  └───────────────────────┴──────────────────┘
        click linear         click split
```

Cycle order is also acceptable: linear → split → graph → linear → … via a single button if you prefer one control over three.

Selection persists across mode switches. Pan/zoom resets on mode entry to graph or split (refit to view); on returning to linear it doesn't matter.

Below 880px viewport width, force a single-pane mode and disable the `split` button — split is unusable at that width.

---

## 13. Anti-patterns (explicit do-nots)

- Don't render an edge `findChoiceConsequences` doesn't produce. If you think the engine is missing an edge, fix the engine.
- Don't store layout positions in `json`. Layout is cosmetic; recompute every render.
- Don't auto-layout while the user is dragging a node. Lock during drag.
- Don't add "preferred path" or "default" annotations that exist only in graph metadata. Every authored thing round-trips through JSON.
- Don't introduce new colors. Use the existing CSS variables only.
- Don't make the graph "pretty." Clarity wins over prettiness. Resist decoration.
- Don't re-render the graph while the user is typing in a linear-pane field. Only structural changes (add/delete/reorder state, trigger edit, choice value/text edit on commit) trigger a re-layout. Hover and selection don't.
- Don't load other files' states. Phase 1 stays inside `currentFile`.
- Don't try to fit > 100 states in one view without subgraph filtering. Add the `/` search and the future cluster-collapse.
- Don't pull in React, d3, cytoscape, or any other framework. Single dependency: dagre.

---

## 14. Definition of done (Phase 1)

- The view toggle works; user can switch linear ↔ graph ↔ split. Choice persists across reloads via `localStorage`.
- All states in the current file render as nodes; node visuals match the role rules in §4.
- All edges derived from `findChoiceConsequences` render correctly. Trust-gated edges are dashed.
- Excluded edges render only when a sibling choice in the source state is pinned.
- Click node scrolls linear pane and applies `.consequence-flash`.
- Hover edge shows tooltip with choice text.
- Theme toggle (`light` ↔ dark) re-renders graph with the right CSS variables.
- Pin/unpin in the linear editor updates the graph immediately.
- Adding a state in the linear editor adds a node in the graph after layout recompute.
- Deleting a state in the linear editor removes the node and its incident edges.
- Zero JSON writes from graph operations (verified by running the file through `verify_roundtrip.js` after a graph-only interaction session — no diff).
- Web export still passes (the editor is HTML/JS only, no Godot impact).
- One new vendored file: `tools/vendor/dagre.min.js`. No other new dependencies.

---

## 15. Phases 2 & 3 (do not implement now; written so the Phase 1 design doesn't paint into a corner)

**Phase 2 — graph-side scaffolding.** Each question node grows out-pins at its bottom edge, one per choice. Drag a pin to empty canvas → reuse the existing `+→` logic to scaffold a new state with an auto-derived trigger and id; place the new node at the drop location. Drag a pin onto an existing node → present a confirmation dialog showing the trigger change needed for the choice's commit to reach that state, then write it. No graph-side text editing yet.

**Phase 3 — graph-first authoring.** Inline editing of node lines and options within the graph view; right-click context menus; node duplication. Defer until Phases 1 and 2 are in use. The linear editor will likely remain the better surface for prose authoring — most projects stop at Phase 2.

If you find yourself wanting to ship Phase 2 features inside Phase 1 to "save a round-trip," resist. Phase 1's read-only constraint is what keeps it landable and the engine-vs-graph contract intact.
