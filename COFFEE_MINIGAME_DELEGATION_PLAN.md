# Coffee Brewing — Delegation Plan

Target: replace the `coffee_brewing.tscn` stub with the full mini-game described
in `minigames.txt` §Mini-Game 1 — tutorial mode for Chapter 1, normal mode for
the office coffee corner, accessibility menu, full visual + audio + dialogue set,
soft-fail philosophy preserved.

The work is split into nine prompts grouped into four phases. Each prompt is
self-contained: pasteable into an agent without our conversation context.

## Sequencing at a glance

Phase 0 (sequential, blocks everything else) is the schema bump and the engine
skeleton. Phase 1 (parallelisable after Phase 0) covers pattern data + content +
art + audio + dialogue. Phase 2 (sequential, after Phase 1) wires the buff into
Chapter 1 court flow and adds the accessibility menu. Phase 3 (last) is the QA
sweep — headless tests, web export, sprint log.

```
Phase 0 — Foundation
  ├─ Prompt 1  [Antigravity / Code]    Engine skeleton + schema bump
  └─ Prompt 2  [Codex]                 v8→v9 save migration test

Phase 1 — Content & polish  (parallel after Phase 0)
  ├─ Prompt 3  [Antigravity / Code]    Pattern data + difficulty modes
  ├─ Prompt 4  [Antigravity / Art]     Visual assets (sprites + animations)
  ├─ Prompt 5  [Antigravity / Art]     Audio (SFX set)
  └─ Prompt 6  [Antigravity / Design]  Dialogue (barista + reactions + retry)

Phase 2 — Integration  (sequential, after Phase 1)
  ├─ Prompt 7  [Antigravity / Code]    Repeatable office trigger + court buff hook
  └─ Prompt 8  [Antigravity / Code]    Accessibility menu

Phase 3 — Verification  (last)
  └─ Prompt 9  [Antigravity / QA]      Headless tests + web export + SPRINT_LOG entry
```

## Scope cuts (deliberate, document so we don't relitigate)

These are excluded from the first ship of the mini-game and tracked here so a
future agent doesn't smuggle them back in unannounced:

- **MinigameRouter abstraction.** The spec sketches one. We don't need it —
  one direct `load(scene_path).instantiate()` from `minigame_trigger.gd` is
  fine until a second mini-game (Document Chase) lands and a router actually
  earns its keep. Rule 2, simplicity first.
- **Crisis mode (Chapter 3) and Final Brief Coffee (Chapter 5).** Tutorial +
  normal mode only. The pattern data layer is structured so Crisis can be
  added later by authoring one more `.tres`.
- **Recipe cards, character coffee preferences.** P2 in the spec; skipped.
- **Mouse fallback controls.** Keyboard + gamepad only.
- **Auto-pour assist mode.** Cut from the accessibility menu in v1. Slower
  notes + wider timing + single-button mode are enough.
- **Chapter 2 Evidence Board hint integration.** Belongs to the Chapter 2
  sprint, not this one. The buff state will already be readable from
  `chapter1.coffee_buff` so the Chapter 2 work picks it up cleanly.

## Critical invariants (apply to every prompt)

- Save schema change requires `SAVE_VERSION` bump + `migrate_save()` step +
  migration test. No exceptions (godot/AGENTS.md §Save migration policy).
- Player-facing strings live in JSON. No literals in `.gd` or `.tscn`.
- Dialogue states must address-form-respect: Crab/Whimsy say "Cula" only after
  recruitment; Asia says "Mr. Murrow"; everyone else says "Dr. A. Cula".
  (godot/AGENTS.md §Address forms in dialogue.)
- Cross-system communication via `Signals` autoload only.
- Coffee failure never blocks story progression — it produces comic dialogue
  variations, nothing else. This is in the spec's acceptance criteria.
- Each prompt's deliverable ends with the standard hard-build invariants
  passing: smoke test, test runner, save round-trip for state changes, web
  export.

---

# Phase 0 — Foundation

## Prompt 1 — Engine skeleton + schema bump

**Agent:** Antigravity / Code role (Opus 4.6 recommended per `code.md`).
**Depends on:** nothing.
**Blocks:** everything else.

Paste:

