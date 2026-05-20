# Phase 0 — Stage Cleanup: Draft Inventory Diff Scan

Generated: 2026-05-17

## Draft Status Analysis

| draft_path | target_canonical_file | status | evidence | recommendation |
|---|---|---|---|---|
| godot/data/_drafts/crab_player_driven_final_2026-05-16.json | godot/data/dialogues/crab.json | PENDING | Structural redesign documented; _status field reads "DRAFT — voice-polished review artifact, not loaded." Merge strategy specifies: "replace ONLY the bodies of before_binder / before_binder_briefing / first_meeting_with_binder / after_binder_first_engagement / crab_post_pitch_response. Add crab_post_pitch_response_wrong_shape immediately BEFORE crab_post_pitch_response." Canonical file still contains v3 architecture. | Promote to canonical once design review confirms. Contains polished voice pass and completes motion-packet redesign. |
| godot/data/_drafts/crab_player_driven_2026-05-15.json | godot/data/dialogues/crab.json | SUPERSEDED | Earlier structural seed of crab_player_driven_final_2026-05-16.json. _status notes "Builds on top of the in-flight voice-pack rewrite" from git commit ba6c094. Final version (2026-05-16) incorporates voice pass and deviations. | Delete. Superseded by final 2026-05-16 polish. |
| godot/data/_drafts/murrow_player_driven_final_2026-05-16.json | godot/data/dialogues/murrow.json | PENDING | Voice-finalized design redesign. _status specifies: "replaces ONLY the bodies of murrow_first_meeting, has_binder_pre_crab, and court_readiness_check, and adds the two new states murrow_post_frame_attaches_motion and murrow_post_frame_walks_back." Targets v3 canonical which lacks these states. | Promote once legal constraints confirmed. Includes soft-fail handler and frame-conditioned motion attachment. |
| godot/data/_drafts/murrow_player_driven_2026-05-15.json | godot/data/dialogues/murrow.json | SUPERSEDED | Structural seed; _status notes final version is a "voice-finalized cut of murrow_player_driven_2026-05-15.json" with additional deviations and states. Final version incorporates address-form fixes and metaphor cuts. | Delete. Replaced by final 2026-05-16 with voice audit complete. |
| godot/data/_drafts/whimsy_player_driven_final_2026-05-16.json | godot/data/dialogues/whimsy.json | PENDING | _status: "FINAL DRAFT — review artifact, not loaded." Merge strategy: "replace the body of before_meeting and add the three new response states." Canonical v4 has before_meeting but lacks response_procedural_throat, response_merits_pivot, response_open_register states. | Promote once gameplay balance confirmed. Completes three-path recruitment option block with voice-polished responses. |
| godot/data/_drafts/whimsy_player_driven_2026-05-15.json | godot/data/dialogues/whimsy.json | SUPERSEDED | Initial design version. Final 2026-05-16 is the voice-polished cut per _status header. | Delete. Replaced by final 2026-05-16. |
| godot/data/_drafts/asia_hints_player_driven_2026-05-16.json | godot/data/dialogues/asia_hint_states_ch1.json | PENDING | DRAFT — companion hint surface. _status: "Targets v17 flag-keyed investigative gaps. Merges into asia_hint_states_ch1.json by inserting these states ahead of the existing quest-progression hints." Not yet present in canonical. | Promote to canonical file once v17 flag declarations completed in state.gd. |
| godot/data/_drafts/asia_hints_player_driven_2026-05-16_v2.json | godot/data/dialogues/asia_hint_states_ch1.json | SUPERSEDED | Earlier iteration marked v2; identical _status and target. Final polish is _v2 iteration. | Delete. Replaced by _v2 polish. |
| godot/data/_drafts/pig_rewrite_2026-05-14.json | godot/data/dialogues/pig.json | STUB | _scope: "Inert draft. Originally an alternate Mr. Pig voice pack. Stubbed 2026-05-14 because the runner now requires globally-unique state ids, and the canonical state ids in this file collide with pig.json." Empty states and idle_flavor arrays. | `git rm`. State collision makes this permanently inert. |
| godot/data/_drafts/murrow_v2_2026-05-14.json | godot/data/dialogues/murrow.json | STUB | _scope: "Inert draft. Originally an alternate Murrow voice pack. Stubbed 2026-05-14 because the runner now requires globally-unique state ids, and the canonical state ids in this file collide with murrow.json." Empty states and idle_flavor. | `git rm`. Collision inert. |
| godot/data/_drafts/asia_rewrite_2026-05-14.json | godot/data/dialogues/asia.json | STUB | _scope: "Inert draft. Originally an alternate Asia voice pack. Stubbed 2026-05-14 because the runner now requires globally-unique state ids, and the canonical state ids in this file collide with asia.json." Empty states and idle_flavor. | `git rm`. Collision inert. |
| godot/data/_drafts/halina_with_trust_meter.json | godot/data/dialogues/halina.json | PENDING | _provenance: "V1.4 phase-7 voice pack (V1_4_halina_meeting_research.md). Session 27: shared intro factored into client_meeting_intro with chain:true options. Session 29: restructured into trust-meter system." Contains trust_delta mechanics and tier-gated responses. Unknown merge status against canonical. | Review for integration. Specifies trust-meter branching; canonical status unclear. |
| godot/data/_drafts/nightly_design_pig_2026-05-14.json | godot/data/dialogues/pig.json | EXPLORATORY | Nightly design agent draft. _beat_ref: "story.txt §Beat 13 — Return to Pig & Swine: celebration, ledger, fee reference, Swine retainer plant." Proposes pig_beat13::pig_court_win_celebration state with maritime register. Flags not yet declared in state.gd (chapter1.client_fee_collected). | Archive or review design constraints. Beat 13 design exploration; requires SAVE_VERSION bump and flag declaration. |
| godot/data/_drafts/nightly_design_beat13_close_2026-05-17.json | godot/data/dialogues/asia.json | EXPLORATORY | Nightly design draft 2026-05-17. _beat_ref: "story.txt §Beat 13 — Return to Pig & Swine: celebration, ledger, fee reference, ominous coffee-machine close." Proposes asia_beat13::asia_post_court_congratulation and env-beat coffee machine. New flags (chapter1.beat13_complete, chapter1.pig_court_win_acknowledged) not yet declared. | Archive or schedule. Beat 13 close design; depends on nightly_design_pig_2026-05-14 for coordinate integration. Requires flag infrastructure. |
| godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json | godot/data/dialogues/murrow.json | EXPLORATORY | Nightly design agent draft 2026-05-15. _beat_ref: "story.txt §Beat 9 — Archive Room research (NEW; phase-8 addition)." Proposes Article 135-bis narration sequence. Flags not yet declared (chapter1.murrow_beat9_dwell, chapter1.article_135bis_understood). | Archive or schedule. Beat 9 archive states are phase-8 extension; blocked on flag infrastructure and doctrine-constraint review. |
| godot/data/_drafts/nightly_dialogue_fixes_2026-05-15.json | godot/data/dialogues/murrow.json & asia.json | EXPLORATORY | Audit tool output listing two corrections: (1) murrow.json::court_readiness_check "Dr. A. Cula" address form fix for Asia speaker (2) asia.json::cula_approach period correction in "Dr. A. Cula" canonical spelling. No state bodies; pure lint findings. | Integrate fixes into canonical files. Two low-risk corrections to address forms and canonical name spelling. |
| godot/data/dialogues/_drafts/crab_decoys_2026-05-16.json | godot/data/dialogues/crab.json | PENDING | DRAFT — decoy revision per PROPOSAL_player_driven_argument.md §1 + §3 + §4 (commit 30680b7). _status: "Companion to the live crab.json at HEAD. NOT loaded by dialogue_runner — lives in data/dialogues/_drafts/ subdirectory." Specifies: "replace the state bodies of first_meeting_with_binder + after_binder_first_engagement + crab_post_pitch_response. ADD the four new sibling response states." Four new frame-conditioned responses. | Cross-promote with crab_player_driven_final_2026-05-16.json. Decoy surface for crab; requires simultaneous merge of structural redesign. |
| godot/data/dialogues/_drafts/murrow_decoys_2026-05-16.json | godot/data/dialogues/murrow.json | PENDING | DRAFT — decoy revision per PROPOSAL_player_driven_argument.md §1 + §3 + §4 (commit 30680b7). Companion to live murrow.json. _status: "NOT loaded by dialogue_runner — lives in data/dialogues/_drafts/ subdirectory." Specifies: "surfaces evidence for frames 2 / 3 / 4 ... He does NOT surface substantive-defense evidence." | Cross-promote with murrow_player_driven_final_2026-05-16.json. Decoy frame surface for Murrow; must merge alongside structural redesign. |
| godot/data/dialogues/_drafts/whimsy_decoys_2026-05-16.json | godot/data/dialogues/whimsy.json | PENDING | DRAFT — decoy revision per PROPOSAL_player_driven_argument.md §1 + §3 (commit 30680b7). Companion to live whimsy.json. _status: "NOT loaded by dialogue_runner — lives in data/dialogues/_drafts/ subdirectory." Specifies: "surfaces evidence for frames 3 / 4 (civic-archive property-transfer record AND the rights memo)." on_dismiss sets surfaced_property_transfer. | Cross-promote with whimsy_player_driven_final_2026-05-16.json. Decoy frame surface for Whimsy; merges with main redesign. |

