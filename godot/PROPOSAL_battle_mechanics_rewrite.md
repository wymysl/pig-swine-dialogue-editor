# PROPOSAL - Battle mechanics rewrite

**Status.** DRAFT for user review. Produced for
`critiques/2026-05-26-design-plan.md` Step 6.1. This file is a proposed
replacement for the body of `../battle_mechanics.txt`; it does not edit that
root source file. Per `AGENTS.md`, the user must either land the root-spec edit
directly or explicitly delegate that edit after reviewing this draft.

**Filed.** 2026-05-26.

**Primary sources checked.**

- `../battle_mechanics.txt` current warning header and obsolete body.
- `PROPOSALS.md` sections 1, 3, 8, and 10.
- `PLAN.md` Standing decisions and Out of scope sections.
- `../story.txt` Chapter 1 Beat 12 and current six-chapter finale structure.
- `../style_canon.txt` Court design principles.
- Runtime files: `data/tag_taxonomy.json`, `data/judgments.json`,
  `data/argument_opponents.json`, `data/evidence_ch1.json`,
  `data/argument_frames_ch1.json`, `data/court_rounds/_schema.md`,
  `scripts/systems/battle/effectiveness.gd`,
  `scripts/systems/battle/packet_scorer.gd`,
  `scripts/systems/battle/battle_controller.gd`,
  `scripts/autoload/state.gd`.

**Chapter-number note.** Older approved proposal text refers to the final case
as Chapter 5. Current `story.txt` and `CURATION_BOARD.md` establish a six-chapter
shape, with the final hearing in Chapter 6 after the compact Kacper chapter was
inserted. This draft follows the current root creative source: Chapter 6 is the
final brief / final hearing. The design rule is unchanged: the Final Printer is
not a standalone mini-game.

---

# Proposed replacement text for `battle_mechanics.txt`

## Part 6 - Casebook Battle System

The player does not collect monsters. The player collects judgments.

The player does not fight creatures. The player contests legal arguments.

The player does not use elemental attacks. The player invokes principles from
authorities, establishes facts on the record, and asks for remedies the court
can actually grant.

The design goal is to borrow the readability and rhythm of a turn-based
effectiveness system while making the substance legal: judgments, principles,
evidence, objections, factual context, and procedural remedies.

The implementation name is **Casebook Battle System**.

Do not use "ECHR Pokemon", "monster battle", "case-catching", or similar terms
in code, UI text, or player-facing design docs.

## Player-facing terminology

Use legal register:

```text
Casebook
Judgment
Authority
Principle
Submission
Argument Strength
Judicial Patience
Witness Cooperation
Trial Record
Legal Encounter
Authority Match
Persuasive Force
```

Avoid game-combat register:

```text
monster
creature
attack
HP
element
type advantage
catch
evolution
trainer
gym
```

Internal code may still use compact engine terms such as `battle`, `move`,
`bucket`, and `effectiveness` where that keeps the implementation clear.
Player-facing text stays legal.

## Core fantasy

Dr. A. Cula faces an opposing submission. The file is incomplete, the court's
patience is finite, and the right authority only matters if the record supports
it. The player must answer three questions:

```text
What fact has the court actually heard?
Which authority answers this legal pressure?
What remedy follows from the defect, without asking for the world?
```

That is the real win condition. The point is not "use Article 6 on Article 6."
The point is: establish service failure, cite the procedural principle that
answers it, and request the modest remedy the chapter permits.

## System objects

The minimum system has these objects:

```text
Judgment
Principle Move
Argument Opponent
Court Round
Phase 1 Fact-Finding State
Phase 2 Closing State
Motion Packet
Trial Record
Effectiveness Resolver
Outcome Band
```

Current runtime files:

```text
data/judgments.json
data/argument_opponents.json
data/tag_taxonomy.json
data/evidence_ch1.json
data/argument_frames_ch1.json
data/court_rounds/_schema.md
data/court_rounds/chapter1_round_0_rehearsal.json
data/court_rounds/chapter1_round_1.json
data/court_rounds/chapter1_round_2.json
data/court_rounds/chapter1_round_3.json
scripts/systems/battle/effectiveness.gd
scripts/systems/battle/packet_scorer.gd
scripts/systems/battle/battle_controller.gd
scripts/ui/trial_record_panel.gd
scenes/ui/trial_record_panel.tscn
```

