---
responds_to: 2026-05-26-design.md
date: 2026-05-26
stance: remediation plan, executable
path_choice: A (tag-effectiveness real)
---

# Remediation Plan — Game & Systems Design critique, 2026-05-26

## Verdict on the verdict

The critique lands. Every concrete file/line claim was spot-checked against
`battle_controller.gd`, `packet_scorer.gd`, `data/judgments.json`,
`data/argument_opponents.json`, `data/tag_taxonomy.json`,
`data/court_rounds/`, and `data/items.json`. The runtime does compute
`court_outcome` before Phase 2 fires (F2), Ch1 does ship one judgment + one
opponent (F1), Rounds 2 and 3 of Ch1 do not exist as fact-flag-wired data
files (F3), and the Trial Record panel is unbuilt (F4). The Pokémon framing
in `battle_mechanics.txt` has been obsolete since PROPOSALS.md §1 closed on
2026-05-04 (F6). None of this is recoverable by patching individual files
in isolation.

## Path choice: A

Tag effectiveness is real. The bucket resolver in `effectiveness.gd` stays.
Phase 2 citations are the dispositive layer, scored by `dot_product`
against opponent move tag profiles. The Trial Record panel surfaces
buckets to the player ("Effective" / "Super effective" / "Backfires").
Ch1 ships with three judgments (one fit, two deliberate misfits) so the
matchup is real, not nominal. Opponent moves carry real
`immune_to`/`resists`/`weak_to` tag sets so the lower buckets are
reachable.

This is the more ambitious option. It commits ~18–22 sessions to slice
completion (vs ~12–15 for Path B). The trade-off is that the game's
mechanical depth becomes player-visible and the
`IMPLEMENTATION_mechanical_depth_2026-05-18.md` direction is honored
rather than walked back.

## Tooling key

Tool/model picks reference the split established in PLAN.md §"Tooling
split": Antigravity is primary for code in `godot/`, Cowork is secondary
for writing-heavy fresh-context work, Codex is optional for second-opinion
review on battle-system and save-migration PRs.

Model shorthand used below:
- **AG / Gemini 3 Pro** — Antigravity Cascade with Gemini 3 Pro. Default
  for architectural code work where multi-file reasoning matters.
- **AG / Claude Sonnet 4.6** — Antigravity Cascade with Claude Sonnet 4.6.
  Default for surgical Godot/GDScript edits with a clear spec.
- **AG / Claude Opus 4.6** — reserved for the highest-risk architectural
  passes (controller refactors that touch save migration + Phase 2 wiring
  simultaneously).
- **CW / Opus 4.6** — Cowork with Claude Opus 4.6. Fresh context,
  writing-heavy. Best for judgment-card writing, dialogue passes, and
  authoring long structured JSON files like court round schemas.
- **CW / Sonnet 4.6** — Cowork with Sonnet 4.6 for shorter dialogue passes
  and per-NPC text work.
- **CW / Haiku 4.5** — Cowork with Haiku 4.5 for one-paragraph annotations
  and small text edits.
- **Codex / GPT-5** — Codex CLI for second-opinion code review on PRs that
  touch save migration or battle-controller state writes.

Each step lists the model that should drive it. Where a step has both code
and writing components, both models are listed with their respective
scopes.

## Phase 0 — Hygiene (1 session, no risk)

Risk-free deletions and renames that don't depend on any decision.

### Step 0.1 — F8: Move `chapter2_round_1.json` out of `data/court_rounds/`

**Tool/model:** AG / Claude Sonnet 4.6
**Scope:** `data/court_rounds/chapter2_round_1.json` → `data/_drafts/chapter2_round_1.json` (or `git rm`).
**Acceptance:** No file under `data/court_rounds/` carries `draft: true`. SPRINT_LOG entry dated 2026-05-26 explains the move and cites PLAN.md §Out of scope + AGENTS.md §Forbidden patterns.
**Verification:** `godot --headless --path . --script tests/test_smoke.gd` (the file should not have been loaded by anything; smoke confirms).
**Why this model:** Mechanical file move + log entry. No reasoning beyond "obey the rule." Sonnet 4.6 is overkill but Antigravity's worktree handling and grep-walk for stale references makes it the right tool. Haiku could land it but a quick scan for stale references benefits from Sonnet's care.

### Step 0.2 — F12: Rename `bonus_evidence_collected` → `client_meeting_evidence`

