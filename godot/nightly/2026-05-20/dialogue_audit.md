# Dialogue Canon Audit — 2026-05-20

Files audited (live): `asia.json`, `asia_hint_states_ch1.json`, `barista.json`, `crab.json`, `cula.json`, `dialogues.json`, `halina.json`, `judge_district_ch1.json`, `murrow.json`, `pig.json`, `postcard_swine_ch1.json`, `whimsy.json`.

`meeting_room_stance.json` is named in the audit task but does not exist on disk (consistent with the project memory note that the file was rejected and pending deletion). `dialogues.json` is an empty `npcs: {}` index file and contains no dialogue lines.

`.bak.*` files and `_drafts/` are excluded per the task brief.

Canon source for this run: `godot/AGENTS.md` §Address forms (authoritative) reconciled with the project-memory rule that "Doctor Cula" is non-canonical and that Murrow uses "Dr. A. Cula" exactly once (first meeting) and bare "Cula" everywhere thereafter, including formal/court-facing contexts.

## Address Form Violations

| File | State ID | Issue | Current Text | Suggested Fix |
|------|----------|-------|-------------|---------------|

None found. All address forms reviewed match canon:

- Pig, Asia, Halina, the judge, and Cula himself (introducing) use "Dr. A. Cula" with the middle initial.
- Crab uses "Dr. A. Cula" pre-recruit (`before_binder`, `first_meeting_with_binder`, `after_binder_first_engagement`, the cold `crab_post_halina_incapacity_refuses` rebuke, and the pre-recruit coffee variants) and bare "Cula" post-recruit. Correct per AGENTS.md §Address forms.
- Whimsy uses "Dr. A. Cula" pre-recruit (`whimsy_first_meeting`, `whimsy_post_decoy_incapacity_refuses`, pre-recruit coffee variants) and bare "Cula" post-recruit. Correct.
- Murrow uses "Dr. A. Cula" only at first meeting (`murrow_first_meeting`, plus the path-A `state_2_response_*` opening trio); every subsequent state uses bare "Cula". Matches the `_provenance` declaration and the 2026-05-19 clarification.
- Cula opens with "Mr. Murrow" in his self-introductions and switches to bare "Murrow" after the friend-invitation calibration line (`murrow_first_meeting` line "Then it's Cula." marks the handover). Subsequent Cula-to-Murrow lines (e.g. `cula_b10_readiness_check` "Murrow. We have service, fairness…") use bare "Murrow". Correct.
- "Doctor Cula" (banned form) does not appear in any live file.
- "Dr. Cula" without middle initial does not appear in any live file outside the AGENTS.md/voice_audit lookbehind exception.

## Canonical Name Misspellings

| File | Found | Should Be |
|------|-------|-----------|

None. Pattern scan for `Kula`, `Muraś`, `Wymysl`, and bare `Rak` returned zero matches across all live files.

## Gender Errors

| File | State ID | Issue |
|------|----------|-------|

None. No "Mrs. Cula", "Ms. Cula", "Doctor she", or female pronoun referring to Cula. The four "she/her" hits found in `asia.json`, `crab.json`, `cula.json`, and `halina.json` all refer correctly to Mrs. Sikorska or Mrs. Wójcik.

## Taste Standard Flags