> You are the Code-role agent on the Pig & Swine RPG. Required reading, in
> order:
>
> 1. Repo root `AGENTS.md`.
> 2. `godot/AGENTS.md` — full read.
> 3. `godot/CONVENTIONS.md` — focus on §Canonical numbers, §State autoload
>    constants, §TileMap vs Sprite2D placement, §Chapter 1 state schema.
> 4. `godot/.antigravity/skills/code.md`.
> 5. Last five entries of `godot/SPRINT_LOG.md`.
> 6. `godot/PLAN.md` §Vertical slice plan and §Out of scope.
> 7. `godot/PROPOSALS.md` — relevant rows.
> 8. `minigames.txt` §Mini-Game 1 (Coffee Brewing) — full read.
> 9. `godot/scripts/autoload/state.gd`, `godot/scripts/autoload/signals.gd`,
>    `godot/scripts/systems/save.gd`, `godot/scripts/actors/minigame_trigger.gd`,
>    `godot/scripts/systems/minigames/coffee_brewing.gd`, and
>    `godot/scenes/minigames/coffee_brewing.tscn`.
> 10. `godot/data/dialogues/barista.json` — for the integration contract it
>     documents in its `_comment_*` fields.
>
> Goal: replace the coffee_brewing stub with a playable rhythm engine that
> implements the spec's three phases (Grind, Pour, Serve) and emits a result
> dictionary. This prompt builds the **engine skeleton** only — pattern data,
> art, audio, and dialogue come in later prompts. Use placeholder text labels
> and `ColorRect`s for every visual, and stub the audio playback through
> named keys that Art will swap in later.
>
> Build:
>
> 1. **Save schema (state.gd):** add to `chapter1` two new fields,
>    `coffee_buff: String` (default `""`, enum: `"procedurally_alert_plus"` /
>    `"procedurally_alert"` / `"caffeinated"` / `"over_caffeinated"`) and
>    `coffee_brew_grade: String` (default `""`, enum: `"S"` / `"A"` / `"B"` /
>    `"C"` / `"D"` / `"F"`). Also add a top-level dictionary
>    `coffee: Dictionary` mirroring the spec's shared coffee state (keys:
>    `tutorial_seen`, `last_result`, `last_grade`, `last_buff`, `assist_used`,
>    `times_brewed`, `best_grade`). Defaults per spec.
> 2. **Save migration (save.gd):** bump `SAVE_VERSION` 8 → 9. Add a v8→v9
>    migration step that adds the two `chapter1` fields and the top-level
>    `coffee` dict if missing, preserving any existing values. Update the
>    version-history comment block at the top.
> 3. **Signal bus (signals.gd):** add one new signal
>    `coffee_brewing_completed(result: Dictionary)` with a docstring describing
>    the payload shape from §Result dictionary of the spec. Do NOT touch the
>    existing `minigame_finished` signal — coffee_brewing.gd will continue to
>    emit it as `("coffee_brewing", buff_string)` for back-compat with the
>    barista dialogue gate.
> 4. **Engine (coffee_brewing.gd + .tscn):** rewrite both. Architecture:
>    - Root: `CanvasLayer` (already, keep). `process_mode = PROCESS_MODE_ALWAYS`
>      and `get_tree().paused = true` on `_ready()` — mirror the stub's
>      pause-the-world contract so the overworld actor pauses while the
>      mini-game runs.
>    - State machine with phases: `READY` → `GRIND` → `POUR` → `SERVE` →
>      `RESULT` → `EXIT`. Phase transitions advance on internal timers, not
>      input. The internal beat clock drives note spawning.
>    - Note model: in-memory `Array[Dictionary]` per phase loaded from the
>      pattern config (Prompt 3 owns the data; this prompt just defines the
>      contract). Each note dict: `{ "time": float, "lane": int,
>      "icon": String, "kind": "tap"|"pour"|"stamp" }`. The engine reads but
>      does not author them.
>    - Timing windows: implement the four-judgment table from spec §Timing
>      judgments (PERFECT/GOOD/OKAY/MISS). Use the tutorial-mode constants
>      from the spec as defaults; the difficulty toggle (Prompt 3) will pass
>      tighter constants for normal mode.
>    - Scoring: as per spec §Scoring. Track `brew_quality: int`,
>      `bitterness: int`, `combo: int`, `perfect_hits`, `good_hits`,
>      `okay_hits`, `misses`, `wrong_hits`.
>    - Input mapping: lane 0 = `move_left`, lane 1 = `move_right`, lane 2 =
>      `move_up`, lane 3 = `move_down`, pour = hold/release `interact`, stamp
>      = `interact` press, quit = `ui_cancel` (Esc). These are all in the
>      existing InputMap — confirm by reading `project.godot` [input]
>      section.
>    - Result grading: `final_score = brew_quality - bitterness`, then map
>      to the grade/result/buff per spec §Result grades. Compose the result
>      dictionary in the spec's §Result object shape.
>    - Exit: write `State.data.chapter1.coffee_tutorial_seen = true`,
>      `State.data.chapter1.coffee_buff = <buff>`,
>      `State.data.chapter1.coffee_brew_grade = <grade>`. Update the
>      top-level `State.data.coffee` dict (`tutorial_seen`, `last_result`,
>      `last_grade`, `last_buff`, `assist_used`, increment `times_brewed`,
>      update `best_grade` if better). For each chapter1 flag written, emit
>      `Signals.chapter1_flag_changed(<flag>, <value>)`. Then emit
>      `Signals.coffee_brewing_completed(result_dict)` AND
>      `Signals.minigame_finished("coffee_brewing", buff_string)` for
>      back-compat. Then `get_tree().paused = false` and `queue_free()`.
> 5. **Scene (coffee_brewing.tscn):** a single screen, 1280×720, with the
>    node names from the spec's §UI layout (CoffeeBrewingRoot →
>    BackgroundPanel, CoffeeMachineSprite, CupSprite, TimingTrackRoot/Lane0…3,
>    TimingLine, PromptSpawner, BrewQualityMeter, BitternessMeter, ComboLabel,
>    PhaseLabel, ResultPanel, CharacterReactionPortrait, AnimationPlayer,
>    AudioStreamPlayer). Every visual is a `ColorRect` or `Label` placeholder;
>    sprite slots are empty `Sprite2D` nodes with `null` textures — Prompt 4
>    fills them. Audio nodes have empty stream slots — Prompt 5 fills them.
>    Set `process_mode = PROCESS_MODE_ALWAYS` on the root.
> 6. **Per-judgment audio hook:** keep audio as named playback keys
>    (`note_hit`, `note_perfect`, `note_miss`, `pour_start`, `pour_loop`,
>    `pour_release_good`, `success`, `failure`, `machine_objects`,
>    `stamp_caffeinated`). Implement a tiny `_play(key: String)` helper that
>    looks up `AudioStreamPlayer.stream` from a `@export Dictionary` keyed by
>    the same names. Prompt 5 will populate the export.
> 7. **Pattern loader:** read patterns from
>    `res://data/minigames/coffee_patterns.json` (Prompt 3 authors this).
>    Until Prompt 3 lands, ship one hard-coded fallback pattern inline (a
>    short two-lane tutorial with 6 taps, 1 pour, 1 stamp) so the engine is
>    playable end-to-end on its own. Comment it `# TODO Prompt 3: replace
>    with JSON-loaded pattern`.
>
> Do not:
> - Author any patterns beyond the inline fallback. That is Prompt 3's job.
> - Author any sprite or sound. Those are Prompts 4 and 5.
> - Author any dialogue line. That is Prompt 6.
> - Touch `data/dialogues/barista.json`. That is Design's file.
> - Add a MinigameRouter abstraction.
> - Add the accessibility menu. That is Prompt 8.
> - Touch the court flow. That is Prompt 7.
>
> Acceptance:
> - `godot --headless --path . --script tests/test_smoke.gd` → exit 0.
> - `godot --headless --script tests/test_runner.gd` → exit 0.
> - `godot --headless --export-release "Web" exports/web/index.html` → produces a
>   non-empty file with no errors.
> - Manual visual check (delegated to human): walk into Café Paragraf, press E
>   on the coffee machine, play through the fallback pattern using A/D + E,
>   observe phase transitions and a result panel.
> - Append a SPRINT_LOG entry: files touched, schema-bump note, "Prompt 3
>   pending pattern data" callout.