**Tool/model:** AG / Claude Sonnet 4.6
**Scope:** `data/items.json` stance_gate keys; `state.gd::chapter1` default; `scripts/systems/save.gd` migration; `tests/test_save_load.gd` migration test; any dialogue trigger reading the flag (grep `bonus_evidence_collected` across `data/dialogues/`).
**Acceptance:** Save version bumps to 13 (current is 12 per memory). New migration test asserts `SAVE_VERSION >= 13` (per `feedback_pig_swine_save_migration_test_pattern.md` memory). Old fixture under `tests/fixtures/` migrates cleanly.
**Verification:** `godot --headless --path . --script tests/test_runner.gd`, focused save migration test.
**Why this model:** Save migration is unforgiving but the rename is well-scoped. Sonnet 4.6 has the right balance of care and speed. Opus is unnecessary unless a hidden dialogue trigger surfaces during grep.

### Step 0.3 — F6 partial: Add hazard header to `battle_mechanics.txt`

**Tool/model:** CW / Claude Haiku 4.5
**Scope:** Insert a 4–6 line `> WARNING` block at the top of
`battle_mechanics.txt`. Body unchanged.
**Acceptance:** Header reads (verbatim or close):

```
> WARNING (2026-05-26): This document is the original 2026-04 spec and
> contradicts the shipped P0. See PROPOSALS.md §1 (DONE 2026-05-04)
> and §10 (DONE) for current direction. Do not author against
> §"Wild Argument encounters", §"Casebook collection", §"Encounter rates",
> or §"Training Battles" until the full rewrite lands (Phase 6).
```

**Verification:** `git diff battle_mechanics.txt` shows additive change only.
**Why this model:** One paragraph, no dependencies, no code path. Haiku 4.5 in Cowork is perfect for the single insertion. AG would over-tool.

**Phase 0 gate:** All three steps land in one commit (or three small
commits). SPRINT_LOG entry. Save migration test green. Then proceed.

## Phase 1 — Architectural truthing (4 sessions)

The two findings that make the runtime lie about its own architecture.
Path A requires both plus a third step for opponent state.

### Step 1.1 — F2: Move `court_outcome` write out of `consume_assembled_packet`

**Tool/model:** AG / Claude Opus 4.6 (primary), Codex / GPT-5 (review)
**Scope:**
- `scripts/systems/battle/battle_controller.gd` — delete the `court_outcome` assignment around line 465 inside `consume_assembled_packet()`. Keep the other assignments (`proposed_frame`, `halina_trust`, `decoy_overbroad_remedy`, `recruited_crab` derivation) intact.
- New function `_compute_court_outcome()` on the controller. Reads packet completeness from the already-computed score plus a new per-round Phase 2 effectiveness record. Fires from `end_round` after round 3 closes (or after round 1 if Phase 3 decides Ch1 is single-round — but under Path A Phase 3 defaults to three rounds; see Step 3.1).
- New state field `chapter1.phase2_round_results: Array[Dictionary]` in `state.gd`. Each entry: `{round: int, citation_id: String, effectiveness_bucket: String, opponent_move: String}`. Default `[]`.
- Save version bump to 14. Migration step in `save.gd`. Migration test using a save fixture from `tests/fixtures/`.
- Outcome bands (Path A): `OUTCOME_STRONG` = packet complete ∧ ≥3 of 5 Phase 2 citations land in `super_effective` bucket. `OUTCOME_STANDARD` = packet complete ∧ ≥2 citations land in `effective` or better. `OUTCOME_NARROW` = packet narrow ∨ citations average `not_very_effective`. `OUTCOME_BLUNDER_RECOVERED` = incapacity-decoy path; see Step 5.1.

**Acceptance:** `consume_assembled_packet` no longer writes `court_outcome`. End-of-Round-3 outcome computation reads `phase2_round_results` and reaches the same band for a procedurally-correct playthrough as today's runtime does, but reaches a *lower* band when the player completes the packet and then deliberately mis-cites in Phase 2. The latter test is the load-bearing one.
**Verification:** Smoke; test_runner; new focused test that fires a flag-complete packet with zero `super_effective` citations and asserts `OUTCOME_STANDARD` or lower (not `OUTCOME_STRONG`). Save migration round-trip with previous fixture.
**Why this model:** Controller refactor that touches save state, signals, and the resolver in one pass. Opus 4.6 is the right call — the failure mode of a botched save migration is silent state corruption. Codex / GPT-5 second-opinion review on the PR per PLAN.md §"Tooling split: Codex" is recommended, not optional.

### Step 1.2 — F4: Ship the Trial Record panel with effectiveness popups (Path A)

