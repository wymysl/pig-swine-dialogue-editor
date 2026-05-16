# Data Consistency Audit — 2026-05-14

> Automated run. git snapshot skipped — `.git/index.lock` held by another process (Godot editor open). No data files modified.

---

## Tag Closure

**PASS**

All `article_tags`, `principle_tags`, and `context_tags` across all six moves in `argument_opponents.json` (`landlord_counsel_ch1`) resolve against `tag_taxonomy.json`. `weak_to`, `resists`, and `immune_to` arrays also checked — all values are valid principle or context tags.

---

## Dialogue Flag References

**Issues found — two tiers**

### Tier 1 — Flags that should be in `chapter1.json` but are absent (actionable)

The trust-meter restructure (Session 29, 2026-05-13) added 8 flags to `halina.json` that are referenced in trigger conditions and `on_dismiss` blocks but were never written back to `chapter1.json`'s `new_state_flags` array:

| File | Flag | Used in |
|------|------|---------|
| halina.json | `chapter1.halina_trust` | trigger `>= 2`, `>= 3`, `>= 4`, `>= 5`; `trust_path` on all options |
| halina.json | `chapter1.halina_r0_done` | triggers for r0_response states; on_dismiss of all r0 branches |
| halina.json | `chapter1.halina_r1_choice` | trigger `!= ''`; write_path on r1 options |
| halina.json | `chapter1.halina_r1_done` | trigger for r1_response states; on_dismiss of r1 branches |
| halina.json | `chapter1.halina_r2_choice` | trigger `!= ''`; write_path on r2 options |
| halina.json | `chapter1.halina_r2_done` | trigger for r2_response states; on_dismiss of r2 branches |
| halina.json | `chapter1.halina_close_done` | trigger for `client_meeting_close`; on_dismiss |
| halina.json | `chapter1.landlord_tip_received` | trigger for `client_meeting_reveal`; on_dismiss of r2_response_high and reveal |

One additional missing flag:

| File | Flag | Used in |
|------|------|---------|
| asia_hint_states_ch1.json | `chapter1.won_court` | state `hint_won_court` (trigger and comment) |

### Tier 1 — Enum violation (actionable)

`halina.json` state `client_meeting_r2_response_high` sets `chapter1.bonus_evidence_collected` to `"landlord_contact"`. The `_enum` in `chapter1.json` for this flag lists only `["wojcik_witness_statement", "return_to_sender_slip", "lease_1962_inheritance_1987"]`. The value `landlord_contact` is undeclared and will cause a save-state validation failure when SAVE_VERSION is bumped.

### Tier 2 — Pre–`new_state_flags` era flags (documentation gap, lower priority)

These flags predate the `new_state_flags` section in `chapter1.json` and are presumably defined in `state.gd`. They are used across dialogues but absent from `chapter1.json`. No runtime breakage expected, but the authoritative flag list is incomplete.

`chapter1.met_pig`, `chapter1.met_murrow`, `chapter1.met_crab`, `chapter1.met_whimsy`, `chapter1.pig_revealed_crisis`, `chapter1.recruited_crab`, `chapter1.recruited_whimsy`, `chapter1.has_law_binder`, `chapter1.has_rights_memo`, `chapter1.coffee_buff`, `chapter1.coffee_brew_grade`, `chapter1.coffee_tutorial_seen`, `chapter1.coffee_retry_decision`, `chapter1.entered_court`, `chapter1.court_ready`, `chapter1.state_choice`, `chapter1.met_asia_via_behind`

(17 flags, found across asia.json, pig.json, murrow.json, crab.json, whimsy.json, barista.json, asia_hint_states_ch1.json)

---

## Item Flag References

**Issues found**

| item_id | state_flag | Status |
|---------|-----------|--------|
| `procedural_binder` | `chapter1.has_law_binder` | Not in `chapter1.json` new_state_flags |
| `rights_memo` | `chapter1.has_rights_memo` | Not in `chapter1.json` new_state_flags |
| `wojcik_witness_statement` | `chapter1.bonus_evidence_collected` | ✓ Present |
| `return_to_sender_slip` | `chapter1.bonus_evidence_collected` | ✓ Present |
| `lease_1962_inheritance_1987` | `chapter1.bonus_evidence_collected` | ✓ Present |

