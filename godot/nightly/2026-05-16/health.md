# Nightly Health — 2026-05-16

## Reversibility Snapshot
SKIPPED — `.git/index.lock` exists and is not removable from the sandbox
(`Operation not permitted`). Another git process (likely the user's editor)
is holding the repo lock. No snapshot commit was created. No working-tree
changes were made by this run.

## Test Results
SKIPPED — Godot 4.6.2 binary is not installed in the automation sandbox
(`which godot` → not found), and the `mcp__godot__*` toolset exposes only
project introspection / launch tools, not a script runner. Headless tests
cannot be executed from this environment.

Test files discovered (45 total): test_asia_progression, test_battle_controller,
test_chapter1_flag_coverage, test_chapter1_motion_packet_full_path,
test_chapter1_phase_b, test_chapter1_v17_flag_coverage, test_coffee_brewing,
test_court_packet_scoring, test_dialogue_box_dismissal_signal,
test_dialogue_runner, test_dialogue_typewriter, test_effectiveness,
test_halina_intro_chain, test_input_check, test_interaction_prompt,
test_motion_packet_assembly, test_npc, test_npc_animation_canon,
test_npc_presence, test_office_wall_visibility, test_pickup_items_data,
test_player_animation, test_player_diagonal_normalised, test_player_sprint,
test_postcard_swine_chain, test_room_transition, test_runner,
test_save_migration_v10_v11, test_save_migration_v11_v12,
test_save_migration_v12_v13, test_save_migration_v13_v14,
test_save_migration_v14_v15, test_save_migration_v16_v17,
test_save_migration_v17_v18, test_save_migration_v18_v19,
test_save_migration_v7_v8, test_save_migration_v8_v9,
test_save_migration_v9_v10, test_scene_inspect, test_smoke,
test_sprite_frames, test_visual_capture, test_visual_smoke,
test_wall_colliders, test_ysort_canon.

## Voice Audit
PASS — 40 files / 24,812 records scanned; 0 violations, 0 JSON errors,
0 normalization needs, 0 duplicates.

## JSON Validity
PASS — 45 files under `godot/data/` parsed cleanly.

## Print Statements (runtime only)
None — no `print(` calls in `godot/scripts/**/*.gd`.

## Godot MCP
Connected — Godot 4.6.2.stable.official.71f334935 (scenes: 12, scripts: 97,
assets: 560).

## Action Required
- Headless test runner is unreachable from nightly automation. Either
  (a) install Godot in the sandbox image, (b) add an `mcp__godot__run_script`
  tool, or (c) downgrade nightly to "static checks only" and remove the
  test-suite section from the skill. Until then this report cannot certify
  test status.
- Investigate the stale `.git/index.lock` — if it persists when no editor is
  open, it's a crashed git process and should be cleaned up manually so
  future nightly snapshots can run.