**Tool/model:** AG / Claude Sonnet 4.6
**Scope:**
- New file: `scripts/ui/trial_record_panel.gd` (Control node, panel renders during court rounds).
- New file: `scenes/ui/trial_record_panel.tscn`. Children: facts-on-record list, authorities-cited list, effectiveness-popup label, opposing-position label.
- New file: `data/court_rounds/_trial_record_labels.json` — bucket label strings ("Effective", "Super effective — strikes the article squarely", "Backfires — confirms opposing counsel's frame", "Not very effective", "No effect"). Legal register, not RPG combat language, per AGENTS.md §"Content Rules".
- Wire to `battle_screen.tscn` — instance the panel as a child, drive from `signals` emitted by `battle_controller.gd` at: packet update, Phase 1 fact-flag reveal, Phase 2 citation resolution.
- Effectiveness popups fire on Phase 2 citation resolution with a 1.5s dwell, then collapse to a row in the authorities-cited list.

**Acceptance:** Panel visible from the moment the court round opens. Updates live as the player Presses, Presents, cites. Effectiveness popup fires on every Phase 2 citation. WCAG AA contrast pass (PLAN.md §Standing decisions). Effectiveness conveyed by both color and text label (color-alone violates accessibility floor).
**Verification:** Smoke; web export build; manual playthrough on the web build to confirm panel renders during Round 1.
**Why this model:** Godot scene authoring with clear spec. Sonnet 4.6 is the sweet spot — Opus is unnecessary; Gemini 3 Pro would also work but Antigravity's Sonnet integration handles `.tscn` round-tripping more reliably in our experience.

### Step 1.3 — F5: Populate `immune_to`/`resists`/`weak_to` on opponent moves (Path A)

**Tool/model:** AG / Claude Sonnet 4.6
**Scope:** `data/argument_opponents.json::landlord_counsel_ch1.court_rounds[0..2].moves[].immune_to`, `.resists`, `.weak_to`. Today most of these are `[]`. Author real tag sets so the lower buckets are reachable.
**Constraints:** Tags must be drawn from `data/tag_taxonomy.json` (closed taxonomy per PLAN.md Standing Decisions). Each opponent move gets at minimum: 1–3 `weak_to` tags (the win conditions), 1–2 `resists` tags (the partial-credit overlaps), 0–1 `immune_to` tags (the deliberately-misfit player picks). The Article 8 home-and-family judgment from Step 2.1 should hit one `immune_to` tag on most landlord moves. The Article 10 expression judgment should resist on most.
**Acceptance:** Player can field a wrong-tag judgment and see "Backfires" or "No effect" in the Trial Record panel. Today's "super_effective everywhere" collapse no longer happens. Bucket distribution across a procedurally-correct playthrough spans at least three of the five buckets.
**Verification:** Smoke; new focused test `tests/test_battle.gd::test_bucket_distribution` that runs the resolver against each opponent move with each judgment's primary tag set and asserts at least three buckets are reachable across the matrix.
**Why this model:** Data-file editing with closed-taxonomy constraints. Sonnet 4.6 handles taxonomy lookup + JSON authoring cleanly. The design call (which tag goes where) needs Cowork / Opus on Step 2.1 *first*, because the opponent strength sets depend on what tags the new judgments carry.

**Phase 1 gate:** Steps 1.1, 1.2, 1.3 land in three commits, in order. Codex review on Step 1.1 PR before merge. Smoke + test runner + web export all green. The runtime stops lying about who decides the verdict.

## Phase 2 — Authoring the missing judgments (3–4 sessions)

Path A's load-bearing step. Without two more judgments, the matchup is
nominal. With them, the player learns by missing.

### Step 2.1 — F1: Author two new Ch1 judgments

**Tool/model:** CW / Claude Opus 4.6
**Scope:** Two new entries in `data/judgments.json`:

