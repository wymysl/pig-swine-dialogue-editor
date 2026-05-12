# Codex prompt — coffee minigame headless tests

Paste everything below the line into Codex (after attaching the
`/Users/piotr/Documents/Silly projects/pig-swine-rpg/` folder).

This is the QA-role half of the original Prompt 9 from
`COFFEE_MINIGAME_DELEGATION_PLAN.md`, scoped down to test authoring only —
the migration tests already exist (`tests/test_save_migration_v8_v9.gd`,
`tests/test_save_migration_v9_v10.gd`).

---

You are working on Pig & Swine RPG, a Godot 4.6.2 GDScript project. The
coffee brewing minigame engine is mechanically complete but has zero
behavioral test coverage — only smoke and migration tests exist. Every
future change to `coffee_brewing.gd` risks silent regression. Your job is
to author `tests/test_coffee_brewing.gd`, a headless test suite that
exercises the judgment system, result grading, state writes, and signal
emissions.

## Required reading

1. Repo root `AGENTS.md`.
2. `godot/AGENTS.md` §Hard build invariants, §File ownership (tests/** is
   QA, append-only).
3. `godot/.antigravity/skills/qa.md` if it exists (skip if missing — you're
   running as Codex which doesn't auto-load skill files).
4. `godot/tests/test_save_migration_v8_v9.gd` and
   `godot/tests/test_dialogue_runner.gd` — for the SceneTree-based test
   pattern used in this repo.
5. `godot/scripts/systems/minigames/coffee_brewing.gd` end-to-end. You
   need to know:
   - The `Phase` enum, the timing-window constants, the scoring constants.
   - `_register_judgment()` — central dispatcher.
   - `_show_result()` and the result-grade thresholds (S/A/B/C/D/F).
   - The signal payloads: `Signals.minigame_finished(minigame_id, outcome)`
     and `Signals.coffee_brewing_completed(result: Dictionary)`.
   - The State writes: `chapter1.coffee_tutorial_seen`, `chapter1.coffee_buff`,
     `chapter1.coffee_brew_grade`, top-level `coffee` dict updates.
6. `godot/scenes/minigames/coffee_brewing.tscn` — to know what node paths
   the engine assumes (you'll instantiate the scene to drive it).
7. `godot/data/minigames/coffee_patterns.json` — for pattern IDs you'll
   exercise (`chapter1_court_coffee` for tutorial, `office_standard_coffee`
   for normal-mode tests).

## Files you may modify (exactly one)

- `godot/tests/test_coffee_brewing.gd` (new file)

## Files you may NOT modify

- Anything in `godot/scripts/`
- Anything in `godot/scenes/`
- Anything in `godot/data/`
- Any existing test file
- Any `.txt` file at repo root

If you discover the engine has a bug while writing tests, document it in
your sprint log entry as a defect note. Do not fix it.

## Critical guardrails

- **Do not run `git checkout`, `git restore`, or any reverting git command.**
- **Do not author Godot scripts that mutate scene files via load/pack/save.**
- This test runs the actual scene; don't add file-system writes that
  pollute the project tree.

## Test pattern (mirror the existing migration tests)

```gdscript
extends SceneTree
## tests/test_coffee_brewing.gd — exercises judgment, grading, and
## result emission against the live coffee_brewing scene.
## Runs headless. Exits 0 on pass, 1 on fail.

var _pass_count: int = 0
var _fail_count: int = 0

func _init() -> void:
    print("[TestCoffeeBrewing] Starting...")
    # ... tests ...
    _finish()

func _pass(msg: String) -> void:
    _pass_count += 1
    print("[TestCoffeeBrewing] PASS: ", msg)

func _fail(msg: String) -> void:
    _fail_count += 1
    printerr("[TestCoffeeBrewing] FAIL: ", msg)

func _finish() -> void:
    print("[TestCoffeeBrewing] Results: %d passed, %d failed" % [_pass_count, _fail_count])
    quit(0 if _fail_count == 0 else 1)
```

## Required tests

### T1 — Scene loads cleanly

Instantiate `res://scenes/minigames/coffee_brewing.tscn`. Assert it returns
a non-null node and has the expected children (`BackgroundPanel`,
`BackgroundPanel/PromptSpawner`, `AnimationPlayer`, `PauseLayer`). Pass if
all present.

### T2 — Pattern loads and split into phases correctly

Programmatically set `pattern_id = "chapter1_court_coffee"` on the
instantiated engine, call `_ready()` (or whatever loads the pattern), then
assert `_pattern_id` matches, `_pattern.lanes == 2`, and that the engine
has populated per-phase note arrays. The exact internal structure may
require reading the engine — use whatever public-ish helper exists, or
read private vars via `get("_pattern")` if you have to.

### T3 — Perfect runs produce S grade + procedurally_alert_plus buff

Drive the engine programmatically:
1. Instantiate the scene and add to the tree.
2. Force `_phase = Phase.GRIND` and seed the engine clock to t=0.
3. For each note in the pattern, call `_register_judgment("perfect", note)`.
   Bypass the input layer entirely — exercise the judgment dispatcher
   directly.
4. Trigger the pour as a perfect center release (or simulate via
   `_register_judgment` if the engine has a `"pour_perfect"` judgment key
   — check what the code uses).
5. Trigger the final stamp as a perfect judgment.
6. Call `_show_result()` or the function that resolves to a grade.

Assert:
- The computed `grade` is `"S"`.
- The computed `buff` is `"procedurally_alert_plus"`.
- `brew_quality > bitterness` by a wide margin.

### T4 — All-miss runs produce D or F + over_caffeinated buff

Same setup as T3 but with every judgment as `"miss"`. Don't trigger any
pour or stamp inputs.

Assert:
- The computed `grade` is `"D"` or `"F"`.
- The computed `buff` is `"over_caffeinated"`.
- `bitterness > brew_quality`.
- The story-progress flag `chapter1.coffee_tutorial_seen` STILL gets set
  to `true` after the run (failure must not block progression).

### T5 — Result dictionary shape

After any complete run, assert the result dictionary emitted via
`Signals.coffee_brewing_completed` contains every key from the spec
§Result object:
- `minigame` (`"coffee_brewing"`)
- `context` (whatever context the trigger passed)
- `grade` (string)
- `result` (string)
- `buff` (string)
- `brew_quality` (int)
- `bitterness` (int)
- `perfect_hits` (int)
- `good_hits` (int)
- `okay_hits` (int)
- `misses` (int)
- `assist_used` (bool)

Capture the signal via a one-shot connection:

```gdscript
var captured_result: Dictionary
sigs.coffee_brewing_completed.connect(func(r): captured_result = r)
```

### T6 — State writes after run

After a perfect run, assert:
- `State.data.chapter1.coffee_tutorial_seen == true`
- `State.data.chapter1.coffee_buff == "procedurally_alert_plus"`
- `State.data.chapter1.coffee_brew_grade == "S"`
- `State.data.coffee.tutorial_seen == true`
- `State.data.coffee.times_brewed > 0`
- `State.data.coffee.last_buff == "procedurally_alert_plus"`

Reset State between this test and T4's run (or run T4 first and check
over_caffeinated, then T6 after a perfect run separately). Use
`State.data = State.reset_state()` to reset.

### T7 — `Signals.minigame_finished` emits with correct outcome string

Connect to `Signals.minigame_finished` before triggering a run. After
result resolves, assert the captured payload is
`("coffee_brewing", <buff_string>)` where `<buff_string>` matches the
grade-derived buff.

### T8 — Normal-mode pattern loads with 4 lanes

Set `pattern_id = "office_standard_coffee"`. Re-instantiate (or re-init
the engine). Assert `_pattern.lanes == 4` and that the engine doesn't
crash if you simulate inputs on lanes 2 and 3 (`move_up`, `move_down`).

### T9 — Single-button assist collapses lane matching

With assist `single_button = true` enabled (set the engine's internal
flag before driving), simulate hitting `interact` at a perfect time
against any note. The lane mismatch should NOT register as wrong — it
should register as perfect (lane matching disabled, timing still
matters). Assert `_perfect_hits` incremented and `_wrong_hits` didn't.

### T10 — Wider timing assist widens windows

With `wider_timing = true`, repeat T3's perfect run but with timing
offsets at the edge of the normal-mode `OKAY_WINDOW`. With the wider
timing scale (1.5×), those should register as `okay` or better. Without
it, they'd register as miss. Assert the difference.

## What to leave alone

- Don't modify `coffee_brewing.gd` even if you think a function should be
  more testable. If you can't test something without restructuring, skip
  that test and document why in the sprint log.
- Don't add helper functions to the engine for test scaffolding.
- Don't introduce new signals.
- Don't create test fixtures under `tests/fixtures/` — the patterns are
  already on disk.

## Verification

Run:
```
godot --headless --path godot --script tests/test_coffee_brewing.gd --log-file /tmp/coffee_test.log
godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/coffee_smoke.log
godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/coffee_runner.log
godot --headless --path godot --script tests/test_save_migration_v8_v9.gd --log-file /tmp/v8v9.log
godot --headless --path godot --script tests/test_save_migration_v9_v10.gd --log-file /tmp/v9v10.log
```

All exit 0. If any of T1-T10 can't be authored due to engine internals
being opaque, mark that test as `_skip("reason")` and document in the
sprint log.

## Sprint log

Append a dated paragraph to `godot/SPRINT_LOG.md`. Title it as completion
of the deferred Prompt 9 test-authoring half. List the tests authored, any
skipped with their reasons, and any defects discovered.
