# Chapter 2 — Court Round 1 schema-stub (design-only)

**Status:** DRAFT — gated on F1 closure (DESIGN_TODO inventory in
`chapter1_round_1.json`). Do not author the live file
(`godot/data/court_rounds/chapter2_round_1.json`) until F1 is at zero.

**Source canon:** `story.txt` §"Beat 14 — Housing Court sequence" /
"Court Round 1 — Was there a clear legal basis for eviction?" (lines
~2483–2520). `story.txt` is read-only per CLAUDE.md.

**Schema authority:** `godot/data/court_rounds/_schema.md`. Round 1 of
Ch2 is the first encounter to consume Ch2 taxonomy tags, so the taxonomy
v2 trim in `tag_taxonomy.json` will need a Ch2 extension pass before this
file lands.

This stub is structure-only. Every Design field is `DESIGN_TODO` per the
two-pass discipline.

---

## Top-level metadata

```text
version            : 1
id                 : "chapter2_round_1"
chapter            : 2
opponent_id        : "landlord_counsel_ch2"   # not yet in argument_opponents.json
judgment_unlock    : "rule_clarity_ch2"       # new judgment, not yet in judgments.json
_status            : "Stub; gated on Ch1 F1 closure."
```

## Open data dependencies (must exist before this file loads)

- `data/argument_frames_ch2.json` — new file. Working frame ids:
  `rule_vagueness`, `overbreadth`, `arbitrary_enforcement`, `merits_defence`.
- `data/argument_opponents.json::landlord_counsel_ch2` — three court rounds,
  one moves[] entry per Ch2 round.
- `data/evidence_ch2.json` — must declare `building_rules_extract` and
  `eviction_notice` as `collected:false, chapter:2` entries with
  argument_tags `["rule_problem", "notice_problem"]`.
- `data/judgments.json::rule_clarity_ch2` — principle_moves[] for citation
  ids referenced below.
- `data/tag_taxonomy.json` — Ch2 tag extension. Working additions:
  - principle: `rule_clarity`, `vagueness`, `overbreadth`,
    `arbitrary_enforcement`, `equal_treatment`, `housing_proportionality`
  - article: `echr_8` (home/private life), `pl_const_75` (housing),
    `pl_const_32` (equal treatment)
  - context: `housing_eviction`, `building_regulation`, `expressive_conduct`
- `state.gd` — declare `chapter2.round1_rule_argument_won` (default false);
  SAVE_VERSION bump + migration test.

## phase_1_fact_finding

### action_costs
Match Ch1: `press: 1`, `present: 1`, `present_bonus: 0`.

### witness_cooperation_total
Target: **6** (one above Ch1's 5; Ch2 is longer, three rounds, more
investigation runway). Distributes across the three witnesses below.

### local_fact_flags
Round 1 is rule-basis. Flags surface evidence that the eviction rule is
vague / overbroad / arbitrarily applied.

| flag id | resolution_weight | set_by (witness.statement.action) |
|---|---|---|
| `_fact.rule_text_undefined_dignity` | primary | `administrator_beton.rule_recitation.press_define_dignity` |
| `_fact.no_published_examples` | primary | `administrator_beton.rule_history.press_prior_enforcement` |
| `_fact.poster_unique_target` | primary | `zielinska.neighbor_observations.present_other_posters_photo` |
| `_fact.rule_amended_post_hoc` | bonus | `kowalski.notice_board_recollection.present_amendment_log` |

All Ch2 fact flags carry article_tags `[echr_8, pl_const_75]` and
principle_tags drawn from the Ch2 taxonomy extension above. Context tags:
`[housing_eviction, building_regulation]`. Bonus flag uses
`available_when: !_fact.rule_amended_post_hoc` and costs 0 to present.

### witnesses

Three witnesses, ordered by docket position. All `display_name` and
statement `text` slots are `DESIGN_TODO`.

