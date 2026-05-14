# Phase 2 — Graph-side Scaffolding

**For:** Claude Design (or me, in this workspace — see "Path" at the bottom)
**Target files:** `tools/vendor/graph-view.js` (most of the work), `tools/vendor/graph-view.css` (small additions), and possibly two small touchpoints in `tools/Dialogue Editor.html` to factor the existing `+→` logic so the module can call it.
**Prerequisites:** Phase 1 shipped (graph module + integration verified).

---

## 1. What Phase 2 ships

Two operations the user can perform from the graph view alone:

1. **Drag from a choice's out-pin onto empty canvas** → editor scaffolds a new state with an auto-derived trigger and id (same logic as the existing linear-pane `+→` button), inserted into `json.states` immediately after the source state. Layout recomputes; the new node appears where it naturally falls under dagre/Sugiyama ranking (not pinned to the drop coordinates — see anti-patterns).

2. **Drag from a choice's out-pin onto an existing node** → present a small confirmation popover showing the trigger amendment that would make this choice's commit reach that target. On accept, parse/modify/serialize the target's trigger; mark dirty; recompute.

No graph-side text editing. No edge deletion. No multi-select. Phase 3 territory.

---

## 2. The architectural rule (still in force)

The JSON is the source of truth. Phase 2 *does* write to JSON, but only through the same two paths the linear editor already uses: appending a new state via the host's `+→` scaffolding logic, or amending a target's `trigger` via `parseTrigger` → splice → `serializeTrigger`. The graph never invents an edge that isn't there in the engine's view after the write commits.

Drop coordinates are *not* persisted. The graph re-layouts after every structural write. If the user wants spatial precision they'll move the node by dragging it (Phase 1 already supports cosmetic node drag) — that position is still in-memory only.

---

## 3. Out-pins on question nodes

Render conditions: a node is "pin-bearing" iff `state.options && Array.isArray(state.options.choices) && state.options.choices.length > 0`. That's the same condition that promotes the node to `role: 'question'` in Phase 1, so the check is one line.

Visual spec (all values theme-aware via existing CSS vars):

- Geometry: a small circle, 8px diameter, anchored at the node's bottom edge. One pin per choice. Distribute evenly across the node's width: `pin_x = nodeLeft + (nodeWidth * (i + 1) / (choices.length + 1))`. The +1 keeps pins off the corners.
- Fill: `var(--accent)` at 70% alpha when idle, 100% on hover. Stroke: 1px `var(--bg)` for legibility against any background.
- Cursor on hover: `grab`. On mousedown / during drag: `grabbing`.
- Hover tooltip: choice text truncated to ~60 chars, same `.gnode-tooltip` style as Phase 1's hover-node tooltip. Anchor above the pin.
- Z-order: pins are SVG `<circle>` children of their parent `<g class="gnode">` and must render *after* the node's body so they sit on top.

Pins are stateless: they have no individual selection, no per-pin styling for trust-delta sign or excluded state. The corresponding edges already convey that.

---

## 4. Drag start

`pointerdown` on a pin (left mouse only):

1. Mark `State.activeDrag = { sourceState, choiceIdx, choice, originX, originY, pinEl }`.
2. Add a transient SVG `<line class="pin-drag-line">` to a new `<g class="graph-overlay">` layer that lives at the same coordinate system as the nodes/edges. Stroke: 2px solid `var(--accent)`, 70% alpha. Dasharray: `4 4`. No arrowhead (this is a "lasso," not a settled edge).
3. Update both line endpoints on `pointermove`: `x1, y1` = pin position (constant); `x2, y2` = current cursor position in graph coordinates (apply pan + zoom transforms — the existing code already has helpers for this).
4. Set `body.style.cursor = 'grabbing'`.
5. Capture the pointer on the canvas so `pointermove`/`pointerup` fire even outside the originating element.

On `pointermove`, in addition to repositioning the line, hit-test the cursor against nodes via `document.elementFromPoint(e.clientX, e.clientY).closest('.gnode')` and mark candidate drop targets:

- Source node, external placeholders, terminal nodes (or any node where amending the trigger is meaningless — see anti-patterns) → `.gnode.invalid-drop`: 1px dashed `var(--danger)` outline.
- Any other node → `.gnode.candidate-drop`: 2px solid `var(--accent)` outline with `0 0 0 4px var(--accent-soft)` outer glow.
- Empty canvas → no outline; instead show a small ghost label near the cursor: `+ new state here` in `var(--mute)`, font-size 11px.

Clear the candidate class on the previous target when the hit-test moves.

---

## 5. Drag cancel paths

Any of these cancel the drag without writing JSON:

- `pointerup` outside any valid drop target.
- `pointerup` on the source node itself.
- `pointerup` on an `.invalid-drop` candidate.
- `Escape` key while a drag is active.
- `pointercancel` (browser-initiated).

On cancel: remove the transient line, clear `.candidate-drop` / `.invalid-drop` classes, restore cursor, clear `State.activeDrag`. No JSON write, no `notifyGraphStructuralChange`.

---

## 6. Drop on empty canvas → scaffold new state

This is the most common authoring action. Reuse the host's existing `+→` logic so the trigger derivation, id generation, dedupe, and insertion point match exactly what the linear-pane button does.

Implementation: factor the host's existing per-choice scaffold body (the click handler attached to `createTargetBtn` in `renderChoiceRow`) into a named host-level function, e.g. `scaffoldTargetStateForChoice(state, opts, choiceIdx) → newStateId`. The function should:

