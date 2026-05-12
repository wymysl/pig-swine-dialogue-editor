# Codex prompt — coffee minigame art wiring

Paste everything below the line into Codex. The prompt is self-contained.

---

You are working on Pig & Swine RPG, a Godot 4.6.2 GDScript project. Your job
is to wire existing PNG assets into the coffee-brewing mini-game scene,
rewrite the prompt-spawner so falling notes display as themed icon sprites
instead of single-letter labels, and author AnimationPlayer states for the
coffee machine and cup. All assets exist on disk. The audio is already wired.
This is a surgical edit of two files.

## Required reading (read before writing anything)

1. Repo root `AGENTS.md`.
2. `godot/AGENTS.md` — focus on §File ownership, §Stack invariants, §Forbidden
   patterns. You are operating as the Code role.
3. `godot/CONVENTIONS.md` §Canonical numbers and §Y-sort and Sprite2D origin
   convention. You will use the offset rule on every new Sprite2D you add.
4. `minigames.txt` §Mini-Game 1 §UI layout, §Visual style, §Meters.
5. `godot/scenes/minigames/coffee_brewing.tscn` end-to-end. The scene already
   has every node you need; you are filling slots, not adding nodes (except
   the meter foreground/background sprite pair).
6. `godot/scripts/systems/minigames/coffee_brewing.gd` — at minimum the
   functions `_spawn_note`, `_icon_label`, `_register_judgment`,
   `_update_meters` (or whatever updates Brew Quality / Bitterness), and the
   result-reveal path.
7. `godot/data/minigames/coffee_patterns.json` — note `icon` values you must
   map to textures.

## Files you may modify (exactly two)

- `godot/scenes/minigames/coffee_brewing.tscn`
- `godot/scripts/systems/minigames/coffee_brewing.gd`

## Files you may NOT modify (absolutely)

- `godot/scenes/interiors/pig_swine_office.tscn` — uncommitted scene state was
  destroyed by another agent reverting this file recently. Do not touch it.
- `godot/scenes/interiors/cafe_paragraf.tscn` — has stale UID warnings. Will
  be fixed separately. Do not touch.
- Any `.txt` file at repo root.
- `godot/scripts/autoload/state.gd` or `godot/scripts/systems/save.gd` —
  schema is at v9 and stable.
- Any `.tscn` other than `coffee_brewing.tscn`.
- Any test file.

## Critical guardrails

**Do not run `git checkout`, `git restore`, or any reverting git command on
any file.** This project has substantial uncommitted scene state. Reverts
have destroyed real work. If you think you need to revert something, stop
and report instead.

**Do not author Godot scripts that mutate scene files via
`load(...).instantiate()` → `PackedScene.pack(scene)` → `ResourceSaver.save()`.**
That pattern has corrupted scenes in this repo. `.tscn` files are
human-readable text — edit them directly with the patch/edit tools.

**Do not use Godot's headless mode to "save" a scene file as part of your
workflow.** Only use headless Godot to RUN tests / smoke checks for
verification at the end.

## Asset inventory (all present on disk)

All under `godot/art/minigames/coffee/`:

Coffee machine states (4 PNGs):
- `coffee_machine_idle.png` — already wired as `ExtResource("art_machine_idle")`
- `coffee_machine_gurgle.png` — unwired
- `coffee_machine_happy.png` — unwired
- `coffee_machine_angry.png` — unwired

Cup fill stack (4 PNGs):
- `coffee_cup_empty.png` — already wired as `ExtResource("art_cup_empty")`
- `coffee_cup_fill_01.png` — unwired
- `coffee_cup_fill_02.png` — unwired
- `coffee_cup_fill_03.png` — unwired

Prompt icons (6 PNGs, all unwired):
- `prompt_bean.png`
- `prompt_milk.png`
- `prompt_sugar.png`
- `prompt_file.png`
- `prompt_mug.png`
- `prompt_stamp.png`

Other (unwired except where noted):
- `timing_line.png` — currently a ColorRect in the scene
- `meter_brew_bg.png`, `meter_brew_fill.png` — meters currently are Labels
- `meter_bitter_bg.png`, `meter_bitter_fill.png` — same
- `puff_offended.png` — for wrong-input feedback (optional)
- `result_stamp_admitted.png`, `result_stamp_objected.png` — already wired
- `sparkle.png` — already wired

## Current scene state (relevant excerpts)

`coffee_brewing.tscn` already has these nodes you will modify:

- `BackgroundPanel/CoffeeMachineSprite` (Sprite2D, position 160,300, idle texture wired)
- `BackgroundPanel/CupSprite` (Sprite2D, position 160,480, empty cup texture wired)
- `BackgroundPanel/TimingTrackRoot/Lane0..3` (ColorRects, x=430..820, y=80..430, 90px wide each)
- `BackgroundPanel/TimingLine` (ColorRect placeholder, x=420..830, y=395..405)
- `BackgroundPanel/PromptSpawner` (Node2D, empty container)
- `BackgroundPanel/BrewQualityMeter` (Label, x=900..1200, y=150..180)
- `BackgroundPanel/BitternessMeter` (Label, just below BrewQualityMeter)
- `AnimationPlayer` (exists, empty)

Lanes are 90px wide each, the timing line is at y=400, prompts fall from y=80
toward y=400 during the pattern.

## Build steps

### Step 1 — Add the missing ext_resources to `coffee_brewing.tscn`

Add Texture2D ext_resources for every unwired PNG above. Use stable id
strings (e.g., `art_machine_gurgle`, `art_cup_fill_01`, `art_prompt_bean`,
`art_timing_line`, `art_meter_brew_bg`, `art_meter_brew_fill`,
`art_meter_bitter_bg`, `art_meter_bitter_fill`, `art_puff_offended`). Bump
`load_steps` in the `[gd_scene]` header to match the new count.

### Step 2 — Replace `TimingLine` ColorRect with a Sprite2D

Same position (centered around y=400 across the lane span). Use
`art_timing_line` as the texture. If the PNG's native dimensions don't span
the full 410px lane width, scale it horizontally via `scale.x` or use
`region_enabled` with a 410px-wide region.

### Step 3 — Replace the two meter Labels with Sprite2D pairs

For each meter (`BrewQualityMeter`, `BitternessMeter`):

- Delete the existing Label node.
- Add a `Sprite2D` named `BrewQualityBg` (or `BitternessBg`) at the same
  position. Use the corresponding `meter_*_bg.png`.
- Add a `Sprite2D` named `BrewQualityFill` (or `BitternessFill`) immediately
  on top with the corresponding `meter_*_fill.png`. Enable
  `region_enabled = true` and set `region_rect = Rect2(0, 0, W, H)` where W
  is the full sprite width (the engine will narrow this at runtime to show
  the fill ratio).
- Add a child `Label` named `ValueLabel` over both sprites with the text
  format `"Brew Quality"` / `"Bitterness"`. Position it inside or above the
  bar — your call.

Important: keep the **node paths recognizable** to the engine. If the
existing GDScript references `$BackgroundPanel/BrewQualityMeter` as a Label
and calls `.text = "..."`, you must update those references to point at the
new structure. Search the .gd for every reference and either (a) keep a
Label named `BrewQualityMeter` as the parent group node and put the bg/fill
sprites as children, or (b) rename references in the .gd to the new node
paths. Option (a) is less invasive; do that if it works.

### Step 4 — Rewrite `_spawn_note` to use Sprite2D prompts

The current `_spawn_note` creates Label nodes with single-letter text from
`_icon_label`. Replace with Sprite2D instantiation:

```gdscript
const PROMPT_TEXTURES: Dictionary = {
    "bean":  preload("res://art/minigames/coffee/prompt_bean.png"),
    "milk":  preload("res://art/minigames/coffee/prompt_milk.png"),
    "sugar": preload("res://art/minigames/coffee/prompt_sugar.png"),
    "file":  preload("res://art/minigames/coffee/prompt_file.png"),
    "mug":   preload("res://art/minigames/coffee/prompt_mug.png"),
    "stamp": preload("res://art/minigames/coffee/prompt_stamp.png"),
}

func _spawn_note(note: Dictionary) -> void:
    var sprite := Sprite2D.new()
    var icon: String = note.get("icon", "bean")
    sprite.texture = PROMPT_TEXTURES.get(icon, PROMPT_TEXTURES["bean"])
    # Preserve existing position + lane assignment + descent-velocity logic
    # ...
    _prompt_spawner.add_child(sprite)
    # Track sprite in whatever per-note metadata structure the engine uses.
```

Preserve all motion / hit-detection logic — only change what gets
instantiated. If `_icon_label()` is now unused, delete it. If it's referenced
anywhere else, leave it alone.

### Step 5 — Author AnimationPlayer states

The AnimationPlayer node exists but has no animations. Author these as
inline `[sub_resource type="Animation"]` blocks in the .tscn:

- `machine_idle`: 1.0s, loop, single keyframe holding `CoffeeMachineSprite.texture`
  at `art_machine_idle`. Plays by default on `_ready`.
- `machine_gurgle`: 0.3s, no loop. Frame 0 sets texture to `art_machine_gurgle`,
  frame end resets to `art_machine_idle`.