```text
1. administrator_beton  (cooperation_budget: 3)
   _status_note: bureaucratic antagonist; speaks in passive voice;
   produces the rule text on demand but resists definitional pressure.
   Voice ref: dialogue_samples_administrator_beton_landlord_representative.jsonl.
   Statements:
     rule_recitation       (article: pl_const_75; principle: rule_clarity)
       press_define_dignity     -> rule_definition_pressed
         fact_flags_set: [_fact.rule_text_undefined_dignity]
       press_who_drafted        -> rule_drafting_pressed
       present_rule_extract     evidence_id: building_rules_extract
         fact_flags_set: []     (no flag — locks the text as in-record)
         judge_reaction: DESIGN_TODO
     rule_history          (article: pl_const_32; principle: arbitrary_enforcement)
       press_prior_enforcement  -> history_admitted_thin
         fact_flags_set: [_fact.no_published_examples]
       present_eviction_notice  evidence_id: eviction_notice

2. kowalski             (cooperation_budget: 2)
   _status_note: comic witness; "no real disturbance" register; literal,
   wandering. Voice ref: dialogue_samples_kowalski.jsonl.
   Statements:
     notice_board_recollection  (principle: rule_clarity, equal_treatment)
       press_when_did_rule_change -> rule_change_admitted
       present_amendment_log     evidence_id: building_rules_extract
         available_when: "_fact.rule_text_undefined_dignity"
         cost: 0   (bonus present)
         fact_flags_set: [_fact.rule_amended_post_hoc]

3. zielinska            (cooperation_budget: 1)
   _status_note: practical witness; targeted-enforcement angle from the
   ground floor. Voice ref: dialogue_samples_zielinska.jsonl.
   Statements:
     neighbor_observations      (principle: equal_treatment, arbitrary_enforcement)
       press_other_residents_posters -> other_posters_acknowledged
         fact_flags_set: [_fact.poster_unique_target]
       present_other_posters_photo   evidence_id: poster_photo
         fact_flags_set: [_fact.poster_unique_target]
         (single-flag dual-source — either press OR present satisfies it)
```

Total witness statements: 4. Press paths: 5. Present paths: 4 (one bonus).

## phase_2_closing

### judicial_patience_default
Same as Ch1: **5**. `merits_defence` frame overrides to **3** (canonical
penalty for arguing merits when a procedural lane exists — but in Ch2
Round 1 the "procedural" lane is rule clarity, not service of process).

### frame_gates

```text
rule_vagueness          patience_start: 5  available: [jq_rule_text, jq_dignity_definition]
overbreadth             patience_start: 5  available: [jq_rule_text, jq_scope]
arbitrary_enforcement   patience_start: 5  available: [jq_scope, jq_targeted_enforcement]
merits_defence          patience_start: 3  available: [jq_rule_text]   # punished
```

### judge_counter_questions

Four questions, ordered. All `text`, `_status_note` close, `defeat_lines`,
`partial_lines` are `DESIGN_TODO`.