## Action Summary

**Delete (STUB):** 3 files
- `godot/data/_drafts/pig_rewrite_2026-05-14.json`
- `godot/data/_drafts/murrow_v2_2026-05-14.json`
- `godot/data/_drafts/asia_rewrite_2026-05-14.json`

**Delete (SUPERSEDED):** 5 files
- `godot/data/_drafts/crab_player_driven_2026-05-15.json`
- `godot/data/_drafts/murrow_player_driven_2026-05-15.json`
- `godot/data/_drafts/whimsy_player_driven_2026-05-15.json`
- `godot/data/_drafts/asia_hints_player_driven_2026-05-16_v2.json`

**Promote (PENDING, high priority):** 6 files
- Crab: `crab_player_driven_final_2026-05-16.json` + `crab_decoys_2026-05-16.json`
- Murrow: `murrow_player_driven_final_2026-05-16.json` + `murrow_decoys_2026-05-16.json`
- Whimsy: `whimsy_player_driven_final_2026-05-16.json` + `whimsy_decoys_2026-05-16.json`

**Promote (PENDING, gated on flag declarations):** 2 files
- `godot/data/_drafts/asia_hints_player_driven_2026-05-16.json`
- `godot/data/_drafts/halina_with_trust_meter.json`

**Archive or schedule (EXPLORATORY):** 4 files
- `nightly_design_pig_2026-05-14.json` (Beat 13 pig celebration)
- `nightly_design_beat13_close_2026-05-17.json` (Beat 13 close)
- `nightly_design_murrow_beat9_2026-05-15.json` (Beat 9 archive)
- `nightly_dialogue_fixes_2026-05-15.json` (lint fixes)
