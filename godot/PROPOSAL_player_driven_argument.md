# PROPOSAL — Player-driven argument synthesis (Chapter 1 Sikorska arc)

**Status.** DRAFT — Phase 1 plan revised 2026-05-16. Original §1 / §3 / §4 / §7 funnelled the player to a single answer; the revision adds credible decoy frames so synthesis is a real choice. The overnight cohort (commits `2f7a81b` through `8d6bb3b`) landed the v17 system scaffolding, the QA passes, and the voice-pack rewrites against the original funnel design — the runtime is consistent with itself but does not yet implement the decoy mechanic. This revision is the design target the next implementation pass works against.
**Filed.** 2026-05-15. **Revised.** 2026-05-16.
**Relation to existing proposals.** Extends PROPOSALS.md §10 (Court Round two-phase split). §10 is marked DONE in the status table but its implementation skeleton was reverted (see `battle_controller.gd`, `judgment.gd`, `principle_move.gd`, `argument_opponent.gd`, `data/court_rounds/_schema.md` — restored by Agent 1 of the overnight cohort at commit `603f65e`). This proposal supplies the missing front half of §10's design: how the player gets to the point of having something to argue with by the time Phase 1 begins. §10 covers Phase 1 (witness fact-finding) and Phase 2 (closing argument). This proposal adds a Phase 0 — INVESTIGATE — and reshapes the existing Beats 4–9 dialogue so that what happens in court is the consequence of what the player synthesised before walking in.

---

## 0. The problem named precisely

The Sikorska arc (Chapter 1) currently positions Cula as a courier between people who already know the answer. Verbatim evidence from the current data:

- `data/dialogues/crab.json` state `first_meeting_with_binder` (lines 38–43): on first contact with the binder, Crab in three consecutive lines (a) reads the envelope address and reads the 2019 renewal address, (b) cites "Article one-thirty-five-bis, paragraph two of the Code of Civil Procedure" by name, and (c) delivers the legal frame ("A confession with a postal date"). The player's three choices that follow are tonal — all three set `chapter1.recruited_crab = true` and converge on `crab_post_pitch_response`. Crab's `_branching_constraint` provenance note acknowledges this explicitly: "value=true for every choice ... the wrong-but-not-blocking choice ... is therefore answered by a single Crab response."
- `data/dialogues/murrow.json` state `murrow_first_meeting` (lines 52–67): Murrow delivers the full case — renumbering, 2019 countersignature, "we file a motion to set aside", "fourteen days from actual notice", "Friday at fourteen hundred, courtroom four" — in eight lines before Cula speaks a substantive sentence. Cula's two interjections are clarification follow-ups, not investigative work.
- `data/dialogues/whimsy.json` state `before_meeting` (lines 8–16): Cula opens with the conclusion already named ("Notice went to an address the client left two years ago. The objection is in the papers; the record does not show it"). Whimsy adds rhetorical framing ("The fair-hearing argument can sing. The service defect gives it a throat") and the recruitment closes.
- `data/dialogues/halina.json` is the counter-example. The trust meter (Session 29, SAVE_VERSION 11) gives Halina three real branches with consequential variation — bonus evidence shifts by stance, the high-trust reveal carries the landlord-intimidation thread into Ch4. This is the shape the rest of the arc lacks.

The mechanic-narrative mismatch is real. The game's identity, per `godot/AGENTS.md` §Project identity, is "a parody of post-Soviet legal practice that takes its law seriously and its dignity not at all" — but the player currently doesn't do any law. Crab, Murrow, and Whimsy do it for them.

## 1. Narrative reshape across the Sikorska arc

The reshape principle: **NPCs surface evidence pointing at multiple credible argument frames. Cula (the player) synthesises by choosing which frame the evidence best supports.** Each NPC moves from "teacher who states the conclusion" to "investigator who hands Cula raw material relevant to several arguments at once." The wrong synthesis must be reachable, credible at the moment of choice, and consequential — wrong frames cost `judicial_patience`, cost `halina_trust`, and burn one of three court-round attempts. The player who picks wrong is not punished into reload; they argue the wrong case and the chapter calibrates around it.

**Decoys are load-bearing.** Without decoys, "synthesis" collapses into "connect the only available dots." Raw-data-no-nudging is the model for later chapters once the player has Casebook intuition; Chapter 1 needs *scaffolded* synthesis where the right answer is reachable and the wrong answers are credible. This revision introduces four argument frames (plus an optional fifth hard-wrong) that any procedurally-literate junior in Cula's position would consider, each with at least one piece of supporting evidence the NPCs put on the table.

### The four frames

