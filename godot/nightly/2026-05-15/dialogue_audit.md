# Dialogue Canon Audit — 2026-05-15

Files audited (godot/data/dialogues/*.json, excluding _drafts/ and .bak):
asia.json, asia_hint_states_ch1.json, asia_hint_states_ch1_rewrite.json,
asia_rewrite.json, barista.json, crab.json, cula.json, dialogues.json,
halina.json, judge_district_ch1.json, meeting_room_stance.json, murrow.json,
murrow_v2.json, pig.json, pig_rewrite.json, postcard_swine_ch1.json,
whimsy.json.

Reversibility snapshot: SKIPPED. A stale `.git/index.lock` (age 7217s, root-owned in
this sandbox) blocked `git commit` and could not be removed under the agent's
permissions. No live files are modified by this run, so the snapshot is
defensive-only. Recommend clearing `.git/index.lock` before the next nightly.

## Address Form Violations

| File | State ID | Issue | Current Text | Suggested Fix |
|------|----------|-------|--------------|---------------|
| dialogues/murrow.json | court_readiness_check (L110) | Asia is outer-circle and must use a full honorific. "Mr." is gender-correct but not the canonical form for Cula. Asia's canonical address form is "Dr. A. Cula". The corresponding line in `murrow_v2.json` (L108) already uses the canonical form. | `She rang an hour ago, Mr. Cula. She'll be there at quarter to.` | `She rang an hour ago, Dr. A. Cula. She'll be there at quarter to.` |

## Canonical Name Misspellings

| File | Found | Should Be |
|------|-------|-----------|
| dialogues/asia.json (L33, `cula_approach` choice "dry") | `Dr. A Cula` (no period after A) | `Dr. A. Cula` |

## Gender Errors

None found. No "she/her Cula" or "Doctor she" usages detected. Cula is referred
to with male pronouns or unspecified throughout.

## Taste Standard Flags

| File | State ID | Issue Type | Line Text |
|------|----------|------------|-----------|
| dialogues/murrow.json | court_readiness_check (Cula, L109) | Generic filler "Understood" (per `legal:brief` / Taste Standard canon "no 'I see', 'Understood', 'Hmm', 'Very well', 'Indeed'"). | `Understood. Asia, has Mrs. Borowski been told we're coming?` |
| dialogues/murrow_v2.json | court_readiness_check (Cula, L104) | Same filler "Understood" — carried over from murrow.json into the V2 rewrite. | `Understood. Asia, has Mrs. Borowski been told we're coming?` |
| dialogues/pig.json | pig_first_meeting (Cula, L18) | Generic filler "Understood". Reads as system-message acknowledgment rather than character voice. | `Six weeks. Understood.` |
| dialogues/pig_rewrite.json | first_meeting (Cula, L18) | Generic filler "Understood" — preserved from pig.json into the V3 rewrite. | `Understood.` |
| dialogues/murrow.json | murrow_coffee_reaction_bad (L93) | Audience-conditional address-form ambiguity per `tools/voice_audit.py`. Murrow says "Doctor Cula" in a state whose id matches none of MURROW_CLIENT_PRESENT, MURROW_FIRST_ENCOUNTER, or MURROW_PRIVATE scene hints. The file's `_comment` justifies it as established speech form, so this is not an objective violation; flagging for human voice-canon arbitration. | `Doctor Cula. You have created a beverage with procedural defects.` |
| dialogues/murrow.json | before_pig (L8) | Same audience-conditional ambiguity. State id "before_pig" is a pre-first-meeting formal-register scene (Cula has not yet entered Pig's office), which voice canon treats as first-encounter formal — but the state id is not in MURROW_FIRST_ENCOUNTER_SCENE_HINTS, so `voice_audit.py` would flag it. Recommend either editing the hint list or renaming the state. | `Doctor Cula. Mr. Pig is expecting you. The case can wait the ten minutes Mr. Pig requires for opening remarks.` |
| dialogues/murrow.json | after_pig (L14) | Speaker-attribution bug, not a Taste-Standard violation in the canonical sense but a content correctness issue. The bracketed inner-monologue convention (see asia.json::cula_approach L26 and cula.json::family_photo_ch1 L11) is reserved for Cula's thoughts. This bracketed line reads as Cula's recognition of Murrow ("This must be Mr. Murrow…") but is tagged `speaker: murrow`. The reference to "Ionkionked" (presumably an in-world LinkedIn analogue) is also a quality flag — confirm spelling/brand intent. | `[This must be Mr. Murrow. Young and promising. I've read his profile on Ionkionked.]` (speaker tagged `murrow`) |

## Placeholder / Stub Lines

None. The only short line found (`"Oh."` in asia.json::cula_approach_response_dry)
is a deliberate beat preceding Asia's full acknowledgement, not a stub.

## Notes on files reviewed but clean

`cula.json`, `whimsy.json`, `crab.json`, `barista.json`, `halina.json`,
`judge_district_ch1.json`, `postcard_swine_ch1.json`,
`asia_hint_states_ch1.json`, `asia_rewrite.json`, and the inert stubs
`dialogues.json`, `meeting_room_stance.json`,
`asia_hint_states_ch1_rewrite.json` produced no flags. Crab's bare-Murrow
usages (`Murrow's procedural binder?`, `Murrow has flagged…`, etc.) are
canonical — Crab is inner-circle to Murrow regardless of recruitment status
per `INNER_CIRCLE_TO_MURROW` in `voice_audit.py`. Asia's quoted sticky-note
content (`The sticky note says 'Cula' and nothing else`) is not an
Asia-addressing-Cula instance — it is reported speech of a note Murrow
wrote, and Murrow's post-invitation address form is bare "Cula".

## Coexistence note: live vs. v2/rewrite variants

`murrow.json` and `murrow_v2.json`, `pig.json` and `pig_rewrite.json`,
`asia.json` and `asia_rewrite.json` all coexist in `godot/data/dialogues/`
and are all loaded by the dialogue runner at boot (per `AGENTS.md` §File
ownership). Both sets share state IDs, so behavior depends on JSON-load
order. The "Understood" filler appears in both pre- and post-rewrite
versions, so the rewrites carried that artifact forward; the "Mr. Cula"
typo exists only in `murrow.json` and is already corrected in
`murrow_v2.json`. Flagged for the Design role: either retire the legacy
files or guarantee unique state IDs across variants.

## Summary

**Objective violations:** 2 across 2 files (1 address form, 1 name misspelling).
**Quality flags for human review:** 6 across 3 files (4 "Understood" filler, 1
audience-conditional "Doctor Cula", 1 speaker-attribution bug).
**Files clean:** 12 of 17.

Draft fixes for the 2 objective violations are written to
`godot/data/_drafts/nightly_dialogue_fixes_2026-05-15.json`.