## Encounter types

Approved encounter types:

1. **Murrow rehearsal.** A Phase-1-only practice encounter before court. No
   verdict, no outcome band, no persistent state except rehearsal completion.
   It teaches Press, Present, and the Trial Record panel.
2. **Court Round.** The main encounter type. Each chapter court uses a fixed
   number of authored rounds. Chapter courts use three rounds. The final court
   uses five rounds.
3. **Advocate Challenge.** A scripted legal challenge by another advocate or
   institutional opponent. These are allowed sparingly when authored as story
   beats, not random encounters.
4. **Final Hearing Round.** The Chapter 6 finale uses Casebook battle logic at
   larger scale. The Final Printer may appear as a Casebook opponent or spectacle
   layer, but it is not a separate mini-game.

Forbidden encounter types:

```text
Wild Argument encounters
Random encounter rates
Training Battles as a separate encounter category
Casebook collection/completion as a goal
Grinding for judgments
Final Printer as a standalone mini-game
```

The Casebook fills through fixed in-world rewards, quest beats, authored
pickups, and chapter completion. The player should never grind legal doctrine.

## Court round structure

Each court round has two phases.

### Phase 1 - Fact-finding

Phase 1 is witness or record examination. The player Presses statements and
Presents evidence. The resource is **Witness Cooperation**.

Phase 1 writes fact flags. Some flags are local to the round (`_fact.*`), and
some evidence cards also surface persistent `chapter1.*` state. These facts are
not flavor; they determine which citations are available in Phase 2.

The design rule:

```text
No fact on the record, no clean citation in closing.
```

A judgment can sit in the Casebook and still be unciteable or weak if the player
never established the fact that lets the principle matter.

### Phase 2 - Closing argument

Phase 2 is the legal submission before the judge. The player cites principle
moves from Casebook judgments against the opponent's pressure move. The resource
is **Judicial Patience**.

The judge raises counter-questions. Available citations are gated by Phase 1
facts, packet assembly state, and the current round's authored data. Each
citation resolves through the tag-effectiveness resolver and records a result in
the Trial Record.

Chapter 1 currently stages Round 1 and Round 2 primarily as fact-finding and
Round 3 as the dispositive closing layer, with data files already authored for
full per-round Phase 1/Phase 2 expansion. The target architecture remains:
every court round may carry its own fact-finding and closing blocks.

## Trial Record

The Trial Record panel is the player's explanation surface. It appears during
rehearsal and court rounds.

It should show:

```text
facts established on the record
facts missed or unavailable
authorities cited
effectiveness result for each citation
the current opposing position
packet completeness, where applicable
```

Effectiveness must be communicated by text and color, never color alone.
Accessibility floor: every label must meet WCAG AA contrast against its
background.

Effectiveness popup language should stay legal:

```text
Directly responsive authority
Relevant authority
Weak fit
No legal effect
Backfires
```

"Super effective" may remain an internal bucket and prototype shorthand. The
final UI should prefer legal labels unless a specific joke earns the phrase.

## Judgments and principle moves

A judgment is a Casebook authority. It has:

```text
id
chapter unlock / pickup condition
draft flag
article tags
principle tags
context tags
principle moves
judgment name
case summary
```

Each principle move has:

```text
id
name
cost
flavor line
effectiveness modifiers or weighted move tags
```

Two-pass authoring rule:

1. Code owns structure: ids, tags, costs, modifiers, taxonomy validity.
2. Design owns text: judgment names, summaries, move names, flavor lines.

Draft judgments are not playable until both passes are complete.

Chapter 1 target set:

```text
procedural_reset_ch1
home_and_family_ch8
expression_and_press_ch10
```

`procedural_reset_ch1` is the fit for Sikorska. The Article 8 and Article 10
judgments are deliberate misfits. They teach the player that an authority can
sound morally attractive and still fail the live procedural question.

## Tag taxonomy

Effectiveness uses three tag families:

```text
Article tag
Principle tag
Context tag
```

The runtime taxonomy is closed and lives in `data/tag_taxonomy.json`.

Current Chapter 1 article tags:

```text
echr_6
echr_8
echr_10
pl_const_45
```

Current Chapter 1 principle tags include:

```text
service_of_process
procedural_fairness
access_to_court
effective_remedy
legal_certainty
prescribed_by_law
proportionality
margin_of_appreciation
private_life
home_inviolability
expression
press_freedom
chilling_effect
public_interest
```

Current Chapter 1 context tags include:

```text
fair_trial
civil_proceedings
housing
service_failure
documentary
deadline
family
public_discourse
```

Do not add tags casually. A new tag requires a Code artifact, taxonomy update,
resolver validation, and tests. Do not create per-judgment custom effectiveness
rules.

## Tag effectiveness - Path A

Path A is the accepted design: tag effectiveness is real.

The resolver in `scripts/systems/battle/effectiveness.gd` is the single source
for mapping a player move against an opponent pressure move. It compares
weighted tag dictionaries and returns:

```text
bucket
score
primary_match
```

Buckets:

```text
super_effective
effective
not_very_effective
no_effect
backfires
```

Runtime rule:

```text
score = weighted dot product of move_tags and opponent weak tags
backfires = move primary tag collides with opponent strength tags
```

The opponent move owns:

```text
weak_to
resists
immune_to / strength tags
base strength or pressure
```

The player move owns weighted tags derived from the judgment move and, where
applicable, presented evidence. Evidence can sharpen a move, but it does not
replace the legal principle.

Backfire is not "wrong Article, ha ha." Backfire means the player strengthened
the opponent's actual frame. Example: relying on margin-of-appreciation logic
when the opponent's best position is precisely that domestic latitude should
control.

## Argument opponents

An Argument Opponent is the opposing legal pressure in the room. In court this
may be opposing counsel, the judge's counter-question, the procedural posture,
or the legal problem itself.

Each opponent round provides:

```text
round label
opening statement
pressure
moves
defeat lines
partial lines
```

Each opponent move provides:

```text
move_id
display_name
article tags
principle tags
context tags
weak_to
resists
immune_to / strength tags
base strength
flavor line
```

Opponent text must be wrong or adversarial in a way a real lawyer might attempt.
It should never be stupid only so the player can look clever.

## Packet assembly

Chapter 1 uses motion-packet assembly before and during court. The player is
not choosing a single abstract theory label. The player is proving the required
elements of a motion to set aside and deciding whether to attach weaker decoys.

Current required packet slots:

```text
element_non_current_address
element_landlord_knowledge
element_timely_actual_notice_motion
element_no_third_party_cure
```

Current optional decoys:

```text
decoy_merits
decoy_notice_period
decoy_standing_wrong_party
decoy_overbroad_remedy
decoy_incapacity
```

Important related state:

```text
chapter1.proposed_frame
chapter1.client_meeting_evidence
chapter1.halina_stance
chapter1.incapacity_penalty
chapter1.recruited_crab
chapter1.recruited_whimsy
chapter1.judicial_patience
chapter1.witness_cooperation
chapter1.phase2_round_results
```

`proposed_frame` is the dominant frame or blunder selected from packet state.
It shapes the bench reaction and starting patience. It is not, by itself, the
final court outcome.

`halina_stance` replaces the old integer `halina_trust`. Valid values:

```text
high
blunt
technical
""
```

`incapacity_penalty` records the specific cost of filing the age/incapacity
blunder. It is a moral and relational consequence, not a progress block.

`recruited_crab` matters because Crab can rescue weak packet paths or withdraw
after the incapacity blunder. The withdrawal must be visible in dialogue before
his support disappears.

## Outcome bands

Court loss never blocks chapter progress. Outcomes grade how the win lands.

Chapter 1 bands:

```text
strong
standard
narrow
blunder-recovered
```

Outcome is computed from both:

```text
packet completeness
Phase 2 citation quality
```

The packet scorer determines whether the motion is structurally complete:

```text
4/4 required slots, no damaging blunder -> strong packet
3/4 with the address defect and one supporting detail -> standard packet
2/4 or decoy-contaminated packet -> narrow packet
<=1 slot, incapacity, or burn-round blunder -> blunder-recovered
```

Phase 2 then downgrades the outcome when citation quality is poor:

```text
backfire -> narrow or worse
unavailable citation -> narrow or worse
repeated no_effect / not_very_effective citations -> narrow
directly responsive citations preserve the packet band
```

Target Path-A final behavior after all dense Phase 2 citations land:

```text
strong = complete packet + repeated directly responsive citations
standard = complete or near-complete packet + enough effective citations
narrow = incomplete packet or weak citation history
blunder-recovered = the bench or ally salvages a fatally compromised packet
```

The current controller computes the dispositive `court_outcome` at end of Round
3. `consume_assembled_packet()` must not write `court_outcome`; packet quality
alone cannot decide the verdict.

## Chapter 1 integration

Chapter 1 court has three questions:

```text
Round 1 - Defective service
Round 2 - Fair hearing / right to be heard
Round 3 - Remedy
```

Round 1 establishes the procedural defect.

Round 2 connects the defect to the affected right.

Round 3 asks for the remedy.

The remedy is modest: set aside or reset the defective hearing so the client can
properly participate. The client does not receive total merits victory. The
firm survives the day, but the harm is not magically undone.

This remedy discipline is load-bearing. Bonus evidence may strengthen the
court's reaction or the flavor of Cula's line, but it cannot upgrade the remedy
beyond procedural reset.

Chapter 1 should be forgiving but not fake. A weak player still advances. A
careful player sees the room acknowledge the difference.

## Murrow rehearsal

The rehearsal exists to teach the verbs before the first real court round.

Rules:

```text
Phase 1 only
one simulated witness
three Press options
one Present option
Trial Record visible
no Phase 2
no verdict
no outcome band
only persistent flag is rehearsal completion
```

Skipping the rehearsal is allowed. The real court must still work.

## Allies and signatures

Allies improve outcomes. Their absence creates weaker outcomes, not hard
failure.

Current Chapter 1 signatures:

```text
Crab - factual defects, service analysis, wrong-address mechanics
Whimsy - rhetorical framing, fair-hearing language, riskier flourishes
Murrow - procedural anchor, archive-law precision, rehearsal teacher
Asia - hint and logistics support; not a courtroom lawyer
```

Whimsy may sharpen an argument already supported by facts. Whimsy must never
substitute rhetoric for missing evidence.

Crab may withdraw from support after the incapacity blunder. The withdrawal is
a visible story consequence, not a silent flag flip.

Asia should not become a court party or cooldown manager. Her function is
office direction, warmth, and practical clarity.

## Evidence integration

Evidence matters in two ways:

1. It establishes facts in Phase 1.
2. It can sharpen a Phase 2 citation when it supports the same legal point.

Evidence should not be manually equipped as a separate pre-battle loadout. The
player already made the meaningful choice by finding it, surfacing it, and
placing it on the record.

Every required investigation item should unlock at least one courtroom use:

```text
fact flag
citation availability
packet slot
bonus reaction
Casebook judgment
```

If an item does none of those, it should be flavor-only or cut from the required
path.

## UI requirements

Court UI should show:

```text
current round
current phase
Witness Cooperation or Judicial Patience
opposing position
Trial Record
available citations
citation result popup
```

Do not show Casebook completion percentage.

Do not make the Casebook a collection grind.

Do not overwhelm the player with twenty authorities during Chapter 1. Chapter 1
should use a small Casebook where the wrong choices teach fit.

## Save data

Saved state must remain backward-compatible. Any saved-state shape change must
follow the save migration policy in `godot/AGENTS.md`.

Battle-related Chapter 1 state currently includes:

```text
court_outcome
court_won_procedural_reset
won_court
element_* packet flags
decoy_* packet flags
proposed_frame
judicial_patience
witness_cooperation
phase2_round_results
halina_stance
incapacity_penalty
rehearsal_accepted
rehearsal_complete
rehearsal_declined
```

`phase2_round_results` entries use this shape:

```text
{
  round,
  citation_id,
  evidence_id,
  evidence_available,
  effectiveness_bucket,
  opponent_move
}
```

These entries support Trial Record display and end-of-court outcome grading.

## Chapter scaling

Chapter courts use the same structure but change the legal question.

Chapter 1 is procedural service and fair hearing.

Chapter 2 can add housing proportionality and individual assessment.

Chapter 3 can add criminal-procedure mitigation and the limits of a compact
assigned case.

Later chapters can add contradiction, technical suppression, mass notices,
public-law compliance, and final-remedy synthesis.

Do not add new core battle systems chapter by chapter. Add data, authored
rounds, judgments, evidence, and opponent moves to the existing system.

## Final hearing and Final Printer

