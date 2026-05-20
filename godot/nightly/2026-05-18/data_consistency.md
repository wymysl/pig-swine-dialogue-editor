# Data Consistency Audit — 2026-05-18

Scope: `godot/data/` JSON layer. 12 dialogue files scanned (excluding the
inert `dialogues.json` staging file and `.bak` snapshots per `_schema.md`),
53 closed tags in `tag_taxonomy.json`, 79 declared `chapter1.*` flags in
`chapters/chapter1.json`, 1 opponent (`landlord_counsel_ch1`) with 3 court
rounds × 2 moves each.

Reversibility snapshot: SKIPPED. A stale `.git/index.lock` (0 bytes, dated
2026-05-17 from a prior run) blocked `git commit` and could not be removed
(filesystem permission denied for the audit's shell user). Recommend a human
removes `/Users/piotr/Documents/Silly projects/pig-swine-rpg/.git/index.lock`
before tomorrow's nightly run.

## Tag Closure
PASS. All `article_tags`, `principle_tags`, and `context_tags` in
`argument_opponents.json` resolve to entries in `tag_taxonomy.json`.

## Dialogue Flag References
PASS. Every `chapter1.*` / `badges.*` / `routes_unlocked.*` path appearing in
a `trigger` expression or option `write_path` across all 12 dialogue files
resolves to a flag declared in `chapter1.json`'s `new_state_flags` array.

## Item Flag References
PASS. All five item `state_flag` values in `items.json` are declared in
`chapter1.json`:

- `procedural_binder` → `chapter1.has_law_binder`
- `rights_memo` → `chapter1.has_rights_memo`
- `wojcik_witness_statement` / `return_to_sender_slip` /
  `lease_1962_inheritance_1987` → `chapter1.bonus_evidence_collected`
  (string enum; pickup writes the item_id value)

## Door Scene References
PASS, with one schema note. `doors.json` uses a single `target_scene` field
per entry, not the `from_scene` / `to_scene` pair the task description
assumed. All six `target_scene` paths exist as `.tscn` files under
`scenes/`:

- `scenes/interiors/pig_swine_office.tscn` (×2: office_front_door, archive_to_office)
- `scenes/world/routes/office_street.tscn` (×2: office_back_to_street, cafe_to_street)
- `scenes/interiors/archive_room.tscn` (office_to_archive)
- `scenes/interiors/cafe_paragraf.tscn` (street_to_cafe)

If the audit definition should evolve, treat `target_scene` as the only
reference to validate; there is no `from_scene` field in the current schema.

## Once-True Orphans
PASS. Every state with `"once": true` writes only to flags that exist in
`chapter1.json`'s `new_state_flags`. Mutation shape inspected:
`{"set": "<flag>", "value": ...}` in `on_dismiss` / `on_enter` / `on_exit`
arrays.

## Character Registry Gaps
1 issue found.

| npc_id | found in file | note |
|--------|---------------|------|
| `meeting_room_stance` | `dialogues/meeting_room_stance.json` | File is an intentional empty stub. Top-level `_scope` field documents it as retired 2026-05-14 — stance choice moved inline into `halina.json::client_meeting_intro`. The runner still loads it, so `npc_id` remains declared. Adding `meeting_room_stance` to `character_registry.json` or `git rm`-ing the stub would both clear the warning; pick one. |

All speaker IDs referenced inside line objects also resolve (separate sub-check
beyond the audit's required scope).

## Draft File Inventory

20 entries in `godot/data/_drafts/` (plus a 5-byte `.write_test` permission-probe
file, ignored). Classification:

- **4 nightly-generated** (prefix `nightly_`): produced by automation and
  awaiting design promotion.
- **16 human-awaiting-promotion**: hand-authored player-driven dialogue work
  and the `ch1_*_2026-05-17.json` design pass.

| File | Type | Age estimate | Notes |
|------|------|-------------|-------|
| nightly_design_pig_2026-05-14.json | nightly-generated | 2026-05-14 (4d) | oldest nightly artifact |
| nightly_design_murrow_beat9_2026-05-15.json | nightly-generated | 2026-05-15 (3d) | — |
| nightly_dialogue_fixes_2026-05-15.json | nightly-generated | 2026-05-15 (3d) | — |
| nightly_design_beat13_close_2026-05-17.json | nightly-generated | 2026-05-17 (1d) | — |
| asia_hints_player_driven_2026-05-16_v2.json | human-awaiting-promotion | 2026-05-16 (2d) | **oldest non-nightly** |
| crab_player_driven_final_2026-05-16.json | human-awaiting-promotion | 2026-05-16 (2d) | "final" naming suggests promotion candidate |
| murrow_player_driven_final_2026-05-16.json | human-awaiting-promotion | 2026-05-16 (2d) | "final" naming suggests promotion candidate |
| whimsy_player_driven_final_2026-05-16.json | human-awaiting-promotion | 2026-05-16 (2d) | "final" naming suggests promotion candidate |
| beat1_murrow_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_asia_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_barista_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_crab_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_cula_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_halina_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_judge_district_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_meeting_room_stance_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_murrow_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_pig_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_postcard_swine_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |
| ch1_whimsy_2026-05-17.json | human-awaiting-promotion | 2026-05-17 (1d) | — |

Oldest non-nightly: `asia_hints_player_driven_2026-05-16_v2.json` (2d).

## Summary
1 issue found: `meeting_room_stance` retired-stub `npc_id` is not registered
in `character_registry.json`. Low-priority cleanup — the stub is deliberate
and documented inline. Data layer is otherwise consistent.

Also flagged for operator attention: stale `.git/index.lock` blocked the
reversibility snapshot.
