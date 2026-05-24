# Data Consistency Audit — 2026-05-21

Snapshot commit: `nightly-snapshot-2026-05-21` (taken at audit start; covers `pig-swine-rpg` working tree).

## Tag Closure
PASS — every tag in `argument_opponents.json.moves[*].(article|principle|context)_tags`, plus the `weak_to`/`resists`/`immune_to` lookups, resolves against `tag_taxonomy.json`.

## Dialogue Flag References
PASS — every `chapter1.*`, `badges.*`, and `routes_unlocked.*` token in `dialogues/*.json` (triggers, on_dismiss sets, write_paths, trust_paths) resolves to a flag declared in `chapter1.json::new_state_flags`.

## Item Flag References
PASS — every `state_flag` in `items.json` maps to a declared chapter1 flag.

## Door Scene References

_Schema note: the task spec referenced `from_scene` / `to_scene`, but `doors.json` actually uses `target_scene` / `target_spawn_id`. Audit ran against `target_scene` (the only scene-path field present)._

PASS — every `target_scene` in `doors.json` resolves to a `.tscn` file under `godot/scenes/`.

## Once-True Orphans
PASS — every `set` / `set_flag` / `write_path` target on a `once: true` state resolves against `chapter1.json`. (State-id-as-key entries are tracked engine-side via the SAVE_VERSION 12 `dialogue_states_seen` array, not as named chapter1 flags, and are therefore out of scope for this check.)

## Character Registry Gaps
PASS — every `npc_id` referenced across 12 dialogue files (`11` distinct ids) has an entry in `character_registry.json`.

## Draft File Inventory

`godot/data/_drafts/` — 23 files (hidden files excluded).

| File | Type | Mtime | Date in filename |
|------|------|-------|------------------|
| asia_hints_player_driven_2026-05-16_v2.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-16 |
| beat1_murrow_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_asia_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_barista_2026-05-17.json | manual (awaiting promotion) | 2026-05-18 | 2026-05-17 |
| ch1_crab_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_cula_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_halina_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_judge_district_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_murrow_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_pig_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_postcard_swine_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| ch1_whimsy_2026-05-17.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-17 |
| crab_player_driven_final_2026-05-16.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-16 |
| mail_carrier_ch1_2026-05-19.json | manual (awaiting promotion) | 2026-05-19 | 2026-05-19 |
| murrow_player_driven_final_2026-05-16.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-16 |
| nightly_design_beat13_close_2026-05-17.json | nightly-generated | 2026-05-17 | 2026-05-17 |
| nightly_design_murrow_beat9_2026-05-15.json | nightly-generated | 2026-05-17 | 2026-05-15 |
| nightly_design_pig_2026-05-14.json | nightly-generated | 2026-05-17 | 2026-05-14 |
| nightly_dialogue_fixes_2026-05-15.json | nightly-generated | 2026-05-17 | 2026-05-15 |
| route_blocker_business_ch1_2026-05-19.json | manual (awaiting promotion) | 2026-05-19 | 2026-05-19 |
| route_blocker_residential_ch1_2026-05-19.json | manual (awaiting promotion) | 2026-05-19 | 2026-05-19 |
| tram_waiter_ch1_2026-05-19.json | manual (awaiting promotion) | 2026-05-19 | 2026-05-19 |
| whimsy_player_driven_final_2026-05-16.json | manual (awaiting promotion) | 2026-05-17 | 2026-05-16 |

- Nightly-generated drafts: **4** (prefix `nightly_`).
- Manual drafts awaiting human promotion: **19**.
- Oldest manual draft: **`asia_hints_player_driven_2026-05-16_v2.json`** (date in filename: 2026-05-16, mtime 2026-05-17).

Note: `godot/data/dialogues/_drafts/` also exists with three decoy drafts (`crab_decoys_2026-05-16.json`, `murrow_decoys_2026-05-16.json`, `whimsy_decoys_2026-05-16.json`); out of scope for the canonical `data/_drafts/` directory inventory but flagged here for completeness.

## Summary
No issues — data layer consistent across tag closure, dialogue/item/once-true flag references, door scene targets, and character registry coverage.

Manual draft backlog: 19 files. Oldest dated draft from the player-driven 2026-05-16 round still unpromoted (see Memory note: meeting_room_stance / player-driven 2026-05-16 drafts pending deletion or reintegration).