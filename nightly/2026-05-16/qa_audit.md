# QA Audit — 2026-05-16

## Summary (read first)
REGRESSION: headless sweep completed, but 3/41 commands failed and static QA found enum/address-form drift. The web export command produced artifacts, but export-log sanity fails because the log contains `ERROR:` lines.

Top concerns:
1. `test_dialogue_runner.gd` fails on Asia hint dispatch after uncommitted `asia_hint_states_ch1.json` now gates the first hint on `chapter1.met_asia`.
2. `test_chapter1_v17_flag_coverage.gd` fails on registry drift, including missing `chapter1.murrow_choice`, and also has a test bug comparing String defaults to bool.
3. Address-form audit finds live `murrow.json` spoken lines using forbidden `Doctor Cula` / `Mr. Cula`, including one Asia-spoken line.

Worked well:
1. Godot CLI was available; smoke, save migrations, battle controller, effectiveness, scene, pickup, and web export all ran.
2. Casebook/court tags, evidence ids, frame ids, and move ids resolve cleanly across the v17 data files.
3. `state.gd`, `save.gd`, `Main.tscn`, and `tag_taxonomy.json` show no schema drift from `bc45550`; only Agent 1's permitted signal addition is present.

Audit basis: current dirty working tree at cutoff, not clean HEAD. Existing uncommitted edits are included in test/static results.

## Cohort delivery
| Agent | Role | Commit | Subject | Status |
| --- | --- | --- | --- | --- |
| 1 | Code / battle | 603f65e | Restore battle_controller and wire Phase 1 / Phase 2 (v17) | LANDED; report in `godot/nightly` |
| 2 | Court data | 8de0ec2 | Court round data: Chapter 1 Phase 1 + Phase 2 | LANDED |
| 3 | Registry / QA test | 2f7a81b | chapter1.json registry catch-up + v17 flag coverage test | LANDED; report in `godot/nightly` |
| 4 | Crab draft | 8de0ec2 + ba6c094 | Crab final draft committed with court data; initial combined draft commit exists | LANDED with commit/report mismatch |
| 5 | Murrow draft | ba6c094? | Murrow player-driven draft included in combined design commit | NO REPORT |
| 6 | Whimsy draft | ba6c094? + untracked final | Initial Whimsy draft committed; final Whimsy draft is untracked | NO REPORT |
| 7 | Asia hints | b40168a | Asia hint surface: player-driven argument signposts (draft) | LANDED; report in `godot/nightly` |
| 8 | Dialogue editor | 81f82ae | Dialogue Editor: enum-value validation for v17 write paths | LANDED; report says `4b91f68`, actual commit is `81f82ae` |
| 10 | Repo hygiene | 05d10b6 / ef68acd | Scratch relocation + lock-stale documentation | LANDED + HALTED category 3 |
| 11 | Governance proposal | 0c7ed07 | Proposal: CONVENTIONS and AGENTS sync | LANDED; report says pending |
| 12 | Unknown | — | No visible commit/report by cutoff | MISSING |

Visible reports: `godot/nightly/2026-05-16/agent1_done.md`, `godot/nightly/2026-05-16/agent3_done.md`, `godot/nightly/2026-05-16/agent7_done.md`, `nightly/2026-05-16/agent10_dialogue_orphan_blocked.md`, `nightly/2026-05-16/agent10_done.md`, `nightly/2026-05-16/agent10_lock_files_for_piotr.md`, `nightly/2026-05-16/agent11_done.md`, `nightly/2026-05-16/agent2_done.md`, `nightly/2026-05-16/agent4_done.md`, `nightly/2026-05-16/agent8_done.md`.

