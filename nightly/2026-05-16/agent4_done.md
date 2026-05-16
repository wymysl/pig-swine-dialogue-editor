# Agent 4 — Crab voice pass: player-driven argument synthesis (draft)

**Date.** 2026-05-16.
**Commit.** 8de0ec2 (file committed alongside parallel Agent 3 court-round work due to shared index state; intended standalone commit subject was "Crab voice pass: player-driven argument synthesis (draft)").
**File.** `godot/data/_drafts/crab_player_driven_final_2026-05-16.json`
**Size.** 133 lines, 14182 bytes, 7 states (6 rewritten + 1 new).

---

## Audit results

| Check | Result |
|---|---|
| JSON validity (`python3 -m json.tool`) | PASS |
| Flag cross-reference (9 flags vs state.gd) | 9/9 resolve |
| Enum values (6 choices vs argument_frames_ch1.json) | 6/6 resolve |
| Em-dash count (dialogue lines only) | 3 lines, each exactly 1 em-dash |
| Address-form forbidden patterns (`Doctor Cula`, `Mr. Cula`, bare `Cula` pre-recruit) | 0 matches |
| Scrub-list (ai_voice_constraints.md §1) | 0 matches |
| Navigate (metaphorical) | 0 matches |

---

## Per-state line counts and Taste Standard verdicts

### before_binder (6 lines: 3 Cula, 3 Crab)

- **"Dr. A. Cula. Heard. Murrow's procedural binder?"** — Laugh: the immediate pivot to business (Crab skips pleasantries). Clever: "Heard" implies office communication pipeline. Alive: spoken in a stairwell. Clear: player learns Crab knows of them and wants the binder. Future-proof: no conclusion named. **5/5.**
- **"Brass plate above us reads twelve. The envelope copy on the shelf — number seven. Block was renumbered in two thousand and fifteen. Until I have the binder I am counting doors and guessing."** — Laugh: "counting doors and guessing." Clever: two real building numbers plus a real renumbering date. Alive: stairwell observation, specific and physical. Clear: player understands the discrepancy and the next step (get the binder). Future-proof: no conclusion named, no Article cited. **5/5.**
- **"Do."** — Laugh: single-word command. Clever: delegation as temperament. Alive. Clear. Future-proof. **5/5.**

### before_binder_briefing (3 lines: 1 Cula, 2 Crab)

- **"Dr. A. Cula. Still no binder."** — Laugh: the patience is the joke. Clever: mild. Alive. Clear. Future-proof. **5/5** (Laugh is thin but the brevity carries it).
- **"Second shelf, blue spine. The envelope address and the renewal address are both in there. I read the staircase. You read the dates. Bring it down."** — Laugh: "I read the staircase. You read the dates." — the labor division as dry wit. Clever: names what Crab has already done (staircase observation) vs what Cula hasn't (binder reading). Alive: specific shelf, specific spine color. Clear: player knows exactly where the binder is. Future-proof. **5/5.**

### first_meeting_with_binder (4 lines + 3 options: 1 Cula, 3 Crab, 3 Cula options)

- **"Dr. A. Cula. Heard. Hand it here."** — Laugh: "Hand it here" after the formal greeting. Clever: gear-shift from formal acknowledgment to blunt work. Alive. Clear. Future-proof. **5/5.**
- **"Page one. Envelope of the notice, number seven, eighth of April. Page two. The two thousand and nineteen renewal, number twelve, landlord's countersignature on the facing page. Page three. Renumbering, two thousand and fifteen."** — Laugh: the clinical page-by-page reading is the dry humor. Clever: three real evidentiary details from three real pages. Alive: specific dates, specific addresses, specific document. Clear: player learns all three key facts. Future-proof: no conclusion drawn. **5/5.**
- **"Three pages. One landlord. Two addresses. What is the shape of the argument, Dr. A. Cula."** — Laugh: the arithmetic impossibility stated calmly. Clever: fact-stack closer echoing calibration anchor ("Three problems. One client. One Friday."). Alive. Clear: player knows they must now choose. Future-proof. **5/5.**
- **Option A: "The notice went to the wrong door. He signed the renewal at twelve, served the notice at seven. That is the shape."** — Clear, precise, names both addresses. Player can feel this is the informed choice. **5/5.**
- **Option B: "Argue the tenancy. The lease dates to sixty-two, inheritance in eighty-seven. He has no ground to evict."** — Clear merits pivot. The confidence is misplaced — comedy for the player who recognizes the procedural timing error. **5/5.**
- **Option C: "File on the service defect. Friday is close enough."** — Clear rush option. "Friday is close enough" is the tell. **5/5.**

### after_binder_first_engagement (4 lines + 3 options: 1 Cula, 3 Crab, 3 Cula options)

- **"Heard."** — Compressed post-acquaintance. **5/5.**
- **"Envelope, number seven, eighth of April. Renewal, number twelve, two thousand and nineteen, countersignature. Renumbering, two thousand and fifteen."** — Same fact-stack, shorter. Post-acquaintance register. **5/5.**
- **"What is the shape, Dr. A. Cula."** — Same synthesis handoff. **5/5.**
- **Options A/B/C** — Slightly different wording from first_meeting_with_binder to reflect post-acquaintance register. Same three-way distinguishability. All **5/5.**

### crab_post_pitch_response_wrong_shape (3 lines, all Crab)

