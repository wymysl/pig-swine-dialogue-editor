# Nightly Health — 2026-05-15

## Test Results
| Test | Result | Note |
|------|--------|------|
| (all 38 test_*.gd files) | SKIPPED | `godot` binary not on PATH in the nightly-task sandbox; headless suite could not be executed |

Test files discovered (38): test_asia_progression, test_chapter1_flag_coverage, test_chapter1_phase_b, test_coffee_brewing, test_dialogue_box_dismissal_signal, test_dialogue_runner, test_dialogue_typewriter, test_effectiveness, test_halina_intro_chain, test_input_check, test_interaction_prompt, test_npc, test_npc_animation_canon, test_npc_presence, test_office_wall_visibility, test_pickup_items_data, test_player_animation, test_player_diagonal_normalised, test_player_sprint, test_postcard_swine_chain, test_room_transition, test_runner, test_save_migration_v7_v8, test_save_migration_v8_v9, test_save_migration_v9_v10, test_save_migration_v10_v11, test_save_migration_v11_v12, test_save_migration_v12_v13, test_save_migration_v13_v14, test_save_migration_v14_v15, test_save_migration_v16_v17, test_scene_inspect, test_smoke, test_sprite_frames, test_visual_capture, test_visual_smoke, test_wall_colliders, test_ysort_canon.

## Voice Audit
PASS — 40 files / 24,812 records scanned, 0 violations, 0 JSON errors, 0 normalization issues, 0 duplicates.

## JSON Validity
PASS — 38/38 JSON files under `godot/data/` parse cleanly.

## Print Statements (runtime only)
None — no `print(` matches in `godot/scripts/**/*.gd`.

## Godot MCP
Connected — Godot 4.6.2.stable.official.71f334935. Project structure: 11 scenes, 88 scripts, 560 assets.

## Action Required
- Headless test suite not run: `godot` binary is unavailable in the scheduled-task sandbox shell (`which godot` returns `command not found`). The Godot MCP server is reachable, but it exposes no test-runner entry point. Options: (a) install Godot in the sandbox image, (b) add an `mcp__godot__run_test_script` tool, or (c) run the suite manually on host. Until resolved, nightly test status will remain SKIPPED.
- Reversibility snapshot step skipped: stale `.git/index.lock` in repo could not be removed (sandbox filesystem permits create but not delete on this mount). Recommend clearing the lock on host: `rm /Users/piotr/Documents/Silly projects/pig-swine-rpg/.git/index.lock`.
