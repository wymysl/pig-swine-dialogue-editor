# Chapter 1 — Phase A foundation prompt

Single prompt covering A.1 + A.2 + A.3 of `chapter_1_tier1_implementation_plan.md`. A.4 (badge popup UI) is deferred — it's polish, not foundation, and easier to write as its own prompt later.

**Copy from the line below into Antigravity.**

---

## Prompt: Chapter 1 Phase A — state extension, dialogue runner actions, Asia hint dispatch

**Model: Claude Opus 4.6** (schema migration + state-machine reasoning across multiple files; the heaviest-context prompt in the chapter-1 plan; do not use Sonnet for this)

**Source plan.** `narrative_revision/phase_7_audits/chapter_1_tier1_implementation_plan.md` Phase A, sub-prompts A.1, A.2, A.3. Read that file first; it is the authoritative spec for this work. A.4 (badge popup UI) is deferred to a future prompt and out of scope.

**Goal.** Engine plumbing for chapter 1. Three changes, in dependency order:

1. **A.1 — Extend `State.data.chapter1` flag set, add `badges` and `routes_unlocked` dictionaries, bump `SAVE_VERSION` 7→8 with a migration step in `save.gd`.**
2. **A.2 — Extend `DialogueRunner._on_dialogue_dismissed` to handle two new action types** (`award_badge`, `unlock_route`) and add corresponding signals on the `Signals` autoload.
3. **A.3 — Resolve Asia hint NPC dispatch using Option 1 from the plan** (drop tone-variant system, replace `asia_hints.json` with `asia_hint_states_ch1.json` as the canonical Asia hint surface, update the runner to support the `lines` shape).

**Schema-rewrite note (load-bearing).** The earlier Antigravity Prompt 11 explicitly forbade adding fields to `State.data`. THAT prompt's "no schema rewrite" rule does NOT apply to this prompt. The schema rewrite here is content-driven: existing dialogue JSON files (`halina.json`, `judge_district_ch1.json`, `postcard_swine_ch1.json`) already reference flags the engine silently drops today. Adding them is fixing a bug, not inventing mechanics. Proceed with the schema change as specified in A.1, with proper `SAVE_VERSION` bump and migration.

**Required reading.**
- `narrative_revision/phase_7_audits/chapter_1_tier1_implementation_plan.md` (full Phase A: lines 1-130)
- `godot/scripts/autoload/state.gd` (current chapter1 flag set; `SAVE_VERSION`; `reset_state()`)
- `godot/scripts/systems/save.gd` (existing migration patterns if any; otherwise establish one here)
- `godot/scripts/autoload/dialogue_runner.gd` (specifically `_on_dialogue_dismissed`, around line 62-64; and the asia_hints load site around line 35)
- `godot/scripts/autoload/signals.gd` (where to add the two new signals)
- `godot/data/chapters/chapter1.json` (`new_state_flags` array currently lists `met_asia` and `viewed_family_photo` — extend with the new flags)
- `godot/data/dialogues/halina.json` (Beat 8; references several new flags in `on_dismiss`)
- `godot/data/dialogues/judge_district_ch1.json` (Beat 12; references `casebook_judge_state` and `court_won_procedural_reset`)
- `godot/data/dialogues/postcard_swine_ch1.json` (Beat 14; references `award_badge` and `unlock_route` actions)
- `godot/data/dialogues/asia_hint_states_ch1.json` (V1.A — the new Asia hint surface)
- `godot/data/asia_hints.json` (the legacy file to be backed up)
- `godot/tests/test_dialogue_runner.gd` (extend with action-type tests)

### A.1 — State extension

Add the following flags to `State.data.chapter1` in `reset_state()`. Defaults are `false` for booleans and `""` (empty string) for the stringly-typed enums.

**Boolean flags:**
- `halina_met`
- `halina_arrived` (added per chapter_1_tier1 §B.2 footnote — gates the meeting-room entry trigger)
- `cardiologist_plant_landed`
- `client_fee_agreed`
- `archive_research_complete`
- `court_won_procedural_reset`
- `beat13_complete`
- `received_swine_postcard`
- `postcard_asia_announced`
- `postcard_readaloud_cue_shown`
- `postcard_body_read`
- `pig_postcard_reaction_shown`
- `whimsy_postcard_deflection_shown`
- `complete`