## Headless test sweep
38/41 commands passed. Failures: `tests/test_chapter1_v17_flag_coverage.gd`, `tests/test_dialogue_runner.gd`, `tests/test_chapter1_flag_coverage.gd`.
| Command | Status | Exit | Key counts | Log |
| --- | --- | --- | --- | --- |
| tests/test_smoke.gd | PASS | 0 |  | /tmp/agent9_smoke.log |
| tests/test_runner.gd | PASS | 0 | GUT placeholder | /tmp/agent9_runner.log |
| tests/test_save_migration_v8_v9.gd | PASS | 0 | 6 passed / 0 failed | /tmp/agent9_v8.log |
| tests/test_save_migration_v9_v10.gd | PASS | 0 | 6 passed / 0 failed | /tmp/agent9_v9.log |
| tests/test_save_migration_v10_v11.gd | PASS | 0 | 6 passed / 0 failed | /tmp/agent9_v10.log |
| tests/test_save_migration_v11_v12.gd | PASS | 0 | 7 passed / 0 failed | /tmp/agent9_v11.log |
| tests/test_save_migration_v12_v13.gd | PASS | 0 | 26 / 26 pass | /tmp/agent9_v12.log |
| tests/test_save_migration_v13_v14.gd | PASS | 0 | 25 / 25 pass | /tmp/agent9_v13.log |
| tests/test_save_migration_v14_v15.gd | PASS | 0 | 29 / 29 pass | /tmp/agent9_v14.log |
| tests/test_save_migration_v16_v17.gd | PASS | 0 | 61 / 61 pass | /tmp/agent9_v17.log |
| tests/test_chapter1_v17_flag_coverage.gd | FAIL | 1 |  | /tmp/agent9_v17_coverage.log |
| tests/test_battle_controller.gd | PASS | 0 | 18 passed / 0 failed | /tmp/agent9_battle.log |
| tests/test_effectiveness.gd | PASS | 0 | 10 passed / 0 failed | /tmp/agent9_eff.log |
| tests/test_dialogue_runner.gd | FAIL | 1 | 21 passed / 1 failed | /tmp/agent9_dialogue.log |
| tests/test_chapter1_phase_b.gd | PASS | 0 | 16 passed / 0 failed | /tmp/agent9_phase_b.log |
| tests/test_halina_intro_chain.gd | PASS | 0 | 9 passed / 0 failed | /tmp/agent9_halina.log |
| tests/test_postcard_swine_chain.gd | PASS | 0 | 15 passed / 0 failed | /tmp/agent9_postcard.log |
| tests/test_pickup_items_data.gd | PASS | 0 | 7 passed / 0 failed | /tmp/agent9_pickup.log |
| tests/test_ysort_canon.gd | PASS | 0 |  | /tmp/agent9_ysort.log |
| tests/test_scene_inspect.gd | PASS | 0 |  | /tmp/agent9_inspect.log |
| tests/test_asia_progression.gd | PASS | 0 | 3 passed / 0 failed | /tmp/agent9_test_asia_progression.log |
| tests/test_chapter1_flag_coverage.gd | FAIL | 1 |  | /tmp/agent9_test_chapter1_flag_coverage.log |
| tests/test_coffee_brewing.gd | PASS | 0 | 10 passed / 0 failed | /tmp/agent9_test_coffee_brewing.log |
| tests/test_dialogue_box_dismissal_signal.gd | PASS | 0 | 3 passed / 0 failed | /tmp/agent9_test_dialogue_box_dismissal_signal.log |
| tests/test_dialogue_typewriter.gd | PASS | 0 |  | /tmp/agent9_test_dialogue_typewriter.log |
| tests/test_input_check.gd | PASS | 0 |  | /tmp/agent9_test_input_check.log |
| tests/test_interaction_prompt.gd | PASS | 0 |  | /tmp/agent9_test_interaction_prompt.log |
| tests/test_npc.gd | PASS | 0 | 5 passed / 0 failed | /tmp/agent9_test_npc.log |
| tests/test_npc_animation_canon.gd | PASS | 0 |  | /tmp/agent9_test_npc_animation_canon.log |
| tests/test_npc_presence.gd | PASS | 0 | 11 passed / 0 failed | /tmp/agent9_test_npc_presence.log |
| tests/test_office_wall_visibility.gd | PASS | 0 |  | /tmp/agent9_test_office_wall_visibility.log |
| tests/test_player_animation.gd | PASS | 0 |  | /tmp/agent9_test_player_animation.log |
| tests/test_player_diagonal_normalised.gd | PASS | 0 |  | /tmp/agent9_test_player_diagonal_normalised.log |
| tests/test_player_sprint.gd | PASS | 0 |  | /tmp/agent9_test_player_sprint.log |
| tests/test_room_transition.gd | PASS | 0 |  | /tmp/agent9_test_room_transition.log |
| tests/test_save_migration_v7_v8.gd | PASS | 0 | 8 passed / 0 failed | /tmp/agent9_test_save_migration_v7_v8.log |
| tests/test_sprite_frames.gd | PASS | 0 |  | /tmp/agent9_test_sprite_frames.log |
| tests/test_visual_capture.gd | PASS | 0 |  | /tmp/agent9_test_visual_capture.log |
| tests/test_visual_smoke.gd | PASS | 0 |  | /tmp/agent9_test_visual_smoke.log |
| tests/test_wall_colliders.gd | PASS | 0 |  | /tmp/agent9_test_wall_colliders.log |
| export Web | PASS | 0 | export build | /tmp/agent9_export.log |