- `machine_happy`: 0.5s, no loop. Same pattern with `art_machine_happy`.
- `machine_angry`: 0.4s, no loop. Sets `art_machine_angry` plus a 4° rotation
  shake on `CoffeeMachineSprite.rotation_degrees` (a couple of keyframes
  oscillating between -4° and +4°).
- `result_reveal`: 0.3s, no loop. Tweens ResultPanel modulate alpha 0 → 1.
- `stamp_impact`: 0.15s, no loop. Scale pulse 1.3 → 1.0 on whichever result
  stamp is visible at result time. Apply to both stamp nodes; whichever is
  hidden won't render the change visibly.

### Step 6 — Wire animation triggers and cup-fill into the engine

In `coffee_brewing.gd`:

- Cache the AnimationPlayer node in `_ready` as `_anim_player`.
- In `_register_judgment` (or whatever function categorizes the hit):
  - On `"perfect"`: `_anim_player.play("machine_happy")`. If a sparkle particle
    helper exists, fire it.
  - On `"good"`: `_anim_player.play("machine_gurgle")`.
  - On `"okay"`: `_anim_player.play("machine_gurgle")`.
  - On `"miss"` or `"wrong"`: `_anim_player.play("machine_angry")`.
- In whatever function updates `brew_quality`, also drive the cup-fill ladder:
  ```gdscript
  var progress := clamp(float(brew_quality) / float(MAX_BREW_QUALITY), 0.0, 1.0)
  var cup_textures := [
      preload("res://art/minigames/coffee/coffee_cup_empty.png"),
      preload("res://art/minigames/coffee/coffee_cup_fill_01.png"),
      preload("res://art/minigames/coffee/coffee_cup_fill_02.png"),
      preload("res://art/minigames/coffee/coffee_cup_fill_03.png"),
  ]
  var idx := clamp(int(progress * 4.0), 0, 3)
  $BackgroundPanel/CupSprite.texture = cup_textures[idx]
  ```
  (Lift the cup_textures array to a const at script top, not inline per call.)
- In whatever function updates the meters, set the fill sprite's
  `region_rect.size.x = full_width * ratio` for each meter.
- On result reveal: `_anim_player.play("result_reveal")` then queue a
  `stamp_impact` on the visible stamp.

If you can't find a single "update meters" function, the engine likely
updates the Label's `.text` inline at multiple call sites. Find them via
`grep` and consolidate into a `_update_meters()` helper as part of this
change — but only if doing so is straightforward; do not refactor the
state machine.

### Step 7 — Y-sort offsets on every Sprite2D you add

Per `godot/CONVENTIONS.md` §Y-sort and Sprite2D origin convention:
`offset.y = -(texture_height / 2)` for every Sprite2D that should anchor
at its bottom edge. Apply this to CoffeeMachineSprite, CupSprite, and the
meter bg/fill sprites if they sit on a surface. For the timing line and
prompt sprites, default centering is fine — they're floating UI.

For the prompt sprites created in `_spawn_note`, NO offset.y adjustment is
needed — they fall vertically and hit detection is on the node origin.

### Step 8 — Smoke verify

Run:

```
godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/coffee_smoke.log
```

Exit 0 expected. Then:

```
godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/coffee_runner.log
```

Exit 0 expected. If `godot/tests/test_coffee_brewing.gd` exists from an
earlier sprint, also run it; if it doesn't, skip.

## What to leave alone

- Phase state machine, timing windows, judgment logic.
- Audio dictionary and `_play()` helper.
- Save schema (v9, stable).
- The `PauseLayer` accessibility panel — verify it still renders on top of
  your new sprites but don't change its content.
- The result-grading math.
- Anything in `data/`.
- Anything in `tests/`.

## Acceptance

Mechanical:
- Smoke + runner exit 0.
- No new GDScript parser warnings introduced (you may leave existing ones).
- `_icon_label` is either removed entirely or unchanged — do not partially
  refactor it.

Visual (delegated to human playtest, but state expected behaviors):
- The coffee machine is a recognizable sprite.
- The cup visibly fills in four steps as the player hits notes.
- Prompts on the timing track show as themed icons (bean, sugar, milk,
  stamp, file, mug) not single letters.
- Brew Quality and Bitterness display as horizontal bars whose fills grow
  as values change.
- On result reveal, one of the two result stamps appears with a brief
  scale pulse.
- Machine sprite swaps to gurgle / happy / angry on hit / perfect / miss.

## Sprint log entry

Append a dated paragraph to `godot/SPRINT_LOG.md` matching the existing
format. Include files touched (the two), one-paragraph summary, AC results.