---

## Prompt 2 — v8 → v9 save migration test

**Agent:** Codex (recipe-based test mirroring an existing pattern).
**Depends on:** Prompt 1 (state.gd + save.gd must be at v9).
**Blocks:** Prompt 9 verification.

Paste:

> You are working on the Pig & Swine RPG Godot project. Read root `AGENTS.md`
> and `godot/AGENTS.md` §Save migration policy. Then read
> `godot/tests/test_save_migration_v7_v8.gd` end-to-end — your task is to
> author the v8→v9 sibling.
>
> Build `godot/tests/test_save_migration_v8_v9.gd` that mirrors the v7→v8
> test exactly in shape but exercises the v8→v9 migration step authored in
> the previous prompt. Required tests:
>
> 1. T1: `state.gd::SAVE_VERSION == 9`.
> 2. T2: pre-existing v8 keys (the full Beat 7-14 flag set, `badges`,
>    `routes_unlocked`) survive the migration with their original values.
> 3. T3: new chapter1 keys `coffee_buff` and `coffee_brew_grade` exist with
>    default `""`.
> 4. T4: new top-level `coffee` dict exists with the seven keys from the
>    spec at their correct default types (`tutorial_seen: false`,
>    `last_result: ""`, `last_grade: ""`, `last_buff: ""`,
>    `assist_used: false`, `times_brewed: 0`, `best_grade: ""`).
> 5. T5: idempotency — re-running migrate_save from v9 must not clobber
>    user-set values.
> 6. T6: v1→v9 chain produces every expected key from every step.
>
> Don't:
> - Don't modify any existing test.
> - Don't modify `state.gd` or `save.gd` — Prompt 1 owns those.
> - Don't add new tests beyond the migration test.
>
> Acceptance: `godot --headless --script tests/test_save_migration_v8_v9.gd`
> exits 0 with all 6 tests passing. The existing
> `test_save_migration_v7_v8.gd` still exits 0 (you didn't break it).

---

# Phase 1 — Content & polish

All four prompts in this phase can run **in parallel** once Phase 0 is
merged. They touch different files (.gd vs .png vs .ogg vs .json) and have no
runtime dependencies on each other.

## Prompt 3 — Pattern data + difficulty modes

**Agent:** Antigravity / Code role.
**Depends on:** Prompt 1 (engine reads the pattern JSON).
**Parallel with:** Prompts 4, 5, 6.

Paste:

> You are the Code-role agent on the Pig & Swine RPG. Required reading: same
> list as Prompt 1 of the coffee-brewing delegation plan, plus
> `godot/scripts/systems/minigames/coffee_brewing.gd` as it stands after
> Prompt 1 (you need to know the pattern-dict contract it expects).
>
> Build:
>
> 1. **Author `godot/data/minigames/coffee_patterns.json`** with the four P0
>    patterns from `minigames.txt` §Pattern design: `chapter1_court_coffee`
>    (tutorial, 2 lanes, ~22s), `cafe_smooth_coffee` (tutorial-equivalent
>    repeat, 2 lanes, ~22s), `office_standard_coffee` (normal mode, 4 lanes,
>    ~27s), `office_panic_coffee` (normal mode, 4 lanes, ~27s, slightly
>    busier final 5s). Each pattern is a JSON object with
>    `id`, `display_name`, `difficulty` (`"tutorial"` or `"normal"`), `bpm`,
>    `duration`, `lanes`, `notes` (array of `{time, lane, icon, kind}`),
>    `pour_events` (array of `{start_time, target_start, target_end}`),
>    `final_stamp` (`{time}`). Hand-author each pattern — do not generate
>    randomly. Each pattern must have: a readable opening (sparse first 3s),
>    a tiny difficulty rise mid-pattern, and a satisfying final stamp.
>    Tutorial patterns: no simultaneous notes, only `bean` and `sugar` icons
>    on the first half, `stamp` icon on the final beat. Normal patterns:
>    occasional double notes allowed in the last 8s; include `milk` and
>    `file` icons in the mix.
> 2. **Wire the loader in coffee_brewing.gd:** replace the inline fallback
>    pattern with a JSON-loaded one. Add an `@export var pattern_id: String`
>    on the engine so the launcher can pick which pattern. Default to
>    `chapter1_court_coffee`. The launcher (`minigame_trigger.gd`) gets a
>    new `@export var pattern_id: String` that it forwards to the
>    instantiated scene on launch.
> 3. **Difficulty branching in coffee_brewing.gd:** add a `Difficulty` enum
>    (`TUTORIAL`, `NORMAL`) derived from the loaded pattern's `difficulty`
>    field. Timing windows switch between the tutorial and normal constants
>    from spec §Timing judgments based on this enum. Lane count is set from
>    the pattern's `lanes` field (2 or 4); UI hides the unused lanes when 2.
> 4. **Trigger wiring:** update `cafe_paragraf.tscn` MinigameTrigger to set
>    `pattern_id = "chapter1_court_coffee"`. Update `pig_swine_office.tscn`
>    MinigameTrigger to set `pattern_id = "office_standard_coffee"`. Don't
>    add an office_panic trigger anywhere — that variant is reserved for a
>    later chapter beat.
>
> Don't:
> - Don't change the engine state machine itself. Prompt 1 owns that.
> - Don't add crisis mode (a third difficulty). The pattern format leaves
>   room for it but no pattern is authored.
> - Don't touch any dialogue or art.
>
> Acceptance:
> - Smoke + runner exit 0.
> - Loading each of the four patterns via the engine produces a finite-time
>   playthrough that resolves to a result dictionary.
> - Manual visual check (human): café tutorial still plays end-to-end with
>   2 lanes; walking into the office coffee corner launches the normal
>   pattern at 4 lanes.

---

## Prompt 4 — Visual assets

**Agent:** Antigravity / Art role.
**Depends on:** Prompt 1 (scene node names defined).
**Parallel with:** Prompts 3, 5, 6.

Paste:

> You are the Art-role agent on the Pig & Swine RPG. Required reading:
>
> 1. Repo root `AGENTS.md`.
> 2. `godot/AGENTS.md`.
> 3. `godot/CONVENTIONS.md` — focus on §Game palettes, §Art direction —
>    two-layer system, §World sprite generation rules.
> 4. `godot/.antigravity/skills/art.md`.
> 5. `style_canon.txt` — for the visual register the mini-game should sit in.
> 6. `minigames.txt` §Mini-Game 1 — focus on §Visual style, §UI layout, and
>    §Character reactions.
> 7. `godot/scenes/minigames/coffee_brewing.tscn` after Prompt 1 — to see
>    which sprite slots need filling.
>
> Build the visual asset set for the coffee brewing mini-game. The screen
> sits inside the 1280×720 viewport with the same Świdziński sprite register
> as the rest of the game — minimal synthetic line drawing, sparse flat
> shapes, institutional mood. Palette: Milk Bar (`art/palettes/milk_bar_palette.png`)
> for the café context; reuse the same set for office-corner repeats (the
> spec describes the office as "older, louder, and more likely to object"
> but the asset set is shared — that mood will land via the SFX in Prompt 5,
> not new sprites in v1).
>
> Asset list (all `art/minigames/coffee/`):
>
> - `coffee_machine_idle.png` — 128×128, pixel-art, the spec's "minor
>   character … printer's less dangerous cousin". Two-tone metal body, single
>   indicator lamp. Read at small scale.
> - `coffee_machine_gurgle.png`, `coffee_machine_happy.png`,
>   `coffee_machine_angry.png` — three frame-mate variants. Tiny silhouette
>   shifts only (steam puff, tilt, tilt-and-shake). Same 128×128 footprint.
> - `coffee_cup_empty.png`, `coffee_cup_fill_01.png`, `coffee_cup_fill_02.png`,
>   `coffee_cup_fill_03.png` — 64×64. Brew Quality reads from this stack
>   directly.
> - `prompt_bean.png`, `prompt_milk.png`, `prompt_sugar.png`,
>   `prompt_stamp.png`, `prompt_file.png`, `prompt_mug.png` — 32×32 each.
>   Chunky, readable at small scale, distinct silhouettes. Bean is round,
>   stamp is square with a handle, file is a folded rectangle.
> - `timing_line.png` — 8×96 vertical bar. Just a marker.
> - `result_stamp_admitted.png`, `result_stamp_objected.png` — 96×64 each.
>   Both look like real legal stamps — circular border, two lines of fake
>   Polish-bureaucratic text inside. Red ink for admitted, dull gray for
>   objected.
> - `meter_brew_bg.png`, `meter_brew_fill.png`, `meter_bitter_bg.png`,
>   `meter_bitter_fill.png` — 240×24 each. The fill sprites are single-color
>   bars the engine scales by `region_rect`; the bg sprites have a thin
>   frame and a label slot.
>
> AnimationPlayer animations (author in `coffee_brewing.tscn`):
>
> - `machine_idle`, `machine_gurgle`, `machine_happy`, `machine_angry` —
>   loop the corresponding sprite swap with a 0.2s cadence.
> - `cup_fill` — drive the cup sprite stack from empty → fill_03 over the
>   pattern duration, driven by `brew_quality` ratio.
> - `steam_loop` — simple 4-frame puff above the machine.
> - `stamp_impact` — 0.15s flash on `result_stamp_*` reveal, scale 1.3 →
>   1.0 with a tiny shake.
> - `result_reveal` — 0.3s fade-in on the ResultPanel.
>
> Visual feedback per spec §Visual style:
>
> - Perfect → small sparkle particle at the timing line (use a simple
>   `CPUParticles2D` configured in `.tscn` with the existing sparkle texture
>   if it exists, otherwise author `art/minigames/coffee/sparkle.png` 16×16).
> - Good → 1.1× scale pulse on the prompt sprite at hit time.
> - Okay → 4° wobble.
> - Miss → prompt splats into a small `bitter_foam.png` puff (32×32).
> - Wrong input → 4-frame machine shake + one `puff_offended.png` (32×32).
>
> Character reaction portraits: the spec wants Barista (perfect/good/okay/
> bad/machine-objects), Asia (perfect/good/bad), Mr. Pig/Murrow/Crab/Whimsy
> (perfect/bad). Barista is a new portrait — author the full 5-expression
> set at 512×512 using the warm register from `CONVENTIONS.md` §Portrait
> generation rules (small-format gouache, naive Polish illustration, flat
> warm earth tones). For Asia/Pig/Murrow/Crab/Whimsy, reuse their existing
> `art/portraits/<char>/neutral.png` and `stressed.png` (already authored)
> until coffee-specific expressions become a P1 polish ask.
>
> Don't:
> - Don't author sound. That's Prompt 5.
> - Don't author dialogue. That's Prompt 6.
> - Don't bake any character into the timing track sprites (e.g., a bean
>   wearing a tie). The icons are objects, not characters.
> - Don't touch any other room's art.
> - Don't introduce new palettes. Stay in Milk Bar.
>
> Acceptance:
> - Every sprite imports without errors. Check via `godot --headless --import`.
> - The mini-game scene visually populates (no missing-texture pink). Human
>   delegated for visual confirmation.
> - Smoke + runner exit 0.