Failure notes:
- `tests/test_chapter1_v17_flag_coverage.gd`: [v17Coverage] FAILED: 16 / 63 tests failed / ERROR: Condition "ret != noErr" is true. Returning: "" /    at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
- `tests/test_dialogue_runner.gd`: [TestDialogueRunner] PASS: T20: production judge open-round OR trigger dispatches bench prompt /  / [TestDialogueRunner] Results: 21 passed, 1 failed
- `tests/test_chapter1_flag_coverage.gd`: [Chapter1FlagCoverage] FAIL: 11 flags are not set by dialogue and are not annotated as engine-set. / ERROR: Condition "ret != noErr" is true. Returning: "" /    at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)

## Cross-reference audit
- JSON validity: PASS (43 files scanned).
- chapter1 flag references: WARN (0 runtime orphan names, 4 draft orphan names, 5 ignored false-positive names).
  - draft-only orphan `article_135bis_understood`: 4 refs; first: godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:10, godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:96, godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:113, godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:126
  - draft-only orphan `client_fee_collected`: 2 refs; first: godot/data/_drafts/nightly_design_pig_2026-05-14.json:8, godot/data/_drafts/nightly_design_pig_2026-05-14.json:29
  - draft-only orphan `closing_order`: 2 refs; first: godot/data/_drafts/murrow_player_driven_2026-05-15.json:69, godot/data/_drafts/murrow_player_driven_2026-05-15.json:70
  - draft-only orphan `murrow_beat9_dwell`: 6 refs; first: godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:9, godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:51, godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:68, godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:88, godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:101
  - ignored false positives: `binder_read_` (1); `foo` (1); `get` (4); `json` (9); `unused_scene_flag` (1)
- Tag taxonomy: PASS (0 unknown references).
- Evidence/frame/move references: PASS (0 unresolved).

## Enum consistency
| Path | Status | Declared | Used | Issues |
| --- | --- | --- | --- | --- |
| chapter1.proposed_frame | WARN | ``, `defective_service_135bis`, `third_party_non_cure`, `fair_hearing_article_6`, `merits_defence` | `defective_service_135bis`, `merits_defence` | registry-but-not-used: fair_hearing_article_6, third_party_non_cure |
| chapter1.whimsy_co_counsel_posture | PASS | ``, `procedural_throat`, `merits_pivot`, `open_register` | `merits_pivot`, `open_register`, `procedural_throat` | none |
| chapter1.client_meeting_stance | FAIL | `sympathetic`, `blunt_procedural`, `technical` | `blunt_procedural`, `sympathetic`, `technical` | registry set differs from expected set |
| chapter1.murrow_choice | FAIL | missing | `dry`, `friendly`, `professional` | missing _enum in chapter1.json registry |
| chapter1.state_choice | FAIL | missing | `dry`, `friendly`, `professional` | missing _enum in chapter1.json registry |
| chapter1.bonus_evidence_collected | FAIL | `wojcik_witness_statement`, `return_to_sender_slip`, `lease_1962_inheritance_1987`, `landlord_contact` | `landlord_contact`, `lease_1962_inheritance_1987`, `return_to_sender_slip`, `wojcik_witness_statement` | registry set differs from expected set |

