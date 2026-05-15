# PROPOSAL — Player-driven argument synthesis (Chapter 1 Sikorska arc)

**Status.** DRAFT — Phase 1 plan, awaiting human approval before Phase 2 execution.
**Filed.** 2026-05-15.
**Relation to existing proposals.** Extends PROPOSALS.md §10 (Court Round two-phase split). §10 is marked DONE in the status table but its implementation skeleton was reverted (see `battle_controller.gd`, `judgment.gd`, `principle_move.gd`, `argument_opponent.gd`, `data/court_rounds/_schema.md` — all REVERTED stubs). This proposal supplies the missing front half of §10's design: how the player gets to the point of having something to argue with by the time Phase 1 begins. §10 covers Phase 1 (witness fact-finding) and Phase 2 (closing argument). This proposal adds a Phase 0 — INVESTIGATE — and reshapes the existing Beats 4–9 dialogue so that what happens in court is the consequence of what the player synthesised before walking in.

---

## 0. The problem named precisely

The Sikorska arc (Chapter 1) currently positions Cula as a courier between people who already know the answer. Verbatim evidence from the current data:

- `data/dialogues/crab.json` state `first_meeting_with_binder` (lines 38–43): on first contact with the binder, Crab in three consecutive lines (a) reads the envelope address and reads the 2019 renewal address, (b) cites "Article one-thirty-five-bis, paragraph two of the Code of Civil Procedure" by name, and (c) delivers the legal frame ("A confession with a postal date"). The player's three choices that follow are tonal — all three set `chapter1.recruited_crab = true` and converge on `crab_post_pitch_response`. Crab's `_branching_constraint` provenance note acknowledges this explicitly: "value=true for every choice ... the wrong-but-not-blocking choice ... is therefore answered by a single Crab response."
- `data/dialogues/murrow.json` state `murrow_first_meeting` (lines 52–67): Murrow delivers the full case — renumbering, 2019 countersignature, "we file a motion to set aside", "fourteen days from actual notice", "Friday at fourteen hundred, courtroom four" — in eight lines before Cula speaks a substantive sentence. Cula's two interjections are clarification follow-ups, not investigative work.
- `data/dialogues/whimsy.json` state `before_meeting` (lines 8–16): Cula opens with the conclusion already named ("Notice went to an address the client left two years ago. The objection is in the papers; the record does not show it"). Whimsy adds rhetorical framing ("The fair-hearing argument can sing. The service defect gives it a throat") and the recruitment closes.
- `data/dialogues/halina.json` is the counter-example. The trust meter (Session 29, SAVE_VERSION 11) gives Halina three real branches with consequential variation — bonus evidence shifts by stance, the high-trust reveal carries the landlord-intimidation thread into Ch4. This is the shape the rest of the arc lacks.

The mechanic-narrative mismatch is real. The game's identity, per `godot/AGENTS.md` §Project identity, is "a parody of post-Soviet legal practice that takes its law seriously and its dignity not at all" — but the player currently doesn't do any law. Crab, Murrow, and Whimsy do it for them.

## 1. Narrative reshape across the Sikorska arc

The reshape principle: **NPCs provide observations, partial views, and doctrinal raw material. Cula (the player) synthesises.** Each NPC moves from "teacher who states the conclusion" to "witness who names what they noticed." The wrong synthesis must be reachable and consequential, not just survivable.

The named dialogue states below are the rewrite targets. Existing state IDs are preserved; line content changes. Existing `on_dismiss` flag writes are preserved at semantically-equivalent triggers. No new flags introduced beyond what §3 specifies.

**Crab — `crab.json`.**

