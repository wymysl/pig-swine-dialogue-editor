# PROPOSAL — Player-driven argument synthesis (Chapter 1 Sikorska arc)

**Status.** DRAFT — Phase 1 plan revised twice. v1 (2026-05-15) funnelled the player to a single right answer. v2 (2026-05-16 AM) replaced the funnel with four credible decoy frames plus an optional hard-wrong; the runtime data files (`evidence_ch1.json`, `argument_frames_ch1.json`) and the three decoy dialogue drafts under `data/dialogues/_drafts/` are at v2. v3 (2026-05-16 PM, this revision) reshapes the synthesis target itself: the Chapter 1 challenge is **motion-packet assembly**, not a theory-label quiz. The player must establish each of four required elements of the KPC Art. 135-bis § 2 motion to set aside, and choose whether to bolt on weaker decoy theories. The decoy roster carries over from v2 with one addition (overbroad remedy); incapacity-by-age remains the punished blunder.

**Filed.** 2026-05-15. **Revised.** 2026-05-16 AM (decoy revision). **Re-revised.** 2026-05-16 PM (motion-packet revision).

**Relation to existing proposals.** Same as v2 — extends PROPOSALS.md §10 (Court Round two-phase split). The §10 Phase 2 of Court Round 1 is now precisely **packet submission**, not theory pitch. The four-element packet maps one-to-one onto the four `resolution_weight: primary` fact flags already authored in `data/court_rounds/chapter1_round_1.json` (`_fact.landlord_knew_address`, `_fact.notice_received_april_28`, `_fact.resident_no_authority`, `_fact.renumbering_2015_documented`), so Code-pass alignment is largely free.

---

## 0. What this revision corrects in v2

v2 framed synthesis as "pick which named theory the case is about." That is structurally a theory-label quiz: the player selects from a menu of frame_ids, the game checks fit, and rewards or punishes. Three problems:

1. **It is not what junior counsel actually do.** A junior preparing a motion to set aside does not first decide whether the case is "a defective-service case" or "a notice-period case." She works from the rule outward — she proves each element the rule requires, and only secondarily considers whether to throw in weaker auxiliary theories. The procedural mistake she risks is including too many theories or asking for too much remedy.

2. **It collapses the four-element procedural test into a single label.** KPC Art. 135-bis § 2 has structure: (i) non-current address, (ii) to the knowledge of the serving party, (iii) motion filed within fourteen days of actual notice, (iv) no third-party authority to cure. v2 buried all four under a single `defective_service_135bis` frame_id and treated "defective service" as the right answer, period. The player never had to demonstrate they understood the rule.

3. **The decoy mechanic was the wrong shape.** v2's decoys were *competing* theories: pick this OR that. In real practice they are *additions* a junior might pile onto a competent motion — "I'll argue defective service AND notice-period AND standing AND, while we are at it, the merits — surely one will land." That additive mistake is the procedurally interesting one, and v2 could not represent it.

This revision keeps what v2 got right (named decoys with halina_trust and judicial_patience consequences; incapacity as the punished blunder) and reshapes the synthesis surface around packet assembly.

## 1. The accepted target — motion-packet assembly

**Synthesis act.** Cula prepares a motion to set aside under KPC Art. 135-bis § 2. The motion has four required elements and a remedy ask. The synthesis surface — Crab's dialogue at first meeting, expanded across the Beat 4–10 path — is where Cula (a) establishes each element by surfacing the evidence that supports it, and (b) decides whether to bolt on weaker decoy theories.

### 1.1 Four required elements

The well-fitted packet covers all four. Each element is established when its supporting evidence is surfaced; flag writes are derived from existing evidence-card `sets_flag` writes plus the existing Phase 1 `_fact.*` flags in `chapter1_round_1.json`.