## Address-form audit
Forbidden-pattern grep: FAIL (11 hits).
- `godot/data/dialogues/halina.json.bak:19` pattern `Doctor Cula`: { "speaker": "murrow", "text": "The notice and the docket are in the file. Doctor Cula will lead." },
- `godot/data/dialogues/halina.json.bak:89` pattern `Doctor Cula`: { "speaker": "murrow", "text": "The notice and the docket are in the file. Doctor Cula will lead." },
- `godot/data/dialogues/halina.json.bak:163` pattern `Doctor Cula`: { "speaker": "murrow", "text": "The notice and the docket are in the file. Doctor Cula will lead." },
- `godot/data/dialogues/murrow.json:8` pattern `Doctor Cula`: "lines": ["Doctor Cula. Mr. Pig is expecting you. The case can wait the ten minutes Mr. Pig requires for opening remarks."]
- `godot/data/dialogues/murrow.json:92` pattern `Doctor Cula`: "_comment": "V1.4 coffee reaction — D/F-grade. Voice verbatim from minigames.txt §Character reactions §Murrow Bad ('You have created a beverage with procedural defects.'). Opens wi
- `godot/data/dialogues/murrow.json:93` pattern `Doctor Cula`: "lines": ["Doctor Cula. You have created a beverage with procedural defects."]
- `godot/data/dialogues/murrow.json:110` pattern `Mr\. Cula`: {"speaker": "asia", "text": "She rang an hour ago, Mr. Cula. She'll be there at quarter to."}
- `godot/data/dialogues/murrow.md:9` pattern `Doctor Cula`: V1.4 (2026-05-12): two coffee_reaction_* states added per minigames.txt §Character reactions §Murrow. Gated on chapter1.coffee_buff and chapter1.met_murrow per the design brief. Ad
- `godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json:4` pattern `Doctor Cula`: "_address_form_check": "Murrow uses bare 'Cula' in private contexts post-befriending (confirmed in murrow.json court_readiness_check line 1: 'Cula.'). Beat 9 is private — Halina ha
- `godot/data/_drafts/nightly_dialogue_fixes_2026-05-15.json:6` pattern `Mr\. Cula`: "current": "She rang an hour ago, Mr. Cula. She'll be there at quarter to.",
- `godot/data/_drafts/nightly_dialogue_fixes_2026-05-15.json:8` pattern `Mr\. Cula`: "reason": "address form: Asia is outer-circle and must use the full honorific 'Dr. A. Cula' (AGENTS.md §Address forms; voice_audit.py Rule B). The line is spoken by Asia (speaker='
Asia outer-circle audit: FAIL (3 findings).
- WARN `godot/data/dialogues/asia.json:32` state `cula_approach` speaker `cula option text in asia file`: bare/non-Dr. A. Cula; `Good morning, you must be Asia? I saw you on the website. Cula, the new hire. Pleasure to meet you.`
- WARN `godot/data/dialogues/asia.json:33` state `cula_approach` speaker `cula option text in asia file`: malformed Dr. A. Cula; bare/non-Dr. A. Cula; `Dr. A Cula, here to see Mr. Pig.`
- FAIL `godot/data/dialogues/murrow.json:110` state `court_readiness_check` speaker `asia`: bare/non-Dr. A. Cula; `She rang an hour ago, Mr. Cula. She'll be there at quarter to.`

## Drafts inventory
| Draft file | Status | Notes |
| --- | --- | --- |
| godot/data/_drafts/asia_hints_player_driven_2026-05-16.json | standalone |  |
| godot/data/_drafts/asia_rewrite_2026-05-14.json | standalone |  |
| godot/data/_drafts/crab_player_driven_2026-05-15.json | superseded | superseded by crab_player_driven_final_2026-05-16.json |
| godot/data/_drafts/crab_player_driven_final_2026-05-16.json | standalone |  |
| godot/data/_drafts/halina_with_trust_meter.json | standalone | no date stamp |
| godot/data/_drafts/murrow_player_driven_2026-05-15.json | standalone |  |
| godot/data/_drafts/murrow_v2_2026-05-14.json | standalone |  |
| godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json | standalone |  |
| godot/data/_drafts/nightly_design_pig_2026-05-14.json | standalone |  |
| godot/data/_drafts/nightly_dialogue_fixes_2026-05-15.json | standalone |  |
| godot/data/_drafts/pig_rewrite_2026-05-14.json | standalone |  |
| godot/data/_drafts/whimsy_player_driven_2026-05-15.json | superseded | superseded by whimsy_player_driven_final_2026-05-16.json |
| godot/data/_drafts/whimsy_player_driven_final_2026-05-16.json | standalone |  |

## Per-agent reconciliation
- Agent 1: battle controller tests pass; its permitted `Signals.judge_skepticism_raised` addition is the only schema-drift hit.
- Agent 2: court round ids/tags/evidence/frame/move references validate; Agent 1 report says this file is not yet runtime-loaded.
- Agent 3: v17 enum additions validate for proposed_frame/Whimsy, but the new test fails broadly on pre-existing registry drift and a String-vs-bool test bug.
- Agent 4: Crab final draft references resolve; only two of four proposed_frame enum values are currently used by dialogue choices.
- Agent 5/6: no reports by cutoff; committed initial Murrow/Whimsy drafts exist in `ba6c094`, and an untracked Whimsy final exists.
- Agent 7: Asia hint draft references resolve; its assumed court_outcome values match Agent 2 `victory_resolution` branch values.
- Agent 8: tooling-only commit does not affect headless runtime; report SHA disagrees with actual git log.
- Agent 10: hygiene halted appropriately on substantive orphan dialogue rewrites; those uncommitted files remain in the dirty tree.
- Agent 11: governance proposal is committed despite done-report saying pending; it misattributes battle restoration to Agent 12.
- Agent 12: no delivery evidence by cutoff.

