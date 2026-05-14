# PROPOSAL — `data/court_rounds/_schema.md`

**Filed:** 2026-05-14 by Code (overnight autonomous pass).
**Status:** DRAFT for human review.
**Unblocks:** PROPOSALS.md §10 (Court Round splits into two phases) — pre-work
explicitly required before `battle_controller.gd` work begins. Reference:
`PLAN.md` §Vertical slice plan step 4.

This is the one-page schema sketch the existing proposal asks for. It does
not extend the proposal's design; it commits to a JSON shape so Code can
implement Phase 1 + Phase 2 sub-controllers from day one, and so Design
knows the authoring target.

---

## Scope

One file per court round at `data/court_rounds/<chapter>_<round>.json`,
loaded once at battle start by `battle_controller.gd`. Chapter 1 ships
three files: `ch1_round1.json`, `ch1_round2.json`, `ch1_round3.json`.
The existing `data/dialogues/judge_district_ch1.json` continues to own
the judge's bench prompts and reactions; the court-round files own the
mechanical sub-controller content — witness statements, evidence presses,
fact-flags, judicial-patience deltas, principle citations.

The judge dialogue file stays the surface for what the judge *says*. The
court-round file is the surface for what the player *does* on either side
of those judge lines.

## Top-level shape

```json
{
  "version": 1,
  "round_id": "ch1_round1",
  "title": "Service of the eviction notice",
  "judge_state_phase_1": "round_1_witness",
  "judge_state_phase_2": "round_1_open",
  "_provenance": "…",
  "phase_1": { … },
  "phase_2": { … }
}
```

`judge_state_phase_1` and `judge_state_phase_2` are the enum values the
controller writes to `chapter1.casebook_judge_state` so the existing
`judge_district_ch1.json` triggers fire at the right phase. New enum
values added by this proposal: `round_1_witness`, `round_2_witness`,
`round_3_witness`. The existing `round_N_open` / `round_N_react` /
`round_3_remedy` values continue to mean Phase 2 substates exactly as
today; nothing in `judge_district_ch1.json` needs to change.

## Phase 1 — Witness fact-finding

```json
"phase_1": {
  "witness_id": "halina",
  "witness_display_name": "Mrs. Sikorska",
  "witness_cooperation_initial": 5,
  "witness_cooperation_minimum_for_full_truth": 3,
  "_doc_cooperation": "Distinct from judicial_patience. Each press costs 1; each present-evidence move that lands costs 0 and may add 1. Below the minimum, the witness withholds the leading fact-flag (collapsing one or more Phase 2 citation paths).",
  "statements": [
    {
      "id": "statement_notice_arrival",
      "lines": [
        "I received the notice on the twenty-eighth of April. The young man at number seven brought it down."
      ],
      "press_options": [
        {
          "id": "press_for_date_of_notice",
          "label": "When was the notice dated, as opposed to received.",
          "trigger": "",
          "cooperation_delta": -1,
          "fact_flag_on_success": "fact_notice_dated_april_8",
          "on_dismiss_lines": [
            "It was dated the eighth of April. Twenty days before I had it in hand."
          ]
        },
        {
          "id": "present_renumbering_ordinance",
          "label": "Present the 2015 renumbering ordinance.",
          "trigger": "chapter1.archive_research_complete == true",
          "cooperation_delta": 1,
          "fact_flag_on_success": "fact_renumbering_2015_on_record",
          "on_dismiss_lines": [
            "Yes. The renumbering. I lived at number seven until two thousand and fifteen. Now number twelve."
          ]
        }
      ]
    }
  ],
  "fact_flags": [
    "fact_notice_dated_april_8",
    "fact_renumbering_2015_on_record",
    "fact_landlord_prior_knowledge_returned_letter"
  ],
  "_doc_fact_flags": "Closed set; declared here so authoring can verify Phase 2 doesn't reference an unestablishable flag. Each is set in State.data.court_facts (a new top-level dict — see Save migration below) when its press/present option lands successfully."
}
```

The carry-over from Phase 1 to Phase 2 lives in `State.data.court_facts`
— a new top-level `Dictionary` keyed by `fact_<id>` with bool value.
Owner: the Phase 1 sub-controller. Phase 2 reads, never writes. Adding
this dict is a Save migration step (new SAVE_VERSION).

`witness_cooperation` lives transiently in the battle controller and is
not persisted — collapsing it on save mid-round would be a feature
addition not covered by Chapter 1.

