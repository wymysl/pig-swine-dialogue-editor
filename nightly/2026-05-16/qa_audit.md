# QA Audit — 2026-05-16

Generated: 2026-05-16 09:42:15 
Audited HEAD before report commit: `0bf6216` (`0bf6216` if unchanged while writing).

## Summary (read first)
Overall verdict: **REGRESSION, but not a catastrophic build break**. The project still launches headlessly and exports web artifacts, JSON and most cross-reference surfaces are structurally coherent, and the v17 court/evidence/frame data mostly aligns. The current tree has 3 failing test commands out of 41, live address-form violations in `murrow.json`, and registry drift around `murrow_choice`/enum defaults. Also, this is a rerun of the earlier Agent 9 audit because Agent 12 and Agent 5 landed after the 06:07 audit snapshot.

Top concerns:
1. `test_chapter1_v17_flag_coverage.gd` fails with a GDScript type error at line 246 and then reports `chapter1.murrow_choice` missing from `chapter1.json` registry.
2. `test_dialogue_runner.gd` fails T17: the isolated Asia V1.A hint expected the Mr. Pig hint but dispatches fallback `[...]`, likely due current `asia_hint_states_ch1.json` trigger/order drift.
3. Live address-form violations remain in `godot/data/dialogues/murrow.json`: `Doctor Cula` runtime lines and Asia saying `Mr. Cula`.

Things that worked unusually well:
1. Full web export exits 0 and produces non-empty `index.html`, `index.wasm`, and `index.pck`.
2. New v17 structural data passes JSON validity, tag taxonomy, evidence-id, frame-id, and court-round citation checks.
3. Schema drift is constrained: `state.gd`, `save.gd`, `Main.tscn`, and `tag_taxonomy.json` are unchanged since `bc45550`; `signals.gd` has only Agent 1’s permitted `judge_skepticism_raised` signal addition.

## Cohort delivery
| Agent | Role | Commit / report | Status | Notes |
|---:|---|---|---|---|
| 1 | Code | `603f65e` | LANDED | Battle controller restored; report is under `godot/nightly/2026-05-16/agent1_done.md`. |
| 2 | Design/Code data | `8de0ec2` | LANDED | Court-round data landed; report at root nightly. |
| 3 | Code/QA registry | `2f7a81b` | LANDED | v17 registry/test landed; test currently fails. |
| 4 | Design Crab | `8de0ec2` shared | LANDED | Crab final draft committed in same commit as Agent 2 due shared-index contention. |
| 5 | Design Murrow | `0bf6216` | LANDED LATE | Landed after prior QA audit; included in this rerun. |
| 6 | Design Whimsy | no report; untracked final draft | MISSING / PARTIAL | `godot/data/_drafts/whimsy_player_driven_final_2026-05-16.json` exists untracked; no agent6 done-report found. |
| 7 | Design Asia hints | `b40168a` | LANDED | Report is under `godot/nightly/2026-05-16/agent7_done.md`. |
| 8 | Tooling | `81f82ae` actual | LANDED | Report says `4b91f68`, but git log shows `81f82ae`; hash mismatch needs provenance cleanup. |
| 10 | Repo hygiene | `05d10b6`, `ef68acd` | PARTIAL | Scratch relocation and lock docs landed; dialogue-orphan cleanup halted for human decision. |
| 11 | Governance proposal | `0c7ed07` | LANDED | Report/proposal only. |
| 12 | Code Binder UI | `b790554` | LANDED LATE | Landed after prior QA audit; included here. Generated `.uid` files are untracked. |

Agents that did not fully deliver: Agent 6 lacks a done-report/commit for the expected final Whimsy pass; Agent 10 intentionally halted one cleanup category; Agent 8 has a reported-vs-actual commit hash mismatch.

## Headless test sweep
| Result | Count |
|---|---:|
| Total commands run | 41 |
| Exit 0 | 38 |
| Failed | 3 |