**String enum flags (default `""`):**
- `client_meeting_stance` — values: `sympathetic`, `blunt_procedural`, `technical`
- `bonus_evidence_collected` — values: `wojcik_witness_statement`, `return_to_sender_slip`, `lease_1962_inheritance_1987`
- `casebook_judge_state` — values: `round_1_open`, `round_1_react`, `round_2_open`, `round_2_react`, `round_3_open`, `round_3_remedy`, `""` (empty)

**Top-level state dictionaries (not under `chapter1`):**
- `badges: Dictionary[String, bool]` — initial: `{"day_one_survivor": false}`
- `routes_unlocked: Dictionary[String, bool]` — initial keys: `residential`, `business_district`, `court_plaza`, all with value `false`

**Save migration:**
- Bump `SAVE_VERSION` constant from 7 to 8.
- In `save.gd`, add a migration step that: detects a pre-v8 save (`save_data.version < 8`), adds the new flags / dictionaries with default values, sets `save_data.version = 8`. The migration must not corrupt or drop existing chapter1 keys (`met_asia`, `viewed_family_photo`, `chapter1.met_pig`, etc.).
- Add `godot/tests/test_save_migration_v7_v8.gd` (new) that constructs a v7 save dict, runs the migration, and asserts all new keys exist with defaults AND all old keys are preserved.

**Update `data/chapters/chapter1.json`:**
- The `new_state_flags` array currently lists `met_asia` and `viewed_family_photo`. Extend it to include every flag added above. (This array is documentation/contract for the dialogue layer.)

### A.2 — DialogueRunner action handler extension

`_on_dialogue_dismissed` in `dialogue_runner.gd` (around line 62-64) currently handles only the `set` mutation type. Add two new action types in the same handler:

```gdscript
# Existing:
# { "set": { "chapter1.<flag>": <value> } }

# New:
# { "award_badge": "<badge_id>" }
# { "unlock_route": "<route_id>" }
```

**Behavior:**
- `award_badge` action writes `State.data.badges[<badge_id>] = true` and emits `Signals.badge_awarded.emit(<badge_id>)`.
- `unlock_route` action writes `State.data.routes_unlocked[<route_id>] = true` and emits `Signals.route_unlocked.emit(<route_id>)`.
- If the badge_id or route_id is unknown (not in the dictionary), log a warning but do not crash.

**Signals additions** (`signals.gd`):
```gdscript
signal badge_awarded(badge_id: String)
signal route_unlocked(route_id: String)
```

**Tests** (extend `test_dialogue_runner.gd`):
- New test case: a mock dialogue dismiss with `{"award_badge": "day_one_survivor"}` → assert `State.data.badges.day_one_survivor == true` AND the `badge_awarded` signal fired with `"day_one_survivor"`.
- New test case: a mock dialogue dismiss with `{"unlock_route": "residential"}` → assert `State.data.routes_unlocked.residential == true` AND the `route_unlocked` signal fired.
- New test case: unknown badge_id (e.g., `"nonexistent"`) → assert no crash; warning logged.

### A.3 — Asia hint NPC dispatch (Option 1: drop tone variants)

Decision (confirmed by Piotr): Option 1 from the plan. V1.A is the committed canonical Asia hint surface; the legacy 10-state tone-variant file (`data/asia_hints.json`) is retired. The runner adapts to the V1.A `lines` shape.

**Steps:**
1. Rename `data/asia_hints.json` to `data/asia_hints.json.bak` (preserve as historical reference; do NOT delete).
2. In `dialogue_runner.gd` around line 35: replace the explicit `asia_hints.json` load with an explicit load of `data/dialogues/asia_hint_states_ch1.json`, keyed under the `"asia"` catalogue ID. Confirm the file is loaded only once.
3. Update the runner's hint dispatch path to support the `lines: [...]` schema in addition to (or instead of) the `hint: { neutral, agitated, deadpan }` schema. Prefer simplest: detect which shape the dialogue object uses and dispatch accordingly. The tone-variant code path can be left in place for any other NPC that still uses `hint.<tone>` shape — only the Asia dispatch is being migrated. If no other NPC uses the tone-variant shape, the tone-variant code path can be removed; grep for `hint.neutral` / `hint.agitated` / `hint.deadpan` first to confirm.
4. Verify Asia's patrol AI in `asia.gd` doesn't break when the hint surface changes. The patrol logic should be hint-agnostic, but confirm.

