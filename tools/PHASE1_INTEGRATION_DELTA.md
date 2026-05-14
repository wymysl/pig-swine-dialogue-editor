# Phase 1 Graph View — Integration Delta

**For:** Claude Design (second pass — integrate the existing graph module into the current editor)
**Target file:** `tools/Dialogue Editor.html` (the live editor, in its current shape with `+→`, position input, drag-to-reorder, delete, etc.)
**Inputs you already have:** `tools/vendor/graph-view.js` (the module, 33KB), `tools/vendor/graph-view.css` (the graph-related styling, ~394 lines), `tools/BRANCHING_DIALOGUE_EDITOR_BRIEF.md` (the original brief — still authoritative for everything except this delta).

The Phase 1 module is already written and verified — it boots via `window.GraphView`, owns its own SVG canvas, derives edges from the existing `findChoiceConsequences` and `computeExcludedForChoice`, and writes zero JSON. The work is to **wire it into the host editor** without losing the features in the current host.

Do **not** start from the previous standalone bundle. That bundle was built from an older snapshot of the host and is missing the `+→`, `state-position-input`, state-card drag, and delete features. Start from the current `tools/Dialogue Editor.html`.

---

## Step 1 — vendor the assets

Already done. The two files sit at:

- `tools/vendor/graph-view.js` — module that defines `window.GraphView`
- `tools/vendor/graph-view.css` — graph-related CSS rules (view-toggle, panes, divider, graph canvas, nodes, edges, search overlay, empty state)

You may either inline both into the host's existing `<style>` and `<script>` blocks (keep the host single-file) or load them via `<link rel="stylesheet">` and `<script src=…>`. Inlining is consistent with the rest of the file; up to you.

## Step 2 — add CSS

Append the contents of `tools/vendor/graph-view.css` to the host's existing `<style>` block, *before* `</style>`. The rules use CSS custom properties already defined in the host's `:root` and `body.light` (`--accent`, `--bg`, `--text`, `--divider`, `--surface-2`, `--text-2`, `--mute`, `--danger`, `--danger-soft`, `--font-ui`). No new variables required.

Rules cover:

- `.view-toggle` button group (the 3-way toggle)
- `#main` grid with `--linear-frac` / `--graph-frac` custom properties for the split
- `#split-divider` (the draggable divider, 6px wide)
- `#graph-pane` and `.graph-canvas` (the SVG host)
- `.gnode` and role-keyed selectors (`[data-role="entry"]`, etc.)
- `.gedge`, `.gedge-trust-gated`, `.gedge-excluded`, `.gedge-label`, `.gedge-delta`
- `.graph-search` overlay (the `/` search box)
- `.graph-empty` placeholder

## Step 3 — topbar HTML

Inside the existing `#topbar`, after the `Theme` button and its divider (or wherever sensibly grouped on the right), insert the view-toggle. Three buttons, each with `data-mode`:

```html
<span class="divider-v"></span>
<div class="view-toggle" role="tablist" aria-label="view mode">
  <button class="view-toggle-btn" data-mode="linear" title="linear view only" aria-label="linear">
    <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor" aria-hidden="true">
      <rect x="1" y="1.5" width="10" height="1.5" rx="0.5"/>
      <rect x="1" y="5.25" width="10" height="1.5" rx="0.5"/>
      <rect x="1" y="9" width="10" height="1.5" rx="0.5"/>
    </svg>
    <span>Linear</span>
  </button>
  <button class="view-toggle-btn" data-mode="split" title="split view: linear + graph" aria-label="split">
    <svg width="12" height="12" viewBox="0 0 12 12" fill="none" stroke="currentColor" stroke-width="1.2" aria-hidden="true">
      <rect x="1" y="1" width="4" height="10" rx="1"/>
      <rect x="7" y="1" width="4" height="10" rx="1"/>
    </svg>
    <span>Split</span>
  </button>
  <button class="view-toggle-btn" data-mode="graph" title="graph view only" aria-label="graph">
    <svg width="12" height="12" viewBox="0 0 12 12" fill="currentColor" aria-hidden="true">
      <circle cx="3" cy="2.5" r="1.4"/>
      <circle cx="9" cy="2.5" r="1.4"/>
      <circle cx="6" cy="9.5" r="1.4"/>
      <path stroke="currentColor" stroke-width="0.8" d="M3 4 L5.4 8 M9 4 L6.6 8"/>
    </svg>
    <span>Graph</span>
  </button>
</div>
```