## Phase 2 — Closing argument

```json
"phase_2": {
  "judge_open_state": "round_1_open",
  "judge_react_state": "round_1_react",
  "judicial_patience_initial": 4,
  "judicial_patience_minimum_for_strong_win": 2,
  "_doc_patience": "Each ineffective citation costs 1; backfires cost 2. Strong win requires patience >= minimum at remedy; weak win otherwise.",
  "judge_questions": [
    {
      "id": "judge_q_service_doctrine",
      "lines": [
        "Counsel. The service question is procedural. The respondent will argue substituted service was effective. Address."
      ],
      "available_citations": [
        {
          "id": "cite_kpc_135bis_2",
          "label": "Cite KPC Article 135-bis § 2 — invalid service to a non-current address.",
          "required_facts": ["fact_renumbering_2015_on_record"],
          "_doc_required_facts": "Closing citation is unciteable if the Phase 1 fact wasn't established. UI greys out the option and renders a single-line locked tooltip referencing the missing fact by display label.",
          "judgment_id": "kpc_135_bis_2",
          "patience_delta_on_strong": 0,
          "patience_delta_on_weak": -1,
          "patience_delta_on_backfire": -2,
          "outcome_branch_on_success": "round_1_react"
        }
      ]
    }
  ]
}
```

`required_facts` is the load-bearing carry-over. A judgment can sit in the
Casebook and still be unciteable in closing if the underlying fact was
never proved in Phase 1. UI surface: locked citation with a one-line
"You did not establish X with the witness" tooltip; no greying-by-color-only
per accessibility floor.

`outcome_branch_on_success` maps to the existing
`chapter1.casebook_judge_state` enum, so the existing judge react states
fire unchanged.

## State-shape additions (Save migration step)

New top-level dict:

```
"court_facts": {
  "fact_notice_dated_april_8": false,
  "fact_renumbering_2015_on_record": false,
  "fact_landlord_prior_knowledge_returned_letter": false
}
```

One migration step in `save.gd`: declare the dict with default-false keys
for each fact_flag declared across all loaded court_rounds files. The
court-rounds loader walks `data/court_rounds/*.json` at boot, collects
the union of declared fact_flags, and seeds `court_facts` keys if any
new flags appear that the save file doesn't have — a self-bootstrapping
shape that future chapters extend without a new Save version per chapter.
The Save version bump happens once when this dict is first introduced.

## What this proposal does not address

- Wild-argument encounters (permanently out of scope per `PLAN.md`).
- Ally support, stance-flavored move lines (per Proposal 10 v1 cut).
- The Final Printer Chapter 5 encounter (uses the same schema but its
  Phase 1 witness is the printer-system administrator, a recurring NPC
  to be introduced later).
- The Casebook UI itself — `battle_screen.tscn` and `casebook_view.tscn`
  are tracked under PLAN.md step 4 separately.

## Open question for the human

The current `judge_district_ch1.json` has `react_round_*` states that
already vary by `chapter1.client_meeting_stance` (sympathetic /
blunt_procedural / technical) and reference
`chapter1.bonus_evidence_collected` (Wójcik / slip / lease). The Phase
1 fact-flag system above adds a second, finer-grained gating layer.
Two readings:

(a) **Layered.** Stance gates the overall judge tone; fact-flags gate
specific citation availability. Both fire. The bonus_evidence stance
1:1 mapping becomes legacy — it survives Chapter 1 only as the
existing dialogue branches, and Phase 1 in Chapter 2 onward uses
fact_flags exclusively.

(b) **Replaced.** Chapter 1 retains the stance-keyed bonus_evidence
shortcut and skips Phase 1 entirely as a Beat-12 prototype; Chapters
2+ get the full two-phase structure. The existing Halina meeting then
*is* Phase 1, in everything but the runtime location.

Recommendation: (a). It keeps the load-bearing Phase 1 → Phase 2
carry-over discipline canonical from Chapter 1, and the existing
stance variation collapses into a simpler "carrier flavor" that
modifies wording without modifying mechanics. The bonus_evidence
strings remain set; they're just supplementary to the fact_flags the
Phase 1 controller produces.

---

**Suggested next step for the human:** mark this PROPOSAL approved /
rejected / amend at the bottom of `PROPOSALS.md` §10. On approval,
move the schema content into `data/court_rounds/_schema.md` and
greenlight the `battle_controller.gd` skeleton.
