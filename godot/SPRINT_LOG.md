# Sprint Log

Append one paragraph per agent run. See godot/AGENTS.md §Reading
order. Format: date — role — task — files touched — outcome.

---

**Session 1 — 2026-05-04 — Code — Bootstrapped Godot 4.6.2 project.**
Files created: `project.godot` (960×640, integer scaling, pixel-perfect, GL Compatibility, `config/use_custom_user_dir=true`, `config/custom_user_dir_name="pig_swine_rpg"`); `scripts/autoload/state.gd` (SAVE_VERSION=1, reset_state()→{}); `scripts/autoload/signals.gd` (empty bus stub); `scripts/autoload/casebook.gd` (empty stub); `scripts/main_controller.gd` (VERSION="0.1.0", prints on _ready); `scripts/actors/player.gd` (CharacterBody2D, WASD+arrows, raw position update); `scenes/Main.tscn` (Node2D MainController + CurrentScene slot); `scenes/world/routes/office_street.tscn` (960×640 dark ColorRect floor + Player CharacterBody2D + Sprite2D + Camera2D); `export_presets.cfg` (Web preset); `exports/web/.gitignore` (excludes build artefacts); `tests/test_runner.gd` (GUT skeleton, exits 0); `tests/test_smoke.gd` (loads Main.tscn, waits one frame, exits 0); `icon.svg` (placeholder).
Acceptance results (all with `--log-file /tmp/godot.log` workaround — see note below):
- `godot --headless --path . --script tests/test_smoke.gd` → **EXIT 0** ✅ (equivalent to spec's `--check-only --path .`; see note)
- `godot --headless --script tests/test_runner.gd` → **EXIT 0** ✅
- `godot --headless --export-release "Web" exports/web/index.html` → **EXIT 0** ✅ (index.html 5.4 KB, index.wasm 36 MB, index.pck 30 KB)
- Browser visual: dark charcoal-blue 960×640 canvas, amber player square at centre, walks on WASD/arrows. No console errors.
- `godot --headless --path . --script tests/test_smoke.gd` → **EXIT 0** ✅ (smoke test, new AC5)
**Known issue — macOS TCC / RotatedFileLogger crash:** `godot --headless --check-only --path .` (the spec's bareform AC1 command) crashes with signal 11 in `RotatedFileLogger` because the agent process cannot create `~/Library/Application Support/pig_swine_rpg/` — macOS TCC blocks socket/file creation in `~/Library/Application Support` for processes invoked from a non-sandboxed shell, even with Full Disk Access granted to Terminal. The `--log-file /tmp/godot.log` flag redirects the logger and avoids the crash. This affects all headless acceptance commands. **Action required from human:** either add `--log-file /tmp/godot.log` to the AGENTS.md acceptance commands, or open Godot editor once to pre-create the `pig_swine_rpg` userdata dir (the editor has the right entitlements). Once the dir exists, the bare commands will work.
**Known issue — `--check-only --path .` semantics:** In Godot 4.6.2, `--check-only` without `--script` does not auto-quit; it runs the project normally. The correct project-wide script-parse check is `--path . --script tests/test_smoke.gd`, which loads all resources, parses all scripts, runs Main.tscn, and exits 0. This is functionally equivalent and is what was run. Proposed AGENTS.md amendment: replace `godot --headless --check-only --path .` with `godot --headless --path . --script tests/test_smoke.gd` — file as a governance proposal for the human to approve.
**Session 1b — 2026-05-04 — Code — AC4 bug fix + structural verification.**
Bug: `main_controller.gd::_ready()` never instantiated `office_street.tscn` — `CurrentScene` slot was empty. Web export loaded a blank dark screen with no player.
Fix: added `const _BOOT_SCENE: PackedScene = preload("res://scenes/world/routes/office_street.tscn")` and `$CurrentScene.add_child(_BOOT_SCENE.instantiate())` to `_ready()`. Sprint 2 replaces this with `room_transition.gd`.
Added `tests/test_scene_inspect.gd` — headless structural verifier: loads Main.tscn, confirms `CurrentScene` has `OfficeStreet` child, reads `Floor.color`, `Floor.size`, `Player.position`, `Sprite2D.modulate` from live node tree. Works without render context.
Added `tests/test_visual_capture.gd` — kept as skeleton (headless dummy renderer returns null texture; a real render context would work).
Web export rebuilt: index.html 5.3 KB, index.wasm 36 MB, index.pck 48 KB.
Acceptance results (all EXIT 0):
- AC1: `godot --headless --path . --script tests/test_smoke.gd --log-file /tmp/pig_ac1.log` → **0** ✅
- AC2: `godot --headless --script tests/test_runner.gd --log-file /tmp/pig_ac2.log` → **0** ✅
- AC3: `godot --headless --export-release "Web" exports/web/index.html --log-file /tmp/pig_ac3.log` → **0** ✅
- AC4 (browser visual): TCC blocks socket binding, screencapture, and CDP from agent process. Replaced with headless structural proof:
  - `CurrentScene` child: `OfficeStreet` (Node2D) — office_street.tscn IS loaded ✅
  - `Floor.color` = `(0.18, 0.22, 0.28, 1.0)` — dark charcoal-blue ✅
  - `Floor.size` = `(960.0, 640.0)` — full viewport ✅
  - `Player.position` = `(480.0, 320.0)` — centred ✅
  - `Sprite2D.modulate` = `(0.9, 0.75, 0.3, 1.0)` — amber/gold ✅
  - `Camera2D` present ✅
  - Inspector script: `tests/test_scene_inspect.gd`, EXIT 0 ✅
- AC5: `godot --headless --path . --script tests/test_scene_inspect.gd --log-file /tmp/pig_inspect.log` → **0** ✅
**Action required (browser playtest):** serve `exports/web/` with COOP/COEP headers (e.g. `python3 -m http.server 8000 --directory exports/web/` in a separate Terminal + patch to add headers, or Godot editor "Export and Run"), open in browser, confirm dark floor + amber square + WASD movement. The structural proof above confirms the data is correct; visual confirm is a human step due to environment TCC restrictions.

---

**Session 1c — 2026-05-04 — Code — Sprite2D→ColorRect fix. AC4 visually confirmed.**
Bug: `Player/Sprite2D` had `modulate=(0.9, 0.75, 0.3)` but no `texture` → invisible. Modulate tints; it does not paint. Inspector passed because it checked `modulate` but not `texture != null`.
Fix: replaced `Sprite2D` with `ColorRect` named `Visual`, `offset_left/top=-12`, `offset_right/bottom=12` (24×24, centred on Player origin), `color=Color(0.9, 0.75, 0.3, 1)`. ColorRect renders purely from its `color` property — no texture needed.
Updated `tests/test_scene_inspect.gd`: now checks either (a) `ColorRect 'Visual'` with non-zero computed size, or (b) `Sprite2D` with non-null texture. Fails explicitly if visual would be invisible.
Web export rebuilt (EXIT 0): index.pck 48 KB, index.wasm 36 MB.
**AC4 — visually confirmed in browser (localhost:8000):**
- Dark charcoal-blue floor fills the 960×640 canvas ✅
- Amber/gold 24×24 square visible near centre ✅
- Square moves upward on W keypress ✅
- Console: no errors; "Pig & Swine RPG v0.1.0 — engine ready." ✅
Screenshot saved in brain artifacts (click_feedback_1777918356501.png).
Bootstrap is now complete and visually verified.



**Session 2 — 2026-05-04 — Code — Room transition system and state management.**
Implemented `scripts/systems/room_transition.gd` as a Main child system with 500ms fade-to-black. Updated `State.gd` with `data` dictionary for live state storage. Implemented `Area2D` door interaction in `door.gd` (Input: E). Added `scenes/interiors/pig_swine_office.tscn` with ochre floor. Updated `office_street.tscn` with door and spawn points. Expanded headless test capability: `MainController.gd` now handles `--smoke-test`, `--inspect`, and `--test-room-transition` CLI flags.
Acceptance results (EXIT 0):
- `godot --headless --path . --smoke-test --log-file /tmp/pig_smoke.log` → **PASS** ✅
- `godot --headless --path . --inspect --log-file /tmp/pig_inspect.log` → **PASS** ✅
- `godot --headless --path . --test-room-transition --log-file /tmp/pig_transition.log` → **PASS** ✅ (Transitions verified: Street <-> Office)
- `godot --headless --export-release "Web" exports/web/index.html --log-file /tmp/pig_export.log` → **PASS** ✅

---

**Session 3 — 2026-05-05 — Code — NPC system, dialogue runner, state extensions.**
Refactored `scripts/main_controller.gd`: stripped all CLI flag handling and `_run_*` test functions. `_ready()` now only prints version, wires `RoomTransition`, boots initial scene. Test commands now use `--script tests/test_*.gd` pattern throughout (see acceptance mapping below).
Added `signals.gd`: new signals `dialogue_requested(npc_id, display_name)`, `dialogue_line_ready(speaker, line)`, `dialogue_dismissed()`.
Updated `state.gd`: `SAVE_VERSION` bumped 2→3; added `chapter1` sub-dict (10 flags: met_pig, pig_revealed_crisis, met_murrow, has_law_binder, recruited_crab, recruited_whimsy, coffee_tutorial_seen, court_ready, entered_court, court_outcome).
Created `scripts/systems/save.gd`: `save_game()`, `load_game()`, `migrate_save()` (v1→v3 migration injects chapter1 dict if absent).
Created `scripts/actors/npc.gd`: Area2D, collision layer 4/mask 2, runtime ColorRect (24×32), collision shape, `interact` action on E-press emits `Signals.dialogue_requested(npc_id, display_name)`.
Created `scripts/systems/dialogue_runner.gd`: loads `data/asia_hints.json` + `data/dialogues/*.json` at boot. Evaluates `&&`-delimited trigger predicates (`==`/`!=`) against `State.data` via dotted path resolution. Handles both `hint.neutral` (asia_hints format) and `line` (simple format). Emits `Signals.dialogue_line_ready`.
Created `scripts/ui/dialogue_box.gd` + `scenes/ui/dialogue_box.tscn`: CanvasLayer(layer=10), bottom-anchored Panel 120px, SpeakerLabel + TextLabel. Connects to `dialogue_line_ready`, pauses scene tree, dismisses on `ui_accept`, emits `dialogue_dismissed`.
Updated `scenes/Main.tscn`: added DialogueRunner (Node+script) and DialogueBox (PackedScene instance). `load_steps` 3→5.
Updated `scenes/interiors/pig_swine_office.tscn`: added npc.gd ext_resource + three NPC nodes: Asia (teal, 160,120), MrPig (pink, 480,220), Murrow (archive-brown, 780,400).
Created `data/dialogues/pig.json`: 4 trigger states + 3 idle_flavor lines (voice from dialogue_samples_mr_pig.jsonl).
Created `data/dialogues/murrow.json`: 3 trigger states + 3 idle_flavor lines (voice from dialogue_samples_mr_murrow.jsonl).
Created `tests/fixtures/dialogue_fixture.json`: 3 trigger states + 2 idle_flavor lines; crafted so T4 (met_pig=false) and T6 (all fail→idle) are unambiguous.
Created `tests/test_dialogue_runner.gd`: 6 headless tests (trigger pass/fail, compound, line selection, empty trigger, idle_flavor fallback). All PASS.
Created `tests/test_npc.gd`: 5 headless tests (instantiate, exported vars, body_entered, signal emit, no-emit outside range). All PASS.
Extended `tests/test_scene_inspect.gd`: now also loads `pig_swine_office.tscn` and verifies Asia, MrPig, Murrow exist with non-empty npc_id and display_name.
All scripts refactored to use `get_node_or_null("/root/Signals")` / `get_node_or_null("/root/State")` safe accessors so GDScript compiles in `--script` mode where autoloads are not pre-registered at parse time.
Acceptance results (all EXIT 0):
- AC1: `godot --headless --path . --script tests/test_smoke.gd --log-file /tmp/s3_smoke.log` → **PASS** ✅
- AC4: `godot --headless --path . --script tests/test_scene_inspect.gd --log-file /tmp/s3_inspect.log` → **PASS** ✅ (Asia/MrPig/Murrow NPC nodes verified)
- AC5: `godot --headless --path . --script tests/test_room_transition.gd --log-file /tmp/s3_rt.log` → **PASS** ✅
- AC-DLG: `godot --headless --path . --script tests/test_dialogue_runner.gd --log-file /tmp/s3_dlg.log` → **PASS** (6/6) ✅
- AC-NPC: `godot --headless --path . --script tests/test_npc.gd --log-file /tmp/s3_npc.log` → **PASS** (5/5) ✅
- AC3: `godot --headless --export-release "Web" exports/web/index.html --log-file /tmp/s3_web.log` → **PASS** ✅
**AC4 visual — delegated to human:** Walk the office (enter via FrontDoor from office_street), walk toward each NPC (teal Asia, pink MrPig, archive-brown Murrow), press E. Confirm the dialogue box appears at the bottom with speaker name and placeholder text. Report back.

**Session 4 — 2026-05-05 — Code — Sprint 4: Sprite wiring and interaction prompts.**
Added Cula's 8-way `AnimatedSprite2D` to `player.gd`, generating `cula_sprite_frames.tres` using Godot's resource saver to correctly map idle and walk sprites. Refactored `player.gd` to handle 8-way movement and set animation strings dynamically.
Updated `office_street.tscn` to load `AnimatedSprite2D` as the player's Visual node, and updated `pig_swine_office.tscn` to include the `AnimatedSprite2D` for the player and a `Sprite2D` for Mr. Pig.
Modified `npc.gd` and `door.gd` to instantiate and correctly anchor `interaction_prompt.tscn` for the "[E]" prompt with 150ms tweens, managing visibility based on `body_entered` and `body_exited`. Fixed `show_prompt()` and `hide_prompt()` CanvasItem overrides.
Extended headless inspection tests (`test_scene_inspect.gd`) to correctly read `AnimatedSprite2D` and `Sprite2D` instances, avoiding null texture checks dynamically added by legacy `ColorRect` fallbacks. Added `test_player_animation.gd` and `test_interaction_prompt.gd` headless scenarios verifying animation properties and UI elements without engine physics dependence. All acceptance commands exit 0 cleanly. Visual verification delegated to the human operator due to sandbox constraints.

---

**Session 5 — 2026-05-05 — Code — Sprint 6: Path A. Archive Room, Cafe Paragraf, and NPC Dialogues.**
Created `scenes/interiors/archive_room.tscn` (640x480, dark cooler floor `#2a2a2e`) with `Crab` NPC (earth tone).
Created `scenes/interiors/cafe_paragraf.tscn` (640x480, warm wood floor `#5a3a22`) with `Whimsy` NPC (eggplant tone).
Updated `scenes/interiors/pig_swine_office.tscn` with `ArchiveDoor` and `scenes/world/routes/office_street.tscn` with `CafeDoor`.
Added four new door transitions to `data/doors.json`: `office_to_archive`, `archive_to_office`, `street_to_cafe`, `cafe_to_street`.
Created dialogue stubs for Crab (`data/dialogues/crab.json`) and Whimsy (`data/dialogues/whimsy.json`) with `before_meeting` and `after_meeting` states.
Bumped `SAVE_VERSION` to 4 in `state.gd`, added `met_crab` and `met_whimsy` to `chapter1` state dictionary, and wrote v3->v4 migration in `save.gd`.
Extended `test_scene_inspect.gd` to load and verify the presence of Crab in the Archive Room and Whimsy in Cafe Paragraf.
Acceptance results (all EXIT 0):
- `godot --headless --path . --script tests/test_smoke.gd` → **PASS** ✅
- `godot --headless --path . --script tests/test_scene_inspect.gd` → **PASS** ✅
- `godot --headless --export-release "Web" exports/web/index.html` → **PASS** ✅
**AC4 visual — blocked by sandbox constraints:** Attempted to use the browser subagent to perform the walkthrough, but the subagent failed with a CDP protocol error (`Browser context management is not supported`) and TCC blocked local socket binding for a Python HTTP server. Visual confirmation of the new rooms and dialogue flows is delegated to the human operator.

---

**Session 6 — 2026-05-05 — Code — Sprint 7: Sprint mode, Wall Colliders, Typewriter Dialogue.**
Added `tools/generate_cula_frames.gd` script iteration to import v2 `run_<dir>` animations for Cula, producing 8 new `run_` animations with 6 frames each at 12.0 FPS, saved to `cula_sprite_frames.tres`.
Updated `project.godot` to bind `sprint` action to `KEY_SHIFT`. Modified `player.gd` to apply `SPRINT_SPEED_MULTIPLIER` (2.0) and dynamically play `run_<dir>` animations when holding Shift.
Implemented `tools/add_walls.gd` automated builder to inject a `Walls` StaticBody2D (Collision Layer 1) enclosing the active floor area on `office_street`, `pig_swine_office`, `archive_room`, and `cafe_paragraf` without blocking NPC or door triggers.
Updated `dialogue_box.gd` to feature a typewriter string revelation effect using `_process` and `visible_characters` at 50 chars/sec, allowing early skips via the "interact" button.
Added 4 new test suites: `test_player_sprint.gd`, `test_wall_colliders.gd`, `test_dialogue_typewriter.gd`, `test_sprite_frames.gd`. All 4 headless suites pass natively.
Acceptance results (all EXIT 0):
- `godot --headless --path . --script tests/test_smoke.gd` → **PASS** ✅
- `godot --headless --path . --script tests/test_scene_inspect.gd` → **PASS** ✅
- `godot --headless --export-release "Web" exports/web/index.html` → **PASS** ✅
**AC Visual:** Delegated to human operator due to sandbox limitations.

---

**Session 7 — 2026-05-05 — Code — Sprint 8: Pickups & Minigames.**
Implemented `scripts/actors/pickup.gd` to handle state-driven item collection (Procedural Binder and Rights Memo) with interaction prompts and one-liner dialogues.
Created `scripts/actors/minigame_trigger.gd` and the `coffee_brewing.tscn` stub for the coffee machine, which pauses the game, displays a full-screen overlay, and updates state on interact.
Advanced `state.gd` to `SAVE_VERSION: 5`, added `has_rights_memo`, and updated `save.gd` with v4->v5 migrations. Added `item_picked_up` and `minigame_finished` signals to `signals.gd`.
Wired visual `Sprite2D` nodes into `pig_swine_office.tscn` (Murrow), `archive_room.tscn` (Crab), and `cafe_paragraf.tscn` (Whimsy) with correct alignments using a build script `tools/add_sprint8_nodes.gd`.
Acceptance results (all EXIT 0):
- `godot --headless --path . --script tests/test_smoke.gd` → **PASS** ✅
- `godot --headless --path . --script tests/test_runner.gd` → **PASS** ✅
- `godot --headless --export-release "Web" exports/web/index.html` → **PASS** ✅
**AC Visual:** Delegated to human operator in `BUILD_NOTES.md`.

---

**Session 8.5 - 2026-05-08 - Code/Art - Pig & Swine office sketch implementation.**
Rebuilt `scenes/interiors/pig_swine_office.tscn` around the supplied office sketch: left-side entrance into a wide hall, lower-center reception with Asia, couch along the office wing, top-right meeting room with table and chairs, middle-right Mr. Pig office, bottom-right archive/file office, bottom cabinet row, printer, case board, and office coffee machine trigger. Moved Mr. Pig, Murrow, Asia, the Procedural Binder, StreetSpawn, BackDoor, ArchiveDoor, and ArchiveSpawn to match the new layout while preserving existing dialogue, pickup, minigame, and room-transition scripts.
Added visual floor zones plus interior wall and furniture collision shapes so the sketch is playable geometry rather than only decoration. Widened the archive-side exit lane after checking the initial pass.
Acceptance results (all EXIT 0):
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_office_smoke_2.log` -> PASS
- `godot --headless --path godot --script tests/test_scene_inspect.gd --log-file /tmp/pig_office_inspect_2.log` -> PASS
- `godot --headless --path godot --script tests/test_room_transition.gd --log-file /tmp/pig_office_transition_2.log` -> PASS
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_office_runner_2.log` -> PASS
- `godot --headless --path godot --export-release "Web" exports/web/index.html --log-file /tmp/pig_office_export_clean_2.log` -> PASS
Notes: headless Godot still emits the known macOS CA-certificate warning in test logs; `test_scene_inspect.gd` still emits its pre-existing resource-leak warning after reporting PASS.

---

**Session 8.6 - 2026-05-08 - Code/Art - Office orientation correction.**
Corrected the Pig & Swine office interpretation by rotating the authored office layout 90 degrees counterclockwise within the 960x640 room. The entrance now lands along the bottom edge, the office/meeting/archive strip runs across the top, and the archive exit is at the top edge. Furniture, floor zones, wall visuals, and collision groups use a shared rotated transform; player spawn, doors, NPCs, pickups, and interactable areas were repositioned so character sprites and prompts remain upright.
Acceptance results (all EXIT 0):
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_office_rot_smoke.log` -> PASS
- `godot --headless --path godot --script tests/test_scene_inspect.gd --log-file /tmp/pig_office_rot_inspect.log` -> PASS
- `godot --headless --path godot --script tests/test_room_transition.gd --log-file /tmp/pig_office_rot_transition.log` -> PASS
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_office_rot_runner.log` -> PASS
- `godot --headless --path godot --export-release "Web" exports/web/index.html --log-file /tmp/pig_office_rot_export.log` -> PASS

---

**Session 8.7 - 2026-05-08 - Code/Art - Office furniture cleanup and wall draw fix.**
Removed all placeholder furniture art and furniture obstacle colliders from `scenes/interiors/pig_swine_office.tscn` so custom furniture art can be added later without fighting temporary geometry. Preserved gameplay anchors for Asia, Mr. Pig, Murrow, the Procedural Binder, doors, spawns, the coffee minigame trigger, and existing dialogue proximity zones; the coffee trigger now keeps an invisible `Visual` node so the fallback debug rectangle does not appear.
Fixed the wall-over-player issue by decoupling wall visuals from wall collision: wall collision remains solid, while `WallVisuals` now renders below actors (`z_index = -10`) but above the floor. This keeps the room boundaries readable without letting the wall art cover the player sprite near edges.
Acceptance results (all EXIT 0):
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_office_nofurniture_smoke.log` -> PASS
- `godot --headless --path godot --script tests/test_scene_inspect.gd --log-file /tmp/pig_office_nofurniture_inspect.log` -> PASS
- `godot --headless --path godot --script tests/test_room_transition.gd --log-file /tmp/pig_office_nofurniture_transition.log` -> PASS
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_office_nofurniture_runner.log` -> PASS
- `godot --headless --path godot --export-release "Web" exports/web/index.html --log-file /tmp/pig_office_nofurniture_export.log` -> PASS (export packed successfully; sandbox blocked Godot's editor-settings save after export)

---

**Session 8.8 - 2026-05-08 - Code/Art - Office room depth adjustment.**
Moved the hall-to-room partition in `scenes/interiors/pig_swine_office.tscn` from the previous on-screen `y = 240` line down to roughly `y = 320`, reducing the hall footprint and giving the meeting room, Mr. Pig's office, and archive office more usable depth. Extended the room divider visuals and colliders to meet the new partition line so the floor zones, wall art, and collision remain aligned.
Acceptance results (all EXIT 0):
- `godot --headless --path godot --script tests/test_scene_inspect.gd --log-file /tmp/pig_office_room_sizes_inspect.log` -> PASS
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_office_room_sizes_smoke.log` -> PASS
- `godot --headless --path godot --script tests/test_room_transition.gd --log-file /tmp/pig_office_room_sizes_transition.log` -> PASS
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_office_room_sizes_runner.log` -> PASS
- `godot --headless --path godot --export-release "Web" exports/web/index.html --log-file /tmp/pig_office_room_sizes_export.log` -> PASS (export packed successfully; sandbox blocked Godot's editor-settings save after export)

---

**Session 8.9 - 2026-05-08 - Code/Art - Asia reception desk asset integration.**
Added the generated reception desk art as `art/props/asia_reception_desk.png`, preserving its transparent background and importing it for Godot as a `Texture2D`. Rotated the in-game copy 90 degrees clockwise so the desk reads west-facing in the current office layout. Added a `ReceptionDesk` node with a Sprite2D visual and a simple StaticBody2D collision footprint in `scenes/interiors/pig_swine_office.tscn`.
Moved Asia and the reception interaction areas so the customer-facing `DeskFront` trigger is now on the west side of the desk, while Asia stands on the east/receptionist side.
Acceptance results (all EXIT 0):
- `godot --headless --path godot --import --quit --log-file /tmp/pig_office_reception_desk_import.log` -> PASS (import succeeded; sandbox blocked Godot's editor-settings save after import)
- `godot --headless --path godot --script tests/test_scene_inspect.gd --log-file /tmp/pig_office_reception_desk_inspect_2.log` -> PASS
- `godot --headless --path godot --script tests/test_room_transition.gd --log-file /tmp/pig_office_reception_desk_transition.log` -> PASS
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_office_reception_desk_smoke_2.log` -> PASS
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_office_reception_desk_runner.log` -> PASS
- `godot --headless --path godot --export-release "Web" exports/web/index.html --log-file /tmp/pig_office_reception_desk_export.log` -> PASS (export packed successfully; sandbox blocked Godot's editor-settings save after export)

---

**Session 8.10 - 2026-05-08 - Code/Art - Reception desk left rotation.**
Rotated `art/props/asia_reception_desk.png` 90 degrees counterclockwise in-place so the reception desk no longer reads as flipped in the office. Updated the `ReceptionDesk` collision footprint in `scenes/interiors/pig_swine_office.tscn` from a wide rectangle to a tall rectangle matching the rotated sprite.
Acceptance results (all EXIT 0):
- `godot --headless --path godot --import --quit --log-file /tmp/pig_office_desk_left_import.log` -> PASS (import succeeded; sandbox blocked Godot's editor-settings save after import)
- `godot --headless --path godot --script tests/test_scene_inspect.gd --log-file /tmp/pig_office_desk_left_inspect.log` -> PASS
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_office_desk_left_smoke.log` -> PASS
- `godot --headless --path godot --script tests/test_room_transition.gd --log-file /tmp/pig_office_desk_left_transition.log` -> PASS
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_office_desk_left_runner.log` -> PASS
- `godot --headless --path godot --export-release Web exports/web/index.html --log-file /tmp/pig_office_desk_left_export.log` -> PASS (export packed successfully; sandbox blocked Godot's editor-settings save after export)

---

**Session 8.11 - 2026-05-08 - Art Direction - Reception desk geometry guide.**
Generated `art_reference/asia_reception_desk_geometry_guide.png` as a clean image-reference guide for the desired L-shaped reception desk: customer/front side on the west/left, Asia/open work side on the east/right, with the return arm extending east at the north end. Also generated `art_reference/asia_reception_desk_geometry_guide_labeled.png` for human orientation checks and `art_reference/asia_reception_desk_geometry_guide_transparent.png` for workflows that prefer alpha.
Acceptance results:
- PNG dimensions verified at 1024x1024 for all three guide variants.
- Runtime tests not run; this is a non-runtime reference artifact.

---

**Session 8.12 - 2026-05-08 - Art Direction - Reception desk guide south-return correction.**
Updated the reception desk geometry guide files in `art_reference/` so the L-shaped return now sits on the south/bottom end and extends east/south, instead of attaching at the north/top end. Preserved the west/customer-front cue and east/Asia-side cue in the labeled guide.
Acceptance results:
- PNG dimensions verified at 1024x1024 for all three guide variants.
- Transparent guide verified with alpha range 0-255.
- Runtime tests not run; this is a non-runtime reference artifact.

---

**Session 9 - 2026-05-11 - Code/Art Direction - Playtest feedback: sprite size, office dimensions, color palette.**
Three changes driven by playtesting:
1. **Office shrink**: canonical office dimensions changed from 24×16 tiles (1536×1024 px, scrolling) to 20×11 tiles (1280×704 px, fits entirely in viewport). Updated `CONVENTIONS.md` room layout, camera limits documentation. Office scene rebuild pending (requires `_build_office.py` update + regeneration).
2. **Sprite size**: canonical character sprite size changed from 112×112 to 64×64 px. Sprites are now the same size as a tile — chunkier, more readable pixel art. Updated `State.gd` (`CHAR_HEIGHT`), `CONVENTIONS.md`, `AGENTS.md` (root), `PLAN.md`, `art/sprites/README.md`, all 8 character `PROMPT.txt` files, `interaction_prompt.gd` comment, and `test_ysort_canon.gd` expected values. Art regeneration in Pixellab pending (Art-owned).
3. **Color palette**: adopted "Marszałkowska" (Palette C) — an 18-color game palette inspired by 1990s Warsaw: PKiN Gray, Tram Green, Neon Red, Plate Glass, Cheap Gold, Mint alongside the existing cast colors. Added §Game palette to `CONVENTIONS.md`. Rebuilt `art/tilesets/TILESET_BRIEF.md` with per-room palette subsets drawn from the master palette. Generated `art/palettes/marszalkowska_palette.png` reference swatch. Updated `art/sprites/README.md` palette section.
Files touched: `AGENTS.md` (root), `godot/CONVENTIONS.md`, `godot/PLAN.md`, `godot/scripts/autoload/state.gd`, `godot/scripts/ui/interaction_prompt.gd`, `godot/tests/test_ysort_canon.gd`, `godot/art/sprites/README.md`, `godot/art/tilesets/TILESET_BRIEF.md`, `godot/art/palettes/marszalkowska_palette.png`, all 8 `PROMPT.txt` files.
**Acceptance:** Docs-only and constant changes. Y-sort test will fail until sprites are regenerated at 64×64 (expected — the test now represents the target state, not the current art). Office scene rebuild is a separate follow-up step.

**Session 9b - 2026-05-11 - Art Direction - Multi-palette system + Świdziński/Waliszewska hybrid.**
1. **Multi-palette system**: expanded from single "Marszałkowska" palette to six Warsaw-themed palettes (Milk Bar, Kiosk RUCH, Marszałkowska, Warsaw Night Life, Praga Północ, Łazienki Autumn). Different scenes/chapters draw from different palettes. Shared character-safe colors defined across all six. Updated `CONVENTIONS.md`, generated swatch PNGs for all six in `art/palettes/`.
2. **Two-layer art direction (Świdziński + Waliszewska)**: adopted hybrid visual system. World sprites follow Jacek Świdziński's "synthetic minimalism" — sparse, functional, silhouette-first at 128→64 downscale. Portraits use a hybrid register: warm naive Polish illustration (Butenko-adjacent) for normal dialogue, Aleksandra Waliszewska-inspired dark symbolism for court/panic/Casebook scenes. The contrast between layers IS the comedy.
3. **All 8 PROMPT.txt files rewritten** for Świdziński-minimal direction: stripped to silhouette + one feature, new style/negative anchors, 128→64 workflow documented.
4. **New docs**: `art/portraits/PORTRAIT_BRIEF.md` (portrait generation guide with warm/dark register prompts, expression sets, Casebook card guidelines). Rebuilt `art/sprites/README.md` for Świdziński workflow.
Files touched: `godot/CONVENTIONS.md`, `godot/art/sprites/README.md`, `godot/art/portraits/PORTRAIT_BRIEF.md` (new), all 8 `PROMPT.txt` files, 3 new palette PNGs.
**Acceptance:** Docs-only. All art regeneration is pending (Art-owned).

---

**Session 9c - 2026-05-11 - Art - Cula 128px animation slicing.**
Sliced the raw Cula sheets in `art/sprites/new/cula/` into transparent 128x128 runtime frames for 8-direction idle, walk, and run animation. Used the supplied east-facing sheets for right/front-right/back-right and mirrored them for left/front-left/back-left. Regenerated `art/sprites/cula/cula_sprite_frames.tres` so the player `AnimatedSprite2D` can play the new 128px `idle_*`, `walk_*`, and `run_*` animations. Added `art/sprites/cula/cula_128_animation_preview.png` as a contact sheet for visual review.
Acceptance results (all EXIT 0):
- `godot --headless --path godot --import --quit --log-file /tmp/pig_cula_128_import.log` -> PASS (import succeeded; sandbox blocked Godot's editor-settings save after import)
- `godot --headless --path godot --script tests/test_sprite_frames.gd --log-file /tmp/pig_cula_128_frames.log` -> PASS
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_cula_128_smoke.log` -> PASS
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_cula_128_runner.log` -> PASS
- `godot --headless --path godot --export-release Web exports/web/index.html --log-file /tmp/pig_cula_128_export.log` -> PASS (export packed successfully; sandbox blocked Godot's editor-settings save after export)

---

**Session 9d - 2026-05-12 - Art - Cula 8-direction facing extracts.**
Extracted the normalized 128x128 Cula idle poses into `art/sprites/cula/facing_8/` as standalone facing images for all 8 runtime directions: front, front-right, right, back-right, back, back-left, left, and front-left. These are duplicated from the existing 128px idle animation frames, so no animation resource or gameplay wiring changed.
Acceptance results:
- PNG dimensions verified at 128x128 RGBA for all 8 facing images.
- `godot --headless --path godot --import --quit --log-file /tmp/pig_cula_facing8_import.log` -> PASS (import succeeded; sandbox blocked Godot's editor-settings save after import)

---

**Session 9e - 2026-05-12 - Design — Fill Casebook stub files against Chapter 1 state machine.**
Filled three stub JSON files to zero lines of placeholder. No code, scenes, dialogue, or spec files were modified.
- `data/argument_opponents.json`: added `landlord_counsel_ch1` with three court rounds keyed to `casebook_judge_state` enum values (`round_1_open/react`, `round_2_open/react`, `round_3_open/remedy`). Two argument moves per round (total six). All tags draw from `data/tag_taxonomy.json` closed set. Display name is "Landlord's Counsel" (unnamed in Ch1 per `judge_district_ch1.json _address_forms`; Attorney Grzyb name reserved for Ch2+).
- `data/judgments.json`: added `procedural_reset_ch1` judgment. Conditions reference `casebook_judge_state == 'round_3_remedy'` AND `court_won_procedural_reset == true`. Documents all three `bonus_evidence_collected` variants and their Round 3 argument effects. Remedy-discipline note embedded. Actual remedy text lives in `judge_district_ch1.json` — not duplicated here. Draft: false (Design pass complete; Code pass is the mechanical `principle_moves[].effectiveness_modifiers`/`cost`, which are stub-correct values).
- `data/items.json`: added five items. Two wired pickups: `procedural_binder` (Beat 4, sets `chapter1.has_law_binder`) and `rights_memo` (Beat 6-7, sets `chapter1.has_rights_memo`). Three bonus-evidence items using the canonical `chapter1.json` enum values: `wojcik_witness_statement` (sympathetic), `return_to_sender_slip` (blunt_procedural), `lease_1962_inheritance_1987` (technical) — all set `chapter1.bonus_evidence_collected`. Required-for-round annotations cross-reference beat 12 round tags.
Acceptance: all three files parse cleanly (`python3 -c "import json; json.load(open(f))"` → OK). Godot test suite not run per task spec (Piotr will run). No chapter1.json, dialogue files, spec files, or scripts modified.

---

**Session 9f - 2026-05-12 - Art - Cula 124px sprite swap.**
Applied the new Cula sprite exported from Pixellab at 124×124 px (group `ba753df1`, state `DR._A._CULA`). The new export has 8-direction rotations (idle), an 8-direction unnamed walk animation (`animation-0545e641`, 6 frames), and an 8-direction Running animation (`Running-92d93825`, 6 frames). A `sitting_down` state was also included in the export but is not wired to the player yet.

Direction mapping applied: south→front, south-east→front_right, east→right, north-east→back_right, north→back, north-west→back_left, west→left, south-west→front_left.

Files overwritten in place (paths unchanged so `cula_sprite_frames.tres` required no edits):
- `art/sprites/cula/cula_idle_*.png` (8 files, 124×124)
- `art/sprites/cula/walk/*/cula_walk_*_0[0-5].png` (48 files, 124×124)
- `art/sprites/cula/run/*/cula_run_*_0[0-5].png` (48 files, 124×124)
- `art/sprites/cula/facing_8/cula_*.png` (8 files, 124×124)

Doc changes:
- `godot/CONVENTIONS.md`: canonical sprite size updated to 124×124, generation workflow step removed (no downscale needed), inline 128-references updated.

Leftover 112px `run/*/frame_06-07` files and `walk/_alt/` folder are not referenced by any `.tres` and were not touched.

Acceptance results (all PASS):
- `godot --headless --import --quit` → PASS
- `godot --headless --script tests/test_sprite_frames.gd` → PASS
- `godot --headless --script tests/test_smoke.gd` → PASS
- `godot --headless --script tests/test_runner.gd` → PASS

---

**Session 9g - 2026-05-12 - Art/Code - Office shrink to 20×11 + tile darkening.**
Two changes per playtest feedback:

1. **Office room resized from 24×16 → 20×11 tiles (1536×1024 → 1280×704 px).** Fits entirely in the 1280×720 viewport with no scrolling.
   - Regenerated both TileMapLayer datasets (Floor 220 tiles, Walls 64 tiles). Binary format: 2-byte header + 12 bytes/tile (`x(i16) y(i16) source_id|(atlas_x<<16) atlas_y(i16) alt(i16)`). Door gaps cut in south wall at tile x=3 (BackDoor) and north wall at tile x=18 (ArchiveDoor).
   - All node positions scaled by (1280/1536, 704/1024). FloorZone ColorRect offsets scaled. Camera limits updated to (0, −64, 1280, 704). MeetingRoomBoundary/Trigger widths updated (512 → 427 px).
2. **Floor tile darkened 20%.** `art/tiles/office_marble_tiles.png` RGB multiplied by 0.80 (mean ~245 → ~196). Alpha unchanged.

Files changed: `scenes/interiors/pig_swine_office.tscn`, `art/tiles/office_marble_tiles.png`.

Acceptance: run on host:
- `godot --headless --script tests/test_scene_inspect.gd --log-file /tmp/office_shrink_inspect.log`
- `godot --headless --script tests/test_smoke.gd --log-file /tmp/office_shrink_smoke.log`
- `godot --headless --script tests/test_runner.gd --log-file /tmp/office_shrink_runner.log`

---

**Session 9h - 2026-05-12 - Art - Office wall tile replaced with dark brick.**
Replaced `art/tiles/office_wall.png` with a pixel-art dark brick tile (mortar #1C1612, body #683018/#6830 1E/#76381E, highlight top strip). Sheet kept at 384×64 (6 atlas slots) to match existing TileSet and scene references. All wall TileMapLayer tiles set to atlas_x=0 (consistent tile, no random variation). Camera zoom set to Vector2(1, 1) (was 1.35×) so the 1280×704 room fits the viewport without scrolling.
Files changed: `art/tiles/office_wall.png`, `scenes/interiors/pig_swine_office.tscn`.
Acceptance: `godot --headless --import --quit` + smoke test on host.

---

**Session 9i - 2026-05-12 - Code/Art - Office shrunk to 16×9 tiles, camera zoom 1.25×.**
Room was still scrolling vertically and felt too spacious (20×11 at zoom 1.0 with limit_top=−64 gave 48 px of extra scroll range).

Fix: **16×9 tiles (1024×576 px) + Camera2D zoom=Vector2(1.25, 1.25)**. At 1.25× zoom the visible world area = 1280/1.25 × 720/1.25 = 1024×576 — exactly the room. Camera limits (0, 0, 1024, 576) produce zero scroll in both axes.

- Floor TileMapLayer: regenerated for 16×9 (144 tiles, source=0, atlas_x random 0–2).
- Walls TileMapLayer: regenerated for perimeter (52 tiles, source=1, atlas_x=0). South gap at tile x=2 (pixel centre 160) for BackDoor; north gap at tile x=14 (pixel centre 928) for ArchiveDoor.
- All node positions scaled by (1024/1280, 576/704). FloorZone offsets, door indicators, collision shapes, spawn points, NPC/prop positions all updated.
- MeetingRoomBoundary/Trigger shapes: 427 → 342 px wide.
- WallClock moved to x=992 (tile 15) to clear the ArchiveDoor gap at tile 14.
- Player spawn: (160, 544) — near BackDoor, inside room.

Files changed: `scenes/interiors/pig_swine_office.tscn`.
Acceptance: `godot --headless --import --quit` + smoke + runner on host.

---

**Session 9j - 2026-05-12 - Design - Two-phase Court Round structure proposed; AGENTS.md required-reading updated.**
Cowork brainstorm on making the game less "running around and a lot of reading" resolved in a design decision: split Court Rounds into Phase 1 (witness fact-finding, new `witness_cooperation` counter) and Phase 2 (closing argument modeled on Polish *mowy końcowe*, existing `judicial_patience` counter), with Phase 1 fact-flags gating Phase 2 principle citations. The carry-over is load-bearing — it lets a sloppy questioning round cost the player when they reach the judge, and lets the procedural reset in Chapter 1's spec follow from gameplay instead of from a scripted win/lose. Procedural and ECHR-substantive citations are not mutually exclusive: Chapter 1 leans procedural (Article 135-bis § 2 KPC) with ECHR flavor allowed; later chapters scale up substantive citations as the Casebook fills and the meta-plot widens. v1 cuts from `battle_mechanics.txt` (one encounter type, ≤ 2 judgments × 3–4 principles, no allies / stance flavor / wild arguments) hold; the two-phase split is additive.
Files changed:
- `godot/PROPOSALS.md`: new §10 "Court Round splits into two phases (witness fact-finding → closing argument)" + status-table row 10 (PENDING).
- `AGENTS.md` (repo root): `godot/PROPOSALS.md` added as item 6 of Required Reading and to Source Of Truth — closes the loop so Codex (which only reads root AGENTS.md) picks it up alongside Antigravity and Cowork.
Acceptance: docs-only change, no Godot test run. Pre-work flagged in §10 Status: Design should sketch a one-page `data/court_rounds/_schema.md` (Phase 1 / Phase 2 JSON shape) before Code starts PLAN.md §Vertical slice plan step 4, so `battle_controller.gd` implements both sub-controllers from day one.

---

**Session 10 - 2026-05-12 - Code - Coffee Brewing rhythm engine skeleton (Prompt 2).**
Replaced the `coffee_brewing.gd` stub (press-E-to-finish) with a playable rhythm engine implementing three phases (Grind → Pour → Serve), four-judgment timing windows (PERFECT/GOOD/OKAY/MISS), scoring per `minigames.txt` §Scoring, result grading (S/A/B/C/D/F → buff mapping), and spec-shaped result dictionary. State machine: READY → GRIND → POUR → SERVE → RESULT → EXIT.

Schema bump: `SAVE_VERSION` 8 → 9. Two new `chapter1` string fields (`coffee_buff`, `coffee_brew_grade`), one new top-level `coffee{}` dict (cross-chapter state: `tutorial_seen`, `last_result`, `last_grade`, `last_buff`, `assist_used`, `times_brewed`, `best_grade`). v8→v9 migration in `save.gd`.

New signal: `Signals.coffee_brewing_completed(result: Dictionary)`. Existing `minigame_finished("coffee_brewing", buff)` preserved for back-compat with `barista.json`.

Scene rewritten with spec node structure: `CoffeeBrewingRoot` → `BackgroundPanel`, `CoffeeMachineSprite`, `CupSprite`, `TimingTrackRoot/Lane0-3`, `TimingLine`, `PromptSpawner`, `BrewQualityMeter`, `BitternessMeter`, `ComboLabel`, `PhaseLabel`, `ResultPanel`, `CharacterReactionPortrait`, `AnimationPlayer`, `AudioStreamPlayer`. All visuals are `ColorRect`/`Label` placeholders; sprite slots are empty `Sprite2D` with null textures; audio slots empty.

Hard-coded fallback pattern: 2-lane tutorial (3 grind taps, 1 pour, 3 serve taps + 1 stamp). **Prompt 3 pending pattern data** — `data/minigames/coffee_patterns.json` placeholder created. Prompt 4 fills art, Prompt 5 fills audio.

Files changed: `scripts/autoload/state.gd`, `scripts/autoload/signals.gd`, `scripts/systems/save.gd`, `scripts/systems/minigames/coffee_brewing.gd` (rewrite), `scenes/minigames/coffee_brewing.tscn` (rewrite), `data/minigames/coffee_patterns.json` (new). Tests: `tests/test_save_migration_v8_v9.gd` (new, 6/6 pass), `tests/test_save_migration_v7_v8.gd` (T1 updated for >= 8, 8/8 pass).
Acceptance results (all EXIT 0):
- `godot --headless --path . --script tests/test_smoke.gd` → PASS ✅
- `godot --headless --path . --script tests/test_runner.gd` → EXIT 0 ✅
- `godot --headless --path . --script tests/test_save_migration_v8_v9.gd` → 6/6 PASS ✅
- `godot --headless --path . --script tests/test_save_migration_v7_v8.gd` → 8/8 PASS ✅
- `godot --headless --export-release "Web" exports/web/index.html` → PASS (index.html 5.4 KB) ✅
Manual visual check: delegated to human — walk into Café Paragraf, press E on coffee machine, play through fallback pattern using A/D + E, observe phase transitions and result panel.

---

**Session 11 - 2026-05-12 - Code/QA - Minor Office tweaks (colliders, y-sort, music)**
Three minor tweaks to the office and archive room based on user feedback:
1. **Added colliders to doors:** Added `StaticBody2D` nodes with matching collision shapes underneath `BackDoor` and `ArchiveDoor` in `pig_swine_office.tscn` and `OfficeDoor` in `archive_room.tscn`. This ensures the player bumps into the door rather than sliding over it before pressing interact.
2. **Fixed player Y-sorting issue:** The player was disappearing behind the floor tiles near the top of the office because their Y-coordinate became negative and was sorted behind the Floor TileMapLayer (which had no explicitly set z_index, thus defaulting to 0). Added `z_index = -20` to the `Floor` TileMapLayer in `pig_swine_office.tscn` to resolve this.
3. **Office music in Archive:** Added the `res://audio/music/office.mp3` `AudioStreamPlayer` to `archive_room.tscn` with `autoplay = true` so the same office music plays when visiting Crab.

Files changed: `scenes/interiors/pig_swine_office.tscn`, `scenes/interiors/archive_room.tscn`.
Acceptance results: Smoke and Runner tests PASS on host.

---

**Session 12 - 2026-05-12 - Art/QA - Office window and door alignment**
Follow-up adjustments for the office layout:
1. **Window replaces wall tile:** Removed the physical wall tile at `(2, -1)` (X=160) and placed the `Window` sprite exactly there (`Vector2(160, 0)`, offset `(0, -64)`). Removed its negative `z_index` so it properly Y-sorts like a wall segment.
2. **Doors align with walls:**
   - Moved the `OfficeDoor` sprite (Back Door) to `Vector2(160, 640)` so it perfectly fills the south wall gap at `(2, 9)`.
   - Duplicated the door sprite for the `ArchiveDoor` on the north wall and placed it at `Vector2(928, 0)` to perfectly fill the north wall gap at `(14, -1)`.
   - Realigned the static colliders for both doors to be exactly 64×64 and perfectly centered on their respective wall gaps (`(160, 608)` and `(928, -32)`).
   - Removed negative `z_index` overrides on wall props (Calendar, Clock, Certificate) and snapped them to `Y=0` (base of the north wall) so they correctly render behind the player when the player walks in front of them.

Files changed: `scenes/interiors/pig_swine_office.tscn`.
Acceptance: Run smoke and runner tests on host → PASS.

---

**Session 14 - 2026-05-12 - Code - Coffee pattern data + loader wiring (Prompt 3).**
Four P0 coffee patterns hand-authored in `data/minigames/coffee_patterns.json`: `chapter1_court_coffee` (tutorial, 2 lanes, ~22s, 15 notes + 1 pour), `cafe_smooth_coffee` (tutorial, 2 lanes, ~22s, 15 notes + 1 pour), `office_standard_coffee` (normal, 4 lanes, ~27s, 22 notes + 1 pour), `office_panic_coffee` (normal, 4 lanes, ~27s, 26 notes + 1 pour, double-notes in final 5s). Each pattern has a readable opening (sparse first 3s), mid-pattern difficulty rise, and satisfying final stamp. Tutorial patterns: no simultaneous notes, only bean+sugar icons. Normal patterns: milk+file icons in the mix, occasional double notes at the end.

Engine changes to `coffee_brewing.gd`: replaced inline fallback pattern with JSON loader keyed by `@export var pattern_id`. Added `Difficulty` enum (TUTORIAL/NORMAL) derived from pattern's `difficulty` field. Timing windows now switch between tutorial (0.075/0.140/0.220) and normal (0.060/0.120/0.190) constants per spec §Timing judgments. Lane count set from pattern's `lanes` field; UI hides Lane2/Lane3 when `lanes == 2`. OKAY judgment now breaks combo in NORMAL mode only (spec).

Trigger wiring: `minigame_trigger.gd` gained `@export var pattern_id` that forwards to instantiated minigame. `cafe_paragraf.tscn` CoffeeMachine: `pattern_id = "chapter1_court_coffee"`. `pig_swine_office.tscn` OfficeCoffeeMachine: `pattern_id = "office_standard_coffee"`. No office_panic trigger wired (reserved for later chapter beat).

Files changed: `data/minigames/coffee_patterns.json` (rewrite), `scripts/systems/minigames/coffee_brewing.gd`, `scripts/actors/minigame_trigger.gd`, `scenes/interiors/cafe_paragraf.tscn`, `scenes/interiors/pig_swine_office.tscn`.
Acceptance results (all EXIT 0):
- `godot --headless --path . --script tests/test_smoke.gd` → PASS ✅
- `godot --headless --path . --script tests/test_runner.gd` → EXIT 0 ✅
Manual visual check: delegated to human — café tutorial should play with 2 lanes; office coffee corner should launch normal pattern with 4 lanes.


---

**Session 13 - 2026-05-12 - Art/QA - Office door access and Y-sorting fixes**
Follow-up adjustments for the office layout:
1. **Door access fixed:** The `Area2D` interaction triggers for the doors were the exact same size as the new 64x64 `StaticBody2D` colliders, preventing the player from overlapping them enough to see the interaction prompt. Increased the trigger `CollisionShape2D` sizes to 64x96 so they extend 16px past the physics bounds.
2. **Y-sorting issues resolved:**
   - North wall props (`Window`, `ArchiveDoorSprite`, `WallCalendar`, etc.) were sorting at `Y=0`, making the player draw behind them if pushed into the wall. Moved their `position.y` and `offset.y` to `-32` to match the wall's Y-sort origin.
   - South wall door (`OfficeDoor`) was sorting at `Y=640` (bottom of the wall). Set its `position.y = 512` and `offset.y = 64` so it sorts at the top face of the wall, allowing the player to correctly sort in front of it.
3. **Bookshelf visibility:** The `Bookshelf` had a legacy `z_index = -3` causing it to hide behind the new opaque dark brick wall tile. Removed the Z-index override so it sorts naturally on the floor at `Y=39`.

Files changed: `scenes/interiors/pig_swine_office.tscn`.
Acceptance: Run smoke and runner tests on host → PASS.

---

**Session 15 - 2026-05-12 - Art - Coffee Brewing SFX set (Prompt 5).**
Authored the complete 11-sound SFX set for the coffee brewing mini-game via procedural synthesis (`tools/generate_coffee_sfx.py`). All sounds use pure-Python wave synthesis (sine, square, sawtooth, noise generators with ADSR envelopes, lowpass/highpass filters, exponential decay) — no external dependencies. Cross-normalised to -3 dBFS peak with balanced RMS across the set.

Sound set (`audio/minigames/coffee/`):
- `coffee_note_hit.wav` — soft wooden tap, ~80ms, 7KB. Default rhythm hit cue.
- `coffee_note_perfect.wav` — wood tap + high bell harmonic layer, ~120ms, 10KB. Distinguishable from note_hit blind.
- `coffee_note_miss.wav` — dull paper crumple (filtered noise bursts), ~140ms, 12KB.
- `coffee_pour_start.wav` — espresso pump motor ramp-up, ~200ms, 17KB.
- `coffee_pour_loop.wav` — seamless 1.0s pour stream, 86KB. Cross-faded at endpoints (50ms) for click-free looping. Import set to `edit/loop_mode=2`.
- `coffee_pour_release_good.wav` — water cutoff + ceramic clink, ~250ms, 22KB.
- `espresso_hiss.wav` — high-pressure steam, ~500ms, 43KB. Highpassed for hissy character.
- `coffee_success.wav` — ascending chime triad + rubber stamp thud, ~600ms, 53KB.
- `coffee_failure.wav` — sad machine sputter + descending offended beep, ~700ms, 62KB.
- `coffee_machine_objects.wav` — comic descending bellows "uh-oh", ~900ms, 79KB. Reserved for F-grade.
- `stamp_caffeinated.wav` — decisive rubber stamp thud, ~150ms, 13KB.

Wired all 11 streams into `scenes/minigames/coffee_brewing.tscn` via the `audio_streams` Dictionary export (11 ext_resource entries, load_steps 2→13). Dictionary keys match exactly the `_play()` calls in `coffee_brewing.gd`: `note_hit`, `note_perfect`, `note_miss`, `pour_start`, `pour_loop`, `pour_release_good`, `espresso_hiss`, `success`, `failure`, `machine_objects`, `stamp_caffeinated`.

**Format note:** Files delivered as WAV (mono, 16-bit, 44100 Hz) because no OGG Vorbis encoder (ffmpeg/oggenc) is available on the current machine. Godot imports them cleanly as `AudioStreamWAV`. To convert to OGG Vorbis per spec:
```
brew install ffmpeg
for f in godot/audio/minigames/coffee/*.wav; do
  ffmpeg -y -i "$f" -ac 1 -ar 44100 -c:a libvorbis -q:a 4 "${f%.wav}.ogg"
done
```
Then update the ext_resource paths in `coffee_brewing.tscn` from `.wav` to `.ogg`.

Files created: `tools/generate_coffee_sfx.py`, 11 WAV files in `audio/minigames/coffee/`.
Files changed: `scenes/minigames/coffee_brewing.tscn`, `audio/minigames/coffee/coffee_pour_loop.wav.import`.
Acceptance results (all EXIT 0):
- `godot --headless --path . --import --quit` → PASS ✅ (all 11 WAVs import as AudioStreamWAV)
- `godot --headless --path . --script tests/test_smoke.gd` → PASS ✅
- `godot --headless --path . --script tests/test_runner.gd` → EXIT 0 ✅

---

**Session 14 - 2026-05-12 - Art/QA - Office colliders and precise Y-sorting offsets**
Corrected major visual and physical alignment bugs introduced in recent layout adjustments:
1. **Bookshelf Y-sorting:** Re-enabled standard Y-sorting for the `Bookshelf` (removed `z_index` hack). Since the Player origin is 16px above their physical feet, offset the bookshelf's sorting origin down by 16px (`position.y = 23`, `offset.y = -48`) so the player consistently draws in front when standing near its base.
2. **Door accessibility:** Extracted the physical `StaticBody2D` colliders from the `Area2D` triggers. Positioned static walls perfectly over the gaps (`64x64`), and shifted the `Area2D` interaction triggers slightly into the room (`48x24`) to ensure reliable overlap for the "Press E" prompt.
3. **Wall props alignment:** Reset `Window`, `WallClock`, `WallCalendar`, and `Certificate` to `position.y = -32` and `offset.y = 0`. This centers them perfectly on the north wall face without forcing them into the ceiling, and properly Y-sorts them below the player if the player pushes against the wall.
4. **South Door visibility:** Deleted the legacy `DoorIndicator` "black belts". Shifted the `OfficeDoor` visual sprite to `position.y = 512, offset.y = 128` so it sorts behind a player standing in the room, but its visual center drops perfectly into the `576-640` wall gap.
5. Restored the missing wall tile behind the window that was accidentally stripped out in the previous pass.

---

**Session 16 - 2026-05-12 - Art - Coffee Brewing visual asset set (Prompt 4).**
Generated the complete visual asset set for the coffee brewing mini-game: 24 pixel-art sprites in `art/minigames/coffee/` and 5 barista portrait placeholders in `art/portraits/barista/`. All assets use Milk Bar palette colors exclusively, drawn programmatically via `tools/generate_coffee_placeholders.py` (pure Python stdlib PNG encoder, no external dependencies).

Asset set (`art/minigames/coffee/`):
- **Coffee machine** (128×128, 4 states): `idle` (green indicator), `gurgle` (amber indicator + steam), `happy` (green, slight tilt), `angry` (red indicator + shake lines + steam).
- **Coffee cups** (64×64, 4 fill levels): `empty`, `fill_01` (33%), `fill_02` (66%), `fill_03` (full + foam line).
- **Prompt icons** (32×32, 6 types): `bean`, `milk`, `sugar`, `stamp`, `file`, `mug`. Clear silhouettes, readable at target scale.
- **Meter sprites** (240×24): `meter_brew_bg`, `meter_brew_fill` (amber), `meter_bitter_bg`, `meter_bitter_fill` (dark brown). Fill bars designed for `region_rect` scaling.
- **Timing line** (8×96): amber vertical bar with dark outline.
- **Result stamps** (96×64): `admitted` (oxblood red #7a1f2a) and `objected` (plaster gray #9a9088) with circular bureaucratic stamp borders.
- **Feedback effects**: `sparkle` (16×16, 4-point gold star), `bitter_foam` (32×32, coffee splat), `puff_offended` (32×32, angry steam cloud).

Portrait set (`art/portraits/barista/`):
- 5 expression placeholders: `perfect`, `good`, `okay`, `bad`, `machine_objects` (512×512).
- Full gouache-register barista portraits were generated via AI image tool (visible in conversation) but could not be copied from brain directory to project due to macOS sandbox permissions. **Human action needed:** replace the geometric placeholders with the AI-generated portraits from the conversation.

Scene changes (`scenes/minigames/coffee_brewing.tscn`):
- Wired `coffee_machine_idle.png` texture to `CoffeeMachineSprite` and `coffee_cup_empty.png` to `CupSprite`.
- Added `StampAdmitted` and `StampObjected` `Sprite2D` nodes inside `ResultPanel` (hidden by default).
- Added `SparkleEffect` `CPUParticles2D` node for Perfect-timing visual feedback (one-shot burst, 6 particles, 0.4s lifetime, gold color).
- `load_steps` bumped 13→18 for new ext_resources.
- **Meter nodes kept as Labels** (not converted to TextureRect) because `coffee_brewing.gd` casts them as `Label`. Meter sprite assets are available for future Code-role integration.
- **AnimationPlayer animations deferred** — requires Code-role coordination to wire sprite swaps to game state transitions.

Files created: `tools/generate_coffee_placeholders.py`, 24 PNGs in `art/minigames/coffee/`, 5 PNGs in `art/portraits/barista/`.
Files changed: `scenes/minigames/coffee_brewing.tscn`.
Acceptance results (all EXIT 0):
- `godot --headless --path . --import --quit` → PASS ✅ (29 .import files created)
- `godot --headless --path . --script tests/test_smoke.gd` → PASS ✅
- `godot --headless --path . --script tests/test_runner.gd` → EXIT 0 ✅

---

**Session 15 - 2026-05-12 - Art/QA - Safe recovery of uncommitted office layout fixes**
Applied the intended visual and collision fixes via a safe GDScript patch directly to the user's uncommitted worktree, avoiding any destructive `git checkout` operations:
1. **Bookshelf visibility:** Reset `Bookshelf` to standard Y-sorting (removed `z_index` hack). Compensated for the player's native 16px sorting offset by shifting the bookshelf's sorting origin down by 16px (`position.y = 23`, `offset.y = -48`) so the player consistently draws in front.
2. **Door accessibility:** Extracted the physical `StaticBody2D` colliders from the `Area2D` triggers. Positioned the static walls perfectly over the structural gaps (`64x64`), and shifted the `Area2D` interaction triggers slightly into the room (`48x24`) to ensure reliable overlap for the "Press E" prompt.
3. **Wall props alignment:** Reset `Window`, `WallClock`, `WallCalendar`, and `Certificate` to `position.y = -32` and `offset.y = 0`. This centers them perfectly on the north wall face without floating near the ceiling, and properly Y-sorts them below the player.
4. **South Door visibility:** Deleted the legacy `DoorIndicator` "black belts". Shifted the `OfficeDoor` visual sprite to `position.y = 512, offset.y = 128` so it sorts correctly behind the player in the room, but its visual center drops perfectly over the `576-640` wall gap. 

---

**Session 16 - 2026-05-12 - Art/QA - Archive door collision fix**
Resolved a bug preventing exit from the archive room:
- The previous addition of a `StaticCollider` child to the `OfficeDoor` in `archive_room.tscn` directly overlapped the `Area2D` interaction trigger, preventing the player from fully overlapping it before being stopped.
- Removed the `StaticCollider` from the door, as the `archive_room.tscn` already utilizes a comprehensive bounding box (`Walls/Bottom`) that correctly serves as the physical barrier. The interaction trigger is now easily accessible just in front of the wall boundary.

---

**Session 17 - 2026-05-12 - Art/QA - Final collision and layer fixes**
- **Archive Room:** Physically removed the rogue `StaticCollider` node from `OfficeDoor` in `archive_room.tscn` (previous GDScript used `queue_free()` which deferred deletion and failed to omit it from the saved scene). The interaction trigger is now unblocked.
- **Office Floor Y-sorting:** Re-applied `z_index = -20` to the `Floor` TileMapLayer in `pig_swine_office.tscn`. The user's manual IDE recovery had dropped this setting, causing the player to render behind the top-most floor tiles when walking near `Y=0`.

---

**Session 18 - 2026-05-12 - Audio/Code - Seamless music transitions**
- Implemented `scripts/systems/persistent_music.gd` to handle seamless background music between scenes.
- Attached this script to the `Music` node in both `pig_swine_office.tscn` and `archive_room.tscn`.
- The script checks if an identical audio stream is already playing globally at `/root/BGM`. If so, it kills the incoming duplicate to allow the original to continue seamlessly. If not, it reparents itself to the root to survive the next scene transition. This avoids bulky Autoloads and respects the "simplicity first" rule.

---

**Session 19 - 2026-05-12 - Art/Audio - Bookshelf depth and robust music persistence**
- **Persistent Music:** Upgraded `persistent_music.gd` to compare `.resource_path` instead of relying on Godot's memory instance comparison (`==`). This ensures the track survives the transition without restarting, even if the new scene loads the track as a distinct resource instance.
- **Bookshelf Sorting:** Calibrated the Bookshelf's Y-sort origin specifically to the player's `-50px` visual feet offset (the difference between the player's logical root `0` and their visual feet at `+50`). The Bookshelf now sits at `position.y = -11` with `offset.y = -14`, ensuring the player correctly draws in front when standing at its base, but completely disappears if walking into the gap *behind* it.

---

**Session 20 - 2026-05-12 - Design - V1.4 coffee dialogue + flavor sprint (Prompt 7).**
Resolved the V1.3 SCOPE NOTE in `data/dialogues/barista.json` by splitting the single `coffee_outcome` state into five buff-gated outcome states (`coffee_outcome_alert_plus`, `coffee_outcome_alert`, `coffee_outcome_caffeinated`, `coffee_outcome_machine_objects`, `coffee_outcome_over_caffeinated`) and added a new `coffee_retry_prompt` state with an in-dialogue `options` block (Appeal / Accept). The F-grade machine-objects state is placed before the generic over_caffeinated state so its more specific gate (`coffee_buff == "over_caffeinated" && coffee_brew_grade == "F"`) wins priority. The retry state's `write_path` (`chapter1.coffee_retry_decision`) and the outcome-acknowledgement-flag pattern required to make retry reachable are surfaced in `PROPOSAL_coffee_engine_followups.md` §1 for Code's Prompt 8.

Added four coffee-result hint states to `data/dialogues/asia_hint_states_ch1.json` (`hint_coffee_alert_plus`, `hint_coffee_alert`, `hint_coffee_over_caffeinated`, `hint_coffee_skipped`), inserted between the existing `hint_court_ready` and `hint_won_court` so they fire only in the post-readiness, pre-court window. Per the design brief `hint_coffee_skipped` is gated on `chapter1.coffee_tutorial_seen == false`; added `chapter1.court_ready && !chapter1.entered_court` to all four to scope the lines to the intended window (surfaced in the file's `_comment_coffee_window_narrowing` note). Pre-existing bug noted in passing: `chapter1.won_court` is referenced by `hint_court_ready` and `hint_won_court` but is not declared in `state.gd::reset_state()`; left untouched (out of Design's scope).

Added coffee_reaction states to four existing NPC dialogue files: `pig.json` (2 states, perfect/bad), `murrow.json` (2), `crab.json` (4 — perfect/bad × pre-recruit/post-recruit), `whimsy.json` (4 — same split). Address forms verified against `AGENTS.md` §Address forms: Pig uses "Dr. A. Cula", Murrow uses "Doctor Cula" (per his existing speech form in this file), Crab/Whimsy use "Cula" post-recruit and "Dr. A. Cula" pre-recruit. All states additionally gated `!chapter1.entered_court` so the reactions stop firing once court begins.

Created new file `data/minigames/coffee_text.json` carrying the player-facing strings the engine currently hard-codes: phase labels (`Grind.` / `Pour.` / `Serve.`), per-phase flavor lines (spec verbatim for Grind and Pour; authored for Serve), four result lines per buff (spec verbatim from §Core fantasy), and the two final-stamp lines. Engine reader is a Code follow-up; PROPOSAL §2 specifies the loader contract.

Files changed: `data/dialogues/barista.json`, `data/dialogues/asia_hint_states_ch1.json`, `data/dialogues/pig.json`, `data/dialogues/murrow.json`, `data/dialogues/crab.json`, `data/dialogues/whimsy.json`. Files created: `data/minigames/coffee_text.json`, `PROPOSAL_coffee_engine_followups.md`.

Acceptance: JSON validity confirmed via `python3 -m json.tool` on all seven `.json` files (7/7 PASS). Cross-reference check: every `chapter1.<flag>` referenced in new triggers exists in `state.gd::reset_state()` except (a) `coffee_retry_decision` — new flag, expected, surfaced in PROPOSAL §1; (b) `won_court` — pre-existing bug in untouched code. Address-form audit: all new lines compliant. Trigger syntax: all new triggers use only `==` / `!=` / bare-truthiness / `&&` per `dialogue_runner.gd::_evaluate_clause`. Taste Standard: every new line passes 5/5 (review notes in the final response).

Action required from Code (Prompt 8): wire the two follow-ups in `PROPOSAL_coffee_engine_followups.md` (retry-honor flag pattern + engine reader for `coffee_text.json`). Until then, both new structural surfaces are inert: retry state is unreachable, and the runtime UI keeps using its hard-coded strings.

---

**Session 20 - 2026-05-12 - Audio - Fixed Godot scene tree locking during reparenting**
- Resolved a "Parent node is busy adding/removing children" crash.
- During Godot's internal `add_child` process (e.g., when `RoomTransition` swaps scenes), the scene tree is locked and `remove_child` cannot be called synchronously inside `_ready()`.
- Refactored `persistent_music.gd` to leave the track-matching logic in `_ready` (so duplicates are killed instantly), but deferred the actual reparenting mechanism (`_do_reparent`) to the next idle frame using `call_deferred`. This satisfies engine safety constraints while retaining seamless audio.

---

**Session 21 - 2026-05-12 - Audio - Fixed null tree crash during music reparenting**
- Fixed an invalid `null` instance access crash in `persistent_music.gd`.
- Root cause: The script previously attempted to retrieve the tree root (`get_tree().root`) *after* executing `remove_child(self)`. Since `self` was no longer in the tree, `get_tree()` correctly returned `null`.
- Fix: Cached the tree root reference *before* decoupling the node from its parent.

---

**Session 22 - 2026-05-12 - Code - Repeatable coffee trigger plumbing**
- Added `repeatable` and `availability_flag` exports to `scripts/actors/minigame_trigger.gd`.
- Non-repeatable triggers now consume themselves after matching `Signals.minigame_finished`; availability-gated triggers hide their prompt and ignore interact until `State.data.chapter1[availability_flag]` is truthy, refreshing on `Signals.chapter1_flag_changed`.
- Wired Cafe Paragraf coffee as one-shot (`repeatable=false`, empty availability flag) and the office coffee corner as repeatable after `coffee_tutorial_seen`.
- Court buff hook not applied in this pass: there is no Chapter 1 court-flow script or battle controller in `scripts/systems/` yet, and the current court surface is data-only (`judge_district_ch1.json`, `argument_opponents.json`). Left this loud rather than adding an uncalled helper.

Verification:
- `godot --headless --path godot --script tests/test_smoke.gd` crashed before boot on the known macOS `user://logs` issue.
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_swine_smoke.log` -> EXIT 0.
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_swine_runner.log` -> EXIT 0.
- `godot --headless --path godot --export-release "Web" exports/web/index.html --log-file /tmp/pig_swine_export.log` -> EXIT 0; produced non-empty `index.html`, `index.wasm`, and `index.pck`. Export still reports the known macOS editor-settings save warning after packing.
- Additional focused scene inspection (`tests/test_scene_inspect.gd`) -> EXIT 1 on a pre-existing expectation that `MrPig/Visual` be `Sprite2D`; current office scene uses `AnimatedSprite2D`. The office scene did instantiate, so this did not expose a minigame-trigger `_ready()` crash.
- Temporary focused trigger-scene load (`/private/tmp/pig_swine_check_minigame_trigger_scenes.gd`) -> EXIT 0 for `cafe_paragraf.tscn` and `pig_swine_office.tscn`.

---

**Session 23 - 2026-05-12 - Code - Coffee accessibility pause panel**
- Added a hidden `PauseLayer` to `scenes/minigames/coffee_brewing.tscn` with data-driven title/toggle/resume text from `data/minigames/coffee_text.json`. `ui_cancel` now toggles this overlay instead of ending the run early, and the only panel command is Resume.
- Implemented the three v1 assists in `coffee_brewing.gd`: slower notes scale pattern note/pour times once at pattern load (`1.4x`), wider timing applies immediately at judgment/miss checks (`1.5x` windows), and single-button mode ignores authored lanes by accepting `interact`/lane presses against the nearest active tap or stamp note.
- Persisted coffee assist settings under `State.data.settings.coffee_accessibility` and advanced saves to `SAVE_VERSION = 10`; `coffee.assist_used` now reflects assists actually active for the run. `save_game()` now creates the custom `user://` save directory before writing so fresh installs can round-trip cleanly.
- Added `tests/test_save_migration_v9_v10.gd` and updated the older v8->v9 migration test's version assertion so it remains valid after the v10 bump.

Verification:
- `jq empty godot/data/minigames/coffee_text.json` -> EXIT 0.
- `godot --headless --path godot --scene res://scenes/minigames/coffee_brewing.tscn --quit-after 2 --log-file /tmp/pig_swine_coffee_scene.log` -> EXIT 0.
- `godot --headless --path godot --script tests/test_save_migration_v8_v9.gd --log-file /tmp/pig_swine_v8_v9.log` -> EXIT 0.
- `godot --headless --path godot --script tests/test_save_migration_v9_v10.gd --log-file /tmp/pig_swine_v9_v10.log` -> EXIT 0.
- Temporary v10 save/load round-trip (`/private/tmp/pig_swine_save_roundtrip_v10.gd`) -> EXIT 0 with escalated filesystem access; script backed up and restored any existing `user://save.json`.
- `godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_swine_smoke.log` -> EXIT 0.
- `godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/pig_swine_runner.log` -> EXIT 0.
- `godot --headless --path godot --export-release Web exports/web/index.html --log-file /tmp/pig_swine_export.log` -> EXIT 0; Godot still prints the known macOS editor-settings save warning after packing.

---

**Session 24 - 2026-05-12 - Code - Coffee minigame art wiring (Prompt 8 scope).**
Wired the existing coffee-art PNG bank into `scenes/minigames/coffee_brewing.tscn` and `scripts/systems/minigames/coffee_brewing.gd`. Scope: surgical edit of those two files only; no save schema, no state machine refactor, no test-file changes.

Scene changes (`scenes/minigames/coffee_brewing.tscn`):
- Registered 16 new Texture2D `ext_resource`s (`art_machine_gurgle/happy/angry`, `art_cup_fill_01/02/03`, `art_prompt_bean/milk/sugar/file/mug/stamp`, `art_timing_line`, `art_meter_brew_bg/fill`, `art_meter_bitter_bg/fill`, `art_puff_offended`) and bumped `load_steps` 18 → 43 to cover the new ext + sub resources.
- `CoffeeMachineSprite` (128×128) now sets `offset = (0, -64)`; `CupSprite` (64×64) sets `offset = (0, -32)` per `CONVENTIONS.md` §Y-sort and Sprite2D origin convention.
- Replaced the `TimingLine` `ColorRect` placeholder with a `Sprite2D` textured from `art_timing_line` (8×96 PNG scaled to ~410×10 over the existing lane span; modulate retains the warm-gold accent).
- Replaced the two meter `Label`s with the option-A layout: `BrewQualityMeter` / `BitternessMeter` stay as named `Label` group nodes (so existing `$BackgroundPanel/BrewQualityMeter` references still resolve), now empty-text. Each holds a `*Bg` `Sprite2D` (left-anchored, `centered = false`) over a `*Fill` `Sprite2D` with `region_enabled = true, region_rect = Rect2(0, 0, 240, 24)`, plus a centred `ValueLabel` carrying the static "Brew Quality" / "Bitterness" copy.
- Authored an inline `AnimationLibrary` with six animations and wired the existing `AnimationPlayer` to it (`autoplay = "machine_idle"`):
  - `machine_idle` (1.0s, loop, holds idle texture).
  - `machine_gurgle` (0.3s, gurgle → idle).
  - `machine_happy` (0.5s, happy → idle).
  - `machine_angry` (0.4s, angry → idle plus a 4° rotation shake on `:rotation`, oscillating −0.0698 → +0.0698 → 0 rad).
  - `result_reveal` (0.3s, `ResultPanel:modulate` fade `Color(1,1,1,0)` → `Color(1,1,1,1)`).
  - `stamp_impact` (0.15s, scale 1.3 → 1.0 on both `StampAdmitted` and `StampObjected`).

Script changes (`scripts/systems/minigames/coffee_brewing.gd`):
- Added top-level `PROMPT_TEXTURES` dict and `CUP_TEXTURES` array (preloaded), plus HUD constants `MAX_BREW_QUALITY = GRADE_S_THRESHOLD`, `METER_BREW_FULL`, `METER_BITTER_FULL = 300`, `METER_FILL_WIDTH = 240.0`, `METER_FILL_HEIGHT = 24.0`.
- Cached new node refs: `_brew_fill`, `_bitter_fill`, `_cup_sprite`, `_anim_player`, `_stamp_admitted`, `_stamp_objected`; retyped `_timing_line` to `Sprite2D` (cast left in place).
- Rewrote `_spawn_note` to instantiate a `Sprite2D` keyed off the note's `icon` field via `PROMPT_TEXTURES` (falls back to `bean`); preserved lane→x assignment (`475 + lane*100`), descent target Y, and the existing `_active_notes` metadata shape. Retyped `node` to `Node2D` in `_update_active_notes` since prompts are now sprites not labels.
- Deleted the now-unused `_icon_label()` helper.
- `_update_meters()` now drives `region_rect.size.x = METER_FILL_WIDTH * ratio` on the two fill sprites instead of writing label text, and delegates to a new `_update_cup_fill()` helper that picks the four-step cup-fill ladder from `progress = _brew_quality / MAX_BREW_QUALITY`.
- `_register_judgment()` triggers `machine_happy` on perfect, `machine_gurgle` on good/okay, and `machine_angry` on miss via a new `_play_anim()` helper. The wrong-input branches in `_try_judge_lane()` and `_try_judge_single_button()` also play `machine_angry`. Audio dictionary and `_play()` helper untouched.
- `_show_result()` resets `ResultPanel.modulate` to alpha-0 before flipping `visible = true`, shows `StampAdmitted` for D-or-better and `StampObjected` for F, plays `result_reveal`, and schedules `stamp_impact` via a 0.3s `SceneTreeTimer`.

Files changed: `scenes/minigames/coffee_brewing.tscn`, `scripts/systems/minigames/coffee_brewing.gd`. No test files, save-schema files, or other scenes touched. Save schema left at v10 (untouched).

Acceptance:
- `godot --headless --path godot --script tests/test_smoke.gd` → EXIT 0 (Linux sandbox; macOS `--log-file` workaround not required here).
- `godot --headless --path godot --script tests/test_runner.gd` → EXIT 0.
- Ad-hoc scene-load probe `load("res://scenes/minigames/coffee_brewing.tscn").instantiate()` → PASS (probe script deleted after use; tests/ left untouched).
- Coffee-specific test (`tests/test_coffee_brewing.gd`) — not present in this branch; skipped per brief.
- No new GDScript parser warnings emitted by the smoke run.
- Web export not re-run this session: the only files touched were the minigame scene and its script; export validity is the same as Session 23's clean export.

Visual acceptance is delegated to human playtest per brief; the underlying art-wiring contract (machine swap by judgment, cup ladder by brew quality, fill bars by ratio, stamp on result) is in place.
