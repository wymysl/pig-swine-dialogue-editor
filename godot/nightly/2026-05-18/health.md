# Nightly Health — 2026-05-18

## Snapshot Commit
SKIPPED — stale `.git/index.lock`, `.git/HEAD.lock`, and `.git/index.lock.stale.1778947302694921369` are still present from prior runs and cannot be removed from this sandbox mount (`Operation not permitted`). `git commit --allow-empty` fails with "Another git process seems to be running". Read-only checks proceeded regardless. **Recommend:** remove the three lock files manually on the host so future snapshots succeed.

## Test Results
| Test | Result | Note |
|------|--------|------|
| (all 46 `tests/test_*.gd`) | NOT RUN | Godot binary unavailable in this sandbox. The MCP host has Godot 4.6.2 but there is no MCP entry point that runs an individual headless script — only `run_project` (full game) is exposed. |

Test files discovered (46): `test_asia_progression`, `test_battle_controller`, `test_case_folder`, `test_chapter1_flag_coverage`, `test_chapter1_motion_packet_full_path`, `test_chapter1_phase_b`, `test_chapter1_v17_flag_coverage`, `test_coffee_brewing`, `test_court_packet_scoring`, `test_dialogue_box_dismissal_signal`, `test_dialogue_runner`, `test_dialogue_typewriter`, `test_effectiveness`, `test_halina_intro_chain`, `test_input_check`, `test_interaction_prompt`, `test_motion_packet_assembly`, `test_npc`, `test_npc_animation_canon`, `test_npc_presence`, `test_office_wall_visibility`, `test_pickup_items_data`, `test_player_animation`, `test_player_diagonal_normalised`, `test_player_sprint`, `test_postcard_swine_chain`, `test_room_transition`, `test_runner`, `test_save_migration_v7_v8` through `test_save_migration_v19_v20` (13 migration tests), `test_scene_inspect`, `test_smoke`, `test_sprite_frames`, `test_visual_capture`, `test_visual_smoke`, `test_wall_colliders`, `test_ysort_canon`.

New since 2026-05-17: `test_case_folder`, `test_save_migration_v19_v20`.

## Voice Audit
PASS — 40 files audited, 24,812 records scanned, 0 violations, 0 JSON errors, 0 normalization issues, 0 duplicates.

## JSON Validity
PASS — all 52 `.json` files under `godot/data/` parse cleanly (+2 since 2026-05-17).

## Print Statements (runtime only)
None — no `print(` matches in `godot/scripts/**/*.gd` (34 files scanned, +3 since 2026-05-17).

## Godot MCP
Connected — Godot 4.6.2.stable.official.71f334935 (project: 13 scenes, 102 scripts, 994 assets).

## Action Required
1. **Headless test suite still not running.** Same structural blocker as prior nights: the scheduled task executes inside a Linux sandbox without the Godot binary, so `godot --headless --script tests/*.gd` is unavailable. Options unchanged: (a) install Godot in the sandbox, (b) run the suite on the host and have this task only consume results, or (c) drop the test-run step from this nightly. As written, this check will continue failing every night.
2. **Stale git locks** in `.git/`: `index.lock`, `HEAD.lock`, and `index.lock.stale.1778947302694921369`. Sandbox lacks `unlink` permission. Remove on the host so the nightly reversibility snapshot succeeds.