## Step 4 — main grid HTML

The host currently has `#main` with `#sidebar` and `#content-pane`. Insert two new siblings inside `#main`, after `#content-pane`, in this order:

```html
<div id="split-divider" title="drag to resize"></div>
<div id="graph-pane"></div>
```

`#graph-pane` is empty — the module fills it on `init()`. Grid columns are driven by CSS custom properties on `#main` (`--linear-frac`, `--graph-frac`); leave them unset and the CSS defaults apply.

## Step 5 — load the module

Add a `<script src="vendor/graph-view.js"></script>` tag (or inline the JS) immediately before the host's main inline `<script>` block, so `window.GraphView` is defined when the host runs. The module is `'use strict'`-safe and side-effect-free until `GraphView.init()` is called.

## Step 6 — boot + handlers + theme + divider

At the bottom of the host's main `<script>`, after the existing boot code (the one that calls `tryAutoRestore()` or similar), add:

```js
// Initialise the graph view (idempotent — safe to call early).
if (window.GraphView && window.GraphView.init) {
  window.GraphView.init();
}

// Three-way view toggle: persisted to localStorage by the module itself.
document.querySelectorAll('.view-toggle-btn').forEach(btn => {
  btn.addEventListener('click', () => {
    if (window.GraphView && window.GraphView.setMode) {
      window.GraphView.setMode(btn.dataset.mode);
    }
  });
});

// Split divider drag — resizes the linear / graph panes only in split mode.
// Stores the split fraction to localStorage so it survives reload.
(function bindSplitDivider() {
  const divider = document.getElementById('split-divider');
  const main = document.getElementById('main');
  if (!divider || !main) return;
  let startX = 0, startLinear = 55, startGraph = 45, totalFlex = 100;
  divider.addEventListener('pointerdown', (e) => {
    if (!main.classList.contains('view-split')) return;
    startX = e.clientX;
    startLinear = parseFloat(main.style.getPropertyValue('--linear-frac')) || 55;
    startGraph = parseFloat(main.style.getPropertyValue('--graph-frac')) || 45;
    totalFlex = startLinear + startGraph;
    document.body.classList.add('is-resizing');
    divider.classList.add('dragging');
    divider.setPointerCapture(e.pointerId);
  });
  divider.addEventListener('pointermove', (e) => {
    if (!divider.classList.contains('dragging')) return;
    const rect = main.getBoundingClientRect();
    const sidebarW = 268; const dividerW = 6;
    const availW = rect.width - sidebarW - dividerW;
    const dx = e.clientX - startX;
    const newLinearPx = (startLinear / totalFlex) * availW + dx;
    const minPx = 220;
    const clamped = Math.max(minPx, Math.min(availW - minPx, newLinearPx));
    const newLinear = (clamped / availW) * totalFlex;
    main.style.setProperty('--linear-frac', String(newLinear));
    main.style.setProperty('--graph-frac', String(totalFlex - newLinear));
  });
  divider.addEventListener('pointerup', (e) => {
    divider.classList.remove('dragging');
    document.body.classList.remove('is-resizing');
    try { divider.releasePointerCapture(e.pointerId); } catch (_) {}
    try {
      const lf = main.style.getPropertyValue('--linear-frac');
      const gf = main.style.getPropertyValue('--graph-frac');
      if (lf && gf) localStorage.setItem('dialogue_editor_split_frac', lf + '|' + gf);
    } catch (_) {}
  });
  try {
    const stored = localStorage.getItem('dialogue_editor_split_frac');
    if (stored && stored.includes('|')) {
      const [lf, gf] = stored.split('|');
      main.style.setProperty('--linear-frac', lf);
      main.style.setProperty('--graph-frac', gf);
    }
  } catch (_) {}
})();

// Helper called from every structural mutation of json.states.
function notifyGraphStructuralChange() {
  if (window.GraphView && window.GraphView.recompute) window.GraphView.recompute();
}
```

In the host's existing `applyTheme(mode)` function (the one toggling `body.classList`), add one line at the bottom:

```js
if (window.GraphView && window.GraphView.onThemeChange) window.GraphView.onThemeChange();
```