The final hearing is a Casebook battle arc. It synthesizes legal defects
established across the game and asks for a procedurally grounded remedy.

The Final Printer may appear as an opponent, evidence source, pressure device,
or spectacle layer. It is not a standalone mini-game and not a replacement for
the legal closing argument.

The final remedy must cite legal defects, not the firm's emotional worth. Pig
and Swine may have character moments. Those moments are not the legal basis of
the win.

## Implementation order

The system should be implemented in this order:

1. Closed taxonomy and resolver tests.
2. Judgment and opponent data loading.
3. Chapter 1 court-round data files.
4. Phase 1 Press/Present flow.
5. Phase 2 citation flow.
6. Trial Record panel.
7. Packet scoring and outcome bands.
8. Rehearsal.
9. Additional judgments and misfit-bucket distribution.
10. Later chapter round files.

Do not build wild encounters, random encounter tables, training-battle scenes,
mastery meters, combo systems, or completion tracking.

## Acceptance criteria for Chapter 1

Chapter 1 Casebook battle is shippable when:

```text
the player meets Press and Present in Murrow's rehearsal
the Trial Record shows established facts
the player can collect three judgments by the end of investigation
the player can select a judgment and principle move in court
the resolver compares weighted tags from the move and opponent pressure
the player can see at least three effectiveness buckets across the judgment matrix
wrong authorities produce clear legal feedback
packet completeness affects court tone and outcome band
Phase 2 citation quality can downgrade a complete packet
incapacity produces visible relational cost without blocking progress
the court always advances the chapter at some grade
the remedy remains a procedural reset
all text uses legal register, not RPG combat register
```

## Final design target

The system should make players think:

```text
What legal problem is actually before the court?
Which facts did I put on the record?
Which authority answers this pressure?
Is this principle a real fit, or only morally attractive?
What remedy follows from the defect?
What did my bad fallback cost in the room?
```

That is the Casebook Battle System.

---

# Spec consistency check

Every major section above maps to shipped runtime or an approved decision:

| Draft section | Source |
| --- | --- |
| No wild arguments / no grinding / no collection goal | `PROPOSALS.md` §1; `PLAN.md` Out of scope permanently |
| Final Printer not a mini-game | `PROPOSALS.md` §3; `PLAN.md` Out of scope permanently; `style_canon.txt` printer note |
| Two-phase court rounds | `PROPOSALS.md` §10; `data/court_rounds/_schema.md` |
| Trial Record panel | `PROPOSAL_mechanical_depth_2026-05-18.md` item 2; `scripts/ui/trial_record_panel.gd`; `scenes/ui/trial_record_panel.tscn` |
| Tag effectiveness Path A | `critiques/2026-05-26-design-plan.md` Path choice A; `scripts/systems/battle/effectiveness.gd` |
| Closed taxonomy | `data/tag_taxonomy.json`; `PLAN.md` Standing decisions |
| Motion packet assembly | `PROPOSAL_player_driven_argument.md`; `data/argument_frames_ch1.json`; `scripts/systems/battle/packet_scorer.gd` |
| `halina_stance` / `incapacity_penalty` | `SPRINT_LOG.md` Step 5.3; `scripts/autoload/state.gd` SAVE_VERSION 27 |
| Outcome computed after packet + Phase 2 | `SPRINT_LOG.md` Step 1.1; `battle_controller.gd::_compute_court_outcome` |
| Murrow rehearsal | `SPRINT_LOG.md` Step 4.1; `chapter1_round_0_rehearsal.json`; `battle_controller.gd::start_rehearsal` |
| Three Ch1 judgments | `data/judgments.json` |
| Three Ch1 court rounds | `chapter1_round_1.json`; `chapter1_round_2.json`; `chapter1_round_3.json`; `story.txt` Beat 12 |
| Remedy discipline | `story.txt` Beat 12 Round 3; `style_canon.txt` §6 |
| Soft-failure court rule | `PLAN.md` Standing decisions; `style_canon.txt` §7 |

No root `.txt` file was edited by this proposal.

## Follow-up decision requested

If this direction is approved, the user can either:

1. Edit `../battle_mechanics.txt` directly using the proposed replacement text.
2. Explicitly delegate the root-spec edit to an agent in a follow-up prompt.

Until then, agents should continue treating this file as a proposal artifact,
not as a source of truth.