| Command key | Exit | Log | Key note |
|---|---:|---|---|
| `v17_coverage` | `1` | `/tmp/agent9_v17_coverage.log` |   PASS: 'chapter1.binder_read_envelope' registry default is false /   PASS: 'chapter1.binder_read_renewal' registry default is false /   PASS: 'chapter1.binder_read_renumbering' registry default is false / SCRIPT ERROR: Invalid operands 'String' and 'bool' in  |
| `dialogue` | `1` | `/tmp/agent9_dialogue.log` | [TestDialogueRunner] PASS: T15: set + award_badge + unlock_route coexist in one on_dismiss / WARNING: DialogueRunner: award_badge unknown badge_id 'nonexistent_badge_xyz'; declare it in State.reset_state().badges first /    at: push_warning (core/variant/varia |
| `extra_test_chapter1_flag_coverage` | `1` | `/tmp/agent9_extra_test_chapter1_flag_coverage.log` | Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org /  / [Chapter1FlagCoverage] UNREFERENCED: chapter1.has_law_binder \| set_by: pickup.gd via items.json procedural_binder / [Chapter1FlagCoverage] UNREFERENCED: chapter1.has_rights_memo \| set |

Passing required highlights: `smoke`, `runner`, migrations v8→v9 through v16→v17, `battle`, `effectiveness`, `phase_b`, `halina`, `postcard`, `pickup`, `ysort`, `inspect`, and `export` all exited 0. All extra tests except `test_chapter1_flag_coverage.gd` exited 0.

Per-failure notes:
- `v17_coverage`: crashes at `godot/tests/test_chapter1_v17_flag_coverage.gd:246` with `Invalid operands String and bool in operator ==`; it also reports `chapter1.murrow_choice` missing from `new_state_flags`. Suggested next step: fix the test’s bool detection and add the missing registry entry rather than reverting v17 wholesale.
- `dialogue`: T17 expected `You should talk to Mr. Pig first...` but received fallback `[...]`. Suggested next step: inspect `godot/data/dialogues/asia_hint_states_ch1.json` trigger priority and the isolated test fixture assumptions.
- `extra_test_chapter1_flag_coverage`: older coverage test treats 11 v17/runtime-owned flags as unreferenced because their `set_by` prose lacks one of the test’s non-dialogue markers. Suggested next step: update marker logic for v17 Code-owned flags or retire/split the stale test.

## Cross-reference audit
| Dimension | Verdict | Summary |
|---|---|---|
| JSON validity | PASS | 44 `godot/data/**/*.json` files parse with `python3 -m json.tool`; 0 failures. |
| `chapter1.*` flag references | WARN | Runtime refs resolve after filtering documented false positives (`chapter1.json`, `chapter1.get`, `chapter1.foo`) and one deliberate test fallback `chapter1.unused_scene_flag`; drafts contain unresolved proposal-only flags listed below. |
| Tag taxonomy | PASS | 53 closed-list tags; 0 unknown tag references in scanned JSON fields. |
| Evidence / frame / citation IDs | PASS | 5 court-round `evidence_id` refs resolve to 8 evidence cards; 4 frame gates resolve to `argument_frames_ch1`; all Phase 2 `available_citations[].move_id` values resolve to judgment moves. Opponent `move_id`s are intentionally a separate namespace. |
| Enum values | FAIL | `proposed_frame` and `whimsy_co_counsel_posture` are clean; `murrow_choice` is missing from registry, and `client_meeting_stance` / `bonus_evidence_collected` registry enums omit the empty default. |
| Address forms | FAIL | Runtime `murrow.json` still contains forbidden `Doctor Cula` and `Mr. Cula`. Grep also finds stale notes documenting those issues. |

Flag-reference details:
- Runtime false positives: `chapter1.json` filename references, `chapter1.get(...)` GDScript dictionary calls, and `chapter1.foo` in a comment example are not state flags.
- Deliberate test-only fallback: `godot/tests/test_pickup_items_data.gd:50` sets `chapter1.unused_scene_flag` before item hydration replaces it with `chapter1.has_law_binder`.
- Draft-only unresolved flags: `chapter1.closing_order` in Murrow drafts is a documented v2 handoff; `chapter1.murrow_beat9_dwell`, `chapter1.article_135bis_understood`, and `chapter1.client_fee_collected` are older draft/proposal flags, warn-only.

Address-form hits requiring attention:
| File | Line | Pattern | Context |
|---|---:|---|---|
| `godot/data/dialogues/murrow.json` | 8 | `Doctor Cula` | runtime Murrow line |
| `godot/data/dialogues/murrow.json` | 93 | `Doctor Cula` | runtime coffee-reaction line |
| `godot/data/dialogues/murrow.json` | 110 | `Mr. Cula` | runtime Asia line |
| `godot/data/dialogues/murrow.md` | 9 | `Doctor Cula` | stale dialogue-sidecar note |
| `godot/data/_drafts/nightly_dialogue_fixes_2026-05-15.json` | 6 | `Mr. Cula` | draft fix record quoting current bad line |

Asia outer-circle note: live Asia hint lines generally use `Mr. Murrow`; bare `Cula` occurrences in `asia.json` are mostly quoted sticky-note text or player-choice text, not Asia addressing Cula. The actual Asia-address failure is `murrow.json:110` (`Mr. Cula`).

## Enum consistency
| Flag | Declared | Used | Verdict |
|---|---|---|---|
| `chapter1.proposed_frame` | `['', 'defective_service_135bis', 'third_party_non_cure', 'fair_hearing_article_6', 'merits_defence']` | `['defective_service_135bis', 'merits_defence']` | PASS |
| `chapter1.whimsy_co_counsel_posture` | `['', 'procedural_throat', 'merits_pivot', 'open_register']` | `['merits_pivot', 'open_register', 'procedural_throat']` | PASS |
| `chapter1.client_meeting_stance` | `['sympathetic', 'blunt_procedural', 'technical']` | `['blunt_procedural', 'sympathetic', 'technical']` | WARN empty default omitted from enum |
| `chapter1.murrow_choice` | `None` | `['dry', 'friendly', 'professional']` | FAIL missing registry entry |
| `chapter1.state_choice` | `None` | `['dry', 'friendly', 'professional']` | WARN no `_enum`; used values mirror Murrow choices in `asia.json` |
| `chapter1.bonus_evidence_collected` | `['wojcik_witness_statement', 'return_to_sender_slip', 'lease_1962_inheritance_1987', 'landlord_contact']` | `['landlord_contact', 'lease_1962_inheritance_1987', 'return_to_sender_slip', 'wojcik_witness_statement']` | WARN empty default omitted from enum |

## Drafts inventory
| Draft file | Status | Notes |
|---|---|---|
| `godot/data/_drafts/asia_hints_player_driven_2026-05-16.json` | standalone |  |
| `godot/data/_drafts/asia_rewrite_2026-05-14.json` | standalone |  |
| `godot/data/_drafts/crab_player_driven_2026-05-15.json` | superseded | later: crab_player_driven_final_2026-05-16.json |
| `godot/data/_drafts/crab_player_driven_final_2026-05-16.json` | standalone |  |
| `godot/data/_drafts/halina_with_trust_meter.json` | standalone |  |
| `godot/data/_drafts/murrow_player_driven_2026-05-15.json` | superseded | later: murrow_player_driven_final_2026-05-16.json |
| `godot/data/_drafts/murrow_player_driven_final_2026-05-16.json` | standalone |  |
| `godot/data/_drafts/murrow_v2_2026-05-14.json` | standalone |  |
| `godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json` | standalone |  |
| `godot/data/_drafts/nightly_design_pig_2026-05-14.json` | standalone |  |
| `godot/data/_drafts/nightly_dialogue_fixes_2026-05-15.json` | standalone |  |
| `godot/data/_drafts/pig_rewrite_2026-05-14.json` | standalone |  |
| `godot/data/_drafts/whimsy_player_driven_2026-05-15.json` | superseded | later: whimsy_player_driven_final_2026-05-16.json |
| `godot/data/_drafts/whimsy_player_driven_final_2026-05-16.json` | standalone | standalone but untracked; likely Agent 6 partial delivery |

## Per-agent reconciliation
- Agent 1 controller reads `proposed_frame`, `judicial_patience`, `witness_cooperation`, `evidence_ch1`, and `argument_frames_ch1`; those surfaces exist and its focused battle test passes. It does not yet load Agent 2’s `data/court_rounds/chapter1_round_1.json` runtime schema; Agent 1 explicitly flagged that as a next Code pass, so this is not a regression.
- Agent 2 court-round data cross-references resolve structurally. Its court-round file is authored but not consumed by the current controller.
- Agent 3 registry mostly landed correctly, but its own v17 coverage test fails and `murrow_choice` remains absent from `chapter1.json`.
- Agent 4 Crab draft values for `chapter1.proposed_frame` resolve against registry/frame IDs.
- Agent 5 Murrow final draft resolves `chapter1.proposed_frame`; it also documents the live `murrow.json` Asia `Mr. Cula` typo. Landed after prior QA, now included.
- Agent 6 has no done-report; Whimsy final draft values resolve, but the file is untracked and should not be assumed landed.
- Agent 7 Asia hint draft values resolve against v17 flags and expected court-outcome strings, but the draft is not merged into live dialogue.
- Agent 8 editor change is tooling-only. The done-report hash does not match git log.
- Agent 10 hygiene work did not break runtime tests, but halted dialogue-orphan handling remains a human decision.
- Agent 11 governance proposal is documentation-only.
- Agent 12 Binder UI v0 introduced `BinderUI` autoload/input action and passes smoke/export in this combined rerun. The generated `.uid` files for its new scripts are untracked.

## Schema-drift findings
| File | Changed since `bc45550` | Verdict |
|---|---|---|
| `godot/scripts/autoload/state.gd` | False | PASS |
| `godot/scripts/systems/save.gd` | False | PASS |
| `godot/scripts/autoload/signals.gd` | True | PASS permitted Agent 1 signal addition |
| `godot/scenes/Main.tscn` | False | PASS |
| `godot/data/tag_taxonomy.json` | False | PASS |

## Web export
| File | Size | Status |
|---|---:|---|
| `godot/exports/web/index.html` | 5447 | OK |
| `godot/exports/web/index.wasm` | 37695054 | OK |
| `godot/exports/web/index.pck` | 16281920 | OK |

Export command exited 0, but log sanity is **FAIL** because `/tmp/agent9_export.log` contains 3 `ERROR:` lines: one macOS CA certificate warning and two editor-settings save errors. These appear environmental and non-blocking for artifact generation, but the assignment required zero `ERROR:` lines.

## Recommended next steps for Piotr
1. Fix `murrow.json` address forms first: replace runtime `Doctor Cula` with `Dr. A. Cula` where appropriate and Asia’s `Mr. Cula` with `Dr. A. Cula`. This is small, high-confidence, and removes a hard AGENTS.md violation.
2. Add `chapter1.murrow_choice` to `data/chapters/chapter1.json` `new_state_flags` and decide whether enum lists should include the empty default consistently for `client_meeting_stance` and `bonus_evidence_collected`.
3. Repair or update `tests/test_chapter1_v17_flag_coverage.gd` and `tests/test_chapter1_flag_coverage.gd`; both are now catching real drift plus stale assumptions, which makes the morning signal noisy.
4. Review Agent 6: either commit/stage the Whimsy final draft and write a done-report, or mark it as missing/partial. Do not let the untracked file become invisible work.
5. Decide whether Agent 2’s `chapter1_round_1.json` is intended to be runtime-loaded now or kept as authored handoff data for the next battle-controller pass.

No commit is obviously revert-worthy. If Piotr wants a clean green test suite immediately, the fastest path is targeted registry/test/address fixes rather than reverting Agent 1/2/12.

## Raw command output
Only failing-command and export slices are inlined here; full logs remain at `/tmp/agent9_*`.

### `v17_coverage`
```text
  PASS: 'chapter1.binder_read_envelope' registry default is false
  PASS: 'chapter1.binder_read_renewal' registry default is false
  PASS: 'chapter1.binder_read_renumbering' registry default is false
SCRIPT ERROR: Invalid operands 'String' and 'bool' in operator '=='.
   at: _test_bool_defaults_are_false (res://tests/test_chapter1_v17_flag_coverage.gd:246)
   GDScript backtrace (most recent call first):
       [0] _test_bool_defaults_are_false (res://tests/test_chapter1_v17_flag_coverage.gd:246)
       [1] _run_all (res://tests/test_chapter1_v17_flag_coverage.gd:41)
       [2] _init (res://tests/test_chapter1_v17_flag_coverage.gd:28)
[T6] v15/v16 flag regression
  PASS: chapter1.state_choice still declared in new_state_flags (v15 regression)
  FAIL: chapter1.murrow_choice MISSING from new_state_flags — pre-existing drift (v16 catch-up pending)
[T7] bonus_evidence_collected enum regression
  PASS: bonus_evidence_collected._enum contains 'wojcik_witness_statement'
  PASS: bonus_evidence_collected._enum contains 'return_to_sender_slip'
  PASS: bonus_evidence_collected._enum contains 'lease_1962_inheritance_1987'
  PASS: bonus_evidence_collected._enum contains 'landlord_contact'
[v17Coverage] FAILED: 16 / 63 tests failed
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### `dialogue`
```text
[TestDialogueRunner] PASS: T15: set + award_badge + unlock_route coexist in one on_dismiss
WARNING: DialogueRunner: award_badge unknown badge_id 'nonexistent_badge_xyz'; declare it in State.reset_state().badges first
   at: push_warning (core/variant/variant_utility.cpp:1034)
   GDScript backtrace (most recent call first):
       [0] _apply_mutations (res://scripts/autoload/dialogue_runner.gd:186)
       [1] _on_dialogue_dismissed (res://scripts/autoload/dialogue_runner.gd:142)
       [2] _init (res://tests/test_dialogue_runner.gd:397)
WARNING: DialogueRunner: unlock_route unknown route_id 'nonexistent_route_xyz'; declare it in State.reset_state().routes_unlocked first
   at: push_warning (core/variant/variant_utility.cpp:1034)
   GDScript backtrace (most recent call first):
       [0] _apply_mutations (res://scripts/autoload/dialogue_runner.gd:196)
       [1] _on_dialogue_dismissed (res://scripts/autoload/dialogue_runner.gd:142)
       [2] _init (res://tests/test_dialogue_runner.gd:397)
[TestDialogueRunner] PASS: T16: unknown badge_id / route_id rejected (warning logged, no crash, no state mutation)
[TestDialogueRunner] FAIL: T17: expected 'You should talk to Mr. Pig first. He's the loudest crisis in the room.' but got: ["..."]
[TestDialogueRunner] PASS: T18: V1.A state 7 (`recruited_whimsy && !halina_met`) dispatches canonical line
[TestDialogueRunner] PASS: T19: V1.A state 12 (default; chapter coda) dispatches canonical line
[TestDialogueRunner] PASS: T20: production judge open-round OR trigger dispatches bench prompt

[TestDialogueRunner] Results: 21 passed, 1 failed
```

### `extra_test_chapter1_flag_coverage`
```text
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[Chapter1FlagCoverage] UNREFERENCED: chapter1.has_law_binder | set_by: pickup.gd via items.json procedural_binder
[Chapter1FlagCoverage] UNREFERENCED: chapter1.has_rights_memo | set_by: pickup.gd via items.json rights_memo
[Chapter1FlagCoverage] UNREFERENCED: chapter1.halina_trust | set_by: dialogue_runner.gd trust_delta on options choices during Beat 8 client meeting (halina.json)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.archive_research_complete | set_by: Beat 9 archive research (not yet authored; flag declared for V1.A state 8 dispatch)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.casebook_judge_state | set_by: casebook engine — Beat 12 court orchestration
[Chapter1FlagCoverage] UNREFERENCED: chapter1.won_court | set_by: future court orchestration on Chapter 1 win; gates asia_hint_states_ch1.json hint_won_court / hint_received_swine_postcard
[Chapter1FlagCoverage] UNREFERENCED: chapter1.binder_read_envelope | set_by: dialogue_runner on_dismiss set actions in crab.json / murrow.json; v2 binder UI on evidence-card surface
[Chapter1FlagCoverage] UNREFERENCED: chapter1.binder_read_renewal | set_by: dialogue_runner on_dismiss set actions in crab.json / murrow.json; v2 binder UI on evidence-card surface
[Chapter1FlagCoverage] UNREFERENCED: chapter1.binder_read_renumbering | set_by: dialogue_runner on_dismiss set actions in crab.json / murrow.json; v2 binder UI on evidence-card surface
[Chapter1FlagCoverage] UNREFERENCED: chapter1.proposed_frame | set_by: crab.json synthesis options block write_path (SAVE_VERSION 17)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.whimsy_co_counsel_posture | set_by: whimsy.json before_meeting options block write_path (SAVE_VERSION 17)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.judicial_patience | set_by: future battle_controller.gd Phase 2 sub-controller (PROPOSALS.md §10)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.witness_cooperation | set_by: future battle_controller.gd Phase 1 sub-controller (PROPOSALS.md §10)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.beat13_complete | set_by: Beat 13 office payoff close
43 flags total, 29 dialogue-set, 3 engine-set, 11 unreferenced
[Chapter1FlagCoverage] FAIL: 11 flags are not set by dialogue and are not annotated as engine-set.
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### `export`
```text
[  98% ] savepack | Storing File: res://tests/test_smoke.gd.remap
[  98% ] savepack | Storing File: res://tests/test_sprite_frames.gd.remap
[  98% ] savepack | Storing File: res://tests/test_visual_capture.gd.remap
[  98% ] savepack | Storing File: res://tests/test_visual_smoke.gd.remap
[  98% ] savepack | Storing File: res://tests/test_wall_colliders.gd.remap
[  98% ] savepack | Storing File: res://tests/test_ysort_canon.gd.remap
[  98% ] savepack | Storing File: res://tools/add_sprint8_nodes.gd.remap
[  98% ] savepack | Storing File: res://tools/add_walls.gd.remap
[  98% ] savepack | Storing File: res://tools/copy_brain_images.gd.remap
[  98% ] savepack | Storing File: res://tools/generate_cula_frames.gd.remap
[  98% ] savepack | Storing File: res://.godot/global_script_class_cache.cfg
[  98% ] savepack | Storing File: res://icon.svg
[  98% ] savepack | Storing File: res://.godot/uid_cache.bin
[  98% ] savepack | Storing File: res://project.binary
[ DONE ] savepack

ERROR: Cannot save file '/Users/piotr/Library/Application Support/Godot/editor_settings-4.6.tres'.
   at: save (scene/resources/resource_format_text.cpp:1756)
ERROR: Error saving editor settings to /Users/piotr/Library/Application Support/Godot/editor_settings-4.6.tres
   at: save (editor/settings/editor_settings.cpp:1404)
```
