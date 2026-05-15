# Court Rounds Schema

## Purpose

A `data/court_rounds/<chapter>_<round>.json` file is the authoritative data contract for one court encounter. `battle_controller.gd` reads it to run the two-phase court flow defined in `PROPOSALS.md` section 10, and the file follows the same two-pass discipline used for `data/judgments.json`: Code fills structure first, then Design fills player-facing text.

## Two-Block Structure

Every court-round file has one top-level metadata section plus two required blocks:

- `phase_1_fact_finding` - witness examination, Press/Present options, `witness_cooperation` budgets, and transient fact flags.
- `phase_2_closing` - judge counter-questions, frame-gated citations, `judicial_patience` deltas, and calibrated victory resolution.

`PROPOSALS.md` section 10 is the authority for this split. If a loader or seed file disagrees, the proposal wins.

## Predicate Syntax

Any predicate or gate stored as a string uses the same lightweight syntax as `DialogueRunner._evaluate_trigger`:

- `&&` and `||` for boolean composition.
- `==` and `!=` for equality.
- `>=` and `<=` for integer comparisons.
- Bare paths for truthy checks and `!path` for falsy checks.
- No parentheses.

These strings are data predicates, not embedded GDScript.

## Phase 1 Block Schema

- `action_costs` - object, Code. Canonical costs for `press`, `present`, and any explicit zero-cost bonus-present path.
- `witness_cooperation_total` - integer, Code. Sum of every witness `cooperation_budget`.
- `local_fact_flags` - object map, Code. Declares every `_fact.*` transient flag the round may set. Each entry names its scope (`local_round`), its tag arrays, whether it is `primary` or `bonus` for resolution, and where it is set/consumed.
- `witnesses` - array, Code+Design. Ordered witness list for the Phase 1 schedule.

Each `witnesses[]` entry contains:

- `id` - string, Code. Stable witness id.
- `display_name` - string, Design. Use `"DESIGN_TODO"` during Code pass.
- `_status_note` - string, Design-facing note explaining the intended voice/register.
- `cooperation_budget` - integer, Code. Per-witness budget consumed by Press/Present actions.
- `statements` - array, Code+Design. Authoritative statement list for that witness.

Each `statements[]` entry contains:

- `id` - string, Code. Stable statement id.
- `text` - string, Design. Use `"DESIGN_TODO"` during Code pass.
- `_status_note` - string, Design-facing note for the final line.
- `article_tags` / `principle_tags` / `context_tags` - arrays of taxonomy ids, Code.
- `press_options` - array, Code+Design. Pressable follow-ups from this statement.
- `present_options` - array, Code+Design. Successful Present targets from this statement; any non-listed evidence card is treated as a wrong present by the controller.
- `fact_flags_set` - array of flag ids, Code. Flags set immediately on entering or accepting this statement; empty array when none.

Each `press_options[]` entry contains:

- `id` - string, Code.
- `cost` - integer, Code. Usually `1`.
- `follow_up_statement_id` - string, Code. Must resolve to another statement id on the same witness.
- `follow_up_text` - string, Design. Use `"DESIGN_TODO"` during Code pass.
- `fact_flags_set` - array of flag ids, Code. Flags awarded on a successful press.

Each `present_options[]` entry contains:

- `id` - string, Code.
- `evidence_id` - string, Code. Must resolve to `data/evidence_ch1.json`.
- `cost` - integer, Code. Normal presents usually cost `1`; bonus evidence may cost `0`.
- `available_when` - predicate string, Code. Optional; use for bonus-evidence gating.
- `fact_flags_set` - array of flag ids, Code. Flags awarded on the successful contradiction.
- `judge_reaction` - string, Design. Use `"DESIGN_TODO"` during Code pass.

## Phase 2 Block Schema

- `judicial_patience_default` - integer, Code. Standard starting patience before frame overrides.
- `frame_gates` - object map, Code. Keys are `chapter1.proposed_frame` enum values from `data/argument_frames_ch1.json`.
- `judge_counter_questions` - array, Code+Design. Ordered question bank consumed by the closing-argument controller.
- `victory_resolution` - object, Code+Design. Ordered branch resolution for strong / standard / narrow wins.

Each `frame_gates.<frame_id>` entry contains:

- `judicial_patience_start` - integer, Code. Starting patience for that frame. `merits_defence` must start at `3`; other Chapter 1 frames start at `5`.
- `available_counter_questions` - ordered array of `judge_counter_questions[].id`, Code.
- `_status_note` - optional note, Code or Design-facing, for unusual frame behavior.

Each `judge_counter_questions[]` entry contains:

- `id` - string, Code.
- `text` - string, Design. Use `"DESIGN_TODO"` during Code pass.
- `_status_note` - string, Design-facing note for the final line.
- `opponent_pressure_move` - string, Code. Must resolve to a move id in `data/argument_opponents.json` for `landlord_counsel_ch1`.
- `article_tags` / `principle_tags` / `context_tags` - arrays of taxonomy ids, Code.
- `pressure_weakness_tags` - weighted dictionary, Code. Keys are taxonomy ids; weights sum to `1.0`.
- `pressure_strength_tags` - weighted dictionary, Code. Keys are taxonomy ids; weights sum to `1.0`.
- `requires_fact_flags` - array of flag ids, Code. Global `chapter1.*` or local `_fact.*`.
- `judicial_patience_default` - integer, Code. Default patience assumption for this question before frame override.
- `available_citations` - array, Code+Design. Citation set the judge will accept on this question.
- `frame_gates` - object map, Code. Optional per-question narrowing of `available_citations`; if a frame key is absent, all listed citations are available.
- `defeat_lines` / `partial_lines` - arrays, Design. Use `"DESIGN_TODO"` placeholders during Code pass.

Each `available_citations[]` entry contains:

- `move_id` - string, Code. Must resolve to `judgments.json` `procedural_reset_ch1.principle_moves[].id`.
- `article_tags` / `principle_tags` / `context_tags` - arrays of taxonomy ids, Code.
- `move_tags` - weighted dictionary, Code. Keys are taxonomy ids; weights sum to `1.0`.
- `requires_fact_flags` - array of flag ids, Code. Optional additional gating.
- `judicial_patience_delta_on_hit` - integer, Code.
- `judicial_patience_delta_on_miss` - integer, Code.
- `judicial_patience_delta_on_backfire` - integer, Code.
- `flavor_line` - string, Design. Use `"DESIGN_TODO"` during Code pass.
- `_status_note` - string, Design-facing note for the final line.

Each `victory_resolution` block contains:

- `evaluation_order` - ordered array of branch ids, Code. First matching branch wins.
- `primary_fact_flags` - ordered array of the `_fact.*` flags counted toward victory quality, Code.
- `branches` - array, Code+Design.

Each `branches[]` entry contains:

- `id` - string, Code.
- `when` - predicate string, Code.
- `sets` - array of `{ path, value }`, Code. Usually writes `chapter1.court_won_procedural_reset` and `chapter1.court_outcome`.
- `result_text` - string, Design. Use `"DESIGN_TODO"` during Code pass.
- `_status_note` - string, Design-facing note for tone and outcome framing.

## Cross-Reference Contract

- Every tag id in arrays or weighted dictionaries must exist in `data/tag_taxonomy.json`.
- Every `evidence_id` must exist in `data/evidence_ch1.json`.
- Every `move_id` citation must exist in `data/judgments.json` `procedural_reset_ch1.principle_moves[]`.
- Every `opponent_pressure_move` must exist in `data/argument_opponents.json` `landlord_counsel_ch1.court_rounds[].moves[]`.
- Every `frame_gates` key must be a valid `chapter1.proposed_frame` value declared by `data/argument_frames_ch1.json`.
- Every fact flag reference must resolve to either a `chapter1.*` key declared in `scripts/autoload/state.gd` or a `_fact.*` key declared in `phase_1_fact_finding.local_fact_flags`.

## Naming Convention

One file per court round: `<chapter>_<round>.json`. Chapter 1 has one court round for now, so the canonical file is `chapter1_round_1.json`. Future chapters add their own files beside it.

## Two-Pass Authoring Discipline

Court-round files follow the same split as `judgments.json`.

- Code pass owns ids, enums, tags, weighted dictionaries, costs, predicates, cross-references, resolution logic, and gating.
- Design pass owns witness lines, follow-up wording, judge reactions, counter-question wording, citation flavor, and resolution lines.

Any entry still carrying `DESIGN_TODO` placeholders is not ready for production play, but it must remain structurally loadable for headless validation and controller testing.
