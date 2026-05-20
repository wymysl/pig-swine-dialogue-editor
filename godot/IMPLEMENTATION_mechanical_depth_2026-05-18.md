# Implementation Plan — Mechanical-Depth Proposals

Operational counterpart to `PROPOSAL_mechanical_depth_2026-05-18.md`. Covers the four items marked **DEVELOP**: §A Trial Record panel (proposal #2), §B Three Phase 1 junior signatures (proposal #6), §C Filable incapacity fallback with relational cost (proposal #4), §D Coffee buff with court-side consequence (proposal #3). Items marked **CUT** (#1, #5) are not in this plan.

The four items are sized for one extended sprint of work combined, distributed across the existing Sprints 4–6 of `PLAN.md` §Vertical slice plan. Two of them (§A and §B) can run in parallel because they touch disjoint files. The other two are sequential dependents.

Authoring discipline follows the existing two-pass split (Code owns ids, predicates, resolver logic, save migrations, tests; Design owns player-facing text, `_status_note` fields, voice-pack lines). Every save-state change requires `SAVE_VERSION` bump, default declarations in `State.reset_state()`, a migration function in `save.gd`, and a `tests/test_save_load.gd` test that asserts `SAVE_VERSION >= N` per the memory pattern.

---

## §A. Trial Record panel (proposal #2)

A Phase 2 UI affordance that surfaces, when the closing round opens, the live Phase 1 fact-flags and the citations they unlocked, against the citations that remain locked because the underlying fact was not established. Pure UI; no schema, no new mechanics.

**Files touched.** `scenes/ui/battle_screen.tscn` adds one panel node tree (collapsible, opens on Phase 2 entry, toggleable with `T`). `scripts/ui/battle_screen.gd` adds `_build_trial_record_panel()` and `_refresh_trial_record_panel()` methods, called from the existing Phase 2 entry hook and on every `_refresh_state()` tick. `data/court_rounds/chapter1_round_1.json` is read but not modified — the panel renders from existing data.

**Data sources.** Two reads off the in-flight `BattleController` instance: (1) the Phase 1 controller's `established_evidence_ids` dictionary and the resolved `_fact.*` and `chapter1.*` flags written during Phase 1; (2) the Phase 2 controller's `_evaluate_citation_availability()` projection across `phase_2_closing.judge_counter_questions[].available_citations[]`, partitioned into available / locked-by-missing-fact / locked-by-frame.

**Code work.**
- Add `BattleController.get_trial_record_snapshot() -> Dictionary` returning `{ established_facts: Array, locked_facts: Array, available_citations: Array, locked_citations: Array }` with each entry carrying `id`, `display_name`, and (for locked entries) a `reason` string (`"fact_missing:_fact.address_renumbered"`, `"frame_gate:merits_defence"`).
- Add `scripts/ui/trial_record_panel.gd` as a small Control script attached to the new panel. Reads the snapshot on `visibility_changed` and on each `BattleController` `phase_state_changed` signal.
- Add `signal phase_state_changed` to `BattleController` if absent (audit first — `signals.gd` may already declare a related signal).
- `T` keybinding added to `project.godot` input map as `toggle_trial_record`.

**Design work.** Write display labels for fact-flag ids (the player should see "Service to current address" rather than `_fact.address_renumbered`). Authored in a new small file `data/court_rounds/_trial_record_labels.json` keyed by flag id, with one entry per `_fact.*` and `chapter1.*` flag referenced by `chapter1_round_1.json`. One line per flag, plus a one-line reason template per lock category. Roughly 20–30 entries for Chapter 1.

**Tests.** `tests/test_battle.gd` grows three cases: snapshot returns the established facts after a successful press; snapshot returns the locked-by-fact reason for citations whose `requires_fact_flags` were not set; snapshot returns the locked-by-frame reason when a citation is gated by an unselected frame. No save-migration test needed (no save shape change).

**Save-state implications.** None. Trial Record state is computed from existing data on demand.

**Accessibility.** Panel uses the existing UI font and palette. Each entry carries both a color indicator (green/red) and a text label for the available/locked state (per `PLAN.md` §Standing decisions: no information conveyed by color alone).

**Effort.** ~1 sprint-day for Code (controller method + UI script + signal); ~½ day for Design (label file); ~½ day for QA (tests + WCAG check). Lands inside Sprint 5.

**Acceptance criteria.** Entering Phase 2 in `chapter1_round_1` shows the panel with at least one established fact, at least one locked citation with a readable reason, and no labels rendered as raw flag ids. Toggling the panel does not advance the round or consume `judicial_patience`.

---

## §B. Three Phase 1 junior signatures (proposal #6)

Three keyed press-option types in Phase 1 witness sub-rounds, one per recruited junior. Crab surfaces factual-defects presses; Whimsy surfaces rhetorical-reframe presses with `judicial_patience` cost-on-failure; Murrow is a passive re-anchor that surfaces during Phase 2 patience troughs.

**Files touched.** `data/court_rounds/chapter1_round_1.json` Phase 1 block grows new press_option entries with `requires_flag` gates. `scripts/systems/battle/battle_controller.gd` PhaseOneController grows a press-resolver branch that handles the new option subtypes. `scripts/systems/battle/battle_controller.gd` PhaseTwoController grows a `murrow_anchor_check()` invoked on patience-delta. `scripts/autoload/state.gd` adds three flags. `data/dialogues/halina.json` and (if witnesses are voiced through dialogue) related witness files grow flavor lines for the press follow-ups.

**Schema changes.**
- New optional `press_options[].subtype` field accepting `"crab_factual_defect"`, `"whimsy_reframe"`, or omitted (default press). Documented in `data/court_rounds/_schema.md`.
- New optional `press_options[].requires_flag` predicate string using existing predicate syntax (`chapter1.crab_recruited`, etc.). Already documented as a general predicate convention — extend the schema doc to make explicit it applies to press_options.
- For Whimsy: new `press_options[].judicial_patience_delta_on_fail` integer (negative). Costs come due in Phase 2's initial patience pool — bookkeeping handled by carrying a `phase_1_patience_debit` accumulator into Phase 2 start.

**Save-state implications.** `SAVE_VERSION` bumps to 21. New flags in `state.gd`:
- `chapter1.crab_active` (bool, default false). Set when `crab_recruited` AND `incapacity_filed != true` (see §C).
- `chapter1.whimsy_active` (bool, default false). Set when `whimsy_recruited` AND no withdrawal flag is set.
- `chapter1.murrow_anchor_used` (bool, default false). Set when Murrow's one-shot Phase 2 re-anchor fires.
- `chapter1.phase_1_patience_debit` (int, default 0). Accumulator carried from Phase 1 to Phase 2.

Migration in `save.gd::_migrate_to_21()`: declare each new key with its default for any save loaded at SAVE_VERSION < 21.

**Code work.**
- `PhaseOneController._apply_press()` (extend existing) — read `press_options[i].subtype`. For `crab_factual_defect`, require `chapter1.crab_active`; on success, set the listed `fact_flags_set` per usual. For `whimsy_reframe`, require `chapter1.whimsy_active`; on a successful reframe (resolved by the existing effectiveness resolver against the witness statement's tags), set the listed `fact_flags_set` AND increase `witness_cooperation` payoff by 1; on failure, debit `phase_1_patience_debit` by the option's `judicial_patience_delta_on_fail`.
- `PhaseTwoController.start()` (extend existing) — read `chapter1.phase_1_patience_debit` and subtract from `initial_patience` after frame override applied. Document the order-of-operations in the controller header comment.
- `PhaseTwoController.murrow_anchor_check(current_patience: int) -> int` — new method. When `chapter1.murrow_recruited == true` AND `chapter1.murrow_anchor_used == false` AND `current_patience` drops below 2, restore patience to 3 and set `murrow_anchor_used = true`. Returns the post-anchor patience. Called from the existing patience-delta application path.
- `scripts/autoload/signals.gd` adds `signal murrow_anchor_fired` for UI hook.
- `BattleScreen` listens for `murrow_anchor_fired` and renders a one-shot Murrow portrait + flavor line. UI work is small.

**Data work.**
- `chapter1_round_1.json` Phase 1: add 1 Crab subtype press per witness statement where a factual defect is plausible (address/renumbering, doręczenie zastępcze posture, lease countersignature — these are already canon facts from `story.txt`). Approximately 3 new press options total.
- `chapter1_round_1.json` Phase 1: add 1 Whimsy subtype reframe per witness, gated by statements whose tags Whimsy's rhetorical-framing voice plausibly targets. Approximately 2–3 new press options total.
- Witness `cooperation_budget` adjusted upward to accommodate the new options without making the round trivially winnable — Code reviews the math during the Code pass.

**Design work.** Per `data/court_rounds/_schema.md` two-pass authoring discipline, Design writes `follow_up_text`, `_status_note`, and any Phase 2 flavor lines for the Murrow anchor moment. The three signatures have distinct voice-pack constraints:
- Crab presses use the technical/stance-trio register (per `style_canon.txt` §2).
- Whimsy reframes use the Rumpole-rhetorical register and should *land sideways* on the procedural facts they're reframing — that is, the reframe is rhetorical packaging of a procedural truth, never a rhetorical substitute for a missing fact.
- Murrow's re-anchor line is one Mrożek-register beat per `style_canon.txt` §2 character push.

Voice-pack audit required per the standard discipline; `tools/voice_audit.py` runs after Design pass.

**Tests.** `tests/test_battle.gd` grows: Crab press fires only when `crab_active` is set; Whimsy reframe success increases witness_cooperation; Whimsy reframe failure debits `phase_1_patience_debit` and reduces Phase 2 starting patience; Murrow anchor fires once at the right threshold and not again. `tests/test_save_load.gd` adds a SAVE_VERSION-20 fixture migrated to 21 and asserts the four new flags exist at defaults. The T1 assertion follows the `SAVE_VERSION >= 21` pattern per the migration-test memory.

**Effort.** ~2–3 sprint-days for Code (controller extensions + migration + tests); ~1 day for Design (8 press-options + Murrow flavor lines); ~½ day for QA (regression on existing Phase 1 flow). Lands inside Sprint 4.

**Acceptance criteria.** With all three juniors recruited, the player has at least 3 extra Crab presses available across the witness round, 2–3 Whimsy reframes (some risky), and Murrow's anchor fires at most once. With Crab not recruited, his presses are not visible. With incapacity filed (see §C), `crab_active` is false and his presses disappear mid-round.

---

## §C. Filable incapacity fallback with relational cost (proposal #4)

The player can file the incapacity argument as a Phase 2 frame and pay for it in relational cost: Halina trust drops below the reveal threshold, the high-trust bonus-evidence path locks, and Crab withdraws (his Phase 1 presses disappear for the rest of the round). The case remains winnable on the procedural reset.

Depends on §B for Crab's withdrawal mechanic (`crab_active` flag drives press visibility).

**Files touched.** `data/argument_frames_ch1.json` upgrades the existing `incapacity_defense` decoy to a *real, filable* frame (currently treated as a decoy frame per `battle_controller.gd::DECOY_FRAME_PRIORITY`). `data/court_rounds/chapter1_round_1.json` Phase 2 `frame_gates` adds an `incapacity_defense` entry. `data/dialogues/halina.json` adds one new state at `chapter1.halina_trust <= 1`. `data/dialogues/crab.json` adds one withdrawal line keyed to `chapter1.incapacity_filed`. `scripts/autoload/state.gd` adds flags. `scripts/systems/battle/battle_controller.gd` modifies the decoy/frame resolver to treat `incapacity_defense` as filable rather than auto-blunder.

**Schema changes.** `argument_frames_ch1.json::incapacity_defense` gets `well_fitted: true` (currently absent; that field is what gates filability per the controller), `supporting_evidence` populated with whatever Phase 1 fact-flags the filed frame can legitimately consume, and a new `relational_cost` block:
```
"relational_cost": {
  "sets": [
    { "path": "chapter1.incapacity_filed", "value": true },
    { "path": "chapter1.halina_trust", "value": 0 },
    { "path": "chapter1.crab_active", "value": false }
  ]
}
```
The `relational_cost` block is a new schema concept; document in `data/court_rounds/_schema.md` and in `argument_frames_ch1.json`'s implicit schema (no schema file exists for argument_frames yet — add one as part of this work).

**Save-state implications.** `SAVE_VERSION` bumps to 22 (after §B's 21). New flag:
- `chapter1.incapacity_filed` (bool, default false). Read by `battle_controller.gd` to drive the decoy-vs-real-frame branch; read by `halina.json` and `crab.json` for dialogue gating.

The existing `chapter1.halina_trust` (int, declared at SAVE_VERSION 11) is overwritten by the relational cost; no schema change.

Migration: `_migrate_to_22()` declares `incapacity_filed = false` for any save loaded below 22.

**Code work.**
- `BattleController._resolve_decoy_frame()` (or wherever `DECOY_FRAME_PRIORITY` is consumed) — split logic so that `incapacity_defense` checks `well_fitted` and `relational_cost`. If `well_fitted == true`, treat as a real frame selection: apply `relational_cost.sets` to `State.data.chapter1`, then enter Phase 2 with the frame's `judicial_patience_start` and `supporting_evidence`. Other entries in `DECOY_FRAME_PRIORITY` retain their existing wrong-shape behavior.
- After applying `relational_cost`, emit `signals.halina_trust_changed` (audit `signals.gd` for an existing equivalent) so the existing trust-meter UI updates.
- The `crab_active = false` write should propagate to the live Phase 1 controller mid-round if the player is still in Phase 1 when filing happens. Audit: filing is a Phase 2 action; Phase 1 is closed by the time it fires. Confirm by reading the existing frame-selection entry point. If filing can only happen at Phase 1 → Phase 2 transition, this is automatic; if filing can happen mid-Phase-1 (e.g., as a press option), redesign the timing.

**Design work.**
- One new Halina state at `chapter1.halina_trust <= 1 && chapter1.incapacity_filed == true`: the canonical client-reaction line "The case is not about whether I can read." Plus a 1–2 line follow-up that closes the bonus-evidence path. Voice per `style_canon.txt` Halina register. State must include the existing Halina state structure (id, trigger, text, options).
- One new Crab line at `chapter1.incapacity_filed == true && chapter1.crab_recruited == true`: a short withdrawal beat, cold/professional. Crab does not lecture.
- One adjustment to the Day-One Summary text in `chapter1.json` `summary_text_branches`: a variant for the incapacity-filed branch that lands without catharsis, in the Kundera register (per `style_canon.txt` §2 character push).
- Voice-pack audit per the standard discipline.

**Tests.** `tests/test_battle.gd` grows: filing `incapacity_defense` sets all three `relational_cost` flags; with `incapacity_filed == true`, Crab's Phase 1 presses are not surfaced if a subsequent Phase 1 sub-round runs (audit whether Phase 2 → Phase 1 re-entry exists — likely not in Ch1); the procedural-reset citation set remains available in Phase 2 for the player who filed. `tests/test_save_load.gd` adds SAVE_VERSION-21 → 22 migration test asserting `incapacity_filed` exists at default false. The trust-meter regression suite (Session 29 era) re-runs to confirm the trust-≤-1 state fires correctly.

**Effort.** ~1.5 sprint-days for Code (frame upgrade + resolver branch + migration + tests); ~1 day for Design (Halina state + Crab withdrawal + summary variant + audit); ~½ day for QA. Lands inside Sprint 4–5, after §B.

**Acceptance criteria.** A player who reaches Phase 2 with `incapacity_defense` available as a frame option can file it; on filing, Halina trust drops to ≤ 1, the bonus-evidence path locks, Crab's Phase 1 presses no longer surface, the case is still winnable via the procedural-reset citation chain, and the Day-One Summary renders the incapacity-filed variant.

---

## §D. Coffee buff with court-side consequence (proposal #3)

A bounded extension of the existing `chapter1.coffee_buff` such that S/A-grade brews unlock a small Phase 2 cushion on one citation, and D/F-grade brews debit `judicial_patience` once on the first weak move. Cosmetic flavor accompanies both. No content is gated; no progress is blocked.

Optional dependency on §B for richer Whimsy-keyed flavor; ships independently with a generic move-variant cushion if §B is not landed.

**Files touched.** `scripts/systems/battle/battle_controller.gd` PhaseTwoController gains a small buff-application step at `start()`. `data/judgments.json` `procedural_reset_ch1.principle_moves[]` gains one optional `coffee_buff_variant` field on the move most plausibly affected (Code chooses; the move keyed to procedural-math rhetoric is the natural target). `data/dialogues/cula.json` and/or `data/dialogues/whimsy.json` gain 1–2 brew-grade-keyed flavor lines for the court entry beat. `data/court_rounds/chapter1_round_1.json` is read; not modified.

**Schema changes.** New optional `principle_moves[].coffee_buff_variant` block on `data/judgments.json`:
```
"coffee_buff_variant": {
  "high_grade": { "flavor_line": "...", "judicial_patience_bonus": 1 },
  "low_grade": { "flavor_line": "...", "judicial_patience_debit": 1 }
}
```
At most one move per judgment carries this. Optional, ignored if absent.

**Save-state implications.** None. The existing `chapter1.coffee_buff` / `chapter1.coffee_brew_grade` flags (SAVE_VERSION 9) carry the necessary information. No SAVE_VERSION bump.

**Code work.**
- `PhaseTwoController.start()` reads `State.data.chapter1.coffee_buff` and `coffee_brew_grade` after frame override applied and after `phase_1_patience_debit` subtraction (§B). Maps `procedurally_alert_plus` and `procedurally_alert` to high_grade; `over_caffeinated` to low_grade; `caffeinated` and empty to neutral.
- The bonus / debit is applied not to starting patience but to the *specific move* via a flag on the move's `judicial_patience_delta_on_hit` (bonus) or via a one-shot `_coffee_low_grade_pending` accumulator that triggers on the first move whose effectiveness bucket is `not_very_effective` or `no_effect` (debit).
- Flavor line surfaced through the existing `BattleScreen` flavor channel when the variant fires.

**Design work.** Per affected judgment move: one `high_grade.flavor_line` (Whimsy-flavored if §B is in; otherwise Cula-internal-monologue register) and one `low_grade.flavor_line` (Mrożek register, cosmetic, ends the brew joke). Both pass Taste Standard. Roughly 4 lines total. Voice-pack audit per the standard discipline.

**Tests.** `tests/test_battle.gd` grows: with `coffee_brew_grade == "procedurally_alert_plus"`, the affected move's hit-delta increases by 1; with `coffee_brew_grade == "over_caffeinated"`, the first weak-bucket move debits patience by 1, and the debit fires at most once per round; with `coffee_brew_grade == ""` or `"caffeinated"`, no buff-keyed deltas fire. No save-migration test.

**Effort.** ~½ sprint-day for Code (controller hook + flag plumbing); ~½ day for Design (4 lines + audit); ~¼ day for QA. Lands inside Sprint 6 (Polish + writing pass).

**Acceptance criteria.** A player who brewed S-grade and reaches Phase 2 sees a one-line flavor beat and gains a +1 cushion on a single citation; a player who brewed F-grade sees a one-line flavor beat and loses 1 patience on their first weak move; a player who skipped coffee sees no buff-keyed flavor. None of these conditions change the win/weak-win threshold.

---

## Sequencing and parallelism

Two work-tracks can run in parallel from Sprint 4:

**Track 1 — UI.** §A Trial Record panel. Touches `battle_screen.gd`, `signals.gd`, and one new label file. Reads existing battle controller state; no schema bumps. Independent of all other items. Ships first because it has the smallest blast radius and unblocks Design feedback on Phase 2 readability before the other items land.

**Track 2 — Mechanics.** §B → §C → §D, sequential.
- §B introduces three new press subtypes, four new flags, SAVE_VERSION 21, and the patience-debit carry-over.
- §C upgrades the incapacity frame and adds the `incapacity_filed` flag (SAVE_VERSION 22). Depends on §B for the `crab_active` semantics used by the relational cost.
- §D layers grade-keyed bonuses on top of the now-stable Phase 2 entry path. No save bump.

Total estimated effort across both tracks: ~6 sprint-days Code, ~3 days Design, ~1.5 days QA. Distributed across Sprint 4 (§B), Sprint 4–5 boundary (§A in parallel, §C), Sprint 6 (§D).

## Prerequisites

Before any of the four items lands:

- Confirm `data/court_rounds/chapter1_round_1.json` is structurally complete per `_schema.md` (Code pass done, even if some `DESIGN_TODO` placeholders remain).
- Confirm `data/argument_frames_ch1.json` schema is documented well enough to extend (currently implicit; this work adds the explicit schema as part of §C).
- Confirm `signals.gd` does not already declare colliding signal names (`phase_state_changed`, `murrow_anchor_fired`, `halina_trust_changed` — audit and reuse if equivalents exist).
- Confirm the trust-meter regression suite (Session 29) is still green at HEAD before §C touches the meter.

## Authoring discipline summary

| § | Item | Code work | Design work | Save bump | Tests | Sprint |
|---|---|---|---|---|---|---|
| A | Trial Record panel | Snapshot method + UI script + signal | Label file (~25 entries) | none | 3 battle cases | 5 |
| B | Junior signatures | Press subtypes + Murrow anchor + migration | 8 press lines + Murrow beat | v21 | Battle + migration | 4 |
| C | Filable incapacity | Frame upgrade + resolver branch + migration | Halina state + Crab line + summary variant | v22 | Battle + migration + trust regression | 4–5 |
| D | Coffee court-side | Buff hook + flag plumbing | 4 flavor lines | none | 3 battle cases | 6 |

## Status

Drafted 2026-05-18 in Cowork as a follow-up to `PROPOSAL_mechanical_depth_2026-05-18.md`. Not yet integrated into `SPRINT_LOG.md` planning. Recommended next step: promote §A–§D into PROPOSALS.md as numbered entries (§§12–15), then schedule §B as the next Code-owned sprint after the current Chapter 1 court-round Code pass completes.