1. Compute the new trigger via the existing rule (`source.trigger` minus the `write_path` clause that's about to flip, plus `write_path == 'choice.value'`).
2. Compute the new id via the existing dedupe (`{source.id}_response_{sanitised choice.value}` with `_2`, `_3` suffix on collision).
3. Splice the new state into `json.states` at `sourceIdx + 1`.
4. Call `markDirty()` and `notifyGraphStructuralChange()`.
5. Return the new state's id.

Then `window.scaffoldTargetStateForChoice = scaffoldTargetStateForChoice;` so the graph module can call it. The existing `createTargetBtn` click handler becomes a one-liner that calls this function.

In the graph module, on drop on empty canvas:

```js
const newId = window.scaffoldTargetStateForChoice(
  State.activeDrag.sourceState,
  State.activeDrag.sourceState.options,
  State.activeDrag.choiceIdx
);
// Module already recomputes on notifyGraphStructuralChange; just select the
// new node so the user can see it and start editing.
if (newId) GraphView.selectStateId(newId, { pan: true });
```

Edge case: if `opts.write_path` is empty, the scaffolded trigger won't have the value clause, but the rest of the source trigger carries over. That's the same behavior as the linear-pane button — keep parity, don't special-case here.

---

## 7. Drop on existing node → trigger amend confirmation

Show a small popover anchored to the target node's top edge. Title: `Wire choice to {target.id}?`. Body: two lines of monospace, ~11px:

```
Current:  {target.trigger}
Proposed: {amended trigger preview}
```

Buttons: `Cancel` (default focus) and `Confirm`. Both `<button class="popover-btn">`; the Confirm one gets `.popover-btn-primary` with `var(--accent)` fill.

The amended trigger is derived as:

```js
const sourceClauses = parseTrigger(target.trigger || '');
const filtered = sourceClauses.filter(c => c.path !== opts.write_path);
filtered.push({
  path: opts.write_path,
  op: '==',
  value: String(opts.choices[choiceIdx].value)
});
const amended = serializeTrigger(filtered);
```

On Confirm: write `target.trigger = amended`, call `markDirty()` and `notifyGraphStructuralChange()`, close the popover. The graph recomputes; the new edge appears.

On Cancel or Escape or click outside the popover: close, no write.

Edge cases (handle as `.invalid-drop` on `pointermove`, before the drop fires):

- `opts.write_path` is empty → can't add a value clause. Toast `this options block has no write_path` and abort.
- Choice already reaches this target (already in `findChoiceConsequences(source, choice, opts)` output) → toast `already reaches this state` and abort. No write.
- Drop is on an external placeholder → toast `external reference; cannot wire from here`.
- Drop is on the source node → cancel silently.

---

## 8. Optional Phase 2.5 (folded in)

Tighten the graph module's `classifyEdgeKind` to match the linear editor's full trust-precision logic. The current Phase 1 implementation dashes any edge where `choice.trust_delta < threshold` using Δ alone; replace with the same logic `findChoiceConsequences` uses (read the source state's trigger for any prior `trust_path` assertions, account for the trust-meter entry-state precision rule via `isFirstStateUsingTrustPath`). About 20 lines in `classifyEdgeKind`. The change ends the divergence between linear-pane consequence highlight and graph-pane edge solidity.

Ship this alongside Phase 2 — it's small enough that it doesn't deserve its own bundle round.

---

## 9. Definition of done

- Question nodes show out-pins, one per choice, hover tooltip shows choice text.
- Drag from a pin shows a dashed line tracking the cursor; cursor changes to grabbing.
- Hover over a valid target node during drag highlights it; invalid targets get the danger outline.
- Hover over empty canvas during drag shows a "+ new state here" ghost label.
- Drop on empty canvas scaffolds a new state with the right trigger and id; the new node appears in the graph after layout recompute; the new state's id input gets focus in the linear pane.
- Drop on an existing node opens a confirmation popover with the current vs proposed trigger; Confirm writes the trigger and the new edge appears; Cancel does nothing.
- Escape cancels any in-flight drag.
- Drop on the source node is a no-op.
- Drop on external/terminal nodes shows a toast and aborts without writing.
- Phase 2.5: `classifyEdgeKind` returns `reachable` exactly when `findChoiceConsequences` returns the target (no false dashes at trust-meter entry).
- Round-trip on `godot/data/dialogues/halina.json` after a Phase 2 session: only the structural changes the user authored differ; no spurious diff.
- JS syntax clean on the embedded host.
- Module is still byte-portable into the bundler manifest.

---

## 10. Anti-patterns reminder

- Don't write drop coordinates to JSON. Layout is computed.
- Don't bypass `parseTrigger` / `serializeTrigger`. Hand-string-concatenating triggers is exactly how the `halina_met == true` typo got shipped.
- Don't add edge deletion in the graph view. Phase 3.
- Don't add multi-select. Phase 3.
- Don't pretend a drop creates an edge directly; the drop modifies a trigger; the edge re-derives.
- Don't introduce new dependencies. SVG + DOM events are sufficient.
- Don't introduce new colors. The pin uses `--accent`; the danger outline uses `--danger`; the popover uses the existing toast colors.
- Don't add a "preferred path" annotation. Same rule as Phase 1.

---

## 11. Paths to ship

**Path A — Claude Design implements end-to-end.** Hand them this brief plus `tools/Dialogue Editor.html`, `tools/vendor/graph-view.js`, `tools/vendor/graph-view.css`. They deliver patched files + bundle. Same round-trip as Phase 1; pay one diverge-and-merge tax if their workspace lags.

**Path B (recommended) — I implement; Claude Design only bundles.** I edit `graph-view.js`, `graph-view.css`, and the small `scaffoldTargetStateForChoice` factor in `Dialogue Editor.html` directly in this workspace. You then hand only the *result* to Claude Design with one instruction: "Re-run the bundler over the current `tools/Dialogue Editor.html`, `tools/vendor/graph-view.js`, and `tools/vendor/graph-view.css`." Their workspace can lag freely — they're not authoring, just packaging.

Path B avoids the diverge-and-merge dance we just paid for at the end of Phase 1, and the Phase 2 work is mostly logic (drag handlers, trigger amend) rather than visual exploration, which is where I'm more useful than Claude Design.
