# Court Round Data Schema

_Implements PROPOSALS.md §10 — two-phase Court Round with witness fact-finding
carry-over into closing argument._

Canonical data path: `godot/data/court_rounds/<chapter>_<round>.json`
(e.g. `ch01_round1.json`).

---

## Top-level shape

```json
{
    "version": 1,
    "id": "ch01_round1",
    "chapter": "ch01",
    "round_title": "Defective Service Hearing",
    "judge_id": "judge_district_ch1",
    "opponent_id": "prosecutor_district_ch1",
    "phase1": { ... },
    "phase2": { ... }
}
```

---

## Phase 1 — Witness fact-finding

Goal: establish the fact-flags that Phase 2 citations will be gated against.
One or more witnesses are examined in sequence. The player spends
`witness_cooperation` to press or present evidence. The witness responds,
and if the player's total cooperation spend is sufficient, a fact-flag is
set in `State.data.chapter1`.

```json
"phase1": {
    "witness_cooperation_max": 6,
    "_comment": "Total budget shared across all witnesses. Pressing or presenting evidence costs 1–2 cooperation; running out ends Phase 1 prematurely, potentially leaving fact-flags unset.",
    "witnesses": [
        {
            "id": "court_clerk_ch1",
            "intro_line": "The clerk reads from the service certificate.",
            "options": [
                {
                    "id": "press_address",
                    "label": "Press on the address discrepancy",
                    "cost": 1,
                    "response": "The address on the certificate differs from the client's registered address by two years.",
                    "sets_fact_flag": "fact_address_discrepancy"
                },
                {
                    "id": "present_certificate",
                    "label": "Present the service certificate",
                    "requires_item": "service_certificate",
                    "cost": 1,
                    "response": "Exhibit admitted. The court notes the date of the certificate predates any address update on file.",
                    "sets_fact_flag": "fact_certificate_dated"
                },
                {
                    "id": "press_receipt",
                    "label": "Ask whether receipt was confirmed",
                    "cost": 2,
                    "response": "The clerk cannot confirm signature of receipt at that address.",
                    "sets_fact_flag": "fact_no_receipt_confirmed"
                }
            ]
        }
    ],
    "fact_flags": [
        "fact_address_discrepancy",
        "fact_certificate_dated",
        "fact_no_receipt_confirmed"
    ],
    "_comment_fact_flags": "Every flag listed here may be set by witness options above. Flags not set by the time Phase 1 ends remain false. Phase 2 then checks which flags are true to gate available citations. Only flags in this list are valid — unknown flags are rejected with push_error."
}
```

### Fact-flag rules

- Each fact-flag is a string key. Authoritative list per-round lives in `phase1.fact_flags`.
- Fact-flags are transient to the battle session, **not** persisted to `State.data`. They live in `BattleState` during the encounter. (Exception: the court-win outcome sets `State.data.chapter1.won_court` via the `on_victory` block — see Phase 2.)
- A flag is set at most once; a second option that would set the same flag still costs cooperation but is a no-op on the flag.
- If `witness_cooperation_max` drops to zero mid-witness, the current witness block ends and Phase 2 begins with whatever flags have been set so far.

---

## Phase 2 — Closing argument (mowy końcowe)

Goal: defeat the judge's counter-questions by invoking Casebook principles. Available citations are gated by Phase 1 fact-flags. `judicial_patience` is the
Phase 2 resource — it starts at the value below and decreases with each exchange.