1. **Non-current address (E1).** The address used for service has been renumbered, altered, or otherwise made non-current. Supporting evidence: `envelope_address_number_seven` (notice addressed to #7), `renewal_2019_number_twelve` (renewal at #12), `renumbering_2015_fact`. Establishes `_fact.renumbering_2015_documented`.
2. **Landlord knowledge (E2).** The defect was known to the serving party. Supporting evidence: `renewal_2019_number_twelve` (landlord countersignature at #12); bonus: `return_to_sender_slip` (October 2018 bounce-back from same misaddressing); bonus: `landlord_contact` (March personal visit to #12). Establishes `_fact.landlord_knew_address`.
3. **Timely actual-notice motion (E3).** Filed within fourteen days of actual notice. Supporting evidence: `notice_timeline_april` (April 8 service to #7, April 28 actual receipt by Halina, today is the 5th of May → 9 days remaining). Establishes `_fact.notice_received_april_28`.
4. **No third-party authority / cure (E4).** The resident of new #7 who accepted the envelope had no authority to receive process for Halina. Supporting evidence: Murrow's first-meeting authority fact (the third clause of Art. 135-bis); reinforced by Crab's pre-binder stairwell observation of the current resident at #7. Establishes `_fact.resident_no_authority`. (NEW evidence card may be needed: `resident_no_7_no_authority` — see §3.)

Packet completeness drives the Phase 2 court reaction: 4/4 → strong; 3/4 → standard; 2/4 → narrow; ≤1/4 → bench-initiative. This maps cleanly onto the existing `primary_fact_count` victory-resolution logic in `chapter1_round_1.json` — minimal Code-pass change.

### 1.2 Decoy items

The player may bolt these on but should not. Each is a real-world junior mistake; each costs `judicial_patience` and (for personally insulting decoys) `halina_trust`. Decoys are NEVER auto-included — they require explicit "yes, include this fallback" decisions at named moments in the synthesis dialogue.

- **D1 — Merits / substantive defense.** Argue Halina has paid the rent. Supporting (decoy-side) evidence: `payment_receipts_sikorska`, `lease_1962_inheritance_1987`. Wrong because the merits are not before the court at the motion stage; the procedural defect wins the hearing without them. Cost: `judicial_patience -2`, `halina_trust 0` (she trusts Cula to find the procedural angle; the merits move is not insulting). Burns a round attempt. Decision moment: Halina meeting (technical/sympathetic stance) or Murrow Beat 9 archive walk-through ("we could plead the merits as a backup — include?").
- **D2 — Notice-period failure under the Tenancy Act.** Argue the notice window itself was short. Supporting evidence: `notice_timeline_april`, `tenancy_act_notice_window_citation`. Wrong because the locational defect ends the matter first; the timing is colorable but procedurally subordinate. Cost: `judicial_patience -2`, `halina_trust -1` (the wrong-door fact is in plain sight on the documents Halina handed Cula; reaching for timing instead reads as missing the obvious). Burns a round attempt. Decision moment: Murrow first-meeting ("the Tenancy Act fourteen-day window is colorable; do we include it?").
- **D3 — Standing / wrong party (post-2018 ownership transfer).** Argue the prior owner has no standing. Supporting evidence: `property_transfer_2018`. Wrong because the lease assigned forward at the 2018 transfer. Cost: `judicial_patience -3`, `halina_trust -1` (she signed the lease with the prior owner and continues to deal with him; the standing theory implies she does not know who her landlord is). Burns a round attempt. Decision moment: Whimsy `before_meeting` ("I keep a folder of who-owns-what — there is a property transfer in two thousand and eighteen. Add it?").
- **D4 — Overbroad remedy.** Ask the court for dismissal with prejudice / a permanent injunction / both. NEW in v3. Wrong because the canonical remedy in this chapter is procedural reset only (story.txt Beat 12 Round 3, "remedy discipline (load-bearing)"). Cost: `judicial_patience -2`, `halina_trust 0` (she does not parse remedy-scope arguments closely). Does NOT burn a round attempt — the remedy ask is part of Phase 2 closing, not a separate frame — but the bench reaction (`sharper_really_your_theory` template) is sharper and the win narrows by one tier. Decision moment: Whimsy `before_meeting` rhetorical-flourish offer ("for theatre we could ask for the world. Permanent injunction. Dismissal with prejudice. Or only what we need.") OR Cula's own option in the Murrow `court_readiness_check`.
- **D5 — Incapacity by age (the punished blunder).** Argue Halina is too elderly to be served. Supporting (such as it is) evidence: `sikorska_age_visible`. Wrong because Polish civil procedure does not impute incapacity from age; the test is cognitive, not chronological — and Halina is sharp. Cost: `judicial_patience -5`, `halina_trust -4`. Crab refuses to assist the next round; recovery requires a post-court apology dialogue beat. Burns a round attempt. Decision moment: a single Cula-internal option in the Crab post-Halina-meeting state ("Halina is seventy-one. Could we plead incapacity as belt-and-braces?"). The option must be reachable so the moral choice is real; the consequences must be loud so it is not the obvious move.

### 1.3 Difference from v2

v2 made the player pick *one* frame. v3 lets the player assemble the packet that actually goes in. The hard call is no longer "what is this case about?" (which had one defensible answer) — it is "do I include this weaker theory as a fallback?" (which has several defensible answers, with different procedural costs). The D1–D3 and D5 decoys carry over from v2 unchanged in cost structure; D4 (overbroad remedy) is new in v3 and absorbs what was implicitly the "ask for everything" failure mode in `chapter1_round_1.json`'s `jq_remedy_scope` (currently silent in v2).

### 1.4 NPC role split — who surfaces what

Largely inherited from v2 §1.4; what changes is the framing of the synthesis dialogue from "pick a frame" to "include this in the packet."

- **Crab — `crab.json`.** Surfaces evidence for E1 (non-current address), E2 (landlord knowledge — via the renewal countersignature), E3 (notice timeline) and E4 (resident-at-#7 lacks authority — Crab's stairwell observation is what makes E4 surfaceable before Murrow's Beat 9 walk-through). The v2 rewrite kept the canonical greeting and the gear-shift fact-stack ("That is not service. That is postal theatre."). The v3 reshape: replace the three-option pitch (currently three tonal Cula lines all writing `recruited_crab = true`) with three packet-shaping options that write per-element bools: "include E1+E2 in the packet" / "include E4 if we can get Murrow's authority point" / "include the incapacity belt-and-braces" (D5). The recruitment flag `recruited_crab` still flips on every option (preserving the existing on_dismiss writes); the per-element bools are the new payload.
- **Murrow — `murrow.json`.** Surfaces evidence for E3 (notice timeline + Tenancy Act citation), E4 (the authority-required third-clause fact), and offers D1 and D2 as named decoy options. The eight-line case-briefing collapses to four observation lines plus two decoy-offer states: "include the merits as a backup?" (D1) and "include the Tenancy Act notice-period angle?" (D2). The fourteen-days-from-actual-notice fact stays — it is E3's primary anchor.
- **Whimsy — `whimsy.json`.** Surfaces evidence for D3 (property transfer) and offers D3 + D4 as named decoy options. His character note "I keep a folder of who-owns-what. Marginal pastime. Occasionally useful." (from the 2026-05-16 voice-pack rewrite at commit 8d6bb3b) is the in-fiction justification for D3. D4 (overbroad remedy) is Whimsy's rhetorical-flourish offer ("for theatre we could ask for the world").
- **Halina — `halina.json`.** Trust meter unchanged. The bonus-evidence enum (`wojcik_witness_statement` / `return_to_sender_slip` / `lease_1962_inheritance_1987` / `landlord_contact`) maps to packet elements: `wojcik_witness` reinforces E1 and E2; `return_to_sender_slip` reinforces E2; `lease_1962_inheritance_1987` reinforces D1 (it is the substantive-defense anchor); `landlord_contact` reinforces E2. No content changes to `halina.json` — the points-to-elements mapping lives in `motion_elements_ch1.json` (see §3), not in the dialogue file. The technical/sympathetic stance also surfaces `payment_receipts_sikorska` (D1's anchor) via existing dialogue.
- **Asia — `asia_hint_states_ch1.json`.** Hint surface. v3 nudges: when the packet is missing an element, Asia's hint signposts the NPC who surfaces it ("Mr. Crab is on the stairwell again — he's been muttering about the door numbers" → E1; "Mr. Murrow flagged a paragraph in green — third clause, page facing the renewal" → E4). When the packet contains a decoy, Asia does NOT comment — the bench is the feedback channel for decoy inclusion, not Asia.

## 2. Reasoning surface — where the player actually synthesises

Unchanged from v2 §2: dialogue-options as the v1 surface (load-bearing); binder UI as v2 deliverable (case-file pages mood, deferred). The packet model makes the binder UI a more obvious fit when it ships — the binder becomes a literal motion-packet draft with element slots and a "decoys" sidebar, and the player drops evidence cards into element slots. But the v1 surface still works: each element bool flips when its supporting evidence is surfaced, and decoy bools flip on explicit dialogue choices. The Crab/Murrow/Whimsy synthesis states carry the load.

The court-round battle UI is still the load-bearing surface for Phase 2. The reverted `battle_controller.gd` skeleton was restored by Agent 1 at commit 603f65e (per v2's Open Question 2, since mooted). Integration of the packet model with Phase 2 is the next pass.

## 3. Data model

### 3.1 Replace `argument_frames_ch1.json` with `motion_elements_ch1.json`

The v2 `argument_frames_ch1.json` is structurally a frames-as-mutually-exclusive-choices file; v3 needs elements-and-decoys-as-independent-bools. Cleanest is a rename + schema replacement. Code's call — alternative is to keep the filename and bump to schema version 3.

```jsonc
{
  "version": 3,
  "elements": {
    "non_current_address": {
      "type": "required",
      "rule_clause": "KPC Art. 135-bis § 2, first clause",
      "supporting_evidence_any_of": ["envelope_address_number_seven", "renewal_2019_number_twelve", "renumbering_2015_fact"],
      "supporting_evidence_strongest": ["envelope_address_number_seven", "renewal_2019_number_twelve"],
      "source_npc_primary": "crab",
      "establishes_fact_flag": "_fact.renumbering_2015_documented",
      "auto_include_when_supporting_surfaced": true,
      "display_name": "",
      "summary": ""
    },
    "landlord_knowledge": {
      "type": "required",
      "rule_clause": "KPC Art. 135-bis § 2, first clause (knowledge requirement)",
      "supporting_evidence_any_of": ["renewal_2019_number_twelve", "return_to_sender_slip", "landlord_contact"],
      "source_npc_primary": "crab",
      "establishes_fact_flag": "_fact.landlord_knew_address",
      "auto_include_when_supporting_surfaced": true,
      "display_name": "",
      "summary": ""
    },
    "timely_actual_notice_motion": {
      "type": "required",
      "rule_clause": "KPC Art. 135-bis § 2, second clause (14-day window from actual notice)",
      "supporting_evidence_any_of": ["notice_timeline_april"],
      "source_npc_primary": "murrow",
      "establishes_fact_flag": "_fact.notice_received_april_28",
      "auto_include_when_supporting_surfaced": true,
      "display_name": "",
      "summary": ""
    },
    "no_third_party_cure": {
      "type": "required",
      "rule_clause": "KPC Art. 135-bis § 2, third clause",
      "supporting_evidence_any_of": ["resident_no_7_no_authority", "murrow_authority_fact"],
      "source_npc_primary": "murrow",
      "establishes_fact_flag": "_fact.resident_no_authority",
      "auto_include_when_supporting_surfaced": true,
      "display_name": "",
      "summary": ""
    }
  },
  "decoys": {
    "merits": {
      "type": "decoy",
      "supporting_evidence_any_of": ["payment_receipts_sikorska", "lease_1962_inheritance_1987"],
      "source_npc_primary": "halina",
      "include_decision_state": "murrow.json:archive_walkthrough_decoy_merits",
      "judicial_patience_delta_on_include": -2,
      "halina_trust_delta_on_include": 0,
      "burns_round_attempt": true,
      "judge_reaction_template": "tolerant_try_again",
      "display_name": "", "wrong_shape_correction": "", "present_cue": ""
    },
    "notice_period": {
      "type": "decoy",
      "supporting_evidence_any_of": ["notice_timeline_april", "tenancy_act_notice_window_citation"],
      "source_npc_primary": "murrow",
      "include_decision_state": "murrow.json:first_meeting_decoy_notice_period",
      "judicial_patience_delta_on_include": -2,
      "halina_trust_delta_on_include": -1,
      "burns_round_attempt": true,
      "judge_reaction_template": "cool_dismissal"
    },
    "standing_wrong_party": {
      "type": "decoy",
      "supporting_evidence_any_of": ["property_transfer_2018"],
      "source_npc_primary": "whimsy",
      "include_decision_state": "whimsy.json:before_meeting_decoy_standing",
      "judicial_patience_delta_on_include": -3,
      "halina_trust_delta_on_include": -1,
      "burns_round_attempt": true,
      "judge_reaction_template": "sharper_really_your_theory"
    },
    "overbroad_remedy": {
      "type": "decoy",
      "supporting_evidence_any_of": [],
      "source_npc_primary": "whimsy",
      "include_decision_state": "whimsy.json:before_meeting_decoy_overbroad_remedy",
      "judicial_patience_delta_on_include": -2,
      "halina_trust_delta_on_include": 0,
      "burns_round_attempt": false,
      "narrows_win_by_one_tier": true,
      "judge_reaction_template": "sharper_really_your_theory"
    },
    "incapacity": {
      "type": "decoy_punished",
      "supporting_evidence_any_of": ["sikorska_age_visible"],
      "source_npc_primary": "none",
      "include_decision_state": "crab.json:post_halina_decoy_incapacity",
      "judicial_patience_delta_on_include": -5,
      "halina_trust_delta_on_include": -4,
      "burns_round_attempt": true,
      "in_fiction_consequence": "Crab refuses to assist the next round (recruited_crab is reset until a post-court Cula→Halina apology dialogue beat); Halina audibly disapproves in court ('I am quite competent, Dr. Cula'); the court reporter pauses typing.",
      "judge_reaction_template": "icy_silence"
    }
  }
}
```

### 3.2 New flags introduced by this revision

Per-element bools (4) and per-decoy bools (5), all default `false`:

- `chapter1.element_non_current_address`
- `chapter1.element_landlord_knowledge`
- `chapter1.element_timely_actual_notice_motion`
- `chapter1.element_no_third_party_cure`
- `chapter1.decoy_merits`
- `chapter1.decoy_notice_period`
- `chapter1.decoy_standing_wrong_party`
- `chapter1.decoy_overbroad_remedy`
- `chapter1.decoy_incapacity`

Element bools are auto-set when the corresponding `supporting_evidence_any_of` is surfaced (the dialogue runner already emits `chapter1_flag_changed` on every flag write; a small `motion_packet.gd` system listening on that signal updates element bools from surfaced evidence — alternatively, dialogue `on_dismiss` blocks write the element bool directly alongside the evidence flag). Decoy bools are written by explicit `on_dismiss` blocks on the named include-decision states.

The v2 `chapter1.proposed_frame` enum field is **retired** under v3 — there is no single frame to commit to. A v17→v18 save migration removes `proposed_frame` and adds the nine new bools. The five v2 `surfaced_*` flags from `evidence_ch1.json` v2 (`surfaced_payment_receipts`, `surfaced_notice_timeline`, `surfaced_property_transfer`, `surfaced_sikorska_age`, `surfaced_tenancy_act_window`) are also declared in the same v17→v18 migration — they were deferred in v2 and now have a natural reason to land. Total: SAVE_VERSION 17 → 18, removes 1 string, adds 14 bools, all defaulting `false` / `""`.

### 3.3 `evidence_ch1.json` extensions

The v2 `evidence_ch1.json` `points_to_frames` field is **retired** under v3 — there are no frames to point to. Replace with `supports_element` (string element_id from `motion_elements_ch1.json:elements`) and `supports_decoy` (string decoy_id from `motion_elements_ch1.json:decoys`). One card may support multiple, but the semantics shift: surfacing the card establishes the supported element (auto-include); supporting a decoy means the decoy's include-decision option becomes selectable, not that the decoy is auto-included.

One new evidence card needed: **`resident_no_7_no_authority`** — Crab's stairwell observation that the current occupant of #7 is a young man unrelated to Halina and clearly not her authorised agent. Surfaceable via Crab `before_binder` (the gear-shift line "The building above us reads number twelve" already lands; one extra line about the occupant slots in). `sets_flag: chapter1.surfaced_resident_no_authority` (new bool, declared in the v17→v18 migration with the other `surfaced_*` set). `supports_element: no_third_party_cure`.

### 3.4 `chapter1_round_1.json` — minimal changes

The Phase 1 `_fact.*` flags map 1:1 onto the four required elements. Phase 1 stays as authored. **Phase 2 frame_gates rewrite**: replace the `defective_service_135bis` / `third_party_non_cure` / `fair_hearing_article_6` / `merits_defence` gate set with packet-based gating:

```jsonc
"phase_2_closing": {
  "packet_gates": {
    "_doc": "Phase 2 reads chapter1.element_* bools to determine which citations are available, and reads chapter1.decoy_* bools to apply patience/trust deltas + sharpen the bench's counter-questions. The available_counter_questions set is now derived from element coverage, not from a single frame_id.",
    "element_to_counter_questions": {
      "no_third_party_cure": ["jq_third_party_cure"],
      "timely_actual_notice_motion": ["jq_article_6_civil"],
      "any_three_or_more": ["jq_remedy_scope"]
    },
    "decoy_to_counter_questions": {
      "merits": ["jq_merits_premature"],
      "notice_period": ["jq_notice_period_subordinate"],
      "standing_wrong_party": ["jq_standing_assignment"],
      "overbroad_remedy": ["jq_remedy_scope"],
      "incapacity": ["jq_capacity_chronological"]
    },
    "judicial_patience_starts_at": 5,
    "judicial_patience_decoy_decrements": "applied at packet submission, before first counter-question"
  },
  "victory_resolution": {
    "_doc": "Existing logic largely preserved; primary_fact_count is the count of element_* bools set to true (4/3/2/≤1 bucket).",
    "branches": [
      {"id": "strong_victory_with_costs", "when": "element_count == 4 && no_decoys_included && judicial_patience >= 4", "outcome": "procedural_reset_with_costs"},
      {"id": "strong_victory", "when": "element_count == 4 && (decoy_count == 0 || (decoy_count == 1 && only_decoy_is_overbroad_remedy)) && judicial_patience >= 3", "outcome": "procedural_reset_full"},
      {"id": "standard_victory", "when": "element_count >= 3 && judicial_patience >= 2 && !decoy_incapacity", "outcome": "procedural_reset_full"},
      {"id": "narrow_victory", "when": "element_count >= 2 && judicial_patience >= 1", "outcome": "procedural_reset_narrow"},
      {"id": "bench_initiative", "when": "element_count <= 1 || decoy_incapacity_with_no_apology", "outcome": "procedural_reset_bench_initiative"},
      {"id": "after_apology", "when": "decoy_incapacity && post_court_apology_completed", "outcome": "procedural_reset_after_apology"}
    ]
  }
}
```

The two new counter-questions referenced (`jq_notice_period_subordinate`, `jq_standing_assignment`, `jq_capacity_chronological`) are Code-pass additions to the existing `judge_counter_questions` array. Text is Design-pass.

**Tag-taxonomy compatibility.** No new tags required.

## 4. Failure modes

The v2 §4 design — soft-fail, no reloads, wrong choices survive — is preserved. The cost model is re-expressed against the packet:

| Action | judicial_patience delta | halina_trust delta | Burns round attempt | Notes |
|---|---|---|---|---|
| Missing element from packet (per missing element, max 3) | -1 each | 0 | no | The bench notices and asks counsel about it during Phase 2; patience erodes by the question, not by the missing fact alone |
| Include D1 (merits) | -2 | 0 | yes | Halina silent — she trusts the procedural angle |
| Include D2 (notice-period) | -2 | -1 | yes | Halina mildly disappointed — wrong-door fact is on the documents she handed Cula |
| Include D3 (standing) | -3 | -1 | yes | Halina disappointed — implies Cula thinks she doesn't know her landlord |
| Include D4 (overbroad remedy) | -2 | 0 | no | Narrows the win by one tier; bench reaction sharpens |
| Include D5 (incapacity) | -5 | -4 | yes | Crab refuses to assist next round; recovery via post-court apology |

**Judge reaction templates** retained from v2: `approving_set_aside`, `tolerant_try_again`, `cool_dismissal`, `sharper_really_your_theory`, `icy_silence`. The templates fire at Phase 2 open per the strongest decoy present (no decoys → `approving_set_aside`; D5 trumps everything → `icy_silence`). The `judicial_patience` trajectory across the round is unchanged from v2 §4.

**Recovery dynamics.** Round 1 is packet submission. Rounds 2 and 3 (the existing chapter1 court structure) become defence rounds: the bench's counter-questions per element/decoy play out as Press/Present exchanges (per PROPOSALS.md §10 Phase 1/Phase 2). The player who realises mid-court that a decoy is sinking the case may withdraw it ("strike that, Your Honour") at a cost of `judicial_patience -1` per withdrawn decoy. Withdrawing does not refund halina_trust.

**Worst case.** Incapacity included → procedural_reset_bench_initiative + Crab withdrawal. The bench reaches for defective service itself because the procedural error is on the face of the documents; Halina wins on a narrow procedural reset, but Cula did not make the argument and Halina pays the fee with cooled regard. Apology dialogue is available post-court; once completed, `chapter1.court_outcome` becomes `procedural_reset_after_apology` and the Ch4 corridor-sighting scene gets the third recolor variant noted in v2 §4.

The chapter never forks into "Halina is evicted." This is the v1/v2/v3 invariant per PROPOSALS.md §9 and story.txt Beat 12 ("remedy discipline (load-bearing)").

## 5. Role split per godot/AGENTS.md

| Sub-work | Owner | Notes |
|---|---|---|
| `state.gd` additions (9 new chapter1 bools + 5 deferred v2 `surfaced_*` bools) | Code | Single writer |
| `save.gd` v17→v18 migration: remove `proposed_frame`, add 14 bools | Code | Plus `tests/test_save_migration_v17_v18.gd` |
| Rename `argument_frames_ch1.json` → `motion_elements_ch1.json` (or v3 schema in-place) | Code | Mechanical fields |
| `motion_elements_ch1.json` — display_name, summary, wrong_shape_correction, present_cue text | Design | Per element/decoy, Taste Standard pass |
| `evidence_ch1.json` schema bump: replace `points_to_frames` with `supports_element` + `supports_decoy` | Code | Mechanical fields |
| New evidence card `resident_no_7_no_authority` (Code-pass shape, Design text) | Code + Design | One new entry |
| `data/court_rounds/chapter1_round_1.json` Phase 2 packet_gates rewrite | Code | Replaces v2 frame_gates block |
| Phase 2 counter-question additions (`jq_notice_period_subordinate`, `jq_standing_assignment`, `jq_capacity_chronological`) | Code (shape) + Design (text) | |
| `data/dialogues/crab.json` rewrite: replace 3-tonal-option block with 3 packet-shaping options (per-element bools as `write_path`); add `post_halina_decoy_incapacity` state | Design | Preserve existing `on_dismiss` flag writes; address forms per AGENTS.md |
| `data/dialogues/murrow.json` rewrite: 4 observation lines + `first_meeting_decoy_notice_period` + `archive_walkthrough_decoy_merits` decision states | Design | |
| `data/dialogues/whimsy.json` rewrite: `before_meeting_decoy_standing` + `before_meeting_decoy_overbroad_remedy` decision states | Design | |
| `data/dialogues/asia_hint_states_ch1.json` — element-missing hint signposts | Design | |
| Optional `scripts/systems/motion_packet.gd` listener (auto-set element bools from surfaced evidence) | Code | If the per-state `on_dismiss` element writes prove brittle |
| Binder UI scene (v2 deliverable, unchanged from v2 §5) | Code + Design + Art | Deferred |
| Phase 1 / Phase 2 controller integration | Code | Per PROPOSALS.md §10 |
| Test suite: `tests/test_save_migration_v17_v18.gd`, `tests/test_motion_packet_assembly.gd`, `tests/test_chapter1_phase_b.gd` updates | QA | |
| `SPRINT_LOG.md` entries | All | Per-role on completion |

Handoff order: Code state/save/schema → Code rename/replace of `argument_frames_ch1.json` and `evidence_ch1.json` schema → Code Phase 2 packet_gates → Design dialogue rewrites → Design court_rounds text → QA tests.

## 6. Migration cost — honest scope

**Two to three sprint sessions** for a coherent Phase 0 + Phase 1 cut, same as v2's estimate. The v2 → v3 reshape is not free, but most of it is rename + reshape rather than net-new authoring:

- Evidence cards: 13 entries authored in v2 carry forward unchanged; one new card (`resident_no_7_no_authority`).
- Element/decoy entries in `motion_elements_ch1.json`: 9 total (4 + 5); the four elements absorb v2's `defective_service_135bis` content; the five decoys absorb v2's four decoy frames + add D4.
- Dialogue rewrites: same three files as v2 (`crab.json`, `murrow.json`, `whimsy.json`). The Crab v2 rewrite already preserves the canonical greeting and gear-shift fact-stack; v3 only changes the options block payload (per-element bools instead of tonal-recruitment). The Murrow and Whimsy v2 rewrites need decoy-offer states appended; existing first-meeting content stays. Net dialogue word-count change: ≈ flat to slightly negative.
- Save migration: v17 → v18, one schema bump, removes 1 string field and adds 14 bools, all defaulting safe.
- Court rounds: `chapter1_round_1.json` Phase 1 stays; Phase 2 frame_gates block is the rewrite (≈ 50 lines).

Recyclable: tag taxonomy, effectiveness.gd, halina.json, items.json bonus-evidence definitions, all v2 evidence cards.

If scope tightens, the minimum viable v3 ships:
- Code state/save/migration
- `motion_elements_ch1.json` Code-pass complete
- `evidence_ch1.json` schema bump
- The crab.json options-block reshape (the one load-bearing dialogue change)
- Phase 2 packet_gates rewrite

That cut produces a meaningfully different chapter: the player establishes elements through evidence surfacing, the court evaluates packet completeness. The decoy decision states for Murrow and Whimsy can land in a follow-up sprint without breaking the spine — without them, the player simply cannot include those decoys, which is a strictly more conservative chapter shape.

## 7. Pokémon vs Ace Attorney — what motion-packet actually steals

v2 §7 argued AA's PRESENT mechanic mapped onto frame-selection. With v3 it maps even more naturally — onto **dropping evidence into element slots** in the packet.

- **Pokémon Yellow** — chassis unchanged. Turn-based selection from a fixed move set, type-effectiveness math. Still the Casebook backbone.
- **Ace Attorney — surface 1 (packet assembly).** Each required element is an open slot. Surfacing the supporting evidence card is structurally identical to AA's PRESENT — the player is offering a piece of evidence against a specific procedural question ("does the rule's first clause apply here?") and the game checks fit. The fit check is binary (the card supports the element or it does not). Multiple cards can satisfy one element; the strongest combination yields the cleanest Phase 2 trajectory. The decoy decision states are AA PRESENT's polarity-flipped sibling: the player is offered a card and asked whether to deploy it as a theory; the game checks whether deploying it is procedurally wise.
- **Ace Attorney — surface 2 (Phase 1 fact-finding).** Press costs `witness_cooperation` and elicits sub-statements; Present aims an evidence card at a specific statement and the resolver checks fit. Unchanged from v2.
- **Ace Attorney — surface 3 (Phase 2 counter-questions).** The bench's counter-questions are AA's cross-examination polarity reversed: the bench presses Cula; Cula's citation moves are her PRESENT responses.
- **Trust-meter calibration** — unchanged. Halina's trust reads in two places (her own meeting at Beat 8; the decoy-include moments). The trust meter is the through-line for Cula's professional relationship with the client.

The deeper change: v2 treated PRESENT as a single moment (pick a frame). v3 treats PRESENT as a sustained activity across Beat 4–10 (assemble the packet, card by card and decision by decision). That maps better onto how AA actually feels in play — the player is constantly looking at evidence and asking "where does this go?" The v3 packet model gives the player that question to ask, throughout the chapter, not just once.

**Why v3 makes AA the right reference, not just a flattering one.** AA's appeal is that the evidence has a place to go and the player figures out where. v2 had evidence cards but only one decision moment for them. v3 has evidence cards and four element slots plus five decoy slots — every card has somewhere it could land, and the player works out the landing.

## 8. Open questions for the human

1. **(NEW) `motion_elements_ch1.json` filename vs in-place schema v3.** Default: rename. Cleaner intent; the file is no longer about frames.
2. **(NEW) Auto-include element bools via `motion_packet.gd` listener, or via per-state `on_dismiss` writes?** Default: `on_dismiss` writes. Less infrastructure; the listener becomes a v2-binder concern.
3. **(NEW) Element 4 (no third-party cure) evidence: ship the new `resident_no_7_no_authority` card, or fold the authority fact into the existing `renumbering_2015_fact` card's `points_to_frames`-equivalent?** Default: new card. The authority fact is a distinct observation and deserves its own surfacing moment (Crab's gear-shift extension line).
4. **(NEW) Should Halina's bonus-evidence enum gain `payment_receipts_sikorska` as a fifth canonical value, or stay derived from `client_meeting_stance != ""`?** Default: stay derived. v2 §3 noted this avoids a chapter1-enum expansion; v3 inherits the same reasoning.
5. **(Carried from v2) Binder UI mood.** Default: case-file pages. Decision still needed before v2 binder sprint.
6. **(Carried from v2) Incapacity decoy: include or omit?** Default: include. The hard-wrong is the firm's moral compass made visible.
7. **(NEW) Should D4 (overbroad remedy) be reachable via a Cula self-prompt (no NPC asks), or only via Whimsy's rhetorical-flourish offer?** Default: only via Whimsy. Limits the surface and keeps Whimsy's role-as-temptation distinct.

## 9. What this proposal explicitly does *not* do

Same list as v2 §9. No Casebook tag taxonomy changes. No new Polish legal doctrine. No changes to the Halina trust meter mechanics, the postcard chain, the coffee minigame. No binder UI in v1 (deferred to v2). No new principle moves on `procedural_reset_ch1`. No chapter-outcome change — Halina still wins on procedural reset; the firm still gets the 5,000 PLN fee; the corridor sighting in Ch4 still happens. Win is wider or narrower based on packet completeness and decoy inclusion; never converted to a loss.

## 10. Acceptance criteria for the v3 first cut

"First cut acceptable" when:

- All four core headless commands pass (smoke, runner, save migration v17→v18, Web export).
- `motion_elements_ch1.json` (or v3 in-place) contains the four required elements and the five decoys with full Code-pass fields populated.
- `evidence_ch1.json` v3 schema applied: `points_to_frames` removed; `supports_element` / `supports_decoy` populated on every entry; the new `resident_no_7_no_authority` card present.
- The v17→v18 save migration removes `chapter1.proposed_frame` and adds the 14 new bools (9 packet flags + 5 deferred `surfaced_*` from v2); migration test passes; reset_state declares all 14.
- `chapter1_round_1.json` Phase 2 `packet_gates` block replaces `frame_gates`; victory_resolution reads element_count and decoy_count; the three new counter-questions present with Code-pass fields.
- The three rewritten dialogue files (`crab.json`, `murrow.json`, `whimsy.json`) carry the per-element / per-decoy decision option-blocks; existing on_dismiss writes preserved; address forms per AGENTS.md.
- A player walking Beat 4 → Beat 9 can: meet Crab, pick up the binder, surface all four required elements through dialogue + evidence, optionally accept or reject each decoy, meet Halina, complete archive research, reach court-ready.
- A wrong-decoy path is reachable and survivable per §4 consequence matrix.
- A player picking incapacity reaches a playable end-of-chapter state with `court_outcome ∈ {procedural_reset_bench_initiative, procedural_reset_after_apology}`.
- The dialogue editor enum validator (Agent 8's commit 81f82ae) accepts the removal of `proposed_frame` from `chapter1.json` registry without manual override.

## 11. SPEC_SYNC — root-spec changes the human should later apply

These are creative-canon edits to the five root `.txt` files that v3 implies but does not perform per AGENTS.md "Forbidden patterns" (only the human edits the root specs). Listed for the human to apply in a future spec pass; the runtime will be authored against these targets and will be SLIGHTLY ahead of the specs until they catch up.

1. **`story.txt` Beat 4 — renumbering target.** Current text: *"Halina's flat went from #7 to #5; the eviction notice was served to the current #7 (a different renter)."* Target: *"Halina's flat went from #7 to #12; the eviction notice was served to the current #7 (a different renter)."* Reason: runtime data (`evidence_ch1.json`: `renewal_2019_number_twelve`) and the v2 Crab rewrite (`crab.json` `before_binder`: "The building above us reads number twelve") have already committed to #12. Standardising on #7 → #12 per the v3 directive.
2. **`story.txt` Beat 9 — Article 135-bis narration.** The Murrow narration block references "#7 → #5" — update to "#7 → #12" wherever the renumbering target is named.
3. **`story.txt` Beat 12 — Court Round 1 framing.** Current text frames Round 1 as "Defective service" with required evidence listed flat. Target: reframe as "Motion-packet submission" with the four required elements named (non-current address; landlord knowledge; timely actual-notice motion; no third-party authority/cure) and the decoy roster acknowledged ("counsel may bolt on weaker theories — merits, notice-period under the Tenancy Act, standing/wrong-party, overbroad remedy ask, or — punished — incapacity by age"). Preserve "remedy discipline (load-bearing)" verbatim; the procedural-reset-only rule is unchanged.
4. **`story.txt` Beat 12 — court_outcome enum extension.** The current Beat 12 names `won_court` and `court_won_procedural_reset` as flags. v3 adds `procedural_reset_with_costs`, `procedural_reset_narrow`, `procedural_reset_bench_initiative`, `procedural_reset_after_apology` as values of `court_outcome`. Document these in the Beat 12 result block so the spec and runtime agree on the outcome vocabulary.
5. **`battle_mechanics.txt` — Phase 1 / Phase 2 split.** If not already documented (PROPOSALS.md §10 was marked DONE but the spec-side text reportedly never landed), add the two-phase round structure: Phase 1 = witness fact-finding with Press/Present; Phase 2 = closing argument with citation moves against bench counter-questions. v3 makes Phase 2 of Round 1 specifically packet submission; document if not already present.
6. **`style_canon.txt` — register note for "packet" vs "frame".** Add a brief register note: Chapter 1 dialogue should prefer "motion", "the packet", "the four elements" over "theory", "frame", "argument shape" when characters discuss the work. The frame language was v2; the packet language is v3. (Optional; useful for keeping voice-pack drafters aligned.)

These are spec changes only — no behaviour depends on the spec catching up before runtime work proceeds; per AGENTS.md the runtime is authored against the proposal and the spec follows.

---

**Human, before next implementation pass.** Seven open questions in §8. Defaults: rename to `motion_elements_ch1.json`; per-state `on_dismiss` element writes (no listener); ship the new `resident_no_7_no_authority` card; keep payment receipts derived from `client_meeting_stance`; case-file binder mood; include incapacity; D4 reachable only via Whimsy. Six SPEC_SYNC items in §11 for a future spec pass; runtime authors against the v3 targets in the meantime.