## Schema-drift findings
Diff vs `bc45550` for single-writer files:
- `M	godot/scripts/autoload/signals.gd`
Allowed: Agent 1 added one court signal to `signals.gd`: `judge_skepticism_raised(round_index, proposed_frame)`.
`state.gd`, `save.gd`, `Main.tscn`, and `tag_taxonomy.json` are unchanged from `bc45550` in the audited diff set.

## Web export
FAIL: export command exited 0; project-relative files are below.
| File | Exists | Bytes |
| --- | --- | --- |
| godot/exports/web/index.html | True | 5447 |
| godot/exports/web/index.wasm | True | 37695054 |
| godot/exports/web/index.pck | True | 16255500 |
Export log `ERROR:` lines: 3.
- `/tmp/agent9_export.log:3` ERROR: Condition "ret != noErr" is true. Returning: ""
- `/tmp/agent9_export.log:1444` ERROR: Cannot save file '/Users/piotr/Library/Application Support/Godot/editor_settings-4.6.tres'.
- `/tmp/agent9_export.log:1446` ERROR: Error saving editor settings to /Users/piotr/Library/Application Support/Godot/editor_settings-4.6.tres

## Recommended next steps for Piotr
1. Fix or revert the uncommitted Asia hint change, or update `test_dialogue_runner.gd` if the new `met_asia` gate is intended.
2. Add registry entries/enums for `chapter1.murrow_choice`, `chapter1.state_choice`, and the missing empty value on `client_meeting_stance`; then harden `test_chapter1_v17_flag_coverage.gd` so string defaults do not crash T5.
3. Correct live address forms in `godot/data/dialogues/murrow.json` (`Doctor Cula`, `Mr. Cula`) before merging further dialogue work.
4. Ask Agents 5, 6, and 12 for late reports or decide whether `ba6c094`/untracked Whimsy final are sufficient provenance.
5. Decide disposition of Agent 10's halted orphan dialogue rewrites before any cleanup agent moves or deletes them.
Revert candidates: no committed cohort SHA needs immediate revert for build/export, but the uncommitted `asia_hint_states_ch1.json` change is the likely cause of the dialogue-runner regression.

## Raw command output
Full logs live in `/tmp/agent9_*.log`; below are compact tail slices.

### tests/test_smoke.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
[SmokeTest] PASS: Main.tscn loaded and _ready() fired without errors.
```

### tests/test_runner.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TestRunner] Pig & Swine RPG — sprint 1 skeleton.
[TestRunner] GUT not yet installed. No tests to run.
[TestRunner] Exit 0.
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_save_migration_v8_v9.gd — PASS exit 0
```
[TestSaveMigrationV8V9] Results: 6 passed, 0 failed
[TestSaveMigrationV8V9] PASS
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_save_migration_v9_v10.gd — PASS exit 0
```
[TestSaveMigrationV9V10] Results: 6 passed, 0 failed
[TestSaveMigrationV9V10] PASS
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_save_migration_v10_v11.gd — PASS exit 0
```
[TestSaveMigrationV10V11] Results: 6 passed, 0 failed
[TestSaveMigrationV10V11] PASS
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_save_migration_v11_v12.gd — PASS exit 0
```
[TestSaveMigrationV11V12] Results: 7 passed, 0 failed
[TestSaveMigrationV11V12] PASS
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_save_migration_v12_v13.gd — PASS exit 0
```
  PASS: badges exists after full chain
  PASS: routes_unlocked exists after full chain
  PASS: coffee exists after full chain
  PASS: settings exists after full chain
  PASS: halina_trust exists (v11 step regression check)
[v12→v13] ALL PASS: 26 / 26
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_save_migration_v13_v14.gd — PASS exit 0
```
  PASS: collider stays scrubbed on re-run
  PASS: kept_state stays kept on re-run
[T7] full v1→v14 chain carries the scrub
  PASS: array exists after full chain
  PASS: empty after full chain
[v13→v14] ALL PASS: 25 / 25
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_save_migration_v14_v15.gd — PASS exit 0
```
  PASS: dialogue_states_seen exists (v12 regression)
  PASS: badges exists (v8 regression)
  PASS: routes_unlocked exists (v8 regression)
  PASS: coffee exists (v9 regression)
  PASS: settings exists (v10 regression)
