# Nightly Health — 2026-05-17

## Snapshot Commit
SKIPPED — stale `.git/HEAD.lock` (dated May 16) cannot be removed from this sandbox mount (Operation not permitted). Subsequent `git commit --allow-empty` failed with the standard "another git process seems to be running" message. Read-only checks proceeded regardless. **Recommend:** remove `.git/HEAD.lock` and `.git/index.lock.stale.*` manually on the host before tomorrow's run.

## Test Results
| Test | Result | Note |
|------|--------|------|
| (all 44 `tests/test_*.gd`) | NOT RUN | Godot binary unavailable in this sandbox. Headless test suite requires execution on the macOS host. |

Test files discovered (44): `test_asia_progression`, `test_battle_controller`, `test_chapter1_flag_coverage`, `test_chapter1_motion_packet_full_path`, `test_chapter1_phase_b`, `test_chapter1_v17_flag_coverage`, `test_coffee_brewing`, `test_court_packet_scoring`, `test_dialogue_box_dismissal_signal`, `test_dialogue_runner`, `test_dialogue_typewriter`, `test_effectiveness`, `test_halina_intro_chain`, `test_input_check`, `test_interaction_prompt`, `test_motion_packet_assembly`, `test_npc`, `test_npc_animation_canon`, `test_npc_presence`, `test_office_wall_visibility`, `test_pickup_items_data`, `test_player_animation`, `test_player_diagonal_normalised`, `test_player_sprint`, `test_postcard_swine_chain`, `test_room_transition`, `test_runner`, `test_save_migration_v7_v8` through `v18_v19` (12 migration tests), `test_scene_inspect`, `test_smoke`, `test_sprite_frames`, `test_visual_capture`, `test_visual_smoke`, `test_wall_colliders`, `test_ysort_canon`.

## Voice Audit
PASS — 40 files audited, 24,812 records scanned, 0 violations, 0 JSON errors, 0 normalization issues, 0 duplicates.

## JSON Validity
PASS — all 50 `.json` files under `godot/data/` parse cleanly.

## Print Statements (runtime only)
None — no `print(` matches in `godot/scripts/**/*.gd` (31 files scanned).

## Godot MCP
Connected — Godot 4.6.2.stable.official.71f334935 (project: 12 scenes, 97 scripts, 565 assets).

## Action Required
1. **Headless test suite did not run.** The nightly schedule executes inside a Linux sandbox without the Godot binary, so the `--script tests/*.gd` step is structurally unavailable. Either (a) install Godot in the sandbox, (b) run the suite on the host and have the scheduled task only consume the results, or (c) drop the test-run requirement from this nightly. As written, this check will fail every night.
2. **Stale git locks** in `.git/`: `HEAD.lock` (May 16) and `index.lock.stale.*` (May 16). Sandbox lacks unlink permission. Remove on the host so future snapshots succeed.
