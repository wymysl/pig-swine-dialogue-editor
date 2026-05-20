# Dialogue Assessment + Final-Cut Workflow — 2026-05-17

Scope: `godot/data/dialogues/` (canonical, runner-loaded) and `godot/data/_drafts/` + `godot/data/dialogues/_drafts/` (staging).

## 1. Inventory snapshot

Canonical (loaded at boot):
- `pig.json` — Beat 1 first meeting, hints, coffee reactions. 8 states.
- `murrow.json` v3 — motion-packet rewrite. 14 states. Beat 1 briefing, decoy decisions, post-packet motion-vehicle naming, cold-walkback, court-readiness check.
- `crab.json` v4 — motion-packet rewrite. 13 states. Pre-binder + binder hand-off + post-packet Article 135-bis naming + post-Halina incapacity offer + cold refusal.
- `whimsy.json` v4 — recruitment + civic-records hand-off + D3/D4 decoys + decoy_incapacity refusal.
- `halina.json` v3 — full trust-meter Beat 8: intro → r0 → r1 → r2 → close → reveal. 14 states. Most mature structure in the corpus.
- `asia.json` + `asia_hint_states_ch1.json` — first meeting + 22 progress-keyed hint states (merged into `asia` dispatch).
- `judge_district_ch1.json` — bench prompts and remedy announcements per round / outcome / frame.
- `postcard_swine_ch1.json` — Beat 14 close.
- `barista.json`, `cula.json`, `meeting_room_stance.json`, `dialogues.json` — minor/empty/retired.

Drafts (NOT loaded; staging surface):
- `*_player_driven_final_2026-05-16.json` (murrow, crab, whimsy) — superseded by v3/v4 commits. Safe to delete after diff check.
- `*_player_driven_2026-05-15.json` — earlier exploration, also superseded.
- `nightly_design_pig_2026-05-14.json` — Beat 13 Pig + Murrow/Crab/Whimsy reference lines. **Pending promotion.**
- `nightly_design_murrow_beat9_2026-05-15.json` — Beat 9 archive walkthrough. **Verify against committed murrow.json before promote-or-discard.**
- `nightly_design_beat13_close_2026-05-17.json` — Beat 13 Asia state + coffee-machine env beat. **Pending promotion.** Requires `pig_court_win_acknowledged` flag (Code task) and a new `coffee_machine_ch1.json` file or env-beat injection.
- `halina_with_trust_meter.json` — already promoted; stale.
- `asia_hints_player_driven_2026-05-16.json` — already merged into `asia_hint_states_ch1.json` v3.
- `nightly_dialogue_fixes_2026-05-15.json` — two micro-fixes; one already applied (asia "Dr. A. Cula" period). Verify the murrow `court_readiness_check` Asia line and either apply or close.
- `dialogues/_drafts/{crab,murrow,whimsy}_decoys_2026-05-16.json` — exploratory 4/5-option decoy expansion. Architecture diverges from committed v3/v4 (which uses element_* bools and a single `decoy_incapacity` write). Not merge-compatible without a separate proposal pass.
- `asia_rewrite_2026-05-14`, `pig_rewrite_2026-05-14`, `murrow_v2_2026-05-14` — explicit stubs marked for `git rm`.

## 2. What is working

Voice integrity. Each NPC is identifiable from a single line: Murrow's archival declaratives, Crab's gear-shift closers ("postal theatre" / "standing in the right order" / "older than the building"), Whimsy's declamatory cadence, Asia's domestic-admin observations, Halina's plain dignity, Pig's maritime panic. The `narrative_revision/voice_agents/` bibles and the anti-AI-voice discipline (no contrastive antithesis, capped em-dashes, no scrub vocabulary) are doing real work.

Address-form discipline. "Doctor Cula" / "Dr. A. Cula" / bare "Cula", "Mr. Murrow" → "Murrow" after the friend-invitation, Asia's permanent outer-circle status — all consistent and authored as live constraints, not afterthoughts.

Legal spine. Article 135-bis § 2, the Tenancy Act 14-day window, ex parte hearing, third-clause cure by occupant — these are doctrinal anchors, not decoration. The Taste Standard "Clever" criterion holds.