```text
jq_rule_text
  opponent_pressure_move: landlord_counsel_ch2.r1.assert_rule_clarity
  article_tags: [pl_const_75]
  principle_tags: [rule_clarity, vagueness]
  pressure_weakness_tags: {rule_clarity: 0.6, vagueness: 0.4}
  pressure_strength_tags: {discretion: 0.5, deference: 0.5}
  requires_fact_flags: [_fact.rule_text_undefined_dignity]
  available_citations:
    - move_id: motion_void_for_vagueness
      tags: weighted {vagueness: 0.7, rule_clarity: 0.3}
      hit: +2  miss: -1  backfire: -2
    - move_id: cite_constitutional_clarity
      tags: weighted {rule_clarity: 0.6, legal_certainty: 0.4}
      hit: +1  miss: -1  backfire: -2

jq_dignity_definition
  opponent_pressure_move: landlord_counsel_ch2.r1.invoke_dignity_norm
  article_tags: [pl_const_75]
  principle_tags: [vagueness, rule_clarity]
  pressure_weakness_tags: {vagueness: 1.0}
  requires_fact_flags: [_fact.rule_text_undefined_dignity, _fact.no_published_examples]
  available_citations:
    - move_id: motion_void_for_vagueness
    - move_id: cite_no_definitional_anchor

jq_scope
  opponent_pressure_move: landlord_counsel_ch2.r1.assert_narrow_application
  article_tags: [pl_const_32, echr_8]
  principle_tags: [overbreadth, equal_treatment]
  pressure_weakness_tags: {overbreadth: 0.6, equal_treatment: 0.4}
  requires_fact_flags: [_fact.poster_unique_target]
  available_citations:
    - move_id: motion_overbreadth
    - move_id: cite_equal_treatment_breach

jq_targeted_enforcement
  opponent_pressure_move: landlord_counsel_ch2.r1.assert_neutral_enforcement
  article_tags: [pl_const_32]
  principle_tags: [arbitrary_enforcement, equal_treatment]
  pressure_weakness_tags: {arbitrary_enforcement: 1.0}
  requires_fact_flags: [_fact.poster_unique_target, _fact.no_published_examples]
  available_citations:
    - move_id: motion_arbitrary_enforcement
    - move_id: cite_uniform_application_violated
```

### victory_resolution

Mirrors Ch1's blunder-first evaluation order.

```text
evaluation_order: [blunder_recovered, narrow_victory, standard_victory, strong_victory]
primary_fact_flags: [_fact.rule_text_undefined_dignity, _fact.no_published_examples, _fact.poster_unique_target]

branches:
  blunder_recovered     when: "judicial_patience <= 1 && primary_fact_count >= 1"
                        sets: chapter2.round1_rule_argument_won = true
                              chapter2.round1_outcome = "blunder_recovered"
  narrow_victory        when: "primary_fact_count == 1 && judicial_patience >= 2"
                        sets: chapter2.round1_rule_argument_won = true
                              chapter2.round1_outcome = "narrow"
  standard_victory      when: "primary_fact_count == 2"
                        sets: chapter2.round1_rule_argument_won = true
                              chapter2.round1_outcome = "standard"
  strong_victory        when: "primary_fact_count >= 3 && bonus_fact_count >= 1"
                        sets: chapter2.round1_rule_argument_won = true
                              chapter2.round1_outcome = "strong"
```

`bonus_fact_count` counts how many `bonus`-weight flags in
`local_fact_flags` are set at resolution time. Strong requires the
amendment-log bonus.

---

## What is intentionally NOT in this stub

- Round 2 (factual basis) and Round 3 (proportionality). Separate files
  per `_schema.md §Naming Convention`: `chapter2_round_2.json`,
  `chapter2_round_3.json`.
- Evidence Board scoring. Ch2's headline new system; not a court-round
  schema concern — lives in its own data + controller.
- Crab / Whimsy support lines. Those are dialogue states, not court-round
  data.
- Voice work. Three witnesses above already have voice reference JSONLs;
  Phase 7 voice pass is unblocked once the round-file lands.

## Open design questions before authoring the real file

1. Does Ch2's `merits_defence` penalty (`patience_start: 3`) match Ch1's,
   or do we want a Ch2-specific re-tuning given the three-round structure?
2. Should the `_fact.poster_unique_target` dual-source pattern (set by
   either press OR present on the same witness) become a schema-level
   convention? `_schema.md` is currently silent on multi-source flags.
3. Does Ch2 grant a procedural reset as floor (mirroring Ch1's
   `procedural_reset_ch1`) or does Ch2 require winning the round on the
   merits to set `round1_rule_argument_won`? Story §"Victory states" implies
   the latter, but `_status_note` should call this out explicitly.
4. Is `landlord_counsel_ch2` the same opponent entity as `attorney_grzyb`,
   or are they separate (Grzyb being the in-court advocate, the
   "landlord_counsel_ch2" being the opponent-id for the schema-side moves
   collection)? Cross-reference with `argument_opponents.json` naming.

End of stub. Real file authoring waits on F1 closure and on the four
open data dependencies above.
