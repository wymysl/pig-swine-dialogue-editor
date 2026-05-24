# Dialogue Canon Audit — 2026-05-22

Audited live dialogue JSON files in `godot/data/dialogues/` (excluding `_drafts/`,
`.bak.*`, `.md`, and `_schema.md`). `meeting_room_stance.json` listed in the
scheduled-task brief does not exist on disk — the design pattern was rejected
(see memory `feedback_pig_swine_meeting_room_stance_rejected.md`); halina.json's
inline chain owns the Beat 8 stance choice. `dialogues.json` is an empty legacy
umbrella file (no `npcs` entries) and is excluded from the per-line scan.

Files audited: `cula.json`, `murrow.json`, `pig.json`, `asia.json`, `crab.json`,
`whimsy.json`, `barista.json`, `judge_district_ch1.json`,
`postcard_swine_ch1.json`, `halina.json`, `asia_hint_states_ch1.json`,
`dialogues.json`.

Step-0 snapshot note: `git commit --allow-empty` failed because
`.git/HEAD.lock` and `.git/index.lock` exist in the worktree and are not
removable from this sandbox (`Operation not permitted`). No write to live
dialogue files was attempted; the audit and the draft-fixes file are the only
new outputs. A human/editor should clear the stale lockfiles before the next
run.

## Address Form Violations

| File | State ID | Issue | Current Text | Suggested Fix |
|------|----------|-------|--------------|---------------|

None. The 2026-05-19 scrub of `murrow.json` removed the legacy "Doctor Cula"
forms; current live files honour the AGENTS.md §Address forms table and the
2026-05-19 clarification (Murrow uses "Dr. A. Cula" once at first meeting then
bare "Cula" thereafter, in all contexts; Crab/Whimsy use "Dr. A. Cula"
pre-recruit and bare "Cula" post-recruit; Asia uses "Dr. A. Cula" and "Mr.
Murrow"; everyone else uses "Dr. A. Cula").

## Canonical Name Misspellings

| File | Found | Should Be |
|------|-------|-----------|
| `asia_hint_states_ch1.json` (state `hint_bonus_evidence_wojcik`) | `Mrs. Wojcik` | `Mrs. Wójcik` |

Justification: `halina.json` consistently spells the neighbour `Wójcik` with
the diacritic (lines 43, 105, 114). The asia_hint_states variant is the only
occurrence missing the acute accent. The state's own slug (`wojcik`) is an ID
and stays ASCII; only the in-line player-facing text needs the diacritic.

## Gender Errors

| File | State ID | Issue |
|------|----------|-------|

None. All "she" / "her" references in live files resolve to Mrs. Sikorska,
Mrs. Wójcik, or Asia. Cula is consistently referenced with he/him pronouns
where pronouns appear. The legacy "Doctor Cula" misgendering risk has been
removed from live files (only present in `_drafts/murrow_decoys_2026-05-16.json`,
which is out of scope).

## Taste Standard Flags

| File | State ID | Issue Type | Line Text |
|------|----------|------------|-----------|
| `cula.json` | `cula_b3_pig_rent_reaction` | Filler opener — `Understood.` as one-word acknowledgment | `"Six weeks. Understood."` (line 1 of 2) |
| `cula.json` | `cula_b10_pig_lecture_reception` | Filler opener — `Understood,` | `"Understood, Mr. Pig. We will keep the printer informed."` |
| `pig.json` | `pig_first_meeting` | Filler — `Understood.` as Cula's reaction line inside Pig's first-meeting block | `{"speaker": "cula", "text": "Six weeks. Understood."}` |
| `murrow.json` | `court_readiness_check` | Filler opener — `Understood.` | `{"speaker": "cula", "text": "Understood. Asia, has Mrs. Sikorska been told we're coming?"}` |
| `crab.json` | `before_binder_briefing` | Filler opener — `Hm.` | `{"speaker": "cula", "text": "Hm. Working on it."}` |
| `murrow.json` | `murrow_post_decoy_incapacity` | Clipped one-word reply | `{"speaker": "cula", "text": "Clear."}` |

Notes on Taste Standard flags:

The four "Understood" occurrences and the "Hm." each pair with substantive
follow-on content, which softens but does not eliminate the SKILL.md rule
against "Understood / I see / Indeed / Hmm / Very well" filler. The pattern is
consistent enough across files (Cula deferring to senior partners) that it may
be a deliberate voice choice — recommend a single human pass to either ratify
the pattern as Cula's voice or rewrite the openers. `cula_b8_approach_choice`'s
_comment explicitly bans empty `Understood.` lines as a Rule B violation; the
remaining instances all attach a substantive second clause, but the openers
themselves are still the flagged tokens.

`murrow_post_decoy_incapacity` `"Clear."` is a single-word submission to
Murrow's rebuke. Context-defensible (the brevity is the reaction) but listed
for human review because it pattern-matches `Indeed / Very well`.

No gamey-register violations found (no `HP`, `damage` as combat metric,
`attack`, `defense` as combat term, `monster`, `type advantage`, `level up`).
The two `defense` hits are both legal — "Sikorska eviction defense" and the
internal flag value `substantive_defense`. The one `damage` hit is "coffee
damage" describing a physical stain on the rights memo.

No real-named-public-figure violations. The "Hennessy retainer phone" is a
firm-client running joke (Hennessy is a brand, not a real institution
attached to a named person).

## Placeholder / Stub Lines

| File | State ID | Current |
|------|----------|---------|
| `asia.json` | `hint_blue_folder` | `"_doc: DRAFT - Asia points Dr. A. Cula to the blue folder on his desk; Mr. Murrow address form reserved for Design."` |

The state carries `"tags": ["hint_state", "blue_folder", "draft"]` and an
`_doc` frontmatter explicitly marking it as awaiting human authorship. The
`lines` array contains the doc-string itself rather than authored game text —
if the trigger fires the player will see the underscore-prefixed doc note in
the dialogue box.

`_comment_ch4_scope` TODO markers in `cula.json` (`family_photo_ch1_repeat`)
and `halina.json` (`post_meeting_ch1`) are documented Chapter-4 scope
deferrals attached to states that are intentionally `silent` or carry a valid
Chapter-1 line; they are not stubs.

## Summary

1 objective violation across 1 file (canonical name diacritic in
`asia_hint_states_ch1.json`).

1 placeholder/stub line across 1 file (`asia.json::hint_blue_folder`) — not
auto-fixable because the human owns the Taste Standard authoring; surfaced
for human action.

6 quality flags for human review (5 `Understood`/`Hm.` filler patterns + 1
clipped `Clear.` reply).