[v14→v15] ALL PASS: 29 / 29
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_save_migration_v16_v17.gd — PASS exit 0
```
[T8] judicial_patience and witness_cooperation are typed integers
  PASS: judicial_patience is TYPE_INT after migration
  PASS: witness_cooperation is TYPE_INT after migration
  PASS: reset_state and migration agree on judicial_patience type
  PASS: reset_state and migration agree on witness_cooperation type
[v16→v17] ALL PASS: 61 / 61
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_chapter1_v17_flag_coverage.gd — FAIL exit 1
```
[T7] bonus_evidence_collected enum regression
  PASS: bonus_evidence_collected._enum contains 'wojcik_witness_statement'
  PASS: bonus_evidence_collected._enum contains 'return_to_sender_slip'
  PASS: bonus_evidence_collected._enum contains 'lease_1962_inheritance_1987'
  PASS: bonus_evidence_collected._enum contains 'landlord_contact'
[v17Coverage] FAILED: 16 / 63 tests failed
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_battle_controller.gd — PASS exit 0
```
  PASS: unknown tag returns false from validate_against_taxonomy
[T8] full three-round smoke
  PASS: all three rounds resolved without backfire
  PASS: court_won_procedural_reset set true
  PASS: State carries court_won_procedural_reset true

[TestBattleController] Results: 18 passed, 0 failed
[TestBattleController] PASS
```

