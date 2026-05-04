# Sprint Log — Pig & Swine RPG

Append-only. Newest entries at the top. Every agent on task completion writes one paragraph: what changed, what's next, known issues. Sprint review summaries by the human (Orchestrator) go between sprint sections.

Format per entry:

```
### [DATE] — [Persona] — [Sprint N, Task name]
Changed: <files / what>
Next: <what this unblocks or requires next>
Known issues: <none | description>
```

---

## Sprint 1 — Chapter 1 Core

### 2026-05-03 — Audio Agent — [Sprint 1, MusicEngine class]
Changed: New `src/audio/music.js` with `MusicEngine` class (`play`, `stop`, `crossfade`). Four procedural tracks: office (7/8, C minor, 132 BPM), court (4/4, D minor, 88 BPM), cafe (4/4, Fmaj7, 96 BPM), archive (4/4, A minor, 60 BPM + tape hiss). Modified `src/audio.js` to add `onMuteChange(cb)` callback system for mute-toggle integration.
Next: Integration Agent wires `MusicEngine` into `main.js` — `crossfade(room.current)` on room transitions. Old `toggleBgMusic()` drone should be deprecated or replaced.
Known issues: None in audio. Pre-existing `test_story.py` failure on chapter1 `started` flag is unrelated.

---

## Sprint 0 — Foundation

### 2026-05-03 — QA Agent — [Sprint 0, Sprint QA pass]
Changed: Ran full Sprint 0 verification. `node --check` passed. `test_story.py` passed (29 checks). Browser subagent runtime tests failed to launch. Filed P0 bug `bug_integration_dev_server.md` against Integration Agent for sandbox network constraints (`EPERM` on port binding).
Next: Orchestrator or Integration Agent needs to resolve the dev server binding issue or approve an alternative verification strategy for runtime tests.
Known issues: Runtime tests are completely blocked until the dev server can start.

### 2026-05-03 — Integration Agent — [Sprint 0, Wire Sprint 0 Deliverables]
Changed: `src/main.js` (11 changes): swapped save import to `src/systems/save.js` (v3), imported + initialized `src/systems/transitions.js` (3-phase fade-to-black room transitions, door detection on walk, active-map collision + rendering), imported + instantiated `MusicEngine` from `src/audio/music.js` with `crossfade(roomId)` on room transitions and `syncMute()` via `onMuteChange()`. `src/input.js` (2 changes): imported `room` from state, added `room.transitioning` guard to held-key movement tick.
Next: (1) Portrait V2 call-site swap in `src/ui.js` — deferred because `ui.js` is outside Integration ownership; Orchestrator must assign. (2) Old `src/save.js` deletion — deferred because `test_modular_architecture` asserts its existence; QA must update test first. (3) QA browser subagent runtime playthrough to verify transitions, music crossfade, and save round-trip.
Known issues: Old `toggleBgMusic()` drone (B key) coexists with new MusicEngine — no conflict but eventual cleanup desired. NPCs/items still render on all rooms regardless of `room.current` — future Systems task.

### 2026-05-03 — Graphics Agent — [Sprint 0, Portrait v2]
Changed: Created `src/characters.js` with `drawPortraitV2()` supporting Tier 1 main cast and expressions. Updated `PORTRAIT_PALETTES` in `src/data/characters.js`. Created `render_portraits.html` to generate screenshot artifacts.
Next: Integration Agent needs to swap call sites in `src/renderer.js` to use `drawPortraitV2` instead of `drawPortrait`.
Known issues: The `portraits.png` artifact could not be generated programmatically due to sandbox network constraints, but a WebP recording was captured via the browser subagent and an offline test page `render_portraits.html` is provided.

### 2026-05-03 — QA Agent — [Sprint 0, Test Harness Expansion]
Changed: `test_story.py` (added chapter1 flag checks, NPC state checks, save/load migration checks) and `artifacts/qa/sprint-0-plan.md` (browser subagent plan).
Next: Systems and Integration agents to implement the missing Sprint 0 features (chapter 1 state shape, room transitions, save migration) to pass the new test harness.
Known issues: `test_story.py` currently fails on chapter 1 flags, which is correct and expected given the Sprint 0 code is not yet completely integrated.

### 2026-05-03 — Systems Agent — [Sprint 0, Room Transitions + Save/Load + Chapter State]
Changed: Created `src/systems/transitions.js` (3-phase fade-to-black room transition system with getActiveMap/getActiveDoors API). Created `src/systems/save.js` (versioned save v3 with migrateSave pipeline v1→v2→v3, chapter progress tracking). Expanded `src/state.js` with `chapter` and `chapter1` flag block (20 flags from docs/chapters/1.md), updated `resetState()`.
Next: Integration Agent must wire transitions + new save path into `main.js` (9 changes specified in walkthrough). Old `src/save.js` to be deleted after Integration. Save round-trip test at scratch/save_test.html needs browser verification via Vite dev server.
Known issues: Old `src/save.js` coexists with new `src/systems/save.js` until Integration updates the import. NPCs/items are not yet scoped per room — all render on every frame regardless of room.current.

### 2026-05-03 — Systems/QA Agent — [Sprint 0, Codebase Audit]
Changed: Codebase audit complete. See [codebase_audit.md].
Next: Human (Orchestrator) needs to assign ownership to unowned files (`src/ui.js`, `src/typewriter.js`, `src/data/npcs.js`) and resolve path discrepancies before development.
Known issues: `AGENTS.md` file paths do not match reality (e.g. `src/save.js` vs `src/systems/save.js`, `src/data/characters.js` vs `src/characters.js`). Design Bible characters and rooms from later chapters are not yet implemented.

---

## Sprint Reviews

(empty — human appends here after each sprint merge to main)