---

## Prompt 5 — Audio (SFX set)

**Agent:** Antigravity / Art role (Art owns audio per file ownership table).
**Depends on:** Prompt 1.
**Parallel with:** Prompts 3, 4, 6.

Paste:

> You are the Art-role agent on the Pig & Swine RPG. Required reading:
>
> 1. Repo root `AGENTS.md`.
> 2. `godot/AGENTS.md` — note that audio lives under `audio/` and is owned by
>    Art.
> 3. `godot/.antigravity/skills/art.md`.
> 4. `style_canon.txt` §Audio canon — the project's audio register.
> 5. `minigames.txt` §Mini-Game 1 §Sound design — the required-sounds list
>    and the "soft rhythm taps … rubber stamp thud … machine sputter … tiny
>    success chime" character notes.
> 6. `godot/scenes/minigames/coffee_brewing.tscn` after Prompt 4 — to see
>    which audio nodes need streams.
>
> Build the SFX set for the coffee brewing mini-game. Every sound is short
> (≤ 1s except `pour_loop` which is a clean 1s loop), mono, OGG Vorbis,
> -3 dBFS peak, normalized loudness across the set.
>
> File list (all `audio/minigames/coffee/`):
>
> - `coffee_note_hit.ogg` — soft wooden tap. The default hit cue. ~80ms.
> - `coffee_note_perfect.ogg` — same tap with a high-pitched bell harmonic
>   layered on. ~120ms. Distinguishable from `note_hit` blind.
> - `coffee_note_miss.ogg` — dull paper crumple. ~140ms.
> - `coffee_pour_start.ogg` — espresso machine pump kicking in. ~200ms.
> - `coffee_pour_loop.ogg` — 1.0s seamless pour stream. Loops while the
>   player holds Interact.
> - `coffee_pour_release_good.ogg` — pour cuts off cleanly with a small
>   ceramic clink. ~250ms.
> - `espresso_hiss.ogg` — half-second high-pressure steam.
> - `coffee_success.ogg` — tiny chime + rubber stamp thud, layered. ~600ms.
> - `coffee_failure.ogg` — sad sputter + offended single beep. ~700ms.
> - `coffee_machine_objects.ogg` — comic mechanical objection (think
>   "uh-oh" via descending bellows). ~900ms. Reserved for the F-grade
>   result.
> - `stamp_caffeinated.ogg` — single decisive rubber stamp thud. ~150ms.
>
> Wire each stream into the corresponding `AudioStreamPlayer` node in
> `coffee_brewing.tscn` via the `@export Dictionary` that Prompt 1
> authored on the engine script. The dictionary keys are exactly the
> filenames-without-extension above.
>
> Source guidance:
>
> - Either author with sfxr/bfxr/jsfxr (chiptune-flavored, fits the project's
>   minimal audio register) or pull from CC0/Pixabay/freesound (with the
>   project's existing attribution discipline — check `style_canon.txt` for
>   the license rules).
> - Avoid melodic loops. The mini-game is short; melody would compete with
>   the rhythm cues.
> - Avoid stock "coffee shop ambience" — there's no background loop in this
>   mini-game; the espresso machine itself is the soundscape.
>
> Don't:
> - Don't author music. The mini-game runs over the existing café/office
>   ambient bed (or silence).
> - Don't author voice lines.
> - Don't touch any other room's audio.
>
> Acceptance:
> - All 11 OGG files import cleanly via `godot --headless --import`.
> - Loop point on `coffee_pour_loop.ogg` is seamless (no click at the join).
>   Check by playing it back twice in a row in the editor.
> - Smoke + runner exit 0.