```json
"phase2": {
    "judicial_patience_max": 10,
    "opening_line": "The court has heard the factual record. Counsel for the applicant may address the procedural questions.",
    "counter_questions": [
        {
            "id": "cq_service_technicality",
            "judge_line": "Counsel, service is a procedural formality. The applicant had constructive knowledge of the proceedings.",
            "argument_strength": 4,
            "_comment": "argument_strength is the number of successful citations needed to defeat this counter-question (1 citation = 1 hit). Partial hits reduce it; 0 = question defeated.",
            "citations": [
                {
                    "id": "golder_access_to_court",
                    "requires_fact_flags": [],
                    "judgment": "Golder v. UK",
                    "principle": "Access to Court",
                    "tags": ["echr_6", "access_to_court", "fair_trial"],
                    "effectiveness": "effective",
                    "result_text": "The court acknowledges access to justice is a substantive right, not a technicality.",
                    "judicial_patience_delta": 0
                },
                {
                    "id": "service_address_discrepancy",
                    "requires_fact_flags": ["fact_address_discrepancy"],
                    "judgment": "Procedural Binder — Article 132",
                    "principle": "Correct Address Required",
                    "tags": ["echr_6", "service_of_process", "service_failure"],
                    "effectiveness": "super_effective",
                    "result_text": "Service to a two-year-old address does not constitute proper notice. The argument strength collapses.",
                    "judicial_patience_delta": 0
                },
                {
                    "id": "no_receipt_wrong_angle",
                    "requires_fact_flags": [],
                    "judgment": "Rights Memo — §4 Equality of Arms",
                    "principle": "Equality of Arms",
                    "tags": ["echr_6", "equality_of_arms", "fair_trial"],
                    "effectiveness": "not_very_effective",
                    "result_text": "Equality of arms is relevant but does not directly answer the service-validity question. The judge is not persuaded.",
                    "judicial_patience_delta": -1
                },
                {
                    "id": "wild_swing",
                    "requires_fact_flags": [],
                    "judgment": "Golder v. UK",
                    "principle": "Practical Rights",
                    "tags": ["echr_13", "effective_remedy", "access_to_court"],
                    "effectiveness": "backfires",
                    "result_text": "Counsel has cited a general effectiveness doctrine where a specific address error is required. The judge's patience diminishes.",
                    "judicial_patience_delta": -2
                }
            ]
        }
    ],
    "victory_threshold": {
        "strong_win": 2,
        "_comment": "Number of counter-questions defeated with only super_effective or effective hits. Fewer = weak_win. None = loss.",
        "weak_win": 1
    },
    "outcomes": {
        "strong_win": {
            "result_text": "The court grants the procedural reset. The hearing is rescheduled.",
            "on_victory": [
                { "set": "chapter1.won_court", "value": true },
                { "set": "chapter1.court_outcome", "value": "procedural_reset" }
            ]
        },
        "weak_win": {
            "result_text": "The court grants a limited reset with reservations. The hearing continues with conditions.",
            "on_victory": [
                { "set": "chapter1.won_court", "value": true },
                { "set": "chapter1.court_outcome", "value": "conditional_reset" }
            ]
        },
        "loss": {
            "result_text": "The court denies the procedural objection. Judicial patience was exhausted.",
            "on_defeat": [
                { "set": "chapter1.won_court", "value": false },
                { "set": "chapter1.court_outcome", "value": "denied" }
            ]
        }
    }
}
```

### Effectiveness enum

| Value | Persuasive Force | Judicial Patience delta (if not overridden) |
|---|---|---|
| `super_effective` | −2 argument_strength | 0 |
| `effective` | −1 argument_strength | 0 |
| `not_very_effective` | −0 argument_strength | −1 |
| `no_effect` | −0 argument_strength | −1 |
| `backfires` | −0 argument_strength | −2 |

Per-citation `judicial_patience_delta` overrides the default above. Use positive
values to reward particularly well-chosen moves if desired (rare).

### Tag matching (authoritative rule)

Effectiveness is NOT computed dynamically from tags in Phase 2. The
`effectiveness` field is authored directly on each citation in the data file.
The `tags` array is metadata for tooling, search, and future wild-argument
encounters (where the Effectiveness Resolver computes from tags). In Court
Rounds the author controls every valid citation per counter-question — the
authored value is final.

---

## BattleState keys (runtime, not persisted)

`battle_controller.gd` maintains a `BattleState` dictionary during the encounter:

```
witness_cooperation_remaining: int      # starts at phase1.witness_cooperation_max
active_fact_flags: Dictionary[String, bool]  # keyed to phase1.fact_flags; all start false
judicial_patience_remaining: int        # starts at phase2.judicial_patience_max
current_phase: int                      # 1 or 2
current_witness_index: int              # Phase 1 only
current_cq_index: int                   # Phase 2 only
cq_argument_strengths: Dictionary[String, int]  # id → remaining strength per CQ
```

None of these are written to `State.data` until the `on_victory` / `on_defeat`
block fires at the end of Phase 2.

---

## Authoring checklist

Before shipping a new `<chapter>_<round>.json`:

- [ ] All `requires_fact_flags` values are listed in `phase1.fact_flags`.
- [ ] At least one citation per counter-question has `requires_fact_flags: []` (always available, prevents a lock-out if Phase 1 goes badly).
- [ ] At least one `super_effective` citation exists per counter-question and requires a Phase 1 flag (rewards thorough fact-finding).
- [ ] `on_victory` sets `chapter1.won_court` appropriately (unless the round is non-decisive).
- [ ] `judicial_patience_max` is calibrated so a careless player can lose without grinding through all counter-questions.