- **`home_and_family_ch8`** — Article 8 (right to respect for home and
  family life) judgment. Five moves, all tagged around `proportionality`,
  `margin_of_appreciation`, `private_life`, `family_unit`, `home_continuity`.
  Deliberately misfit for the Sikorska eviction (the issue isn't
  substantive home-rights, it's procedural service-of-process). When
  Pressed at the landlord counsel it lands in the `not_very_effective` or
  `backfires` bucket because the opposing counsel's frame is procedural,
  not substantive. Player who picks it learns the article-fit lesson.

- **`expression_and_press_ch10`** — Article 10 (freedom of expression)
  judgment. Five moves around `expression`, `press_freedom`,
  `chilling_effect`, `public_interest`, `prior_restraint`. Even more
  obviously misfit — testing whether the player reads the case before
  selecting their judgment.

Each judgment carries: `id`, `name`, `description`, `moves[5]` with
per-move `id`, `name`, `flavor_line`, `cost`, `effectiveness_modifiers`,
plus judgment-level tag arrays. Schema follows `procedural_reset_ch1`.
Taste Standard pass on every `name`, `description`, and `flavor_line`.

**Acceptance:** `data/judgments.json` contains three judgments. Each new
judgment passes JSON schema validation. Voice audit clean
(`python tools/voice_audit.py` if a voice-reference file exists for the
narrator/Cula on judgment cards; otherwise verify against
`style_canon.txt` register manually).

**Verification:** JSON validate; `tools/voice_audit.py` against any
voice-reference files that cover judgment-card copy; manual Taste
Standard pass per AGENTS.md.

**Why this model:** Judgment-card writing is exactly the use case PLAN.md
§"Tooling split: Cowork" calls out: "Best for writing-heavy work that
wants a fresh context… judgment-card writing (each Casebook entry is a
small writing task)." Opus 4.6 is warranted because each judgment has to
land the legal-comedy register cleanly across five moves while staying
inside the closed taxonomy.

### Step 2.2 — F1 cont.: Author overworld pickups for the two new judgments

**Tool/model:** AG / Claude Sonnet 4.6
**Scope:**
- Two new pickup interactables placed in scenes the player visits in
  Ch1. Suggested locations: the Café Paragraf side-table for
  `home_and_family_ch8` (a discarded brief from a previous client), the
  Archive Room for `expression_and_press_ch10` (a Murrow-flagged
  Strasbourg digest). Both should be flavor-justified, not magical.
- Each pickup writes a chapter1 flag (`picked_up_article_8`,
  `picked_up_article_10`) and appends the judgment to `Casebook` via
  the autoload's existing `add_judgment(judgment_id)` API.
- Update `data/items.json` if the pickups want item-bag visibility, or
  keep them Casebook-only.

**Acceptance:** Player can walk into Café Paragraf or the Archive Room
in Ch1 and pick up the new judgments. Picked-up judgments show in the
Casebook view. Save round-trip preserves the picked-up state. The
overworld pickup placements respect the no-magic, flavor-justified rule
(don't put an Article 8 binder on a hallway floor; put it inside a
file box that fits the room).

**Verification:** Smoke; manual playthrough confirming pickup; save
round-trip test with at least one new judgment in the bag.

**Why this model:** Scene wiring with clear constraints. Sonnet 4.6 +
Antigravity handles the interactable + signal + Casebook autoload chain
fluently. Worth a CW / Sonnet 4.6 follow-up pass to write the pickup
flavor text and Cula's reaction line on collecting each judgment.

### Step 2.3 — F5 close: Wire opponent strength tags against the new judgments

**Tool/model:** AG / Claude Sonnet 4.6
**Scope:** Return to `data/argument_opponents.json::landlord_counsel_ch1`
after Steps 2.1 and 2.2 land. For each opponent move, audit whether the
new judgments' primary tags fall into `immune_to`, `resists`, or
neutral. Adjust `immune_to`/`resists`/`weak_to` to make the misfits land
in the `backfires` or `not_very_effective` bucket as designed.
**Acceptance:** Bucket distribution test from Step 1.3 now spans all
five buckets across the full judgment × opponent matrix.
**Verification:** Same focused test as Step 1.3, retargeted.
**Why this model:** Same as Step 1.3 — data editing, closed taxonomy.

**Phase 2 gate:** Player has three judgments in the Casebook by end of
Ch1 investigation. Picking the wrong one in court is visibly punishing
(via Trial Record popups from Phase 1). The Pokémon framing earns its
keep.

## Phase 3 — Three full court rounds (4–5 sessions)

Path A defaults to F3a. Ch1 needs three rounds of real fact-finding for
the player to experience matchup variety against a single opponent's
shifting move set.

### Step 3.1 — F3a: Author `chapter1_round_2.json` and `chapter1_round_3.json`

**Tool/model:** CW / Claude Opus 4.6
**Scope:** Two new files matching the schema of
`chapter1_round_1.json` (1,037 lines as reference). Each file declares:
- `phase_1_fact_finding` block with witness statements, Press options,
  fact-flag writes. Round 2's facts build on Round 1's
  (`requires_fact_flags` from Round 1's set). Round 3's remedy-discipline
  facts gate the closing.
- `phase_2_argument` block with Phase 2 citation options,
  `requires_fact_flags` per citation, opponent move references from
  `argument_opponents.json::landlord_counsel_ch1.court_rounds[1..2]`.
- `judge_reactions_ch1.json` extensions for new round-specific judge
  beats.

Story.txt Beat 12 + the remedy-discipline rule from `judgments.json::procedural_reset_ch1.remedy_discipline` constrain the content:
Round 1 = service of process, Round 2 = fair hearing / wrong-address,
Round 3 = remedy proportionality. Each round must have a fact the player
either nails or misses; the misses cascade to Round 3's available
remedy.

**Acceptance:** Both files JSON-valid, schema-conformant, and load
cleanly through `battle_controller.start_round`. Each round writes its
own `chapter1.round_N_fact_*` flags. Round 2's Phase 2 citations
require Round 1's facts; Round 3's require Round 2's. The remedy-
discipline rule fires as a Round 3 mechanic, not as a description
string.

**Verification:** JSON validate both files; `test_runner.gd` extension
that fires Round 2 and Round 3 against a Round-1-complete save fixture
and asserts the controller can step through both.

**Why this model:** Each round file is the same shape as Round 1 — a
~1,000-line structured authoring task with dense Taste Standard
requirements and legal-procedure constraints. This is the second
clearest Cowork / Opus 4.6 case in the plan (after Step 2.1). Fresh
context per round file; long-form structured output; Opus's instruction
following on closed-taxonomy + procedural-accuracy is load-bearing.

### Step 3.2 — F3a controller: Drop recursive `start_round` over opponent moves

**Tool/model:** AG / Claude Opus 4.6
**Scope:** `battle_controller.gd::start_round` and `end_round`. Today
`end_round` recurses `start_round(opponent.id, round_index + 1)` and
inherits round-1 phase-one state. After Step 3.1, each round has its
own data file. Controller loads `chapter1_round_{N}.json` for round N
and runs its declared phases. No recursion; explicit per-round file
loading. Phase 2 effectiveness writes append to
`chapter1.phase2_round_results` per Step 1.1.
**Acceptance:** Controller can run rounds 1 → 2 → 3 with each pulling
its own data file. State accumulates across rounds (Round 2's Phase 2
sees Round 1's fact-flags; Round 3 sees both).
**Verification:** Smoke; focused test that runs all three rounds end-
to-end against a fresh state. Save round-trip mid-Round-2.
**Why this model:** Controller surgery on top of Step 1.1's already-
substantial controller refactor. Opus 4.6 again because the failure
mode is state corruption across the round boundary.

**Phase 3 gate:** A stranger can play through Beat 12 across three
distinct rounds, each surfacing different fact-finding work, each
demanding a different Phase 2 citation set. The two-phase carry-over
that PROPOSALS.md §10 promised is real for the full court arc, not
just Round 1.

## Phase 4 — Teach the verb before Beat 12 (2 sessions)

### Step 4.1 — F11: Author the Murrow rehearsal encounter

**Tool/model:** AG / Claude Sonnet 4.6 (data + controller), CW / Sonnet 4.6 (Murrow's drill-partner dialogue)
**Scope:**
- New file: `data/court_rounds/chapter1_round_0_rehearsal.json`. Schema-
  conformant with Round 1, but downscaled: one witness statement
  (Murrow simulating a notice-of-service witness), three Press options,
  one Present option, no Phase 2, no verdict.
- New controller entry point `battle_controller.start_rehearsal()` that
  runs Phase 1 only, surfaces the Trial Record panel from Step 1.2 as
  the teaching surface, and exits to dialogue on completion. No outcome
  bands. No flags written beyond `chapter1.rehearsal_complete = true`.
- Gate: triggered on first interaction with Murrow after binder pickup,
  during Beat 3 or Beat 4. Optional but strongly suggested ("Want to
  try this on a record before the real one?").
- Murrow's drill-partner script: 6–10 lines of dialogue framing the
  rehearsal as practice, plus three "Murrow as witness" statements
  authored to surface the Press verb cleanly.

**Acceptance:** Player meets Press/Present and Trial Record panel by
Beat 3–4 instead of Beat 12. Skipping the rehearsal is allowed; the
real court round still works. Save round-trip preserves rehearsal
state.

**Verification:** Smoke; manual playthrough from a fresh save through
Beat 4 confirming rehearsal fires when expected and the Trial Record
panel renders. Web export.

**Why this model:** Data file + controller entry point + dialogue
authoring. The data + code halves go to AG / Sonnet 4.6 because it's a
clone of Round 1's shape. The dialogue half goes to CW / Sonnet 4.6
because Murrow's voice is well-established and a 6–10 line drill-
partner pass is a one-pomodoro task; fresh context helps voice
consistency.

**Phase 4 gate:** A stranger sitting down with the web build meets the
court system's verbs in a no-stakes setting within their first ~10
minutes, not at minute 40.

## Phase 5 — Consequences (3 sessions)

Three findings about choices that have no in-fiction weight.

### Step 5.1 — F9: Let incapacity end the round on the wrong note

**Tool/model:** CW / Claude Sonnet 4.6 (dialogue + judge state), AG / Sonnet 4.6 (controller-side outcome wiring)
**Scope:**
- `data/judge_reactions_ch1.json::icy_silence` — rewrite the bench-
  initiative recovery line. The judge still rules on the procedural
  defect, but the new text makes clear Cula did not speak the winning
  argument. Procedurally accurate ("the court accepts the respondent's
  competence on its own observation, having heard her") but does not
  credit counsel.
- New state in `cula.json` or `data/dialogues/day_one_summary.json`:
  `incapacity_recovery_internal` with one Cula-internal line — "I held
  the wrong argument. The court found the right one without me."
  Dispatched in the Day-One Summary scene per the
  `2026-05-24-f4-fanout-recon.md` §Open Question 1 internal-monologue
  channel decision (which must land first; see Open Decisions below).
- `OUTCOME_BLUNDER_RECOVERED` band keeps the name but the run-summary
  text changes from "you recovered" to "the court recovered". The
  "Day-One Survivor" badge still awards (court-loss-never-blocks rule
  from PLAN.md Standing Decisions).
- `packet_scorer.gd::_packet_recovery_source` still resolves but the
  source label changes from `court_redirect` to `bench_initiative` and
  the Day-One Summary reads off the new label.

**Acceptance:** Filing incapacity costs the player visible credit in
the room. The judge's line, Cula's internal line, the band's summary
text, and the badge description all reflect that. The badge still
awards (no blocking failure).

**Verification:** Smoke; manual playthrough with incapacity filed,
confirming the new lines fire in order. Save round-trip.

**Why this model:** Dialogue + judge state writing is CW / Sonnet 4.6
work. Controller-side outcome label change is AG / Sonnet 4.6 — small,
single-file. The two halves can land in parallel commits.

### Step 5.2 — F10: Block the silent `recruited_crab = false` flip

**Tool/model:** AG / Claude Sonnet 4.6 (signal + state), CW / Sonnet 4.6 (Crab's withdrawal line)
**Scope:**
- `battle_controller.gd:463` — replace the immediate
  `_write_chapter1_flag("recruited_crab", false)` with a signal emit:
  `signals.crab_withdrew_after_incapacity.emit()`. The flag flip
  deferred.
- New `signals.gd` entry: `crab_withdrew_after_incapacity`.
- New state in `data/dialogues/crab.json`: `crab_incapacity_withdrawal`.
  Gated on `chapter1.incapacity_filed == true && chapter1.recruited_crab == true`. `once: true`. Single Crab line on stepping back. `on_dismiss`
  writes `recruited_crab = false`. Authoring per Crab bible (peer-to-Cula
  register, no flourish, leverage-aware).
- Crab's line authoring: 1–2 lines. Must land the moral position
  (Crab withdraws because filing capacity-on-the-client crosses a line),
  without becoming a lecture.

**Acceptance:** Filing incapacity surfaces a Crab dialogue state before
his Phase 1 press options disappear. The state fires once. Dismissing
it writes the flag. Save round-trip preserves both the state-seen
record and the flag.

**Verification:** Smoke; focused dialogue test asserting the state
fires on the trigger and dismisses cleanly; save migration covered if
any new flag added (none expected — the state-seen record is already
in `dialogue_states_seen` per SAVE_VERSION 12).

**Why this model:** Signal + state plumbing is AG / Sonnet 4.6; Crab's
line is CW / Sonnet 4.6 (Crab's voice is established and a 1–2 line
pass benefits from fresh context for register consistency).

### Step 5.3 — F7: Rename `halina_trust` → `halina_stance` + `incapacity_penalty`

**Tool/model:** AG / Claude Sonnet 4.6
**Scope:**
- `state.gd::chapter1.halina_trust: int` → split into
  `halina_stance: String` (enum-as-string: `"high"` / `"blunt"` /
  `"technical"` / `""`) and `incapacity_penalty: bool`.
- `data/dialogues/halina.json` — all `trust_delta` writes become
  `stance` writes (which they effectively already are — the stance is
  set in `client_meeting_intro` options). Drop the `trust_delta`
  numeric writes from non-stance-setting states.
- `data/argument_frames_ch1.json` — drop the -1/-1/-4 trust deltas;
  fold the incapacity penalty into a single `incapacity_penalty = true`
  write.
- Halina trust meter consumers — grep `halina_trust` across `data/` and
  `scripts/` and rewrite to read `halina_stance` / `incapacity_penalty`.
- Save version bump to 15. Migration: prior fixture's `halina_trust` int
  maps to `halina_stance` via threshold (≥5 → "high", 0–4 → "blunt"
  default, negative → "blunt" + `incapacity_penalty = true`).
- Update `project_pig_swine_trust_meter.md` auto-memory to reflect the
  rename. Today the memory claims architecture-of-record for an
  integer that doesn't carry dramatic weight.

**Acceptance:** No `halina_trust` reference remains in code or data.
The Beat 8 reveal at the former "trust ≥ 5" threshold now keys off
`halina_stance == "high" && !incapacity_penalty`. Behaviorally
identical to current best-case runs; behaviorally identical to current
incapacity-filed runs. Memory entry updated.
**Verification:** Smoke; full test_runner; save migration test against
the prior fixture; focused test asserting the Beat 8 reveal still
fires on the high-stance + no-incapacity path.
**Why this model:** Mechanical refactor + save migration. Sonnet 4.6
in Antigravity. Opus is overkill; the schema is simple, just touches
many files. Codex / GPT-5 review on the save migration PR is
recommended given memory entry conflict.

**Phase 5 gate:** The three moments where a choice carries no in-fiction
weight all carry it now. Filing incapacity costs visible credit; Crab's
withdrawal is announced before his press options vanish; the trust
"meter" stops pretending to be an integer.

## Phase 6 — Spec sync (1–2 sessions, human-owned)

### Step 6.1 — F6 full: Rewrite `battle_mechanics.txt`

**Tool/model:** CW / Claude Opus 4.6 to produce a *draft rewrite* as
`PROPOSAL_battle_mechanics_rewrite.md`. User to approve and either land
the rewrite themselves into `battle_mechanics.txt` or explicitly delegate
the root-spec edit to the agent.

**Scope of the rewrite:**
- Preserve §"Casebook battle system" intent: type-effectiveness via
  Article + Principle + Context tags, judgment moves, opponent moves.
- Strip §"Wild Argument encounter design", §"Encounter rates",
  §"Training Battles", §"Casebook collection as a goal", any references
  to the Final Printer as a mini-game.
- Add §"Two-phase court rounds" describing the Phase 1 fact-finding /
  Phase 2 citation structure that PROPOSALS.md §10 codified.
- Add §"Packet assembly" describing the flag-derived state
  (`proposed_frame`, `halina_trust`/now-stance, `decoy_overbroad_remedy`,
  `recruited_crab`) that gates Phase 2 citations.
- Add §"Outcome bands" describing the four bands and how they're
  computed (post-Step 1.1).
- Add §"Path A — Tag effectiveness" describing the bucket resolver as
  the dispositive layer in Phase 2.

**Acceptance:** Draft rewrite proposal landed. User-level decision on
whether to delegate the actual root-spec edit follows; agent does not
edit `battle_mechanics.txt` body without explicit approval per AGENTS.md.

**Verification:** Spec consistency check — every section of the new
draft maps to a shipped runtime feature or to an approved PROPOSALS.md
entry. No new mechanics introduced in the spec that aren't already in
the runtime (PLAN.md "spec follows or spec leads" reconciliation
deferred to Step 6.2).

**Why this model:** Long-form structured rewrite of a 2,751-line spec
file. CW / Opus 4.6. Fresh context, writing-heavy, requires close
reading of the current spec plus the runtime to ensure the rewrite
matches reality.

### Step 6.2 — Standing Concern §1: Demote root .txt files or commit to spec-first

**Tool/model:** Human + user-led discussion. Optionally CW / Sonnet 4.6
to draft both options for AGENTS.md and PLAN.md.

**Scope:** Pick one:
- **Option 6.2a:** Demote root `.txt` files from "Source of Truth" to
  "Frozen reference". Promote `PROPOSALS.md` + `PLAN.md` + the
  `data/` layer to authoritative. Update AGENTS.md §"Source Of Truth"
  accordingly.
- **Option 6.2b:** Commit to a strict "no runtime change without spec
  update" gate. Add an AGENTS.md rule. Make every PR that touches
  battle/court mechanics also touch `battle_mechanics.txt` or a
  PROPOSALS entry.

The plan can't pick this for you — it's a governance call. But the
current middle ground is the source of every spec-runtime drift the
critique catalogues.

**Why human-led:** Governance change. No agent should land this without
explicit user direction.

## Phase 7 — Governance bookends (no sprints)

### Step 7.1 — Standing Concern §2: Cap proposals-in-flight at one

**Tool/model:** CW / Claude Haiku 4.5
**Scope:** Append to AGENTS.md §"Working Rules" or `godot/AGENTS.md`:
"No new `PROPOSAL_*.md` file may be opened while another is in DEVELOP.
The exception is hostile-critique response plans, which are not
proposals." Close
`PROPOSAL_player_driven_argument.md` and
`PROPOSAL_mechanical_depth_2026-05-18.md` as their items land via this
plan; mark them DONE in `PROPOSALS.md`.
**Acceptance:** AGENTS.md rule added. Two in-flight proposal files
closed by end of plan execution.
**Why this model:** Single text addition; Haiku 4.5 is right.

### Step 7.2 — Standing Concern §3: Playtest gate before Ch2

**Tool/model:** CW / Claude Haiku 4.5
**Scope:** Append to PLAN.md §"Out of scope until Chapter 1 ships":
"No Ch2 authoring (data files, scenes, dialogue, opponents) until a
stranger has played through Ch1 on the web build, sat through the
Day-One Summary, and signed off on the Casebook reveal."
**Acceptance:** PLAN.md gate added. Step 0.1 (delete Ch2 stub) becomes
load-bearing rather than hygiene.
**Why this model:** Same as 7.1.

## Sequencing summary

```
Phase 0: Hygiene                      (1 session)   AG/Sonnet × 2, CW/Haiku
Phase 1: Architectural truthing       (4 sessions)  AG/Opus, AG/Sonnet, AG/Sonnet, Codex/GPT-5 review
Phase 2: Missing judgments            (3-4 sessions) CW/Opus, AG/Sonnet, AG/Sonnet
Phase 3: Three full court rounds      (4-5 sessions) CW/Opus × 2, AG/Opus
Phase 4: Verb-teaching rehearsal      (2 sessions)  AG/Sonnet + CW/Sonnet
Phase 5: Consequences                 (3 sessions)  CW/Sonnet + AG/Sonnet × 3
Phase 6: Spec sync                    (1-2 sessions, human-owned) CW/Opus
Phase 7: Governance bookends          (no sprints)  CW/Haiku × 2
```

Total: ~18–22 sessions. Original PLAN.md slice budget was 14–20 for the
whole slice; the slice is past budget. This plan finishes the work that
keeps Ch1 from shipping. Steps 0–5 land the runtime; Step 6 closes the
spec gap; Step 7 prevents the drift from recurring.

Critical-path note: Phase 1 must land before Phase 2 (Trial Record panel
is needed to teach effectiveness). Phase 2.1 must land before Phase 1.3
and Phase 2.3 (opponent tags depend on what judgments exist). Phase 3
can begin while Phase 5 runs in parallel — they touch different code
paths. Phase 4 should land between Phase 3 and Phase 5 so the rehearsal
exists before incapacity-decoy testing. Phase 6 and 7 close at end.

## Open decisions for the user

Path A is locked. Three smaller forks remain.

**D1 — F3 round count.** Path A defaults to F3a (three full rounds).
Confirm or override. If override to F3b (one true round + two post-
verdict scenes), Phase 3 drops to ~2 sessions and Phase 2's judgment
count can drop to one new judgment (matchup variety comes from the one
round, not three).

**D2 — F7 stance representation.** Plan recommends F7b (rename to enum
+ bool) on the grounds the integer never lives in interesting
territory. F7a (build trust into a 3–4 choice sequence across Beats
4–10) is a separate authoring sprint that could ship after the slice.
Confirm F7b for the plan as written, or signal F7a for a Phase-5.5
addition.

**D3 — Internal-monologue dispatch channel.** Step 5.1 needs the
`cula_internal` rendering channel that 2026-05-24-f4-fanout-recon.md
§Open Question 1 flagged. Pick (a) lift to `idle_flavor` on family-
photo re-interaction, (b) per-zone ambient triggers, or (c) extend
`DialogueRunner` to render `cula_internal` as a thought-balloon UI
element. The recon doc didn't pick; this plan can't proceed Step 5.1
until you do.

If D1 = F3a (default), D2 = F7b (recommended), D3 = answered, the plan
executes as written.