---

## Prompt 6 — Dialogue (barista + reactions + retry)

**Agent:** Antigravity / Design role.
**Depends on:** Prompt 1 (the engine writes `chapter1.coffee_buff` that
dialogue triggers will gate on).
**Parallel with:** Prompts 3, 4, 5.

Paste:

> You are the Design-role agent on the Pig & Swine RPG. Required reading:
>
> 1. Repo root `AGENTS.md`.
> 2. `godot/AGENTS.md` — especially §Address forms in dialogue, §Taste
>    Standard, §First-meeting introductions.
> 3. `godot/CONVENTIONS.md` — §Chapter 1 state schema for the flag names
>    you'll trigger on.
> 4. `godot/.antigravity/skills/design.md`.
> 5. `style_canon.txt` — voice references for every character you author
>    a line for.
> 6. `minigames.txt` §Mini-Game 1 — §Narrative placement, §Core fantasy,
>    §Character reactions, §Failure philosophy. The Barista's exact suggested
>    lines are quotes-as-spec; use them as starting drafts but pass each one
>    against the Taste Standard before committing.
> 7. `godot/data/dialogues/barista.json` — read the current contract and
>    the SCOPE NOTE comment block. You are now resolving the SCOPE NOTE.
> 8. `godot/data/asia_hints.json` — for the existing Asia pattern.
> 9. `godot/data/voice_references/dialogue_samples_barista.jsonl` and the
>    other character voice references — these are draft lines authored to
>    illustrate voice, NOT committed text; use them as voice anchors.
>
> Build:
>
> 1. **Expand `data/dialogues/barista.json`.** Resolve the SCOPE NOTE by
>    splitting the single `coffee_outcome` state into five buff-gated
>    states: `coffee_outcome_alert_plus`, `coffee_outcome_alert`,
>    `coffee_outcome_caffeinated`, `coffee_outcome_over_caffeinated`,
>    `coffee_outcome_machine_objects`. Each gates on
>    `chapter1.coffee_buff == "<value>"` (the engine writes
>    `procedurally_alert_plus` / `procedurally_alert` / `caffeinated` /
>    `over_caffeinated` / the F-grade is mapped to `over_caffeinated` AND
>    `chapter1.coffee_brew_grade == "F"` — see spec §Result grades).
>    Author the Barista's exact lines from spec §Character reactions as
>    draft material, then Taste-Standard them. Keep the `coffee_order`
>    state's voice (Cula's "Black coffee." opener).
> 2. **Add the retry prompt** as a state with `options` (see
>    `godot/CONVENTIONS.md` §Dialogue option schema). The retry prompt
>    fires after any result state's `on_dismiss`, gated on
>    `chapter1.coffee_buff != ""`. Options: `"Appeal the coffee."` (value
>    `"retry"`, writes back to a transient flag the engine can pick up)
>    and `"Accept the beverage."` (value `"accept"`). Note: this requires
>    a small Code follow-up to honor the retry — surface this as a
>    PROPOSAL artifact rather than wiring it yourself; you do not own the
>    engine.
> 3. **Add coffee-result hint states to `data/asia_hints.json`**:
>    `hint_coffee_alert_plus`, `hint_coffee_alert`,
>    `hint_coffee_over_caffeinated`, `hint_coffee_skipped` (gated on
>    `chapter1.coffee_tutorial_seen == false`). The exact suggested lines
>    are quoted in spec §Chapter integration — Chapter 1, plus the Asia
>    reactions in §Character reactions. Asia uses "Mr. Murrow" and
>    "Dr. A. Cula" per the address rules.
> 4. **Reaction lines for Pig/Murrow/Crab/Whimsy in their existing
>    dialogue files.** Add new `coffee_reaction_*` states in each NPC's
>    `data/dialogues/<npc>.json` gated on `chapter1.coffee_buff ==
>    "<value>"` AND `met_<npc> == true` (so it only fires after the
>    introduction beat). One Perfect and one Bad variant per character,
>    using the spec's quoted lines as starting drafts. Address forms:
>    Crab/Whimsy use "Cula" only post-recruitment — gate the post-recruit
>    variants on `recruited_crab` / `recruited_whimsy` accordingly; the
>    pre-recruit variants use "Dr. A. Cula".
> 5. **Phase flavor text and result messages.** Author the in-game flavor
>    strings the engine displays during play (PhaseLabel and result panel)
>    in a new file `data/minigames/coffee_text.json`:
>    - Phase labels: `"Grind."`, `"Pour."`, `"Serve."`.
>    - Per-phase flavor (one line each): use the spec's suggested texts
>      from §Phase 1 (Grind), §Phase 2 (Pour), §Phase 3 (Serve).
>    - Result lines (one per buff): use the spec's suggested results from
>      §Core fantasy ("Coffee admitted into evidence.", "Brew served out
>      of time but accepted in the interests of justice.", "Machine
>      objects.", "Caffeine level disproportionate but not fatal.").
>    - Final stamp lines: `"STAMPED: CAFFEINATED"` and
>      `"STAMPED: QUESTIONABLE"`.
>    Engine reads this file by key; you are establishing the contract by
>    authoring the file, and Code will pick up the keys in a follow-up.
>    File a one-paragraph PROPOSAL artifact noting the engine still needs
>    to read this file (parallel to the retry-honor PROPOSAL above) —
>    Code's Prompt 8 will handle both.
>
> Don't:
> - Don't author the engine. Code owns coffee_brewing.gd.
> - Don't break the existing barista `coffee_order` state — only add
>   states and split `coffee_outcome`.
> - Don't introduce a line that requires a fake Polish legal doctrine.
>   Coffee parodies institutional language only.
> - Don't put a coffee reaction line in Halina's or Mrs. Sikorska's
>   dialogue files — Halina meets Cula post-coffee in the same chapter
>   but coffee is not a beat she shares, and adding her reaction would
>   stretch scope.
>
> Acceptance:
> - JSON validates.
> - Cross-reference check (run the existing dialogue cross-ref script if
>   present, otherwise spot-check): every flag name referenced in a new
>   trigger exists in `state.gd::reset_state()` post-Prompt 1.
> - Taste Standard pass: every committed line scores 5/5. Drop or rewrite
>   any 4/5.
> - Address form check: every "Cula"/"Dr. A. Cula"/"Mr. Murrow" usage
>   matches the speaker-gate rules in `godot/AGENTS.md`.

---

# Phase 2 — Integration

## Prompt 7 — Repeatable office trigger + court buff hook

**Agent:** Antigravity / Code role.
**Depends on:** Prompts 1, 3, 6.
**Parallel with:** Prompt 8.

Paste:

> You are the Code-role agent on the Pig & Swine RPG. Required reading: same
> as Prompt 1 of the coffee-brewing delegation plan, plus
> `godot/scripts/actors/minigame_trigger.gd`, the office and café scene files,
> the court flow script (find it under `godot/scripts/systems/` —
> likely `battle/` or a `court_*.gd`), and `data/asia_hints.json` after
> Prompt 6.
>
> Build:
>
> 1. **Repeatable trigger plumbing on `minigame_trigger.gd`.** Add two
>    `@export` properties: `repeatable: bool = false` and
>    `availability_flag: String = ""`. Semantics:
>    - If `repeatable == false`, the trigger gates itself once the
>      mini-game completes — currently nothing stops the player from
>      replaying it via the same interactable. Use a local
>      `_consumed: bool` flag flipped on `Signals.minigame_finished`
>      matching the configured `minigame_scene_path`.
>    - If `availability_flag != ""`, the trigger only shows its prompt
>      and accepts interact input when `State.data.chapter1[availability_flag]`
>      is truthy. Use the existing `Signals.chapter1_flag_changed` to
>      refresh the gate without a scene reload.
> 2. **Wire the café trigger:** `cafe_paragraf.tscn` — set `repeatable = false`,
>    `availability_flag = ""`. (The café version is one-shot. Barista
>    dialogue already gates by `coffee_tutorial_seen` so the player can
>    still talk to her after; only the mini-game itself is consumed.)
> 3. **Wire the office trigger:** `pig_swine_office.tscn` — set
>    `repeatable = true`, `availability_flag = "coffee_tutorial_seen"`.
>    The office coffee corner becomes available only after Café Paragraf
>    has played, then stays repeatable.
> 4. **Court buff hook.** Read the Chapter 1 court flow code. Identify the
>    point where Murrow whispers a hint to Cula on a wrong-argument-pick.
>    If the buff is `procedurally_alert` or `procedurally_alert_plus`,
>    the hint should fire on the first wrong pick instead of after two
>    consecutive wrong picks (or the existing equivalent). If the buff is
>    empty or `caffeinated`, behavior is unchanged. If the buff is
>    `over_caffeinated`, do NOT alter the hint cadence — the comic
>    variation goes through dialogue lines (Prompt 6 authored those),
>    not court mechanics.
>
>    Implement this by reading `State.data.chapter1.coffee_buff` at the
>    decision point and adjusting the hint-trigger threshold. Do not
>    persist a new flag for "buff applied"; the buff is a one-shot read at
>    court start. Spec §Buff effects allows this read-once-and-act model.
>
> Don't:
> - Don't change `minigame_finished`'s signal shape.
> - Don't author dialogue lines. Prompt 6 owns the court Murrow whisper
>   variants if a new variant is needed; otherwise reuse the existing
>   whisper.
> - Don't gate the office trigger on anything other than
>   `coffee_tutorial_seen`. In particular don't add a "Chapter 1
>   complete" gate — the office coffee is meant to be available across
>   chapters.
> - Don't refactor `minigame_trigger.gd` beyond the two new exports plus
>   their evaluation. Document Chase will reuse this same plumbing in
>   Chapter 2, so keep it general.
>
> Acceptance:
> - Smoke + runner exit 0.
> - Manual playthrough (human-delegated): café coffee plays once, can't
>   be replayed at the café; office coffee corner unlocks after the café
>   playthrough and accepts repeat interactions; with
>   `coffee_buff == "procedurally_alert"`, Murrow's whisper fires earlier
>   in court Round 1.
> - SPRINT_LOG entry.

---

## Prompt 8 — Accessibility menu

**Agent:** Antigravity / Code role.
**Depends on:** Prompts 1, 3, 6.
**Parallel with:** Prompt 7.

Paste:

> You are the Code-role agent on the Pig & Swine RPG. Required reading: same
> as Prompt 1, plus `data/minigames/coffee_text.json` after Prompt 6 (you
> will read several of its keys in this prompt).
>
> Build the accessibility menu the spec §Accessibility mode and §P1 polish
> describe. v1 scope is the three toggles the spec calls out as essential —
> slower notes, wider timing windows, single-button mode — plus a pause
> overlay that exposes them. Cut auto-pour mode.
>
> Build:
>
> 1. **Pause/settings panel inside coffee_brewing.tscn.** A `CanvasLayer`
>    child of the mini-game root, `process_mode = PROCESS_MODE_ALWAYS`,
>    hidden by default. `ui_cancel` (Esc) toggles it. The panel has:
>    a title `"Pause"` (from `coffee_text.json` key `"pause_title"`,
>    which Prompt 6 authored), three toggle rows (Slower notes / Wider
>    timing / Single-button), and a single "Resume" button.
> 2. **Resume vs Quit.** No quit option in v1 — pausing must always
>    resume to the same state. The mini-game cannot be exited mid-run
>    without finishing, because exit semantics for partial runs are
>    underspecified and would create a "skip without consequences" hole.
>    If the player wants to bail, they finish the pattern (every
>    remaining note becomes a miss, result is `over_caffeinated`, story
>    continues — same as a bad run).
> 3. **Slower notes toggle.** When on, all `note.time` values in the
>    loaded pattern are scaled by 1.4×. Pour event windows scale by the
>    same factor. Engine reads the scale factor once on pattern load,
>    not per-frame.
> 4. **Wider timing toggle.** When on, every timing window
>    (PERFECT/GOOD/OKAY) multiplies by 1.5×. Apply at hit-judgment time.
> 5. **Single-button toggle.** When on, all input lanes collapse to
>    `interact` regardless of authored lane. Timing still matters; only
>    lane matching is disabled. Wrong-lane misses become correct hits if
>    the timing is in window.
> 6. **Persist toggles** in `State.data.coffee.assist_used` (boolean —
>    flips true if any of the three were on for the most recent run) and
>    in a new dict `State.data.settings.coffee_accessibility` with the
>    three booleans. This is a save-shape change: `SAVE_VERSION` bumps
>    9 → 10, migrate_save v9→v10 adds the dict with defaults all false,
>    and a v9→v10 migration test gets added (mirror the v8→v9 test
>    structure).
>
> Don't:
> - Don't add auto-pour mode.
> - Don't add a "Quit run" button.
> - Don't surface the toggles outside the mini-game's pause panel — no
>   global settings menu integration in v1.
> - Don't change pattern files. The scale factors are applied at runtime.
>
> Acceptance:
> - Smoke + runner exit 0.
> - New v9→v10 migration test passes.
> - Manual playthrough: pressing Esc mid-run pauses; toggling Slower
>   notes mid-run does NOT retroactively rescale (toggle reads only at
>   pattern load — document this in the panel UI as "applies next run");
>   toggling Wider timing DOES apply immediately; toggling Single-button
>   DOES apply immediately.
> - SPRINT_LOG entry.

---

# Phase 3 — Verification

## Prompt 9 — Headless tests + web export + sprint log

**Agent:** Antigravity / QA role.
**Depends on:** Prompts 1, 2, 3, 6, 7, 8 (everything except Art).
**Blocks:** call this "done".

Paste:

> You are the QA-role agent on the Pig & Swine RPG. Required reading:
>
> 1. Repo root `AGENTS.md`.
> 2. `godot/AGENTS.md` — full read, especially §Hard build invariants.
> 3. `godot/.antigravity/skills/qa.md`.
> 4. `godot/SPRINT_LOG.md` last 5 entries.
> 5. `godot/scripts/systems/minigames/coffee_brewing.gd` and
>    `godot/scenes/minigames/coffee_brewing.tscn` after Phase 2.
> 6. `godot/data/dialogues/barista.json`, `godot/data/asia_hints.json`,
>    `godot/data/dialogues/pig.json`, `murrow.json`, `crab.json`,
>    `whimsy.json` — anywhere a coffee reaction was authored.
> 7. `godot/data/minigames/coffee_patterns.json` and
>    `godot/data/minigames/coffee_text.json`.
> 8. `minigames.txt` §Acceptance criteria — your verification matrix.
>
> Build:
>
> 1. **`godot/tests/test_coffee_brewing.gd`** — headless, SceneTree-based,
>    mirror the existing `tests/test_dialogue_runner.gd` structure. Tests:
>    - T1: scene loads without error.
>    - T2: load `chapter1_court_coffee` pattern, simulate 100% perfect hits
>      (advance time, synthesize `move_left`/`move_right` actions at each
>      note's `time`), assert final buff == `procedurally_alert_plus` and
>      grade == `S`.
>    - T3: same pattern, simulate all misses (advance time without any
>      input), assert buff == `over_caffeinated` and grade ∈ {`D`, `F`}.
>    - T4: assert that on completion, `State.data.chapter1.coffee_tutorial_seen`
>      flipped to true and `Signals.minigame_finished` emitted with
>      `minigame_id == "coffee_brewing"`.
>    - T5: assert that `Signals.coffee_brewing_completed` fired with a
>      result dict containing the spec's required keys (`grade`, `result`,
>      `buff`, `brew_quality`, `bitterness`, `perfect_hits`, `good_hits`,
>      `okay_hits`, `misses`, `assist_used`).
>    - T6: load `office_standard_coffee` pattern, assert
>      `pattern.lanes == 4` and the engine accepts `move_up`/`move_down`
>      inputs without crashing.
>    - T7: single-button assist on, simulate one-button-only input timed
>      perfectly, assert all hits register as Perfect (lane matching
>      disabled).
> 2. **Dialogue cross-reference check.** A short script
>    `tests/test_coffee_dialogue_xref.gd` that loads every coffee-related
>    dialogue state and asserts every triggered flag exists in
>    `state.gd::reset_state()` and every referenced `coffee_text.json`
>    key resolves. Mirrors any existing cross-ref tests.
> 3. **Run the full acceptance matrix.** Commands, from repo root:
>    ```
>    godot --headless --path godot --script tests/test_smoke.gd
>    godot --headless --path godot --script tests/test_runner.gd
>    godot --headless --path godot --script tests/test_save_migration_v8_v9.gd
>    godot --headless --path godot --script tests/test_save_migration_v9_v10.gd
>    godot --headless --path godot --script tests/test_coffee_brewing.gd
>    godot --headless --path godot --script tests/test_coffee_dialogue_xref.gd
>    godot --headless --path godot --export-release "Web" exports/web/index.html
>    ```
>    On macOS, add `--log-file /tmp/godot_<tag>.log` to each command if
>    the userdata directory issue surfaces.
> 4. **Cross off the spec's acceptance criteria.** Write a markdown table
>    in the SPRINT_LOG entry, one row per acceptance line in
>    `minigames.txt` §Acceptance criteria, marking each ✅ or ⚠️ with a
>    one-line note. Items that require human visual verification (e.g.
>    "the final stamp moment feels satisfying") are marked ⚠️ human and
>    delegated.
> 5. **SPRINT_LOG entry.** Single dated paragraph with files touched
>    across all nine prompts, AC results, schema-bump notes (v8 → v9 → v10),
>    and the spec-acceptance-criteria table. Format: match the existing
>    Session entries.
>
> Don't:
> - Don't modify any production code. If a test fails, file a defect note
>   and stop. The fix belongs to the role that owns the file.
> - Don't modify any existing test. Append-only per QA file ownership.
> - Don't claim the web export passed unless `index.html`, `index.wasm`,
>   `index.pck` all exist and are non-empty.
>
> Acceptance:
> - Every command above exits 0.
> - SPRINT_LOG entry committed.
> - Spec acceptance-criteria table shows ✅ on every mechanical line and
>   ⚠️ on at most the lines that require subjective human playtest.

---

# Notes on agent selection

The strong default is **Antigravity** — its role skills encode the project's
ownership boundaries, address-form rules, Taste Standard checks, and save
migration policy, and the role agents are tuned to read the right files in
the right order. **Codex** comes in for Prompt 2 only because that prompt is
a tight recipe-mirror of an existing test, and Codex tends to be fast on
single-file pattern-mirroring jobs.

If you want to compress the plan further: Prompts 3+6 can be one human pass
each (paste both at once into two different Antigravity sessions), and
Prompts 4+5 can be one Art-role session each rather than two — none of the
parallel prompts share files. Phase 0 must run first; Phase 3 must run last.
Phase 2 must follow Phase 1.