1. **Substantive defense — fight the eviction on merits.** Argue Mrs. Sikorska has met every obligation under the lease; the underlying tenancy is sound. Anchor evidence: payment receipts from Sikorska's records (six months of rent statements showing settlement) plus the 1962/1987 lease chain. *Wrong because Friday is too close to develop merits substance, and the procedural defect already wins the immediate hearing.* This frame absorbs the old "rush to file" and "merits_defence" wrong-shape from the original §3 — it is now an explicit, named, evidence-supported decoy rather than an implicit straw.
2. **Notice-period failure — argue the eviction notice period was insufficient under the Tenancy Act.** Polish tenancy law requires specific notice intervals before an eviction action; argue the landlord undershot. Anchor evidence: the dates on the notice timeline (April 8 service, April 28 actual receipt, hearing held ex parte three weeks late). *Wrong because the defect here is locational (wrong door), not temporal — the timing math is colorable but irrelevant once the address fails.* Plausible because notice-period defenses are the standard junior move when an eviction notice arrives mis-served.
3. **Standing / wrong party — argue the proper plaintiff is the new building owner, not the original landlord.** A property-transfer record (introduced via Whimsy's civic-records archive in §1.3) shows the building changed hands in 2018; the landlord-of-record on the eviction notice is the prior owner. *Wrong because the lease assigned forward at transfer — Sikorska's obligations and the new owner's rights run together; the prior landlord retains some claim under the assignment.* Aggressive, defensible, and the kind of theory a sharp counsel would test.
4. **Defective service under Article 135-bis § 2 KPC — the right answer.** Service to the post-renumbering wrong door, with landlord knowledge demonstrated by the 2019 renewal countersignature. Supported by the strongest combined evidence once Cula has read both the envelope and the renewal.

**Optional fifth frame (hard-wrong) — incapacity defense.** Argue Mrs. Sikorska is elderly and therefore not competent to be served. The "evidence" is her age (visible in the client meeting; documented in her file). Wrong because Polish civil procedure does not impute incapacity from age; the test is cognitive, not chronological — and Sikorska is sharp. *Game-punished:* Halina disapproves audibly (`halina_trust -4`), Crab refuses to assist beyond the bare procedural duties (`recruited_crab` does NOT flip; the Crab side-track requires reset via a `decline_incapacity` follow-up), the judge reaction is icy silence and a sharp `judicial_patience -5`. Include this frame *unless* QA tests show it materially disrupts the soft-fail balance — its purpose is to draw the moral compass of the Pig & Swine firm explicitly. The firm's identity per AGENTS.md §Humor rules is "incompetent but morally worth saving" — incapacity-against-an-elderly-client is the line the firm does not cross, and the game's refusal to let the player cross it without consequence is part of the chapter's character work.

### NPC role split — who surfaces what

The named dialogue states are rewrite targets. Existing state IDs are preserved; line content changes. Existing `on_dismiss` flag writes are preserved at semantically-equivalent triggers. The overnight cohort already landed voice-pack rewrites on these files (commit `8d6bb3b`); the decoy reshape is the next pass on the same files, layered on top of the voice work.

**Crab — `crab.json`.** Crab surfaces evidence for frames 1 (substantive), 2 (notice-period timeline), and 4 (defective service). He does NOT surface evidence for standing — civic records are not his beat.

- `before_binder` and `before_binder_briefing`: Crab observes the envelope number, observes the building number above the stairwell, names the 2015 renumbering. He does not connect them; he does not name the Article. He mentions, in passing, that Sikorska "has paperwork — receipts, the kind you keep when you expect the landlord to forget" — surfaces the substantive-defense evidence pointer without naming the frame.
- `first_meeting_with_binder` (the load-bearing rewrite): Crab takes the binder, reads aloud the envelope address, reads the renewal address, names the renumbering year. He explicitly notes the dates (notice April 8, actual receipt April 28) as a separate fact — this surfaces the notice-period evidence pointer. He does NOT cite Article 135-bis. The options block becomes Cula's *synthesis* choice: four argument frames Cula proposes (substantive, notice-period, standing, defective-service), only one of which is well-fitted. Crab's response is calibrated by frame fit per §4. The optional incapacity frame appears as a fifth option ONLY if Cula has met Halina (post-`halina_met`); it is procedurally-junior-mistake territory and earns the game-punished response per §4.
- `after_binder_first_engagement` (late-binder path): same shape — synthesis-choice options, fit-calibrated responses.
- `crab_post_pitch_response`: post-synthesis, well-fitted-frame variant. Crab produces the *labelling* — "Article 135-bis, paragraph two of the Code of Civil Procedure" — but only after Cula has named the *shape* of the argument. New sibling states `crab_post_pitch_response_substantive`, `crab_post_pitch_response_notice_period`, `crab_post_pitch_response_standing` carry the wrong-frame walk-backs per §4 voice templates.

**Murrow — `murrow.json`.** Murrow surfaces evidence for frames 2 (notice-period — tenancy-act citations), 3 (standing — lease assignment article), and 4 (defective service). He does NOT surface substantive-defense evidence because that lives with Halina and the client's records.

- `murrow_first_meeting`: the eight-line case briefing collapses to four observation-shaped lines about the file. Murrow names what is true about the *file* — dates, countersignature, docket entry, the ex parte hearing — and offers two doctrinal pointers: "The Tenancy Act sets a fourteen-day window from notice; check it" (notice-period pointer) and "When the building sold in two thousand and eighteen, the lease assigned forward; the prior owner remains a real party in interest" (standing pointer, with the implicit message that the assignment theory is *colorable* but not winning). He does NOT name the motion to set aside. The fourteen-day-from-actual-notice statute fact stays.
- `has_binder_pre_crab`: branches on `binder_read_*` flags (see §3). Cula who has skimmed gets a different response than Cula who has read.
- `court_readiness_check`: Murrow asks Cula to state the argument; Cula's options block produces the closing posture Phase 2 consumes. The current "Service first. Fair hearing second. Remedy last" line moves into a Cula-spoken option, not a Murrow line.

**Whimsy — `whimsy.json`.** Whimsy surfaces evidence for frame 3 (standing — property-transfer records from Whimsy's civic-archive hobby) and frame 4 (defective service — the rights memo). He does NOT surface notice-period or substantive evidence.

- `before_meeting`: Cula opens with the *question* she wants help with, not the conclusion. Three Cula option-pitches map to frames 1/2/3/4 (the option set varies by which evidence Cula has surfaced before reaching Whimsy). Whimsy responds in his three established postures (procedural_throat / merits_pivot / open_register) but now with a fourth surface: he produces the property-transfer record from his civic-archive collection if Cula's pitch touches standing, and he marginalises in espresso on the rights memo regardless.
- Whimsy's character note (already in the voice-pack rewrite at commit `8d6bb3b`): "I keep a folder of who-owns-what. Marginal pastime. Occasionally useful." This is the in-fiction justification for Whimsy as the standing-evidence source. The civic-archive record is plausibly Whimsy's because Whimsy is rhetorical-associate-by-temperament but also a literal records hobbyist.

**Halina — `halina.json`.** Trust meter unchanged. The bonus-evidence enum (`wojcik_witness_statement` / `return_to_sender_slip` / `lease_1962_inheritance_1987` / `landlord_contact`) stays. **Addition:** the technical-stance carrier `lease_1962_inheritance_1987` now also points at frame 1 (substantive defense) — the long unbroken tenancy is part of the substantive case. The blunt-stance `return_to_sender_slip` strengthens frame 4 (already does). The sympathetic-stance `wojcik_witness_statement` strengthens frame 4 and weakly supports frame 1. The high-trust reveal `landlord_contact` strengthens frame 4 only. No changes to halina.json content — the points-to-frames mapping lives in `data/evidence_ch1.json`, not in the dialogue file.

**Halina — payment receipts.** The substantive-defense frame needs the payment receipts as supporting evidence. The receipts surface in halina.json on the *sympathetic* stance (where Halina talks about her records) and on the *technical* stance (where she produces her folder). To avoid a new chapter1 flag and a SAVE_VERSION bump, the receipts are not a separate `bonus_evidence_collected` value; they are derivable from `chapter1.client_meeting_stance != ""` (any completed meeting surfaces the existence of receipts in conversation; the technical-stance and sympathetic-stance specifically yield the actual document). The frame's `requires_flags` use this derivation.

**Asia — `data/dialogues/asia.json` and `asia_hint_states_ch1.json`.** Asia is a hint surface. Her hints become *signposts to investigative gaps and frame-fit nudges*. When the player has proposed a wrong frame to Crab, Asia's hint nudges toward re-reading the envelope — without naming what's wrong. Specifics in the overnight cohort's `data/dialogues/asia_hints_player_driven_2026-05-16.json` draft (still pending merge).

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

The original §3 introduced `evidence_ch1.json` and `argument_frames_ch1.json` and committed the v17 flag set. Those landed in commit `bc45550` and the registry catch-up at `2f7a81b`. **This revision extends both files** with `points_to_frames` weighted mappings on the evidence side, and `strength_rating` / `judge_reaction_template` / `source_npc` on the frame side. The schema extensions are additive — no SAVE_VERSION bump is required because the wire format for `chapter1.proposed_frame` does not change (it remains a string field; the enum value set expands per the directive, which is permitted without a wire-format bump). Existing field semantics are preserved.

**Evidence card schema (revised).** `data/evidence_ch1.json` entries gain a `points_to_frames` field. Schema:

```jsonc
{
  "version": 2,
  "evidence": {
    "envelope_address_number_seven": {
      "_status": "Code-pass complete; Design text pending.",
      "source": "binder_page_1",
      "source_npc": "crab",
      "discovered_when": "chapter1.has_law_binder == true",
      "sets_flag": "chapter1.binder_read_envelope",
      "argument_tags": ["service_of_process"],
      "context_tags": ["service_failure", "documentary"],
      "points_to_frames": {
        "defective_service_135bis": 0.9,
        "notice_period_failure":    0.2
      },
      "display_name": "",
      "summary": "",
      "press_lines": [],
      "present_lines": []
    }
    /* ... */
  }
}
```

The `points_to_frames` dictionary maps frame_id → support weight in `[0.0, 1.0]`. Multiple frames can be supported by one evidence card; the weights need NOT sum to 1.0 (an envelope strongly supports defective service AND weakly hints at timing). The `source_npc` field names which NPC surfaces this evidence in conversation — used by the binder UI v2 to attribute marginalia and by Asia's hint surface to nudge the player toward the right NPC.

**New evidence pieces to add tonight:**

| evidence_id | source_npc | discovered_when | sets_flag | points_to_frames |
|---|---|---|---|---|
| `payment_receipts_sikorska` | halina | `chapter1.client_meeting_stance != ""` | `chapter1.surfaced_payment_receipts` *(NEW — see flags below)* | `substantive_defense: 0.85, defective_service_135bis: 0.1` |
| `notice_timeline_april` | crab | `chapter1.met_crab == true && chapter1.has_law_binder == true` | `chapter1.surfaced_notice_timeline` *(NEW)* | `notice_period_failure: 0.9, defective_service_135bis: 0.2` |
| `property_transfer_2018` | whimsy | `chapter1.met_whimsy == true` | `chapter1.surfaced_property_transfer` *(NEW)* | `standing_wrong_party: 0.9, defective_service_135bis: 0.1` |
| `sikorska_age_visible` | none (Cula's observation in client meeting) | `chapter1.halina_met == true` | `chapter1.surfaced_sikorska_age` *(NEW)* | `incapacity_defense: 1.0` |
| `tenancy_act_notice_window_citation` | murrow | `chapter1.met_murrow == true && chapter1.has_law_binder == true` | `chapter1.surfaced_tenancy_act_window` *(NEW)* | `notice_period_failure: 0.7` |

The five new `surfaced_*` flags are bools, default `false`. They join the existing seven v17 flags as a SECOND wave of additions — but they do NOT require a SAVE_VERSION bump because the wire format of `chapter1` (a dictionary) accepts new boolean keys forward-compatibly; the migration only needs to add them at the v17→v18 step (when one is next required) or via the `Dictionary.has()` guards in dialogue triggers. The recommended path is **defer their addition to a SAVE_VERSION bump combined with the next genuine wire-change** — typically when Chapter 2 schema additions arrive. In the meantime, drafts and dialogue files reference these flags via `Dictionary.get(flag, false)` semantics already supported by `DialogueRunner._evaluate_trigger` (missing paths warn and fail the trigger; declare them in `State.reset_state()` and the migration before referencing in committed dialogue). **If the next implementation pass needs these flags live, a v17→v18 migration adds them as default-false; the wire format is unchanged.** Document the deferral in the runtime files when authored.

**Argument frame schema (revised).** `data/argument_frames_ch1.json` entries gain `strength_rating`, `judge_reaction_template`, and `source_npc_primary`. Schema:

```jsonc
{
  "version": 2,
  "frames": {
    "defective_service_135bis": {
      "display_name": "Service to the wrong address",
      "summary": "",
      "supporting_evidence": ["envelope_address_number_seven", "renewal_2019_number_twelve", "renumbering_2015_fact"],
      "statute_anchor": "KPC Article 135-bis § 2",
      "source_npc_primary": "crab",
      "strength_rating": 5,           /* 0..5, 5 = strongest evidence chain when fully surfaced */
      "well_fitted": true,
      "court_round_unlock": "round_1_open",
      "requires_flags": [
        "chapter1.binder_read_envelope",
        "chapter1.binder_read_renewal"
      ],
      "judge_reaction_template": "approving_set_aside",
      "judicial_patience_delta_on_select": 0,
      "halina_trust_delta_on_select": 0,
      "burns_round_attempt": false
    },
    "substantive_defense": {
      "display_name": "Argue the merits — Sikorska has paid the rent",
      "supporting_evidence": ["payment_receipts_sikorska", "lease_1962_inheritance_1987"],
      "statute_anchor": "Civil Code, lease obligations (out of place at the motion stage)",
      "source_npc_primary": "halina",
      "strength_rating": 3,
      "well_fitted": false,
      "court_round_unlock": "round_2_open",
      "requires_flags": ["chapter1.surfaced_payment_receipts"],
      "judge_reaction_template": "tolerant_try_again",
      "judicial_patience_delta_on_select": -2,
      "halina_trust_delta_on_select": 0,
      "burns_round_attempt": true,
      "wrong_shape_correction": "The merits are not before the court at this stage. Service is the door."
    },
    "notice_period_failure": {
      "display_name": "Notice period failure under the Tenancy Act",
      "supporting_evidence": ["notice_timeline_april", "tenancy_act_notice_window_citation"],
      "statute_anchor": "Tenancy Act § notice windows",
      "source_npc_primary": "murrow",
      "strength_rating": 3,
      "well_fitted": false,
      "court_round_unlock": "round_1_open",
      "requires_flags": ["chapter1.surfaced_notice_timeline"],
      "judge_reaction_template": "cool_dismissal",
      "judicial_patience_delta_on_select": -2,
      "halina_trust_delta_on_select": -1,
      "burns_round_attempt": true,
      "wrong_shape_correction": "The timing is colorable. The locational defect ends the matter first."
    },
    "standing_wrong_party": {
      "display_name": "Standing — wrong plaintiff (post-2018 ownership transfer)",
      "supporting_evidence": ["property_transfer_2018"],
      "statute_anchor": "Civil Code, assignment of obligations on transfer",
      "source_npc_primary": "whimsy",
      "strength_rating": 2,
      "well_fitted": false,
      "court_round_unlock": "round_1_open",
      "requires_flags": ["chapter1.surfaced_property_transfer"],
      "judge_reaction_template": "sharper_really_your_theory",
      "judicial_patience_delta_on_select": -3,
      "halina_trust_delta_on_select": -1,
      "burns_round_attempt": true,
      "wrong_shape_correction": "The lease assigned forward at transfer. The prior owner remains a real party."
    },
    "incapacity_defense": {
      "display_name": "Incapacity — Mrs. Sikorska elderly",
      "supporting_evidence": ["sikorska_age_visible"],
      "statute_anchor": "Civil Code, capacity (chronological age does not impute incapacity)",
      "source_npc_primary": "none",
      "strength_rating": 0,
      "well_fitted": false,
      "court_round_unlock": "round_1_open",
      "requires_flags": ["chapter1.halina_met"],
      "judge_reaction_template": "icy_silence",
      "judicial_patience_delta_on_select": -5,
      "halina_trust_delta_on_select": -4,
      "burns_round_attempt": true,
      "wrong_shape_correction": "Age does not impute incapacity. Mrs. Sikorska is competent. The argument insults her.",
      "in_fiction_consequence": "Crab refuses to assist (`recruited_crab` unflipped if not yet); Halina visibly disapproves."
    }
  }
}
```

The auxiliary frames from the original §3 (`third_party_non_cure`, `fair_hearing_article_6`, `merits_defence`) are absorbed:

- `third_party_non_cure` → moves out of the `frames{}` block and becomes a Phase 2 *sub-citation* under `defective_service_135bis`. The fact that the resident at no. 7 doesn't cure service is an argument within the defective-service case, not a separate frame.
- `fair_hearing_article_6` → same — becomes a Phase 2 sub-citation available when the rights memo is collected. Within defective-service.
- `merits_defence` → renamed to `substantive_defense` and reshaped as a real decoy with payment-receipts evidence rather than a straw "merits at the wrong stage."

**State-flag inventory under this revision:**

Existing v17 flags (committed at `bc45550`, unchanged): `binder_read_envelope`, `binder_read_renewal`, `binder_read_renumbering`, `proposed_frame` (enum expands per below), `whimsy_co_counsel_posture`, `judicial_patience`, `witness_cooperation`.

The `chapter1.proposed_frame` enum expands from the original `{"" | "defective_service_135bis" | "third_party_non_cure" | "fair_hearing_article_6" | "merits_defence"}` to **`{"" | "defective_service_135bis" | "substantive_defense" | "notice_period_failure" | "standing_wrong_party" | "incapacity_defense"}`**. This is an enum value change, not a wire-format change. The dialogue editor enum validator (Agent 8's work at commit `81f82ae`) reads enum values from `chapter1.json.new_state_flags._enum`; the registry update lands in this revision's data-expansion commit. No SAVE_VERSION bump.

New flags introduced by this revision (5 booleans, defer to v17→v18 migration when next required): `surfaced_payment_receipts`, `surfaced_notice_timeline`, `surfaced_property_transfer`, `surfaced_sikorska_age`, `surfaced_tenancy_act_window`. All default `false`. The migration is *not landed by this proposal* — it lands the *next time* a wire change requires a SAVE_VERSION bump. Until then, dialogue triggers can reference these via missing-key-fails-trigger semantics; runtime code that needs to read them must use `Dictionary.get(flag, false)`. The decoy dialogue drafts (committed alongside this proposal revision) author the trigger predicates *as if* the flags exist; they will resolve once declared.

### Evidence-to-frame mapping rules — under/over-investigation behavior

The directive: "Under-investigation should leave multiple frames at ~60% supported. Over-investigation should make the right answer visible without forcing it."

The implementation: each frame has a `strength_rating` (0..5) and a `requires_flags` set. The synthesis UI (Crab's options block in v1; the binder UI in v2) computes per frame:

- `frame_visible = all(requires_flags resolve to true)` — gate on whether the frame appears as an option at all
- `frame_support = sum(card.points_to_frames[frame_id] for each surfaced card)` — running total
- `frame_support_normalised = min(frame_support / frame.strength_rating, 1.0)` — 0..100% scale

Under-investigation: a player who has read only the envelope reaches Crab with `defective_service_135bis` at ~18% (0.9 / 5), `notice_period_failure` not visible (`surfaced_notice_timeline` not set), `substantive_defense` not visible. The only frame visible is at 18% — Cula doesn't have enough to argue anything yet. The dialogue should signpost the player to keep investigating.

Mid-investigation: a player who has read envelope + renewal + met Halina (sympathetic) sees `defective_service_135bis` at ~(0.9 + 0.85 + 0.1*sympathetic_evidence)/5 ≈ ~38%, `substantive_defense` at ~(0.85 + 0.5*lease)/3 ≈ ~45% (the receipts and the lease both point at substantive). Both at ~40-50% — the player has a real choice with credible alternatives.

Over-investigation: a player who has read envelope + renewal + renumbering + bonus evidence + met every NPC sees `defective_service_135bis` at 100% with strong support, the decoys at 60-80%. The right answer is *visible* without being *forced* — the wrong answers remain selectable, but the right answer's strength makes it the procedurally-obvious choice.

### Judge reaction templates

The `judge_reaction_template` field on each frame names a key into a new file `data/judge_reactions_ch1.json` (or into `data/court_rounds/chapter1_round_1.json` as a sub-block — Agent 2's existing court-round file structure makes the latter natural). Each template carries:

- The judge's spoken response when the frame opens Phase 2.
- The judicial-patience trajectory across the round (e.g., `tolerant_try_again` lets the player recover; `icy_silence` does not).
- The Halina-observation lines (sometimes Halina audibly reacts — for incapacity, audibly disapproves).
- The Crab/Whimsy reactions in court (Crab refuses to support incapacity; Whimsy reframes notice-period as "a defensible second-chair theory").

Author the templates as part of Agent 2's `chapter1_round_1.json` Phase 2 block or as a separate file at Code's discretion. This revision specifies the names: `approving_set_aside`, `tolerant_try_again`, `cool_dismissal`, `sharper_really_your_theory`, `icy_silence`.

**Tag-taxonomy compatibility.** No new tags required — the existing `data/tag_taxonomy.json` covers Chapter 1 entirely. The new evidence/frame files use currently-declared article/principle/context tags.

## 4. Failure modes

The original §4 settled on soft-fail (wrong frame survives, costs `judicial_patience`, narrows remedy). This revision keeps the design and adds two new cost dimensions per the directive: **wrong frames also cost `halina_trust` and burn one of three court-round attempts**. The Chapter 1 court has three rounds (Round 1 — Defective Service; Round 2 — Fair Hearing; Round 3 — Remedy, per the existing `argument_opponents.json` structure). A burnt round is an attempt the player has spent on a wrong frame; the player gets the remaining rounds to recover. Recovery is procedurally possible on the right frame *if* `judicial_patience` and `halina_trust` are not exhausted. Three burnt rounds in a row is the worst case and still produces a narrow procedural-reset victory — the proposal §9 commitment that Halina wins on procedural reset is preserved.

### Per-frame consequence matrix

| Frame | well_fitted | judicial_patience delta on select | halina_trust delta on select | Burns round attempt | Judge reaction template |
|---|---|---|---|---|---|
| `defective_service_135bis` | true | 0 | 0 | no | `approving_set_aside` |
| `substantive_defense` | false | -2 | 0 | yes | `tolerant_try_again` |
| `notice_period_failure` | false | -2 | -1 | yes | `cool_dismissal` |
| `standing_wrong_party` | false | -3 | -1 | yes | `sharper_really_your_theory` |
| `incapacity_defense` | false | -5 | -4 | yes | `icy_silence` |

The deltas apply at the moment Cula commits to a frame in the Crab synthesis dialogue (when `proposed_frame` is written), NOT in court. The court-round controller reads the committed frame and applies the deltas plus the in-court round-by-round consequences. This separation is deliberate — the synthesis choice is the moment the player pays the cost; court is the moment the consequence plays out.

### Judge reaction templates — the feedback channel

The judge's reaction is the player's primary signal for "you've picked the wrong frame." Five templates, named per §3:

- **`approving_set_aside`** — for the well-fitted defective-service frame. The judge accepts the procedural argument as stated and proceeds to consider the remedy. Lines are dry, professional, no rhetorical lift. The bench finds for Cula but does NOT congratulate.
- **`tolerant_try_again`** — for substantive defense. The judge notes that the merits aren't before the court at the motion stage, asks counsel whether there's a procedural defect she'd like to argue instead. This is the most generous wrong-frame reaction; the player can pivot in the next round to defective-service and recover most of the lost ground. Halina is silent (`halina_trust_delta = 0`); she trusts Cula to find the procedural angle.
- **`cool_dismissal`** — for notice-period failure. The judge notes the timing arithmetic, observes that the address itself was wrong, and asks counsel whether she'd care to address that first. Cooler than `tolerant_try_again` because the judge has noticed the locational defect and is now wondering why counsel didn't see it. Halina mildly disappointed (`-1`); she expected the procedural angle because the wrong-door fact is in plain sight on the documents.
- **`sharper_really_your_theory`** — for standing/wrong-party. The judge raises an eyebrow at the assignment theory, observes that the lease runs with the property, and asks counsel whether the procedural angle has been considered. Sharper because standing is an aggressive theory that asks the court to do real work; getting it wrong reads as either inexperience or grandstanding. Halina disappointed (`-1`).
- **`icy_silence`** — for incapacity defense. The judge says nothing for a beat too long, then asks counsel to confirm the theory. When confirmed, the judge moves immediately to the procedural defect without dignifying the incapacity argument with engagement. The court reporter pauses typing. Halina says "I am quite competent, Dr. Cula" audibly enough for the bench to hear (`halina_trust_delta = -4`). Crab refuses to argue the next round; recovery requires Cula to apologise to Halina (a new dialogue beat in the post-court scene). This is the game-punished hard-wrong.

The judge reaction is **shown not told**: the templates produce dialogue lines and `judicial_patience` decrements; the player infers fit from the contrast between reactions. The dialogue surface of court is where this lands — the controller emits the judge's reaction lines after the player's frame opens Phase 2, before the opponent's counter-move.

### Recovery dynamics

The directive specifies: "Picking wrong costs `judicial_patience`, `halina_trust`, and burns one court-round attempt." Three rounds, one burn per wrong frame, so up to three wrong choices before the player is at zero rounds.

Each round, the player can pivot: in Phase 1 (witness fact-finding), Press and Present actions can surface additional evidence that points at a different frame. The synthesis options are NOT a one-shot at the start of court — they re-open between rounds. The player who commits to substantive defense in Round 1 can pivot to defective-service in Round 2 if Phase 1 Press/Present in Round 1 surfaced the envelope+renewal evidence chain. The pivot itself costs `judicial_patience -1` (the bench notes the change of theory) but does not burn another round attempt — pivot is recovery, not a new commitment.

If `judicial_patience` drops to 0, Phase 2 closing argument is constrained: the player gets one citation slot per round instead of three, and the bench delivers a curt narrow-procedural-reset judgment regardless of frame fit. If `halina_trust` drops to 0 or below, the post-court scene branches — Halina pays the fee but does not refer the firm to other clients (Chapter 2 onboarding shifts). If three rounds are burnt without finding the right frame, the chapter ends on `procedural_reset_narrow` (the bench reaches for the defective-service finding itself because the procedural error is on the face of the documents; Cula gets the win but the bench made the argument).

The chapter `court_outcome` enum gains values to reflect this:

- `procedural_reset_full` — Cula committed to defective-service Round 1, `judicial_patience >= 4`, `halina_trust` unchanged. The strong-victory case.
- `procedural_reset_with_costs` — Cula committed to defective-service Round 1, `judicial_patience >= 4`, bonus evidence collected (any of the four). Costs assessed against landlord; firm gets an additional 1,000 PLN in costs.
- `procedural_reset_narrow` — Cula pivoted to defective-service mid-court, OR `judicial_patience < 4`. Win, but narrow.
- `procedural_reset_bench_initiative` — Cula never reached defective-service; bench made the argument itself. Win, but Cula didn't make it. Affects Chapter 4 corridor-sighting subtext.
- `procedural_reset_after_apology` — Cula picked incapacity, recovered via post-court apology. Win, but the firm's standing with Halina is bruised; affects Chapter 4 differently.

### Why this design avoids the failure modes already rejected

- **Not loud-fail-and-retry:** every wrong frame survives. Reload is never necessary.
- **Soft-fail-with-judicial-skepticism remains the spine:** but with *real* decoys, the skepticism is targeted (different reactions per wrong frame) rather than generic.
- **Not branch-and-live-with-it:** Halina still wins on procedural reset. The chapter outcome calibrates; it does not fork into a "Halina is evicted" tail.

The Ch4 corridor-sighting beat per PROPOSALS.md §11 has additional grain now. "The procedural reset was real. The harm continued anyway" lands differently when the player remembers having argued the wrong frame in Round 1 — the procedural reset was real *despite* Cula, not because of her.

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

The original §7 concluded "Pokémon contributes the chassis; AA contributes the soul; the trust-meter contributes the consequence model." The decoy revision sharpens the AA contribution: with credible decoys, **AA's PRESENT-against-statement mechanic maps cleanly onto the frame-selection moment itself**, not just onto court-round moves.

**Pokémon Yellow** is still the chassis: menu-driven turn-based selection from a fixed move set, type-effectiveness math. The Casebook still uses this — `principle_moves[]`, `effectiveness.gd`, five buckets. Unchanged from the original analysis.

**Ace Attorney is now load-bearing on TWO surfaces**, not one:

1. **Synthesis as PRESENT (Phase 0 — pre-court).** Cula presents a frame as her theory of the case. The frame is a *claim*; the supporting evidence is the *exhibit*. The judge (and Crab, in the synthesis dialogue) reacts to the (frame, supporting-evidence) tuple. A frame with strong evidence support reads convincingly; a frame with thin support reads as a stretch. This is structurally identical to AA's *court Present* — the player is offering a piece of legal argumentation against the case's central question, and the game checks whether the offering fits. The difference from AA is that Cula's frame is opposing-counsel-shaped (positive argument for her client) rather than contradiction-shaped (negative argument against a witness statement). The mechanic is the same; the polarity differs.

2. **Press / Present as court turns (Phase 1 — fact-finding, Phase 2 — closing).** As in the original §7. Press costs `witness_cooperation` and elicits witness sub-statements; Present aims an evidence card at a specific statement and the resolver checks fit.

The first surface is what the original §7 missed. The original §7 treated synthesis as "the player picks a move from a menu" — Pokémon. With decoys, the player is **PRESENTING a theory** (which frame the case is about) and the **judge/Crab is the listener** who evaluates the offering. That's AA all the way down. Each decoy frame is a credible alternative theory the player could plausibly present; the wrong-frame consequences are AA's "penalty" mechanic ported to legal stakes (judicial_patience instead of HP, halina_trust instead of player score, burnt round attempt instead of "Wrong! Try again").

**Synthesis the revised proposal commits to:**

- Pokémon-shaped *turn structure and effectiveness math* — unchanged.
- Ace-Attorney-shaped *frame-selection PRESENT* — new in this revision. The synthesis options are presenting-a-theory; the judge/Crab response is the listener's evaluation. The decoy frames are the credible alternative theories. Picking wrong costs `judicial_patience`, `halina_trust`, and burns a round attempt — AA's penalty mechanic adapted to legal stakes.
- Ace-Attorney-shaped *court PRESS and PRESENT* — unchanged from original analysis.
- Halina-trust-meter-shaped *consequence calibration* — extended. Trust meter now reads in two places: Halina's own meeting at Beat 8 (existing) AND the court synthesis moment via the `halina_trust_delta_on_select` per frame (new). The trust meter becomes the through-line for the player's professional relationship with the client across Beats 8–12.

This is a *deeper* fusion than the original. Pokémon contributes the chassis. AA now contributes the soul on two surfaces — frame-selection and court turns. The trust-meter contributes the calibration model across both surfaces.

**Why decoys make AA the better fit.** AA's appeal is that wrong PRESENTs are reachable and have proportional consequences. The original Chapter 1 had no decoys, so PRESENT collapsed to "pick the one option that exists" — the AA influence was decorative. With four credible frames and one hard-wrong, PRESENT is a real choice with real consequences. The AA mechanic finally has something to do.

## 8. Open questions for the human

Original three plus three new ones surfaced by the decoy revision.

1. **Binder UI mood (case-file pages vs index cards vs AA evidence panel).** Default: case-file pages with paper texture and Murrow marginalia. The binder UI v0 prototype landed at commit `b790554` (overnight cohort) and reads `data/evidence_ch1.json` — when the new evidence cards land tonight, the v0 binder shows them as additional pages. Decision still needed before v1 sprint.
2. **Should Phase 2 ship before the battle controller is restored?** Mooted — Agent 1 restored the battle controller at commit `603f65e`. The dialogue work and controller work are both landed; the integration pass is what remains.
3. **Are the v17 state-keys acceptable as-shipped?** Mooted — committed at `bc45550`. The revision proposes 5 new boolean flags (the `surfaced_*` set in §3); decision needed on whether to land them with a v17→v18 migration now or defer until the next genuine wire change.
4. **(NEW) Incapacity-defense frame: include or omit?** Default: include. The hard-wrong is the firm's moral compass made visible. Omit only if QA testing shows it disrupts the soft-fail balance — e.g., if the post-court apology beat doesn't have authoring bandwidth this sprint. The frame is independently revertable (one entry in `argument_frames_ch1.json`, one evidence pointer, no other system depends on it).
5. **(NEW) Should the `proposed_frame` enum value rename `merits_defence` → `substantive_defense` cleanly, or carry both for migration safety?** Default: rename. The original `merits_defence` was a straw-shape decoy; the revised `substantive_defense` is the real one. Save files with `chapter1.proposed_frame == "merits_defence"` are unlikely to exist in the wild (the field shipped only at `bc45550` four days ago and most playtesters have flagged-default `""`). The dialogue-editor enum validator (Agent 8's commit `81f82ae`) reads from `chapter1.json` registry — update the registry, the editor catches the change. If extreme migration safety is wanted, a one-line v17→v18 migration step rewrites `"merits_defence"` → `"substantive_defense"` and bumps SAVE_VERSION to 18.
6. **(NEW) Three burnt-round attempts vs unlimited pivoting?** Default: three burnt is the maximum cost; pivots cost `-1 judicial_patience` but don't burn. The directive specifies "burns one court-round attempt" — this revision implements that as a per-frame `burns_round_attempt` boolean that the controller reads. The bench-initiative `procedural_reset_bench_initiative` outcome is the failure floor — a guaranteed win on every playthrough but not a satisfying one. Confirm or override.

## 9. What this proposal explicitly does *not* do

- Does not alter the Casebook tag taxonomy.
- Does not introduce new Polish legal doctrine.
- Does not touch the Halina trust meter, the postcard chain, or the coffee minigame.
- Does not deliver the binder UI in v1 (deferred to v2).
- Does not extend the procedural-reset judgment's tag set or principle-move set.
- Does not change the chapter outcome — Halina still wins on procedural reset, the firm still gets the 5,000 PLN fee, the corridor sighting in Ch4 still happens. The win is *narrower or wider* based on play; it is not turned into a loss.

## 10. Acceptance criteria for the Phase 2 first cut (decoy revision)

The decoy implementation is "first cut acceptable" when:

- All four core headless commands pass (smoke, runner, save migration, Web export).
- The four credible frames (`defective_service_135bis`, `substantive_defense`, `notice_period_failure`, `standing_wrong_party`) and the optional fifth (`incapacity_defense`) appear as authored entries in `data/argument_frames_ch1.json` with full Code-pass fields populated.
- The five new evidence cards (`payment_receipts_sikorska`, `notice_timeline_april`, `property_transfer_2018`, `sikorska_age_visible`, `tenancy_act_notice_window_citation`) appear in `data/evidence_ch1.json` with Code-pass fields populated; `points_to_frames` weighted mappings present on every evidence entry; `source_npc` populated.
- The three decoy dialogue drafts (`data/dialogues/_drafts/crab_decoys_2026-05-16.json`, `murrow_decoys_2026-05-16.json`, `whimsy_decoys_2026-05-16.json`) demonstrate the multi-frame-surface reshape with state IDs preserved, `on_dismiss` flag writes preserved, and the synthesis option-blocks expanded to 4 (or 5) frame choices.
- A player walking the Beat 4 → Beat 9 path can reach the binder, the Crab synthesis dialogue with all credible frame options visible, the recruitment beat regardless of frame choice, the Halina meeting, the archive research, and the court-ready state — without dead-ending on any frame including incapacity.
- Wrong-frame paths are reachable and survivable per §4 consequence matrix: a player who picks `substantive_defense` reaches a playable end-of-chapter state with `chapter1.court_outcome ∈ {procedural_reset_narrow, procedural_reset_bench_initiative}` after pivot or bench-initiative recovery.
- The dialogue editor enum validator (Agent 8's commit `81f82ae`) accepts the new `proposed_frame` enum values from `chapter1.json` registry without manual override.

---

**Human, before next implementation pass.** Six open questions in §8 above. Defaults if unchanged: include incapacity frame; rename `merits_defence` → `substantive_defense` cleanly without migration step (or with a one-line v17→v18 if extreme safety is wanted); three burnt-round attempts as the cost ceiling; defer the 5 `surfaced_*` flag declarations to the next genuine SAVE_VERSION bump unless implementation needs them sooner.
