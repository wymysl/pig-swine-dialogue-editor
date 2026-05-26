# Data Consistency Audit — 2026-05-26

> Automated nightly run. Git snapshot skipped — HEAD.lock held by another process (Godot editor or prior crash); lock could not be cleared under sandbox permissions. No data files were modified.

## Tag Closure

PASS — All `article_tags`, `principle_tags`, and `context_tags` across all moves in `argument_opponents.json` (landlord_counsel_ch1, 3 rounds, 6 moves) resolve to known entries in `tag_taxonomy.json`. `weak_to`, `resists`, and `immune_to` arrays likewise clean.

## Dialogue Flag References

**2 genuine issues** (1 false positive excluded):

| File | State ID | Unknown flag | Context |
|------|----------|-------------|---------|
| `murrow.json` | `murrow_rehearsal_offer` (trigger) | `chapter1.rehearsal_complete` | Step 4.1 feature (2026-05-26 design plan): rehearsal offer fires while `!rehearsal_complete`. Flag set by engine `end_rehearsal()` — not yet registered in chapter1.json. |
| `murrow.json` | `murrow_rehearsal_offer` (trigger) | `chapter1.rehearsal_declined` | Same Step 4.1 block — offer suppressed once player declines. Set by `murrow_rehearsal_skip` on_dismiss. |
| `murrow.json` | `murrow_rehearsal_debrief` (trigger) | `chapter1.rehearsal_complete` | Debrief fires when engine writes `rehearsal_complete = true`. Same unregistered flag. |
| `murrow.json` | `murrow_rehearsal_debrief` (trigger) | `chapter1.rehearsal_declined` | Guard to prevent debrief firing for skip path. Same. |

> **Note:** `whimsy.json` state `whimsy_b7_dwell_options` contains a `_comment` that mentions `chapter1.whimsy_b7_dwells_done` as a possible future guard — this is author commentary, not a live condition, and is not flagged as an issue.

**Root cause:** The four Step 4.1 states (`murrow_rehearsal_offer`, `murrow_rehearsal_accepted`, `murrow_rehearsal_skip`, `murrow_rehearsal_debrief`) were written into `murrow.json` on 2026-05-26 but the three flags they introduce — `chapter1.rehearsal_complete`, `chapter1.rehearsal_declined`, `chapter1.rehearsal_accepted` — were not added to `chapter1.json` `new_state_flags`. This is a registry-only gap; runtime defaults are unset. Requires a `new_state_flags` addition and a `state.gd::reset_state()` entry before the rehearsal mini-sequence can be tested.

## Item Flag References

**2 issues:**

| item_id | state_flag | Status |
|---------|-----------|--------|
| `article_8_brief` | `chapter1.picked_up_article_8` | Not in chapter1.json |
| `article_10_digest` | `chapter1.picked_up_article_10` | Not in chapter1.json |

Both items are `casebook_pickup` type added to `items.json`. Their pickup flags (`picked_up_article_8`, `picked_up_article_10`) were never registered in `chapter1.json`. These are Casebook collectibles rather than gating flags, but `pickup.gd` will attempt to write them via `State.data` at collection time. They need registry entries with `default: false`.

## Door Scene References

PASS — All 6 door entries in `doors.json` resolve to `.tscn` files that exist on disk:

- `res://scenes/interiors/pig_swine_office.tscn` ✓
- `res://scenes/world/routes/office_street.tscn` ✓
- `res://scenes/interiors/archive_room.tscn` ✓
- `res://scenes/interiors/cafe_paragraf.tscn` ✓

## Once-True Orphans

**2 issues** (subset of the dialogue flag issues above — same Step 4.1 cluster):

| File | State ID | Flag set on_dismiss | Status |
|------|----------|---------------------|--------|
| `murrow.json` | `murrow_rehearsal_accepted` | `chapter1.rehearsal_accepted` | Not in chapter1.json |
| `murrow.json` | `murrow_rehearsal_skip` | `chapter1.rehearsal_declined` | Not in chapter1.json |

> `murrow_rehearsal_debrief` has `once: true` but sets no flags on_dismiss; its orphan exposure is only via trigger (covered under Dialogue Flag References above).

## Character Registry Gaps

**2 issues:**