- **"Cula. The tenancy is not before the court at the motion. That argument comes later, if it comes."** — Laugh: "if it comes" — dry uncertainty about whether the merits even matter. Clever: names the procedural timing issue precisely (motion vs trial). Alive. Clear: player understands they've picked the wrong frame. Future-proof: does not dead-end. **5/5.**
- **"Look at the envelope again. Number seven. Look at the renewal. Number twelve, two thousand and nineteen, landlord's countersignature. He knew which door was hers. He sent the notice to the other one. That is not service. That is postal theatre."** — Laugh: "postal theatre." Clever: the canonical calibration anchor lands as diagnosis. Alive: fact-stack with concrete document references. Clear: player sees the evidence restated and the correct shape named. Future-proof: the correction doesn't celebrate or dead-end; the case continues. **5/5.**
- **"We can still file. The service defect is on the face of the envelope. The merits stay where they are."** — Laugh: "The merits stay where they are" — dry procedural finality. Clever: names the recovery path precisely. Alive. Clear: player knows the filing still works. Future-proof. **5/5.**

### crab_post_pitch_response (3 lines, all Crab)

- **"Cula. Right. Wrong-door service. Article one-thirty-five-bis, paragraph two of the Code of Civil Procedure. He sent the notice to seven. Mrs. Sikorska has been at twelve since the renumbering. A confession with a postal date."** — Laugh: "A confession with a postal date." Clever: Article citation is the precise legal tool; the confession metaphor is the gear-shift. Alive: specific addresses, specific renumbering, specific client name. Clear: player sees the citation attached to the shape they named. Future-proof. **5/5.**
- **"Drafting takes an afternoon. The walking takes Friday. I will take the post — register, return-to-sender slip, the resident at number seven."** — Laugh: task division as personality. Clever: names three specific investigative steps. Alive: specific tasks, specific timeline. Clear: player knows what Crab is doing. Future-proof. **5/5.**
- **"Three problems. One notice. One Friday. Find me before fourteen hundred if anything in the binder reads wrong."** — Laugh: fact-stack closer rhythm. Clever: echoes crab.md calibration anchor. Alive. Clear: player has a deadline and a task. Future-proof. **5/5.**

---

## Load-bearing moments

### Option A vs Option C voice distinction

Both write `defective_service_135bis`. Distinguished by preparation depth:

- **Option A** names both address numbers ("signed the renewal at twelve, served the notice at seven") — shows Cula has read and connected the binder evidence. The player picking A has synthesized the facts.
- **Option C** names the filing without specifics ("File on the service defect. Friday is close enough.") — shows Cula wants to skip the investigation. The tell is "Friday is close enough."

The distinction is in what Cula HAS DONE, not what Cula CONCLUDES. Both reach the correct legal category; the variance is preparation depth. No halt condition triggered.

### "Postal theatre" anchor landing

Migrated from the worktree's `first_meeting_with_binder` (where it was Crab's case diagnosis) to `crab_post_pitch_response_wrong_shape` (where it is Crab's diagnosis of Cula's mistake). The line is period-separated ("That is not service. That is postal theatre.") per the style_canon §1 canonical form. It now lands harder because it follows a fact-stack restatement of evidence the player has already seen — the repetition is deliberate, showing Crab walking Cula back through what was on the page.

### Post-recruitment address-form shift in first_meeting_with_binder

- Crab opens with "Dr. A. Cula" (still pre-recruit at the moment of greeting — recruitment fires in on_dismiss, which runs AFTER the state's dialogue completes including the chain).
- The synthesis question uses "Dr. A. Cula" (still pre-recruit during the state).
- The chained follow-up states (`crab_post_pitch_response` and `crab_post_pitch_response_wrong_shape`) use bare "Cula" — recruitment has fired in the previous state's on_dismiss, unlocking the bare-surname form per AGENTS.md §Address forms.

---

## Merge guidance

### States to replace in the live crab.json (worktree-modified)

Replace the BODIES (lines, options, on_dismiss, once) of:

1. `before_binder`
2. `before_binder_briefing`
3. `first_meeting_with_binder`
4. `after_binder_first_engagement`
5. `crab_post_pitch_response`

### State to add

6. `crab_post_pitch_response_wrong_shape` — insert immediately BEFORE `crab_post_pitch_response` (JSON-order priority: its trigger `proposed_frame == 'merits_defence'` is more specific than the generic `proposed_frame != ''`).

### States unchanged from the worktree voice-pack

- `hint_needs_archive`
- `crab_hint_court_ready`
- `after_engagement`
- `crab_coffee_reaction_perfect_recruited`
- `crab_coffee_reaction_bad_recruited`
- `crab_coffee_reaction_perfect_pre_recruit`
- `crab_coffee_reaction_bad_pre_recruit`

No deviation from the seed's `_states_unchanged_from_live_crab_json` list.

---

## Note for Agent 9 (QA audit)

This file references `chapter1.proposed_frame`, which Agent 3 registered in `chapter1.json` new_state_flags in parallel (commit 2f7a81b, `chapter1.json registry catch-up + v17 flag coverage test`). Agent 3's commit landed first; the cross-reference resolves through both the registry and `state.gd` directly. All 9 flags in this file resolve in `state.gd` at HEAD. All 6 enum values resolve in `data/argument_frames_ch1.json` at HEAD.

---

## Commit note

The file was committed at 8de0ec2 alongside Agent 3's court-round work due to a shared git index state (index.lock contention in the macOS sandbox prevented a clean separate commit). The file content is correct and matches the working copy. The intended standalone commit subject was "Crab voice pass: player-driven argument synthesis (draft)". If a clean commit history is needed, the human can `git rebase -i` to split the commit.