Halina's trust meter. Three rounds × three stances × trust thresholds × bonus-evidence binding is a genuine branching system with mechanical payoff. The high-trust February-intimidation reveal is the strongest writing in Chapter 1.

Decoy refusal beats land. Murrow + Crab + Whimsy + Halina + Asia each refusing the incapacity-blunder gives the wrong choice a textured social consequence, not just a flag flip.

## 3. What is broken or weak

**3.1. The motion-packet pivot produced long technical first meetings.** `murrow_first_meeting` is 15 lines, 8 of them dense procedural fact-reading before Cula's first interject. `crab.first_meeting_with_binder` is 7 lines reading envelope / renewal / renumbering / notice receipt. `whimsy.before_meeting` packs recruitment + civic-records hobby + remedy framing into 10 lines. A player in hour three will glaze. The Taste Standard "Alive" and "Clear" criteria are bending under "Future-proof flag-write completeness."

**3.2. Decoy mechanics are correct on paper but flat in dialogue.** The D-state option text reads like checklist toggles ("Leave it out / Include in the alternative"). No temptation in the wrong choice, no flavor in the right one. Compare to Halina's `client_meeting_intro` triad (sympathetic / blunt / technical), which carries Cula's whole social register; the decoy choices don't.

**3.3. Choice-payoff asymmetry.** Halina's choices have visible payoff (trust delta, bonus evidence, optional reveal). Crab/Murrow/Whimsy decoy choices write a boolean the courtroom system reads downstream — the player feels no immediate reaction. Crab gives the same gear-shift closer whether notice-period is included or not. The system is hidden; the dialogue isn't carrying it.

**3.4. Cula's voice is thin outside Halina's meeting.** Most Cula lines are placeholders: "Right." / "Understood." / "Working on it." / "Crab. I'm Cula." The motion-packet rewrite reduced Cula's options to "Thank you, Mr. Murrow." Cula is the player's mouthpiece — but most of the time the player is dismissing text, not choosing.

**3.5. Funny is underweighted in the motion-packet states.** `pig_first_meeting` lands ~5 distinct laughs in 14 lines (bankruptcy / polite knock / leaks-and-momentum / printer-by-telephone / Business Development billing). `crab.first_meeting_with_binder` lands one ("postal theatre"). The motion-packet rewrite traded jokes for procedural completeness.

**3.6. NPC monologue bursts without turn-taking.** `murrow_first_meeting` fires 8 NPC lines before Cula's first interject. Halina's round structure forces turn-taking and reads better.

**3.7. Duplicated branching paths costing maintenance.** `crab.json` has two near-identical states (`first_meeting_with_binder` + `after_binder_first_engagement`) for the binder-before-Crab vs binder-after-Crab orders. They've drifted by one `on_dismiss` write and one `once: true`. Bug surface.

**3.8. Schema fragmentation across characters.** Halina = trust meter with thresholds; Murrow/Crab = single-choice flag write; Asia = chain-via-state-id. Different mechanics for "choice that affects future." Increases learning curve and obscures reusable patterns.

**3.9. Decoy refusal beats blur together.** Five characters refusing incapacity in close succession start to sound the same ("I will not do that, that is wrong"). Whimsy's refusal-of-rhetoric ("I sing for the case. I do not sing for that.") is the strongest because it lands in his register; the others need sharper character-specific framings.

**3.10. Drafts are accumulating without cleanup.** 17 files in `_drafts/`. Several superseded by promotion; several are explicit stubs awaiting `git rm`. Cognitive load rising.

## 4. Workflow for taking dialogues to final

Eight phases. The first one is one-time; the others run per beat.

### Phase 0 — Stage cleanup (one-time, do this week)

- `git rm` the explicit stubs: `_drafts/asia_rewrite_2026-05-14.json`, `_drafts/pig_rewrite_2026-05-14.json`, `_drafts/murrow_v2_2026-05-14.json`, `dialogues/meeting_room_stance.json`, `dialogues/dialogues.json`. The runner already skips them.
- For each remaining draft, diff against the committed file. If absorbed → delete. If pending → leave with a `_status: PENDING_PROMOTION_<reason>` field. If exploratory and abandoned → delete or move to `_drafts/_archive/`.
- A draft older than 14 days that has not been promoted is presumed abandoned. Either delete or archive.