- `before_binder` (pre-binder, first contact): Crab observes the envelope number, observes the building number above the stairwell. He does not connect them. The "postal theatre" calibration anchor stays — it is a *temperament* line about how envelopes can lie, not a *case-specific conclusion*. Crab's job in this state is to make Cula look at the envelope.
- `before_binder_briefing` (repeat pre-binder visit): Crab names the renumbering as a historical fact about the building, not a conclusion about the case. "The block was renumbered. The dates are in the binder. I am not the one who reads the dates." This is the procedural-investigator move — Crab knows where the paper is, not what it says.
- `first_meeting_with_binder` (the load-bearing rewrite): Cula has the binder; Crab takes it, finds the envelope copy, finds the renewal page. He reads aloud what is on each. He does not say which Article applies and does not name the defect. The options block becomes Cula's *synthesis* choice — three argument frames Cula proposes, only one of which is well-fitted to the evidence in front of them. Crab's response to each is calibrated by *fit*, not by recruitment stance: wrong frames get a procedural correction; the right frame gets quiet approval. Recruitment now happens on the next state (`crab_post_pitch_response`) and is gated on having proposed something procedurally credible — *not* on having proposed the canonically right thing. A wrong-but-procedurally-credible frame still recruits Crab; a frame that misreads the evidence (e.g. "merits") earns a beat where Crab walks Cula back through the document before the player retries.
- `after_binder_first_engagement` (late-binder path): same shape as `first_meeting_with_binder` — synthesis-choice options, fit-calibrated responses.
- `crab_post_pitch_response`: post-synthesis. Crab now produces the *labelling* — "Article 135-bis, paragraph two of the Code of Civil Procedure" — but only after Cula has named the *shape* of the argument (defective service, prior knowledge, no third-party cure). This is the new contract: Cula sees the legal shape, Crab attaches the legal citation.

**Murrow — `murrow.json`.**

- `murrow_first_meeting`: the eight-line case briefing collapses to three observation-shaped lines. Murrow names what is true about the *file* (the dates, the countersignature, the docket entry) but does not say what the file *means*. The "motion to set aside" line moves to a later state, gated on Cula having proposed a defective-service frame. The fourteen-day window line stays — it is a fact about KPC, not about Cula's case. Murrow keeps the friend/Mister-Murrow exchange and the meeting-room handoff to Halina.
- `post_briefing_pre_binder`: unchanged (one-line shelf nudge).
- `has_binder_pre_crab`: rewrites from "Now Crab. Nothing else moves until service is checked" to a state that asks Cula what she has read in the binder. Branches on a binder-reading flag (see §3) — Cula who has skimmed gets a different response than Cula who has read.
- `court_readiness_check`: unchanged in shape but the readiness items are now *flag-checked* rather than asserted. Murrow asks Cula to state the argument; Cula's options block produces the closing posture that Phase 2 will consume. The current "Service first. Fair hearing second. Remedy last" line moves into a Cula-spoken option, not a Murrow line.

**Whimsy — `whimsy.json`.**

- `before_meeting`: Cula opens with the *question* she wants help with, not the conclusion. The current opening ("Notice went to an address the client left two years ago. The objection is in the papers; the record does not show it") becomes a *Cula option* — one of three framings the player can pitch to Whimsy. Whimsy's response varies by framing: the procedural-defect pitch gets the "fair-hearing argument can sing" response (current line); a merits-first pitch gets a Whimsy walk-back ("The merits are for after the door is open. The door is the procedural point"); a generic "I need help" gets Whimsy probing for the shape ("Tell me the geometry of the wrong, and I will lend it a throat"). All three paths still recruit; the variance is in what *kind* of co-counsel Whimsy becomes in court — a flag the Phase 2 closing-argument controller will read.

**Halina — `halina.json`.** No change. The trust meter already implements the right shape and is the calibration anchor for this whole proposal. The bonus-evidence enum (`wojcik_witness_statement` / `return_to_sender_slip` / `lease_1962_inheritance_1987` / `landlord_contact`) is the existing model for "what investigative depth produces evidence-of-record."

**Asia — `data/dialogues/asia.json` and `asia_hint_states_ch1.json`.** Asia is a hint surface, not an answer surface; her existing role is correct under the new design. Asia's hints become *signposts to investigative gaps* rather than gates on quest-flags: when the player has the binder but has not opened the synthesis screen, Asia's hint nudges toward the binder. When the player has proposed a wrong frame to Crab, Asia's hint nudges toward re-reading the envelope.

## 2. Reasoning surface — where does the player actually synthesise?

