# Data Consistency Audit — 2026-05-25

Scope: dangling references and schema violations across `godot/data/`. Read-only audit; no data files modified.

Pre-run snapshot: `git commit --allow-empty` failed with "Another git process seems to be running" / permission denied on `.git/objects/tmp_obj_*`. The audit itself is read-only, so the missing snapshot does not affect correctness. The lock should be investigated separately.

## Tag Closure

PASS — All `article_tags`, `principle_tags`, and `context_tags` across every move in `argument_opponents.json` resolve to keys in `tag_taxonomy.json`. `weak_to` / `resists` / `immune_to` entries (treated as principle-tag references) also resolve cleanly.

Schema note: the task brief assumed a flat `moves[*].tags[]` field; the actual schema splits tags into three typed arrays (`article_tags`, `principle_tags`, `context_tags`). All three were checked.

## Dialogue Flag References

PASS — 65 unique flag references across 11 dialogue JSON files; all map to keys in `chapter1.json::new_state_flags` (80 declared keys). Coverage:

- Scanned: `asia.json`, `asia_hint_states_ch1.json`, `barista.json`, `crab.json`, `cula.json`, `halina.json`, `judge_district_ch1.json`, `murrow.json`, `pig.json`, `postcard_swine_ch1.json`, `whimsy.json`.
- Regex matched `chapter\d+.*`, `badges.*`, `routes_unlocked.*` in `trigger`, `condition`, `conditions`, `requires`, `requires_flags`, `when`, `if` fields.

## Item Flag References

PASS — All five entries in `items.json` declare a `state_flag` that exists in `chapter1.json`:

| item_id | state_flag |
|---|---|
| procedural_binder | chapter1.has_law_binder |
| rights_memo | chapter1.has_rights_memo |
| wojcik_witness_statement | chapter1.bonus_evidence_collected |
| return_to_sender_slip | chapter1.bonus_evidence_collected |
| lease_1962_inheritance_1987 | chapter1.bonus_evidence_collected |

## Door Scene References

PASS — All six entries in `doors.json` resolve to existing `.tscn` files in `godot/scenes/`.

Schema note: the task brief specified `from_scene` / `to_scene` fields; the actual schema uses only `target_scene` (with `map_pos` representing the source position within the current scene). Audit checked `target_scene` against the scene file inventory:

- `res://scenes/interiors/pig_swine_office.tscn` — exists
- `res://scenes/world/routes/office_street.tscn` — exists
- `res://scenes/interiors/archive_room.tscn` — exists
- `res://scenes/interiors/cafe_paragraf.tscn` — exists

## Once-True Orphans

PASS (vacuously) — 60 states with `"once": true` were found across the dialogue files. None of them write an explicit chapter-flag in their `on_dismiss` / `on_enter` / `on_exit` actions. This matches the documented architecture (see memory: `project_pig_swine_dialogue_once.md`): once-fire is tracked by the engine via the top-level `dialogue_states_seen` array keyed on state id, not by per-state flag writes. There is therefore no flag-key to validate against `chapter1.json` for these states.

If the original check intent was to verify that every `once:true` state has a unique state id (since state ids are the de-facto key), spot-check passed — no duplicate ids surfaced during traversal.

## Character Registry Gaps

PASS — Eleven distinct `npc_id` values appear in dialogue files; all eleven have entries in `character_registry.json`:

`asia`, `asia_hint_states_ch1`, `barista`, `crab`, `cula`, `halina`, `judge_district_ch1`, `murrow`, `pig`, `postcard_swine_ch1`, `whimsy`.

Registry also defines `cula_internal`, `murrow_stranger`, `swine`, `stage_direction` (used as multi-speaker `speaker` overrides rather than top-level `npc_id`s — out of scope for this check but present and intact).

## Draft File Inventory

`godot/data/_drafts/` contains 25 JSON files plus a `.write_test` marker. Categorized:

| File | Type | Mtime | Notes |
|---|---|---|---|
| nightly_design_pig_2026-05-14.json | nightly | 2026-05-17 | 11 days old (by filename date) — oldest nightly draft awaiting human action |
| nightly_design_murrow_beat9_2026-05-15.json | nightly | 2026-05-17 | 10 days old |
| nightly_dialogue_fixes_2026-05-15.json | nightly | 2026-05-17 | 10 days old |
| nightly_design_beat13_close_2026-05-17.json | nightly | 2026-05-17 | 8 days old |
| nightly_dialogue_fixes_2026-05-22.json | nightly | 2026-05-22 | 3 days old |
| asia_hints_player_driven_2026-05-16_v2.json | human | 2026-05-17 | 9 days old by filename |
| crab_player_driven_final_2026-05-16.json | human | 2026-05-17 | 9 days old by filename — **oldest human draft** |
| murrow_player_driven_final_2026-05-16.json | human | 2026-05-17 | 9 days old by filename |
| whimsy_player_driven_final_2026-05-16.json | human | 2026-05-17 | 9 days old by filename |
| beat1_murrow_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_asia_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_barista_2026-05-17.json | human | 2026-05-18 | 8 days old |
| ch1_crab_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_cula_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_halina_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_judge_district_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_murrow_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_pig_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_postcard_swine_2026-05-17.json | human | 2026-05-17 | 8 days old |
| ch1_whimsy_2026-05-17.json | human | 2026-05-17 | 8 days old |
| mail_carrier_ch1_2026-05-19.json | human | 2026-05-19 | 6 days old |
| route_blocker_business_ch1_2026-05-19.json | human | 2026-05-19 | 6 days old |
| route_blocker_residential_ch1_2026-05-19.json | human | 2026-05-19 | 6 days old |
| tram_waiter_ch1_2026-05-19.json | human | 2026-05-19 | 6 days old |

Counts: 5 nightly-generated drafts, 20 human-authored drafts. The four `*_player_driven_final_2026-05-16.json` and `asia_hints_player_driven_2026-05-16_v2.json` are the oldest human drafts on the floor (9 days). Per memory `feedback_pig_swine_meeting_room_stance_rejected.md`, the player-driven drafts in particular are flagged for deletion review.

## Summary

No issues — data layer consistent.

Schema deviations from the task brief (target_scene vs. from_scene/to_scene; split tag arrays; once:true tracked by state id not flag) noted inline. None of them represent a defect in the data; they reflect that the audit spec was written against an older or hypothetical schema. Next audit run should be reconciled to the current shape.

Backlog observation (informational, not a check failure): the human-authored drafts dated 2026-05-16/17 are sitting on the floor approaching two weeks. Worth a triage pass.
