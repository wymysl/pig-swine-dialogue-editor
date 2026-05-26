# Code Quality Audit — 2026-05-26

> **Snapshot note:** The pre-audit git snapshot commit (`nightly-snapshot-2026-05-26`) failed because `.git/HEAD.lock` existed and could not be removed from the sandbox (permission denied). Godot editor was likely open. The audit is read-only and proceeded without modification; no source files were touched.

---

## Untyped Function Parameters

| File:Line | Function | Untyped Param |
|-----------|----------|---------------|
| — | — | — |

**PASS.** All function signatures have typed parameters. Six multi-line declarations were manually verified (their closing `)` line carries the `-> ReturnType:` annotation): `_collapse_popup_if_token` (trial_record_panel.gd:145), `_packet_slot_supported` and `_packet_outcome` (packet_scorer.gd:143, 236), inner-class `start` (battle_controller.gd:47), `_append_phase2_result` (battle_controller.gd:875), and `resolve` (effectiveness.gd:62).

---

## Missing Return Annotations

| File:Line | Function Signature |
|-----------|--------------------|
| — | — |

**PASS.** All functions carry `->` return types, either on the same line or on the closing `)` line of a multi-line declaration. Every multi-line declaration was individually verified.

---

## Undefined Signal References

| Signal Name | Used In | Not in signals.gd |
|-------------|---------|-------------------|
| — | — | — |

**PASS.** All signals emitted via `sigs.<name>.emit()` cross-reference against `signals.gd` cleanly. Complete set confirmed present: `dialogue_requested`, `dialogue_line_ready`, `dialogue_dismissed`, `dialogue_ended`, `dialogue_options_ready`, `dialogue_option_committed`, `dialogue_chain_start`, `chapter1_flag_changed`, `badge_awarded`, `route_unlocked`, `case_folder_fragment_added`, `case_folder_acquired`, `case_folder_toggled`, `manual_save_requested`, `item_picked_up`, `save_completed`, `save_failed`, `room_transition_started`, `room_transition_finished`, `judge_skepticism_raised`, `trial_record_round_started`, `trial_record_fact_established`, `trial_record_citation_resolved`, `trial_record_opponent_stated`, `trial_record_packet_scored`, `crab_withdrew_after_incapacity`.

The three lines matching `Signals.chapter` in the grep output are comments only (documentation references to `Signals.chapter1_flag_changed`), not code.

---

## Hardcoded Player-Facing Strings

| File:Line | String | Why Flagged |
|-----------|--------|-------------|
| `scripts/actors/pig_idle_zone.gd:27` | `"Every second you stand still, a client somewhere is also standing still. This is a coincidence I cannot afford."` | Sentence-cased player-visible dialogue line in `.gd`. Documented as fallback; canonical in `data/zone_barbs.json`. |
| `scripts/actors/pig_idle_zone.gd:28` | `"Standing still is a philosophical position, Dr. A. Cula. I do not endorse it professionally."` | Same file, same pattern. |
| `scripts/actors/behind_desk_zone.gd:26` | `"Dr. A. Cula? Are you looking for paperclips?"` | Same pattern; Asia zone-barb fallback. |
| `scripts/actors/behind_desk_zone.gd:27` | `"If you need to print something, just ask."` | Same. |
| `scripts/actors/behind_desk_zone.gd:28` | `"I would love to chat with you, but I have all this chaos to manage."` | Same. |
| `scripts/actors/behind_desk_zone.gd:29` | `"Have you lost something?"` | Same. |
| `scripts/actors/behind_desk_zone.gd:30` | `"I'm wondering who even uses fax anymore."` | Same. |
| `scripts/systems/minigames/coffee_brewing.gd:1169` | `"Status: " + str(result["buff"])` | Result panel UI label — no JSON backing, player-visible. |
| `scripts/systems/minigames/coffee_brewing.gd:1171` | `"Quality: %d  Bitterness: %d  Combo: %d"` | Result panel detail label — no JSON backing, player-visible. |
| `scripts/systems/save.gd:120,130,134,150,155,162` | `"State data is unavailable."` / `"Cannot create the save directory."` / etc. | Internal fallbacks for `_reason()`, which loads from `case_folder_strings.json`. These are error strings shown in a toast, technically player-visible. Low-risk because primary source is JSON. |

**Assessment:** The zone-barb fallbacks (`pig_idle_zone.gd`, `behind_desk_zone.gd`) are intentional and documented as defensive fallbacks — canonical text lives in `data/zone_barbs.json`. Not a violation of the "no hardcoded strings" rule in spirit, but they are load-bearing player-facing lines in `.gd` that could diverge from the JSON without a test to catch it. The coffee result labels (`coffee_brewing.gd:1169,1171`) have no JSON backing at all and are a genuine violation.

---

## SAVE_VERSION Migration Chain

**PASS.** Current `SAVE_VERSION = 27`. Migration chain in `scripts/systems/save.gd` covers every step:

| Steps | Status |
|-------|--------|
| v1→v2 | `pass` (no structural change; explicit branch present) |
| v2→v3 | ✓ adds `chapter1` sub-dict |
| v3→v4 | ✓ `met_crab`, `met_whimsy` |
| v4→v5 | ✓ `has_rights_memo` |
| v5→v6 | ✓ `met_asia`, `viewed_family_photo` |
| v6→v7 | ✓ `met_asia_via_behind` |
| v7→v8 | ✓ full Beat 7–14 flag set + badges + routes |
| v8→v9 | ✓ coffee brewing flags |
| v9→v10 | ✓ accessibility settings |
| v10→v11 | ✓ halina trust meter (8 flags) |
| v11→v12 | ✓ `dialogue_states_seen` |
| v12→v13 | ✓ `won_court`, `coffee_retry_decision` |
| v13→v14 | ✓ scrubs legacy once-state collider ids |
| v14→v15 | ✓ `state_choice` |
| v15→v16 | ✓ `murrow_choice` |
| v16→v17 | ✓ argument scaffolding (binder_read_*, proposed_frame, etc.) |
| v17→v18 | ✓ motion-packet foundation (surfaced_* + element_* + decoy_*) |
| v18→v19 | ✓ packet assembly persistence (packet_slot_* strings) |
| v19→v20 | ✓ Blue Folder foundation |
| v20→v21 | ✓ `cula_postcard_reaction_shown` |
| v21→v22 | ✓ rename `bonus_evidence_collected` → `client_meeting_evidence` |
| v22→v23 | ✓ `phase2_round_results` |
| v23→v24 | ✓ judgment pickup flags |
| v24→v25 | ✓ Beat 13 close flags |
| v25→v26 | ✓ Murrow rehearsal flags |
| v26→v27 | ✓ `halina_trust` → `halina_stance` + `incapacity_penalty` rename |

---

## State Flag Multiple Writers

| Flag | Writer 1 | Writer 2 |
|------|----------|----------|
| `chapter1.client_meeting_stance` | `dialogue_runner.gd` via options `write_path` on_dismiss | `client_stance_menu.gd:75` — direct `state_node.data["chapter1"]["client_meeting_stance"] = stance` |

**Details:** `CONVENTIONS.md §Chapter 1 meeting-room sub-area` explicitly states "The standalone modal `client_stance_menu.tscn` is retired in favour of this flow [dialogue options]." `client_stance_menu.gd` still exists and still writes `client_meeting_stance` directly at line 75. The script also emits `chapter1_flag_changed` correctly, so the NPC gate will refresh. But the dual-writer violates the single-owner contract and means a stance could be set via the retired menu path if the scene is ever reloaded into the tree. The script and its scene should be deleted or stripped of its write logic.

No other flags were found with multiple GDScript writers. Note: `battle_controller.gd` exclusively uses `_write_chapter1_flag()`, which centralises its writes correctly.

---

## Naming Convention Violations

| File:Line | Found | Should Be |
|-----------|-------|-----------|
| — | — | — |

**PASS.** The `[a-z][A-Z][a-z]` pattern produced matches only in node-path string literals (`$Panel/PortraitRect`, `BackgroundPanel/BrewQualityMeter`, etc.) and Godot API class references (`AudioStreamPlayer`, `TextServer.AUTOWRAP_WORD_SMART`, `PackedStringArray`). No camelCase variable or function names found in runtime code. The `var [a-z][a-z_]*[A-Z]` pattern returned no matches at all.

---

## TODO / FIXME / HACK Comments

| File:Line | Text |
|-----------|------|
| `scripts/autoload/signals.gd:11` | `## TODO(consumer): Badge/toast feedback is deferred; see 2026-05-19 tech critique F5.` |
| `scripts/autoload/signals.gd:16` | `## TODO(consumer): Pickup acknowledgment UI is deferred; see 2026-05-19 tech critique F5.` |
| `scripts/autoload/signals.gd:22` | `## TODO(consumer): Pause/HUD affordance is deferred; see 2026-05-19 tech critique F5.` |
| `scripts/autoload/signals.gd:151` | `## TODO(consumer): Judge-skepticism camera/HUD response is deferred; see 2026-05-19 tech critique F5.` |

All four are in signal declaration comments only (not in runnable code paths) and reference the same deferred decision (tech critique F5, 2026-05-19). They are documentation debt, not code debt.

---

## Print Statements in Runtime Code

None. The `print\(` search across all `scripts/**/*.gd` files returned zero matches.

---

## Summary

**3 real issues found.** Top priority: the `client_meeting_stance` dual-writer in `client_stance_menu.gd` — a retired script still writing live state. Medium priority: hardcoded UI strings in `coffee_brewing.gd` result panel (two labels with no JSON backing). Low priority: zone-barb fallback strings in `pig_idle_zone.gd` and `behind_desk_zone.gd` (intentional and documented, but untested for drift against JSON canon).

Everything else is clean: 0 untyped parameters, 0 missing return annotations, 0 undefined signals, complete 1→27 migration chain, no naming violations, no print statements in runtime code.