### Phase 1 — Beat brief (input, human-authored)

For each Chapter 1 beat still needing dialogue work, write `narrative_revision/beats/<beatN>_<topic>.md`:

- Story-spec source — verbatim from `story.txt §Beat N`.
- Cast in scene + their address forms in this beat.
- Flags that must be true / false coming in.
- Flags this beat must write going out.
- Player choices and their **visible** narrative payoff (not just the flag — what the player sees change in fiction).
- Doctrinal anchor (Polish legal fact this beat parodies).
- **Length budget**: target line count per state, hard cap per state, max NPC lines before a Cula interject.

No drafting without a brief. The brief is the gate.

### Phase 2 — Draft (Claude / nightly agent)

Output: one `_drafts/beat<N>_<npc>_<YYYY-MM-DD>.json` file per beat (not per NPC across beats; that's what produces the accumulation problem).

Drafting rules baked into the agent prompt:

- Cap each state body at **8 NPC lines before a Cula interject**. Need more? Split the state.
- Every Cula option must have a **player-visible payoff** within two beats. No "Right." / "Understood." options unless they enable a `chain: true` to a meaningfully different state.
- Each multi-line state carries **at least two jokes** (the Taste Standard "Laugh" criterion is per-state, not per-NPC).
- Address forms verified inline (state-level `_comment` cites the AGENTS.md rule).
- Trigger and on_dismiss flags written compactly; explanation lives in `_comment`.

### Phase 3 — Voice pass (per-character)

Read draft against `narrative_revision/voice_agents/<npc>.md` + `data/voice_references/<npc>.jsonl` + `narrative_revision/ai_voice_constraints.md`.

Two cuts:
- Remove redundant procedural lines. If the same fact is read aloud by two NPCs, decide which one owns it. Murrow owns the docket; Crab owns the envelope; Whimsy owns the civic records; Halina owns her own paperwork.
- Insert / restore one specific joke per state in the character's pet idiom: Pig = maritime, Crab = gear-shift closer, Whimsy = declamatory metaphor, Murrow = single archival adjective, Asia = domestic-admin observation, Halina = plain dignified factuality.

Output: revised draft, same file, with `_voice_pass_YYYY-MM-DD` summarizing changes.

### Phase 4 — Choice audit (cross-character, post-voice-pass)

For each `options` block in the draft, fill a one-line per choice:

- "Player chose X → the NEXT scene visibly changes Y."
- If Y is null, the choice is fake. Either remove it or add a visible payoff — an NPC line that references the choice, a flavor change two beats later, an Asia hint state that fires only on this path.
- The worst option must still have voice. It should sound like a tempting wrong call, not a checklist false. If the wrong option reads as "obviously do not click this," remove the temptation problem by either (a) making the wrong option's text sound smart-but-misled, or (b) cutting the choice and making the path linear.

This is where the decoy mechanic re-arms: each decoy `true` value must produce at least one downstream dialogue beat that references it visibly. Currently `decoy_notice_period` and `decoy_overbroad_remedy` write flags the courtroom reads but no NPC visibly reacts to. Either add a reaction beat or drop the choice as cosmetic.

### Phase 5 — Taste Standard 5/5 (per-state, per-line)

A focused Claude pass scoring each NPC line on Laugh / Clever / Alive / Clear / Future-proof. 5/5 ship; 4/5 revise; 3/5 cut.

Output: `_taste_standard` array per state, or a sibling review artifact in `narrative_revision/audit/`.

### Phase 6 — Promote to canonical file

Mechanical merge. The draft is the editable surface; the canonical file is the read surface.

Promotion rule:
- Append new states; replace state bodies of existing states only when explicitly noted in the draft's `_merge_strategy`.
- The draft's `_provenance`, `_anti_ai_voice_pass`, `_taste_standard`, `_voice_pass_*` fields move into the canonical file's state-level `_comment`.
- On successful promotion, **delete the draft**. Do not archive. Git history is the archive.

### Phase 7 — Validate

Existing:
- `tools/verify_dialogue_roundtrip.js` — schema check.
- `python tools/voice_audit.py godot/data/voice_references/` — already enforces address forms per memory; extend to scan `data/dialogues/*.json`.
- `godot --headless --path godot --script tests/test_smoke.gd` + `test_runner.gd`.

New tests to author (QA role):
- `tests/test_dialogue_lengths.gd` — fail if any state has > 8 NPC lines without Cula interject; warn if > 12 total lines.
- `tests/test_choice_payoff.gd` — for every state with an `options` block, assert at least one downstream state's trigger references the option's `write_path`.

### Phase 8 — Playtest (manual, infrequent)

Run full Chapter 1 in headed Godot. Capture dialogue log. Read cold for tedium, redundancy, voice slips. Patch via Phase 1–7 mini-cycle.

## 5. Tooling to add or extend

- `tools/dialogue_editor.html` exists (per memory). Extensions: line count per state; warn on > 8 NPC lines without Cula interject; for every option, show downstream states reading its `write_path`; preview the choice-payoff chain as a tree.
- `tools/voice_audit.py` — extend with Taste Standard heuristics (adjective load, em-dash count, contrastive antithesis detection, scrub-vocabulary scan).
- `tools/draft_index.py` — new. Walks `_drafts/`, reports file age, npc, status (promoted/pending/abandoned). Markdown output.
- `tools/choice_audit.py` — new. Walks canonical files, flags fake choices (option whose `write_path` is never read downstream).

## 6. Where Claude / agents fit per phase

| Phase | Owner |
|---|---|
| 0 cleanup | Human / Claude one-off |
| 1 brief | Human (Claude can refine, not generate) |
| 2 draft | Claude (nightly or in-chat), constrained by length-budget rules |
| 3 voice pass | Claude, per-character voice-agent file |
| 4 choice audit | Mechanical script + Claude verdict ("does the wrong option tempt?") |
| 5 Taste Standard | Claude, structured-output pass |
| 6 promote | Mechanical |
| 7 validate | Mechanical |
| 8 playtest | Human; Claude analyzes log after |

## 7. Concrete next moves for the current corpus

In order:

1. **Stage cleanup.** `git rm` the four explicit stubs after confirming the runner skips them (asia_rewrite, pig_rewrite, murrow_v2, meeting_room_stance, dialogues.json). Diff and delete the player-driven-final + decoys + halina_with_trust_meter + asia_hints_player_driven drafts that v3/v4 commits absorbed.
2. **Promote `nightly_design_pig_2026-05-14.json`** (Beat 13 Pig state) and **`nightly_design_beat13_close_2026-05-17.json`** (Beat 13 Asia + coffee-machine env-beat). The latter needs `pig_court_win_acknowledged` flag declared in `state.gd` first — Code task.
3. **Apply or close `nightly_dialogue_fixes_2026-05-15.json`.** Verify the murrow `court_readiness_check` Asia line; one fix already applied.
4. **Audit length on `murrow_first_meeting`, `crab.first_meeting_with_binder`, `whimsy.before_meeting`.** All three exceed the proposed 8-NPC-lines-before-Cula-interject budget. Either split into two states with a Cula interject between them, or trim 2–3 lines.
5. **Decoy-state voice pass.** The D1–D5 option text reads as checklist toggles. Rewrite each option pair with voice: the wrong option should sound smart-but-misled in the character's idiom; the right option should sound like the deliberate procedural reading.
6. **Decoy refusal differentiation.** The three NPC + Halina + Asia refusals of the incapacity blunder need sharper per-voice framings. Whimsy's is the model. Murrow's "unkind and procedurally wrong" works. Crab's three-paragraph refusal trims. Halina's is dignified but plain — add one concrete detail. Asia's is currently generic; her domestic-admin idiom should land here too.
7. **Cula voice strengthening.** Across crab.json, murrow.json, whimsy.json, audit Cula's lines. Replace "Right." / "Working on it." with one-line questions or observations that show the player Cula has read the room. The `cula.json` file is nearly empty — Cula's "speaker" lines live inside other NPCs' state bodies, so the fix is per-state.

## 8. One open question

Murrow's first meeting can be split (preferred per length budget) or trimmed. Splitting changes the chain structure: first state ends after the friend-invitation calibration, second state covers the procedural binder pointer and the cure-by-third-party doctrinal pointer. Splitting is the right call long-term but requires re-running the boot validator's flag-write assertions. Worth doing as a paired Code+Design artifact rather than a Design-only patch.