## Step 7 — structural-change touchpoints

Call `notifyGraphStructuralChange()` after every mutation of `json.states` or any state's `trigger`, options, or on_dismiss block. The module debounces, so calling it eagerly is fine. Specific places in the current host where you must add the call:

| Function | After… |
|---|---|
| `selectFile(name)` | after `renderContent()` |
| `rebuildStates(focusIdx)` (inside `renderContent`) | after the `forEach` that appends state cards |
| `renderState`'s id input handler | on `change` AND `blur` (rename can affect edge endpoints) |
| `renderState`'s `+↑ insert above` click | after the splice |
| `renderState`'s `✕ delete` click | after the splice |
| `renderState`'s drag-drop reorder | after the splice |
| `renderState`'s position-input commit | after the splice |
| `renderConditionsEditor`'s trigger commit (`commitTrigger`) | after `markDirty()` |
| `renderConditionsEditor`'s on_dismiss commit | after `markDirty()` |
| `renderChoiceRow`'s value-input commit, text commit, trust_delta commit | after the in-place `refreshConsequences()` already there |
| `renderChoiceRow`'s `+→ create target state` click | after the splice that inserts the new state |
| `renderChoiceRow`'s `+↑ insert above`, `✕ delete`, drag-drop | after each splice |
| `togglePinnedConsequence` | after `syncPinnedBadges()` |
| `clearAllPinnedConsequences` | after `clearConsequenceHighlight()` |

It is *not* needed for pure text edits inside a line textarea — those don't change the dialogue graph. Don't fire it per-keystroke; the graph layout flicker would be distracting.

## Step 8 — node-click → linear pane

In `renderState`, when the user clicks a state card (or the state-id-input gains focus), call:

```js
if (window.GraphView && window.GraphView.selectStateId) {
  window.GraphView.selectStateId(state.id, { pan: true });
}
```

The module flashes the corresponding node and pans it into view. The reverse direction (click node in graph → scroll linear) is handled inside the module — no host code needed.

## Step 9 — verify

Definition of done is unchanged from §14 of the original brief. Two additional checks specific to this re-integration:

1. **No feature regression.** Confirm that after merging, the current host's features all still work: `+→`, numeric position input on each state, state drag-to-reorder, state delete (`✕`), the once toggle, choice editor with trust_delta + drag + delete. Grep for `state-position-input`, `createTargetBtn`, `+↑`, `dragend`, and `removeBtn` — counts should be at least what they were before.

2. **No silent JSON writes from graph.** Open a sample file (`godot/data/dialogues/halina.json`), enter graph mode, click around, pan, zoom, select nodes, open and close the `/` search. Save. Run `node tools/verify_dialogue_roundtrip.js godot/data/dialogues/halina.json`. The "Triggers parsed" / "Mismatches: 0" line is still the green signal.

## Step 10 — bundle decision

If the deliverable is again a self-extracting standalone bundle (à la `Dialogue Editor (standalone).html`), use the *current* `tools/Dialogue Editor.html` as the input to the bundler this time, not the previous one. The two vendor files (`graph-view.js`, `graph-view.css`) can stay as a manifest entry referenced by `<script src>` and `<link rel>` if the bundler prefers that, or be inlined into the host's existing `<style>` and `<script>` blocks. Either is fine; inlining is slightly smaller and removes a manifest entry.

## Anti-patterns reminder (same as the brief)

Don't render an edge `findChoiceConsequences` doesn't produce. Don't store layout positions in JSON. Don't auto-layout while dragging a node. Don't add "preferred path" annotations that only live in the graph. Don't introduce new colors. Don't load other dialogue files into the graph view in Phase 1. Don't pull in any new dependency — the layered layout already implemented in `graph-view.js` is the layout algorithm.

---

## Open deviation logged

The graph module's `classifyEdgeKind` is conservative-only: it dashes an edge when `choice.trust_delta < threshold` using the choice's Δ alone. The brief asked for parity with the linear editor's full trust-precision logic (which exact-matches at the trust-meter entry state via `isFirstStateUsingTrustPath`). The deviation is safe (never claims false reachability), but it means the graph shows more dashed edges than the linear-pane consequence highlight shows non-green. Acceptable for Phase 1; consider tightening when the integration lands.