**Pre-flight grep (do this BEFORE the asia_hints.json rename):**
```bash
grep -r "asia_hints" --include="*.gd" --include="*.tscn" --include="*.json" godot/
```
Any reference outside `dialogue_runner.gd` is unexpected; report it before proceeding.

**Test:**
- New test case in `test_dialogue_runner.gd` (or a new `test_asia_hint_dispatch.gd`): set `State.data.chapter1.<various_flags>` to trigger each V1.A state transition, request the Asia hint via the runner, assert the returned line matches the expected V1.A canonical line for that state.

### Allowed writes

- `godot/scripts/autoload/state.gd` — `reset_state()` body, `SAVE_VERSION` constant.
- `godot/scripts/systems/save.gd` — v7→v8 migration step; preserve all pre-existing migration logic.
- `godot/scripts/autoload/dialogue_runner.gd` — action handler extension; Asia hint load site.
- `godot/scripts/autoload/signals.gd` — two new signals.
- `godot/data/chapters/chapter1.json` — `new_state_flags` array.
- `godot/data/asia_hints.json` → `godot/data/asia_hints.json.bak` (rename only).
- `godot/tests/test_dialogue_runner.gd` — extend with new action and Asia hint tests.
- `godot/tests/test_save_migration_v7_v8.gd` (new file).
- `godot/CONVENTIONS.md` — short note documenting the chapter1 flag set and the badges/routes_unlocked schema.

### Forbidden

- Any change to dialogue JSON files OTHER than the asia_hints.json rename. Specifically: do NOT edit `halina.json`, `judge_district_ch1.json`, `postcard_swine_ch1.json`, or `asia_hint_states_ch1.json` content.
- Phase B/C/D/E work from the plan (Halina NPC creation, stance-pick UI, court rounds, postcard scene, etc.).
- Adding badge popup UI or route-unlock acknowledgment UI (A.4 — deferred).
- Modifying `casebook.gd` logic.
- Changing existing chapter1 flag names. Add only; do not rename.
- Touching `narrative_revision/` content (it's source-of-truth narrative documentation, not engine).

### Acceptance

- `State.data.chapter1` contains every flag listed in A.1 above, with documented defaults.
- `State.data.badges` and `State.data.routes_unlocked` exist with declared initial keys.
- `SAVE_VERSION = 8`. Migration test (`test_save_migration_v7_v8.gd`) constructs a v7 save dict, runs the migration, asserts new keys exist AND old keys are preserved.
- `DialogueRunner._on_dialogue_dismissed` handles `award_badge` and `unlock_route`. Signal emissions confirmed by test.
- `Signals.badge_awarded` and `Signals.route_unlocked` exist.
- `asia_hints.json` renamed to `.bak`; `asia_hint_states_ch1.json` loads under `"asia"` catalogue key; Asia hint dispatch test passes.
- `CONVENTIONS.md` has a short section "Chapter 1 state schema" enumerating the new flags + dictionaries + their semantic owners.
- All existing tests still pass.

### Output artifact

- Diffs for: `state.gd`, `save.gd`, `dialogue_runner.gd`, `signals.gd`, `chapter1.json`, `CONVENTIONS.md`.
- New file: `test_save_migration_v7_v8.gd`.
- Diff for: `test_dialogue_runner.gd` (extended).
- File rename: `asia_hints.json` → `asia_hints.json.bak`.
- A short report (in the agent response, not a file) listing every grep hit for `asia_hints` to confirm no orphaned references survive.

### Follow-ups (do NOT do in this prompt)

- A.4 — badge popup + route-unlock acknowledgment UI (next prompt).
- B.1 — Beat 7 stance-pick UI.
- B.2 — Halina NPC + meeting-room area.
- Phase C, D, E (court rounds, postcard scene, polish).

---

**Notes on running.** Opus 4.6 because this touches the State schema and the dialogue runner — load-bearing changes that need careful reasoning across multiple files. A wrong save migration corrupts player saves; a wrong dialogue runner change breaks the entire chapter-1 narrative flow. Don't downgrade the model.

After the agent runs, do a walkthrough verification: open Godot, load the office scene, check the console for new warnings, run any chapter-1 entry script (if one exists) to verify the new flags are reachable, run the test suite. If tests pass and no new warnings appear, move on to A.4 (or skip A.4 if you'd rather get straight to Phase B's Halina NPC).