| File | State ID | Issue Type | Line Text |
|------|----------|-----------|-----------|
| asia.json | hint_blue_folder | Placeholder line still in `lines` array (also listed in §Placeholder / Stub Lines below) | `_doc: DRAFT - Asia points Dr. A. Cula to the blue folder on his desk; Mr. Murrow address form reserved for Design.` |
| cula.json | cula_b3_pig_rent_reaction | Generic filler "Understood." (banned per task brief); Cula voice. The accompanying `_comment` frames this as a deliberate dry-register beat that registers Pig's "six weeks" figure without engaging the maritime metaphor. Borderline — flag for human read. | `Six weeks. Understood.` |
| cula.json | cula_b10_pig_lecture_reception | Generic filler "Understood." (banned per task brief) opening Cula's polite reception of Pig's "kraken" aside. `_comment` defends it as polite-but-disengaged register; the punch is in the "keep the printer informed" half. Borderline. | `Understood, Mr. Pig. We will keep the printer informed.` |
| murrow.json | court_readiness_check | Generic filler "Understood." (banned per task brief) opening Cula's pivot from Murrow's procedural rundown to Asia's witness-status check. No `_comment` justification on this specific line. | `Understood. Asia, has Mrs. Sikorska been told we're coming?` |
| pig.json | pig_first_meeting | Generic filler "Understood." (banned per task brief). Identical line to `cula.json::cula_b3_pig_rent_reaction` line 1 — this is the inlined version inside Pig's first-meeting state. Same borderline judgment applies, and the duplication itself is worth a glance: if `cula.json`'s standalone reaction is unreachable (cula.json is dispatched only by the family-photo interactable per project memory), the inline copy in `pig.json` is the canonical instance and the cula.json copy is dead. | `Six weeks. Understood.` |
| halina.json | client_meeting_close | "I do." — Murrow's two-word affirmation in the file-inventory exchange. Borderline; the matrimonial-vow echo is arguably the "clever" element, and the procedural-rhythm staccato matches Murrow's register. Low-priority; flag for human read. | `I do.` |
| halina.json | client_meeting_reveal | "Of course." — Cula's two-word permission for Halina's catch-him-alone moment. On the banned filler list per task brief, but contextually a single courtesy beat before a long disclosure. Borderline; low-priority. | `Of course.` |

No RPG-combat-register hits in dialogue text (no "HP", "damage" used in the combat sense, "attack", "defense", "level up", "monster", "stat", "grind", "XP", "mana"). The single `damage` hit was `whimsy_first_meeting` line referencing "a rights memo with coffee damage on it" — physical staining, not combat damage.

No modern-internet voice hits (no `yikes`, `tbh`, `lol`, etc.).

No invented Polish legal doctrine surfaced in this pass: Article 135-bis KPC, the Tenancy Act fourteen-day notice window, doręczenie zastępcze, and the cooperative renumbering are all anchored to real institutional procedure or to the project's existing canonical fictional building-blocks in `story.txt` / `world.txt`.

## Placeholder / Stub Lines

| File | State ID | Current |
|------|----------|---------|
| asia.json | hint_blue_folder | `_doc: DRAFT - Asia points Dr. A. Cula to the blue folder on his desk; Mr. Murrow address form reserved for Design.` — the `_doc` marker has leaked into the `lines` array; the state ships its own draft note as the line a player would see. Authoring TODO. |

The two `_comment_ch4_scope` TODO entries in `cula.json` (line 20) and `halina.json` (line 273) are deliberate scope-marker comments tied to Chapter-4 retraversal content; they sit on `_comment_*` keys, not on `lines`, and are explicitly flagged as out-of-scope for the current file. Not placeholder violations.

## Summary

0 objective violations (address form / canonical names / gender) across 11 audited live dialogue files plus the empty `dialogues.json` index.

7 quality flags for human review:
- 1 unfilled `_doc` draft surfaced into the `lines` array (`asia.json::hint_blue_folder`) — authoring task.
- 4 "Understood" generic-filler instances in Cula's mouth (`cula.json` ×2, `murrow.json` ×1, `pig.json` ×1), all defended by authored `_comment` blocks as deliberate dry register but matching the task brief's banned-filler list. Worth a deliberate yes-or-no from Design.
- 2 short courtesy beats in `halina.json` (`I do.`, `Of course.`) — borderline filler that may be doing real work in their contexts.

Because there are zero objective violations, the draft-fixes JSON (`godot/data/_drafts/nightly_dialogue_fixes_2026-05-20.json`) is intentionally not written this run.