| npc_id | Found in file | Status |
|--------|--------------|--------|
| `coffee_machine_ch1` | `coffee_machine_ch1.json` | Not in `character_registry.json` |
| `smokers_lawyer_ch1` | `smokers_lawyer_ch1.json` | Not in `character_registry.json` |

Both are NPC dialogue files whose `npc_id` values are missing from `character_registry.json`. The coffee machine is an ambient interactable; the smokers' lawyer is a background NPC. Neither has a display-name entry. `DialogueRunner` will fail to resolve a speaker label for any line attributed to these IDs.

## Draft File Inventory

| File | Type | Age (days) | Notes |
|------|------|------------|-------|
| `nightly_design_pig_2026-05-14.json` | nightly-generated | 12 | Oldest nightly; content likely superseded by canonical pig.json |
| `nightly_design_murrow_beat9_2026-05-15.json` | nightly-generated | 11 | Beat 9 archive design; beat not yet authored in canonical files |
| `nightly_dialogue_fixes_2026-05-15.json` | nightly-generated | 11 | Fix batch; likely applied |
| `asia_hints_player_driven_2026-05-16_v2.json` | pending promotion | 10 | **Oldest non-nightly draft** |
| `crab_player_driven_final_2026-05-16.json` | pending promotion | 10 | Superseded by rejection of meeting_room_stance pattern (see MEMORY) |
| `murrow_player_driven_final_2026-05-16.json` | pending promotion | 10 | Same player-driven batch; canonical murrow.json is the live version |
| `whimsy_player_driven_final_2026-05-16.json` | pending promotion | 10 | Whimsy posture-pick not yet integrated; canonical whimsy.json is live |
| `beat1_murrow_2026-05-17.json` | pending promotion | 9 | Beat 1 Murrow variant; status unknown |
| `ch1_asia_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_barista_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_crab_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_cula_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_halina_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_judge_district_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_murrow_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_pig_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_postcard_swine_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `ch1_whimsy_2026-05-17.json` | pending promotion | 9 | Bulk 2026-05-17 snapshot batch |
| `nightly_design_beat13_close_2026-05-17.json` | nightly-generated | 9 | Beat 13 close design |
| `mail_carrier_ch1_2026-05-19.json` | pending promotion | 7 | New NPC; no canonical file yet |
| `route_blocker_business_ch1_2026-05-19.json` | pending promotion | 7 | Route-blocker NPC for business district |
| `route_blocker_residential_ch1_2026-05-19.json` | pending promotion | 7 | Route-blocker NPC for residential district |
| `tram_waiter_ch1_2026-05-19.json` | pending promotion | 7 | Tram-waiter NPC; no canonical file yet |
| `nightly_dialogue_fixes_2026-05-22.json` | nightly-generated | 4 | Most recent nightly; most recent fix batch |
| `chapter2_round_1.json` | pending promotion | undated | Ch2 court round draft; no date in filename |
| `.write_test` | system artifact | today | 5-byte test file written by audit tooling; safe to delete |

**Oldest non-nightly draft:** `asia_hints_player_driven_2026-05-16_v2.json` (10 days, 2026-05-16).

**Notable:** Four 2026-05-19 NPC drafts (`mail_carrier_ch1`, `route_blocker_business_ch1`, `route_blocker_residential_ch1`, `tram_waiter_ch1`) have no corresponding canonical dialogue files and are not yet registered in `character_registry.json`. These are world-population NPCs presumably awaiting the next design pass.

## Summary

**7 distinct issues found** across 4 checks (Dialogue Flag References, Item Flag References, Once-True Orphans, Character Registry Gaps). Tag Closure and Door Scene References are clean.

**Highest priority:** The Step 4.1 rehearsal cluster in `murrow.json` introduces 3 unregistered flags (`rehearsal_complete`, `rehearsal_declined`, `rehearsal_accepted`). These will cause `State.data` write failures and trigger evaluation errors at runtime. Register all three in `chapter1.json` `new_state_flags` and add defaults to `state.gd::reset_state()` before any rehearsal-path testing.

**Secondary:** `article_8_brief` and `article_10_digest` pickup flags (`picked_up_article_8`, `picked_up_article_10`) are unregistered. Low runtime risk until the Café Paragraf and Archive pickups are wired, but register now to keep chapter1.json as the single source of truth.

**Registry only:** `coffee_machine_ch1` and `smokers_lawyer_ch1` are missing from `character_registry.json`. Add display-name entries to prevent DialogueRunner speaker-label failures.