### tests/test_effectiveness.gd — PASS exit 0
```
       [0] validate_against_taxonomy (res://scripts/systems/battle/effectiveness.gd:128)
       [1] _init (res://tests/test_effectiveness.gd:174)
[TestEffectiveness] PASS: T10: validate rejects '_doc' sentinel keys

[TestEffectiveness] Results: 10 passed, 0 failed
[TestEffectiveness] PASS
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_dialogue_runner.gd — FAIL exit 1
```
       [2] _init (res://tests/test_dialogue_runner.gd:397)
[TestDialogueRunner] PASS: T16: unknown badge_id / route_id rejected (warning logged, no crash, no state mutation)
[TestDialogueRunner] FAIL: T17: expected 'You should talk to Mr. Pig first. He's the loudest crisis in the room.' but got: ["..."]
[TestDialogueRunner] PASS: T18: V1.A state 7 (`recruited_whimsy && !halina_met`) dispatches canonical line
[TestDialogueRunner] PASS: T19: V1.A state 12 (default; chapter coda) dispatches canonical line
[TestDialogueRunner] PASS: T20: production judge open-round OR trigger dispatches bench prompt

[TestDialogueRunner] Results: 21 passed, 1 failed
```

### tests/test_chapter1_phase_b.gd — PASS exit 0
```
[TestChapter1PhaseB] PASS: T9b: low-trust Halina path reaches shared close and writes completion flags
[TestChapter1PhaseB] PASS: T10a: preconditions unmet → no dispatch
[TestChapter1PhaseB] PASS: T10b: gating met + empty stance → Halina intro path
[TestChapter1PhaseB] PASS: T10c: gating met + stance committed → dialogue dispatch path
[TestChapter1PhaseB] PASS: T10d: halina_met=true → no dispatch (post-meeting no-op)

[TestChapter1PhaseB] Results: 16 passed, 0 failed
[TestChapter1PhaseB] PASS
```

### tests/test_halina_intro_chain.gd — PASS exit 0
```
[HalinaIntroChainTest] PASS: chain 'blunt_procedural' writes stance and trust delta
[HalinaIntroChainTest] PASS: dismiss 'blunt_procedural' writes first-round evidence return_to_sender_slip
[HalinaIntroChainTest] PASS: chain 'technical' reaches a Cula-led r0 response state
[HalinaIntroChainTest] PASS: chain 'technical' writes stance and trust delta
[HalinaIntroChainTest] PASS: dismiss 'technical' writes first-round evidence lease_1962_inheritance_1987

[HalinaIntroChainTest] Results: 9 passed, 0 failed
[HalinaIntroChainTest] PASS
```

### tests/test_postcard_swine_chain.gd — PASS exit 0
```
[TestPostcardSwineChain] PASS: whimsy_postcard_deflection_shown set on dismiss
[TestPostcardSwineChain] PASS: complete dispatches with expected speaker and line
[TestPostcardSwineChain] PASS: complete set on dismiss
[TestPostcardSwineChain] PASS: T6b: chapter close awards day_one_survivor
[TestPostcardSwineChain] PASS: T6c: chapter close unlocks all Chapter 1 routes

[TestPostcardSwineChain] Results: 15 passed, 0 failed
[TestPostcardSwineChain] PASS
```

### tests/test_pickup_items_data.gd — PASS exit 0
```
[TestPickupItemsData] PASS: T3: item_picked_up emits hydrated display name
[TestPickupItemsData] PASS: T4: bool pickup emits chapter1_flag_changed
[TestPickupItemsData] PASS: T4b: hydrated pickup_line is emitted
[TestPickupItemsData] PASS: T5: string state flag writes item_id for bonus evidence
[TestPickupItemsData] PASS: T6: string pickup emits chapter1_flag_changed with item_id

[TestPickupItemsData] Results: 7 passed, 0 failed
[TestPickupItemsData] PASS
```

### tests/test_ysort_canon.gd — PASS exit 0
```
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
[YSortCanon] Phase 2 NOTE — headless DisplayServer cannot provide a reliable viewport image; pixel-order check skipped. Structural checks passed.
[YSortCanon] ALL PHASES PASS.
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_scene_inspect.gd — PASS exit 0
```

[Inspect] NPC 'Crab' found in archive_room.tscn
[Inspect] NPC 'Whimsy' found in cafe_paragraf.tscn
[Inspect] PASS — scene tree is correctly wired, visually renderable, and NPCs are present.
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_asia_progression.gd — PASS exit 0
```
[TestAsiaProgression] Starting...
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
[TestAsiaProgression] PASS: T1: Asia hint correct before meeting pig
[TestAsiaProgression] PASS: T2: Asia hint correct after meeting pig
[TestAsiaProgression] PASS: T3: Asia hint correct after meeting murrow
[TestAsiaProgression] Results: 3 passed, 0 failed
[TestAsiaProgression] PASS
```

### tests/test_chapter1_flag_coverage.gd — FAIL exit 1
```
[Chapter1FlagCoverage] UNREFERENCED: chapter1.whimsy_co_counsel_posture | set_by: whimsy.json before_meeting options block write_path (SAVE_VERSION 17)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.judicial_patience | set_by: future battle_controller.gd Phase 2 sub-controller (PROPOSALS.md §10)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.witness_cooperation | set_by: future battle_controller.gd Phase 1 sub-controller (PROPOSALS.md §10)
[Chapter1FlagCoverage] UNREFERENCED: chapter1.beat13_complete | set_by: Beat 13 office payoff close
43 flags total, 29 dialogue-set, 3 engine-set, 11 unreferenced
[Chapter1FlagCoverage] FAIL: 11 flags are not set by dialogue and are not annotated as engine-set.
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_coffee_brewing.gd — PASS exit 0
```
[TestCoffeeBrewing] PASS: T9: single-button assist accepts the nearest note without lane mismatch penalty
[TestCoffeeBrewing] PASS: T10: wider timing turns a beyond-normal OKAY offset from miss into okay

[TestCoffeeBrewing] Results: 10 passed, 0 failed, 0 skipped
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 4 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_dialogue_box_dismissal_signal.gd — PASS exit 0
```
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
[DialogueBoxDismissalSignalTest] PASS: T1: advancing to page two does not emit dialogue_dismissed
[DialogueBoxDismissalSignalTest] PASS: T2: closing after final page emits dialogue_dismissed exactly once
[DialogueBoxDismissalSignalTest] PASS: T3: pressing E during typewriter completes text without dismiss

[DialogueBoxDismissalSignalTest] Results: 3 passed, 0 failed
[DialogueBoxDismissalSignalTest] PASS
```

### tests/test_dialogue_typewriter.gd — PASS exit 0
```

ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
[TypewriterTest] PASS
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 2 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_input_check.gd — PASS exit 0
```
[InputCheck] 'move_left': registered=true event_count=2
             └ InputEventKey: keycode=65 (A), mods=none, physical=false, location=unspecified, pressed=false, echo=false
             └ InputEventKey: keycode=4194319 (Left), mods=none, physical=false, location=unspecified, pressed=false, echo=false
[InputCheck] 'move_right': registered=true event_count=2
             └ InputEventKey: keycode=68 (D), mods=none, physical=false, location=unspecified, pressed=false, echo=false
             └ InputEventKey: keycode=4194321 (Right), mods=none, physical=false, location=unspecified, pressed=false, echo=false
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_interaction_prompt.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
PASS — test_interaction_prompt.gd
```

### tests/test_npc.gd — PASS exit 0
```
[TestNPC] PASS: T1: NPC Area2D instantiated without error
[TestNPC] PASS: T2: Exported vars npc_id and display_name correct
[TestNPC] PASS: T3: _on_body_entered sets _player_inside = true for player group
[TestNPC] PASS: T4: dialogue_requested emitted with correct npc_id and display_name
[TestNPC] PASS: T5: No dialogue_requested emitted when _player_inside is false

[TestNPC] Results: 5 passed, 0 failed
[TestNPC] PASS
```

### tests/test_npc_animation_canon.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[TestNPC Canon] Starting...
[TestNPC Canon] PASS: All fallbacks resolved successfully.
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_npc_presence.gd — PASS exit 0
```
[TestNPCPresence] PASS: T4a: all-of-two, only one true → hidden
[TestNPCPresence] PASS: T4b: all-of-two, both true → visible
[TestNPCPresence] PASS: T4c: all-of-two, flag re-flipped → re-hidden after signal
[TestNPCPresence] PASS: T5a: hidden NPC has monitoring=false and monitorable=false
[TestNPCPresence] PASS: T5b: visible NPC has monitoring=true and monitorable=true
[TestNPCPresence] PASS: T6: MrPig and Murrow stay visible across canonical chapter1 states
[TestNPCPresence] Results: 11 passed, 0 failed
[TestNPCPresence] PASS
```

### tests/test_office_wall_visibility.gd — PASS exit 0
```

ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
[OfficeWallVisibility] PASS - office remains visible with TileMap walls and locked camera bounds.
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_player_animation.gd — PASS exit 0
```
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
ERROR: 1 RID allocations of type 'P11GodotBody2D' were leaked at exit.
WARNING: 2 RIDs of type "CanvasItem" were leaked.
   at: _free_rids (servers/rendering/renderer_canvas_cull.cpp:2692)
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_player_diagonal_normalised.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[DiagonalNorm] PASS — walk=120 px/s, sprint=336 px/s, diagonal normalised, all 8 buckets correct.
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_player_sprint.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
[SprintTest] PASS
```

### tests/test_room_transition.gd — PASS exit 0
```
[TestRoomTransition] Triggering office_back_to_street...
[TestRoomTransition] Back to room: OfficeStreet
[TestRoomTransition] Player pos: (480.0, 304.0) Spawn pos: (480.0, 304.0)
[TestRoomTransition] PASS
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_save_migration_v7_v8.gd — PASS exit 0
```
[TestSaveMigrationV7V8] Results: 8 passed, 0 failed
[TestSaveMigrationV7V8] PASS
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
WARNING: ObjectDB instances leaked at exit (run with --verbose for details).
   at: cleanup (core/object/object.cpp:2641)
ERROR: 1 resources still in use at exit (run with --verbose for details).
   at: clear (core/io/resource.cpp:810)
```

### tests/test_sprite_frames.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[FramesTest] PASS: All 24 animations verified.
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_visual_capture.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[Capture] NOTE: headless DisplayServer cannot provide viewport pixels; skipping PNG capture.
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_visual_smoke.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

[VisualSmoke] Starting visual smoke regression suite...
[VisualSmoke] NOTE: headless DisplayServer cannot provide viewport pixels; skipping screenshot capture.
ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
```

### tests/test_wall_colliders.gd — PASS exit 0
```
Godot Engine v4.6.2.stable.official.71f334935 - https://godotengine.org

ERROR: Condition "ret != noErr" is true. Returning: ""
   at: get_system_ca_certificates (platform/macos/os_macos.mm:1028)
[WallTest] PASS: Player blocked by wall.
```

### export Web — PASS exit 0
```
[  98% ] savepack | Storing File: res://.godot/uid_cache.bin
[  98% ] savepack | Storing File: res://project.binary
[ DONE ] savepack

ERROR: Cannot save file '/Users/piotr/Library/Application Support/Godot/editor_settings-4.6.tres'.
   at: save (scene/resources/resource_format_text.cpp:1756)
ERROR: Error saving editor settings to /Users/piotr/Library/Application Support/Godot/editor_settings-4.6.tres
   at: save (editor/settings/editor_settings.cpp:1404)
```
