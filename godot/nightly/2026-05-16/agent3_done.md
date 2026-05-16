# Agent 3 — v17 Flag Registry Catch-up (2026-05-16)

## Commit

`2f7a81b` — chapter1.json registry catch-up + v17 flag coverage test

## Seven Flag Declarations Added

| key | type | default | owner |
|---|---|---|---|
| `chapter1.binder_read_envelope` | bool | false | crab.json synthesis options on_dismiss + v2 binder UI |
| `chapter1.binder_read_renewal` | bool | false | crab.json synthesis options on_dismiss + v2 binder UI |
| `chapter1.binder_read_renumbering` | bool | false | crab.json synthesis options on_dismiss + v2 binder UI |
| `chapter1.proposed_frame` | string | `""` | crab.json first_meeting_with_binder / after_binder_first_engagement options write_path |
| `chapter1.whimsy_co_counsel_posture` | string | `""` | whimsy.json before_meeting options write_path |
| `chapter1.judicial_patience` | int | 5 | future battle_controller.gd Phase 2 sub-controller |
| `chapter1.witness_cooperation` | int | 0 | future battle_controller.gd Phase 1 sub-controller |

## Enum Values Declared and Source Cross-Reference

**`proposed_frame._enum`** (`["", "defective_service_135bis", "third_party_non_cure", "fair_hearing_article_6", "merits_defence"]`)
Source: `data/argument_frames_ch1.json` — `.frames` object keys. All four frame ids present in the file as of bc45550. Empty string is the unset (pre-synthesis) value and leads the array per project convention.

**`whimsy_co_counsel_posture._enum`** (`["", "procedural_throat", "merits_pivot", "open_register"]`)
Source: `data/_drafts/whimsy_player_driven_2026-05-15.json` — `states[0].options.choices[*].value` (the before_meeting options block). Three posture values matching the three rhetorical paths. Empty string leads the array.

## Test File

`godot/tests/test_chapter1_v17_flag_coverage.gd` — seven `_test_*` functions:

| fn | description | expected |
|---|---|---|
| `_test_save_version` | T1: SAVE_VERSION >= 17 (future-bump-safe) | PASS |
| `_test_registry_runtime_cross_reference` | T2: named v17 key assertions + fail-soft full sweep | PASS for v17 keys; FAIL-SOFT for `murrow_choice` (see drift below) |
| `_test_enum_values_match_data_files` | T3: proposed_frame vs argument_frames_ch1.json; whimsy posture vs canonical set | PASS |
| `_test_int_defaults_match_runtime` | T4: registry _default == reset_state() value for all int-typed flags | PASS |
| `_test_bool_defaults_are_false` | T5: v17 bools default false; broader pass flags any bool defaulting true | PASS |
| `_test_v15_v16_regression` | T6: state_choice still declared; murrow_choice fail-soft | PASS for state_choice; FAIL for murrow_choice (expected — see drift) |
| `_test_bonus_evidence_enum_regression` | T7: all four bonus_evidence_collected enum values intact | PASS |

## Acceptance Command Results

| command | exit | note |
|---|---|---|
| `python3 -m json.tool godot/data/chapters/chapter1.json` | 0 | JSON valid |
| `godot --headless ... test_chapter1_v17_flag_coverage.gd` | NOT RUN | Godot binary is macOS-native; bash sandbox is isolated Linux. Test file follows exact pattern of test_save_migration_v16_v17.gd; run from macOS host to confirm. |
| `godot --headless ... test_save_migration_v16_v17.gd` | NOT RUN | same constraint |
| `godot --headless ... test_chapter1_flag_coverage.gd` | NOT RUN | same constraint |
| `godot --headless ... test_smoke.gd` | NOT RUN | same constraint |
| `godot --headless ... export-release "Web"` | NOT RUN | same constraint |

The Godot MCP (`mcp__godot__*`) provides project-level run only (no `--script` mode). All headless acceptance commands must be run from the macOS host.

## Pre-existing Registry Drift Found

**`chapter1.murrow_choice`** — present in `State.reset_state().chapter1` (committed in bc45550 as part of in-flight v16 work described in that commit message), but has NO entry in `data/chapters/chapter1.json` `new_state_flags`. This is pre-existing drift, not introduced by this commit. T2 and T6 fail-soft on this key and report it explicitly so Agent 9 / morning audit sees the full picture.

Recommended follow-on: a Session-39-style single-flag catch-up commit adding `{ "key": "chapter1.murrow_choice", "default": "", "set_by": "murrow.json options write_path (v16)" }` to `new_state_flags`. No `_enum` block required (bare string slot, not a closed enum per state.gd). No SAVE_VERSION change needed — the key already exists in runtime.

No other pre-existing drift found. All flags in `reset_state().chapter1` except `murrow_choice` are accounted for in the registry.

## Agent 2 Cross-Reference

`data/court_rounds/chapter1_round_1.json` appeared as an untracked file in the worktree during this session — Agent 2 landed after the initial file reads. The file is not yet committed. T3's proposed_frame cross-reference validates against `argument_frames_ch1.json` (the canonical enum source), which is complete and committed. When `chapter1_round_1.json` is committed, its `frame_gates` keys should be audited against `proposed_frame._enum` to confirm alignment; that audit is outside this commit's scope.