Three candidates evaluated.

**(a) Blue binder UI as a standalone casework screen.** A pause-screen with evidence cards (what Crab observed, what Halina said, what is in the renewal), a statute panel (Article 135-bis text excerpt), and a proposed-argument frame the player assembles by combining evidence + statute. This is the casework metaphor.

**(b) Court-round battle UI as the synthesis venue.** No pre-court pause-screen; synthesis happens in dialogue option-blocks and live in court, turn-by-turn. The existing dialogue-options + court-round battle controller carry the load.

**(c) Both — binder for pre-court assembly, battle for delivery and counterargument defence.** Binder is the workshop; court is the performance.

**Recommendation: (c) with (b) as the load-bearing surface and (a) as a v2 deliverable.**

Reasoning: the existing dialogue-options mechanic is *already* a synthesis surface — option-blocks let Cula say "this is the shape I think the argument is." Halina's trust meter proves the shape works. Adding a binder UI now risks building a screen the player visits twice and never again. The dialogue-option synthesis approach gives us the player-driven mechanic at low scope, validates the design with a playable Beat 4–9 in this sprint, and earns the right to build the binder UI later as a *visualisation* of state the player has already produced through dialogue choices.

The binder UI is the v2 deliverable because the assembly metaphor really does become valuable in Chapter 3 (Kacper's *areszt śledczy* visit, multiple evidence threads) and Chapter 5 (Final Hearing). Building it for Chapter 1 alone is over-investment.

The court-round battle UI is the load-bearing surface. The reverted `battle_controller.gd` skeleton from commit c83feaa should be restored (per `PROPOSAL_court_rounds_schema.md`'s revert note: "When §10 is approved, restore the previous content from commit c83feaa"). §10 is now DONE per PROPOSALS.md status table; the revert was procedural, not editorial. The restoration becomes the venue where Phase 1 (witness fact-finding) and Phase 2 (closing argument) play out. Player turns in court are the Ace Attorney **Press** and **Present** primitives, mapped to legal mechanics — see §7.

**Hard call I am making, for the human to override.** The binder pause-screen mood is unspecified — index cards vs case-file pages vs Ace-Attorney evidence panel. My default for the v2 binder is *case-file pages* (annotated paper, marginalia in Murrow's handwriting, paper-clipped exhibits): it matches the office register (period-frozen 1990s/2000s) and the existing pickup_line for the procedural binder ("Murrow has flagged Article 135-bis in three colors"). If the human prefers the index-cards or AA-evidence-panel direction, name it before v2 starts. The Phase 1 work in this proposal does not depend on this choice.

## 3. Data model

Three additions, all behind one SAVE_VERSION bump.

**Evidence cards** — `data/evidence_ch1.json` (new file, Code-owned schema, Design-owned text). Schema:

```json
{
  "version": 1,
  "evidence": {
    "envelope_address_number_seven": {
      "display_name": "Eviction notice envelope (no. 7)",
      "source": "binder_page_1",
      "discovered_when": "chapter1.has_law_binder == true",
      "argument_tags": ["service_of_process"],
      "context_tags": ["service_failure", "documentary"],
      "press_lines": ["The envelope reads number seven, dated the eighth of April."]
    },
    "renewal_2019_number_twelve": { /* ... */ },
    "renumbering_2015_fact": { /* ... */ },
    "wojcik_witness_statement": { /* hydrated from items.json bonus evidence */ },
    "return_to_sender_slip": { /* ditto */ },
    "lease_1962_inheritance_1987": { /* ditto */ }
  }
}
```

Bonus evidence already exists in `data/items.json` with `argument_tags`, `context_tags`, `required_for_rounds`, `stance_gate`. The new evidence file generalises that pattern to *all* evidence — observed-on-page items get the same shape as picked-up items. The pickup mechanic in `scripts/actors/pickup.gd` is unchanged; the new file is read by the (new, see below) synthesis engine and the (restored) battle controller.

**Argument frames** — `data/argument_frames_ch1.json` (new file). Schema:

```json
{
  "version": 1,
  "frames": {
    "defective_service_135bis": {
      "display_name": "Service to the wrong address",
      "supporting_evidence": ["envelope_address_number_seven", "renewal_2019_number_twelve", "renumbering_2015_fact"],
      "statute_anchor": "kpc_135_bis_para_2",
      "court_round_unlock": "round_1_open",
      "well_fitted": true
    },
    "third_party_non_cure": { /* depends on resident-at-no-7 fact */ },
    "fair_hearing_article_6": { /* depends on Rights Memo */ },
    "merits_defence": {
      "display_name": "Argue the underlying tenancy",
      "supporting_evidence": ["lease_1962_inheritance_1987"],
      "well_fitted": false,
      "wrong_shape_correction": "The merits are not before the court. Service is the door."
    }
  }
}
```

Argument frames are the synthesis units. The dialogue options the player picks in §1's rewrites set `chapter1.proposed_frame = <frame_id>`. The court-round controller reads this flag at Phase 2 start and uses it to gate citations.

**Save-state additions.** `State.data.chapter1` adds (booleans default false, strings default `""`):

- `chapter1.binder_read_envelope: bool` — set when the player has read the envelope-address evidence card (dialogue or binder UI). Required for proposing the defective-service frame.
- `chapter1.binder_read_renewal: bool` — set when the player has read the 2019 renewal page evidence card.
- `chapter1.binder_read_renumbering: bool` — set when the player has surfaced the 2015 renumbering fact.
- `chapter1.proposed_frame: String` — the argument frame Cula committed to in the Crab synthesis dialogue. Enum: `""` (none) / `"defective_service_135bis"` / `"third_party_non_cure"` / `"fair_hearing_article_6"` / `"merits_defence"`.
- `chapter1.whimsy_co_counsel_posture: String` — the rhetorical posture Whimsy adopted when recruited. Enum: `""` / `"procedural_throat"` / `"merits_pivot"` / `"open_register"`. Affects Phase 2 closing-argument flavor lines.
- `chapter1.judicial_patience: int` — already specced in PROPOSALS.md §10 Phase 2. Declared now (default 5) so dialogue/court systems can both read/write it cleanly.
- `chapter1.witness_cooperation: int` — already specced in §10 Phase 1. Declared now (default 0) so Phase 1 controller writes are pre-validated.

**SAVE_VERSION bump.** 16 → 17. Migration in `scripts/systems/save.gd`: add the seven new keys with defaults, preserve existing keys, idempotent. Test in `tests/test_save_migration_v16_v17.gd` following the established pattern from `test_save_migration_v14_v15.gd`: SAVE_VERSION ≥ 17 assertion (not ==), forward-add only, full v1→v17 chain regression.

**Tag-taxonomy and existing-data compatibility.** No new tags required — the existing `data/tag_taxonomy.json` closed list covers Chapter 1 entirely. The new evidence/frame files use only currently-declared article/principle/context tags. The existing `data/items.json`, `data/judgments.json`, and `data/argument_opponents.json` shapes are unchanged; the new files reference into them.

## 4. Failure modes

Three options for what happens when the player picks a wrong-shape frame.

**Loud-fail-and-retry.** Lose the round, retry the case. Rejected — punitive, kills tension, makes the game a flashcard quiz with consequences attached. Not consistent with the trust-meter idiom Piotr already validated for Halina.

**Soft-fail-with-judicial-skepticism.** Wrong frame is reachable; the round still plays out; `chapter1.judicial_patience` drops; closing-argument remedy is weaker. The player can still win the chapter on a wrong frame, but the remedy is narrower (procedural reset with explicit costs-against-landlord becomes procedural reset only) and Phase 2 flavor lines reflect the judge's reduced patience. **Recommended.** This is the Halina trust-meter pattern mirrored to the court venue and matches §10's `judicial_patience` design. The wrong choice carries consequence without dead-ending the player.

**Branch-and-live-with-it.** Wrong frame survives, you lose the case, the chapter forks into a "Halina is evicted" tail. Rejected for Chapter 1 — too punitive for the player's first court encounter and not narratively earned. Reserve this shape for Chapter 3 (Kacper's Assigned Case, where the moral question itself is whether procedure can save someone whose situation procedure was not designed for) and Chapter 5 (Final Hearing, where the three-branch ending per PROPOSALS.md §11 is explicit).

The soft-fail design gives us two consequential dimensions on Chapter 1 outcomes that aren't currently load-bearing:

- `chapter1.court_outcome` (already in state) gains real variance — currently it's a string-default; under soft-fail it carries `"procedural_reset_full"` vs `"procedural_reset_narrow"` vs `"procedural_reset_with_costs"` based on (frame fit) × (judicial patience) × (bonus evidence). All three are *wins*, just calibrated wins.
- The Ch4 corridor-sighting beat per PROPOSALS.md §11 has more to grab onto. "The procedural reset was real. The harm continued anyway" lands harder when the player remembers having ground judicial patience down to win on the wrong frame.

A wrong frame is recoverable mid-court: Phase 1 Press/Present misses cost `witness_cooperation` but do not lock out Phase 2; Phase 2 misses cost `judicial_patience` but do not lock out the next citation. This matches §10's design ("a sloppy questioning round actually cost the player when they reach the judge"). The player who realises mid-round they've picked the wrong frame loses depth, not the win.

## 5. Role split per godot/AGENTS.md

| Sub-work | Owner | Notes |
|---|---|---|
| `state.gd` additions (the 7 new keys above) | Code | Single writer; per `.antigravity/skills/code.md` |
| `save.gd` v16→v17 migration | Code | Plus `tests/test_save_migration_v16_v17.gd` |
| `signals.gd` — new signal `evidence_card_read(card_id)` if needed by binder UI v2 | Code | Defer if Phase 0 ships without binder UI |
| `scripts/systems/battle/*` restoration from commit c83feaa | Code | `git show c83feaa -- godot/scripts/systems/battle/` and re-apply, then iterate |
| `data/evidence_ch1.json` — structural shape (schema, ids, flags) | Code | Mechanical fields |
| `data/evidence_ch1.json` — display text, press_lines | Design | Per item, Taste Standard pass |
| `data/argument_frames_ch1.json` — schema, ids, supporting_evidence lists, well_fitted flags | Code | Mechanical fields |
| `data/argument_frames_ch1.json` — display_name, wrong_shape_correction text | Design | Per frame, Taste Standard pass |
| `data/court_rounds/chapter1_round_*.json` — Phase 1 witness statements + press/present option trees | Design (text) + Code (state-machine fields) | Per §10's authoring shape |
| `data/dialogues/crab.json` rewrites (states `before_binder`, `before_binder_briefing`, `first_meeting_with_binder`, `after_binder_first_engagement`, `crab_post_pitch_response`) | Design | Preserve existing on_dismiss flag writes; pass Taste Standard 5/5; comply with `AGENTS.md` §Address forms |
| `data/dialogues/murrow.json` rewrites (states `murrow_first_meeting`, `has_binder_pre_crab`, `court_readiness_check`) | Design | Same constraints |
| `data/dialogues/whimsy.json` rewrites (state `before_meeting`) | Design | Same constraints |
| `data/dialogues/asia_hint_states_ch1.json` — new hint states keyed off the new binder-read flags | Design | Hint signposts to investigative gaps |
| Binder UI scene (v2) — `scenes/ui/blue_binder.tscn`, `scripts/ui/blue_binder.gd` | Code (structure) + Design (page text/marginalia) + Art (paper texture, handwriting font, exhibit images) | Deferred to v2 sprint |
| Phase 1 / Phase 2 controller integration | Code | Per §10; lives in `scripts/systems/battle/battle_controller.gd` |
| Test suite extensions | QA | `tests/test_save_migration_v16_v17.gd`, `tests/test_argument_frame_synthesis.gd`, `tests/test_chapter1_phase_b.gd` updates |
| `SPRINT_LOG.md` entries | All | Per-role on completion |

Handoffs needed:

1. Code authors the SAVE_VERSION 17 migration and the new state-keys before Design rewrites the dialogues, so Design can reference the new flags by name in triggers.
2. Code authors the schema for `evidence_ch1.json` and `argument_frames_ch1.json` (empty or stub entries) before Design fills in the text fields, per the two-pass authoring discipline already used for `judgments.json` and `argument_opponents.json`.
3. Code restores the battle controller from commit c83feaa before Design authors any Phase 1 or Phase 2 content, so Design knows the surface they are writing for.
4. Design rewrites the three NPC dialogue files only after Code's flag writes are in place.

The natural Phase 2 execution order is: Code state/save/schema → Code battle restoration → Design dialogue rewrites → Design court_rounds authoring → QA tests. Each is a separable commit.

## 6. Migration cost — honest scope

Realistic estimate: **two to three sprint sessions** for a coherent Phase 0 + Phase 1 first cut. Single sprint is feasible if the binder UI is genuinely deferred and Phase 1 ships with text-only press/present dialogue rather than a custom court UI. Phase 2 (closing argument) can ship in the same sprint as Phase 1 because both phases reuse the dialogue-options mechanic.

Recyclable from current Sikorska content:

- All four bonus-evidence definitions in `data/items.json` (already shaped right — `argument_tags`, `context_tags`, `required_for_rounds`).
- `data/judgments.json` `procedural_reset_ch1` — the four principle moves and tag sets are unchanged; only the gating predicate changes from "won three rounds" to "well-fitted frame + adequate judicial patience."
- `data/argument_opponents.json` `landlord_counsel_ch1` — the three rounds, six moves, opening statements, and effectiveness tags are all reusable. The opponent's Phase 1 / Phase 2 split is additive; existing rounds become Phase 2 closing-argument rounds and Phase 1 fact-finding rounds get authored fresh.
- `data/dialogues/halina.json` — the load-bearing rewrite reference. No changes required.
- `tag_taxonomy.json` — unchanged.
- `effectiveness.gd` — unchanged; the resolver and bucket math work as-is for the new flow.

Rewriting required:

- Five state bodies in `crab.json` (specifics in §1).
- Three state bodies in `murrow.json`.
- One state body in `whimsy.json`.
- Several hint states in `asia_hint_states_ch1.json`.

Net dialogue word-count change is roughly *flat* — Crab's current first-meeting state is dense; the rewrite redistributes the same content across an observation phase + a synthesis phase. The hard part is voice discipline. Each NPC has a voice agent in `narrative_revision/voice_agents/` and a constraints file in `narrative_revision/ai_voice_constraints.md` — the Phase 2 dialogue work must consult both, per the established Design workflow.

If Phase 2 ships only dialogue + state/save without restoring the battle controller, that is also a coherent stopping point. The dialogue rewrites alone produce a meaningfully different chapter — the player synthesises through dialogue choices and the eventual court round consumes the flags later. This is the *minimum viable Phase 2* if scope tightens.

## 7. Pokémon Yellow vs Ace Attorney — what we should actually steal

The human raised both as inspirations. They are not equivalent for this game.

**Pokémon Yellow** = menu-driven turn-based selection from a fixed move set. Each move has a type, the opponent has a type, type-effectiveness multiplies damage. The player's authorial moment is *choosing* between owned moves, not constructing arguments. The Casebook already has this skeleton — `principle_moves[]` per judgment, the `effectiveness.gd` resolver, five buckets. Pokémon's contribution to this design is **the turn structure and the bucket-resolution math** — both of which we already have in `effectiveness.gd`. Pokémon is a poor analog for *how legal argument is built* because it offers no surface for synthesis. The player owns moves; they don't construct them.

**Ace Attorney** = an investigation phase (Examine, Talk) followed by a courtroom phase whose primitives are **Press** (push a witness on a specific statement to elicit detail) and **Present** (offer a piece of evidence against a specific statement to land a contradiction). The (statement_id, evidence_id) match is checked; wrong matches cost penalty. AA's contribution to this design is **the unit of argumentation**: a piece of evidence *aimed at* a specific opposing claim. That is the operation a real lawyer performs. That is the missing primitive in the current Sikorska arc.

**Synthesis the proposal commits to:**

- Pokémon-shaped *turn structure* — turn-based, menu-driven, opponent argues first, player picks a response.
- Pokémon-shaped *effectiveness math* — keep `effectiveness.gd` and the five buckets. Tag-fit drives strength.
- Ace-Attorney-shaped *response primitive* — the player's "move" is the tuple (principle_move from Casebook, evidence from current case file). Both elements are chosen by the player each turn. Wrong evidence with a right move → no_effect or backfires; right evidence with a wrong move → not_very_effective. The Casebook's `principle_moves[]` becomes the move set; `data/evidence_ch1.json` becomes the evidence pool.
- Ace-Attorney-shaped *Press* — a non-attacking action that asks the opposing counsel to expand a statement. Costs a turn, opens a sub-statement that may be Presentable against. This is how Phase 1's `witness_cooperation` resource gets exercised against witnesses.
- Halina-trust-meter-shaped *consequence* — `judicial_patience` and `witness_cooperation` are running tallies, not hit points. They calibrate the *quality* of the win.

This is a fusion, not a port. Pokémon contributes the chassis; AA contributes the soul; the trust-meter contributes the consequence model.

## 8. Open questions for the human

Three calls I am making with defaults, for the human to confirm or override.

1. **Binder UI mood (case-file pages vs index cards vs AA evidence panel).** Default: case-file pages with paper texture and Murrow marginalia. Decision needed before v2 sprint, not before v1.
2. **Should Phase 2 ship before the battle controller is restored?** Default: yes. Dialogue rewrites + state/save migration are a coherent commit; the controller restoration is a separable second commit that lands after dialogue is in place. This protects the Phase 0 → Phase 1 dialogue work from being held up by controller scope.
3. **Are the seven new state-keys in §3 acceptable, or do you want a narrower set?** Default: ship all seven. `binder_read_*` flags are the read-state hooks for Asia's hint surface and the binder UI v2; `proposed_frame` and `whimsy_co_counsel_posture` are the synthesis-output flags; `judicial_patience` and `witness_cooperation` are §10's resource counters and need to exist somewhere — declaring them now beats declaring them in the next SAVE_VERSION bump.

## 9. What this proposal explicitly does *not* do

- Does not alter the Casebook tag taxonomy.
- Does not introduce new Polish legal doctrine.
- Does not touch the Halina trust meter, the postcard chain, or the coffee minigame.
- Does not deliver the binder UI in v1 (deferred to v2).
- Does not extend the procedural-reset judgment's tag set or principle-move set.
- Does not change the chapter outcome — Halina still wins on procedural reset, the firm still gets the 5,000 PLN fee, the corridor sighting in Ch4 still happens. The win is *narrower or wider* based on play; it is not turned into a loss.

## 10. Acceptance criteria for the Phase 2 first cut

The Phase 2 implementation is "first cut acceptable" when:

- `godot --headless --path . --script tests/test_smoke.gd` → EXIT 0.
- `godot --headless --script tests/test_runner.gd` → EXIT 0.
- `godot --headless --path . --export-release "Web" exports/web/index.html` → EXIT 0.
- `tests/test_save_migration_v16_v17.gd` passes (added in Phase 2).
- The three rewritten dialogue files (`crab.json`, `murrow.json`, `whimsy.json`) pass `jq empty` validity and the cross-reference check that every referenced flag exists in `State.reset_state()`.
- A player walking the Beat 4 → Beat 9 path can reach the binder, the Crab synthesis dialogue, the recruitment beat, the Halina meeting, the archive research, and the court-ready state without dead-ending. (Manual playthrough; documented in `BUILD_NOTES.md`.)
- The wrong-frame path is reachable and survivable: a player who picks the "merits defence" option at the Crab synthesis dialogue still reaches a playable end-of-chapter state, with `chapter1.court_outcome` reflecting the calibration.

---

**Human, before Phase 2.** Three things to confirm or override: the §8 open questions above. Default if unchanged: case-file binder mood, dialogue/migration commit lands before controller restoration, all seven new state-keys ship.