`has_law_binder` and `has_rights_memo` are almost certainly pre-era flags (see Tier 2 above), but since `items.json` relies on them for pickup.gd writes, they should be documented in `chapter1.json` regardless of origin.

---

## Door Scene References

**PASS**

All 6 door entries in `doors.json` resolved against the 11 `.tscn` files found under `godot/scenes/`:

| door_id | target_scene | Exists |
|---------|-------------|--------|
| `office_front_door` | `res://scenes/interiors/pig_swine_office.tscn` | ✓ |
| `office_back_to_street` | `res://scenes/world/routes/office_street.tscn` | ✓ |
| `office_to_archive` | `res://scenes/interiors/archive_room.tscn` | ✓ |
| `archive_to_office` | `res://scenes/interiors/pig_swine_office.tscn` | ✓ |
| `street_to_cafe` | `res://scenes/interiors/cafe_paragraf.tscn` | ✓ |
| `cafe_to_street` | `res://scenes/world/routes/office_street.tscn` | ✓ |

Note: `doors.json` uses only `target_scene`; no `from_scene` field is present in the schema.

---

## Once-True Orphans

**PASS**

No `"once": true` entries found in any `dialogues/*.json` file. The `once` mechanic was specified in Session 30 (SAVE_VERSION 12) but has not yet been applied to any authored state.

---

## Character Registry Gaps

**Issues found**

Three active (non-empty, non-inert) dialogue files have `npc_id` values with no entry in `character_registry.json`:

| npc_id | display_name in file | Found in |
|--------|---------------------|---------|
| `judge_district_ch1` | `"Judge"` | judge_district_ch1.json |
| `asia_hint_states_ch1` | `"Asia"` | asia_hint_states_ch1.json |
| `postcard_swine_ch1` | `"Postcard"` | postcard_swine_ch1.json |

The following inert/retired stubs also have unregistered `npc_id` values but are empty (`states: []`) and flagged for `git rm`: `meeting_room_stance`, `pig_rewrite`, `asia_rewrite`, `murrow_v2`, `asia_hint_states_ch1_rewrite`. No action needed until deletion.

---

## Draft File Inventory

| File | Type | Modified | Notes |
|------|------|----------|-------|
| `nightly_design_pig_2026-05-14.json` | Nightly-generated | 2026-05-14 19:31 | Tonight's nightly design draft for Mr. Pig |
| `halina_with_trust_meter.json` | Non-nightly (awaiting promotion) | 2026-05-14 11:44 | Pre-dates Session 29 merge; trust-meter Halina prototype. Now superseded by halina.json. Oldest non-nightly draft. |

`halina_with_trust_meter.json` is likely safe to delete — its content was incorporated into `halina.json` during Session 29. Human confirmation recommended before removal.

---

## Summary

**11 actionable issues found across 4 checks.** 17 additional lower-priority documentation gaps (pre-era flags in state.gd not mirrored to chapter1.json).

| # | Check | Severity | Description |
|---|-------|----------|-------------|
| 1–8 | Dialogue flag references | High | 8 trust-meter flags from Session 29 missing from `chapter1.json` new_state_flags (halina_trust, r0/r1/r2 done + choice flags, halina_close_done, landlord_tip_received) |
| 9 | Dialogue flag references | High | `chapter1.won_court` referenced in asia_hint_states_ch1.json but not defined anywhere in chapter1.json |
| 10 | Dialogue flag references | High | `chapter1.bonus_evidence_collected` set to undeclared enum value `"landlord_contact"` in halina.json `client_meeting_r2_response_high` |
| 11–12 | Item flag references | Medium | `chapter1.has_law_binder` and `chapter1.has_rights_memo` used by pickup.gd (via items.json) but absent from chapter1.json |
| 13–15 | Character registry gaps | Low | `judge_district_ch1`, `asia_hint_states_ch1`, `postcard_swine_ch1` not in character_registry.json |

**Recommended immediate actions:**
1. Add the 8 trust-meter flags + `chapter1.won_court` to `chapter1.json` `new_state_flags` (bump SAVE_VERSION, add migration + reset defaults).
2. Add `"landlord_contact"` to the `bonus_evidence_collected` `_enum` in `chapter1.json`, or rename the value to match an existing enum entry if this is a typo.
3. Register `judge_district_ch1`, `asia_hint_states_ch1`, and `postcard_swine_ch1` in `character_registry.json`.
