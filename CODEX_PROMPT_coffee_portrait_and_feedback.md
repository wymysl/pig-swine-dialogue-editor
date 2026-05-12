# Codex prompt — coffee minigame portrait wiring + miss/wrong feedback sprites

Paste everything below the line into Codex (after attaching the
`/Users/piotr/Documents/Silly projects/pig-swine-rpg/` folder to its session).

---

You are working on Pig & Swine RPG, a Godot 4.6.2 GDScript project. The
coffee-brewing mini-game is mechanically complete and visually wired except
for two gaps: the `CharacterReactionPortrait` slot is empty and never updates,
and two miss-feedback sprites (`bitter_foam.png`, `puff_offended.png`) exist
on disk but never spawn. Your job is to wire all three.

## Required reading (before editing)

1. Repo root `AGENTS.md`.
2. `godot/AGENTS.md` — focus on §File ownership, §Forbidden patterns.
3. `minigames.txt` §Mini-Game 1 §Visual feedback, §Character reactions.
4. `godot/scenes/minigames/coffee_brewing.tscn` — locate the existing
   `CharacterReactionPortrait` Sprite2D node (around line 386 — position
   Vector2(160, 160), no texture assigned).
5. `godot/scripts/systems/minigames/coffee_brewing.gd` — read end-to-end.
   You need to find:
   - `_show_result()` — the function that activates the result panel and the
     correct stamp.
   - `_register_judgment(judgment, note_data)` — the central dispatcher with
     branches for `"perfect"`, `"good"`, `"okay"`, `"miss"`, `"wrong"` etc.
     The miss branch already calls `_play_anim("machine_angry")`.
   - The wrong-input call sites (search for `_wrong_hits += 1`) — three
     places, all already call `_play("note_miss")` and
     `_play_anim("machine_angry")`.

## Files you may modify (exactly two)

- `godot/scenes/minigames/coffee_brewing.tscn`
- `godot/scripts/systems/minigames/coffee_brewing.gd`

## Files you may NOT modify (absolutely)

- `godot/scenes/interiors/pig_swine_office.tscn` — uncommitted scene state
  was destroyed by a previous agent reverting this file. Do not touch.
- `godot/scenes/interiors/cafe_paragraf.tscn`
- Any `.txt` file at repo root
- `godot/scripts/autoload/state.gd`, `godot/scripts/systems/save.gd` — schema
  is at v10 and stable
- Any test file
- Any `.tscn` other than `coffee_brewing.tscn`
- Any portrait or sprite PNG (the placeholders on disk are what you wire;
  do not regenerate them)

## Critical guardrails

- **Do not run `git checkout`, `git restore`, or any reverting git command on
  any file.** Substantial uncommitted scene state exists in this repo.
- **Do not author Godot scripts that mutate `.tscn` files via
  `load(...).instantiate()` → `PackedScene.pack()` → `ResourceSaver.save()`.**
  Edit the `.tscn` directly as plain text.
- **Do not redesign or refactor the engine state machine.** Add lines, don't
  rewrite functions.

## Asset inventory (all on disk; you wire them, not regenerate them)

Barista reaction portraits (512×512, geometric placeholders — real
illustrations will replace them later, do not touch the files):
- `godot/art/portraits/barista/perfect.png`
- `godot/art/portraits/barista/good.png`
- `godot/art/portraits/barista/okay.png`
- `godot/art/portraits/barista/bad.png`
- `godot/art/portraits/barista/machine_objects.png`

Miss-feedback sprites (32×32 each):
- `godot/art/minigames/coffee/bitter_foam.png` — Miss splat
- `godot/art/minigames/coffee/puff_offended.png` — Wrong-input puff

## Build steps

### Step 1 — Add five new ext_resources to `coffee_brewing.tscn`

Add Texture2D ext_resources for the five barista portraits. Use stable ids:
`portrait_barista_perfect`, `portrait_barista_good`, `portrait_barista_okay`,
`portrait_barista_bad`, `portrait_barista_machine_objects`.

The miss-feedback PNGs are spawned via code (preloaded in the .gd), not via
the scene file — no new .tscn ext_resources needed for those.

Bump `load_steps` in the `[gd_scene]` header by 5.

### Step 2 — Set a default texture on `CharacterReactionPortrait`

The node exists at scene line ~386 as a `Sprite2D` parented to
`BackgroundPanel` at `position = Vector2(160, 160)`. Add a `texture` line
pointing at `portrait_barista_good` (a sane neutral default — the barista
looks generally pleased before the player has done anything). Also set
`visible = false` initially — the portrait stays hidden until the result
reveal. The engine flips visibility on result (step 4).

### Step 3 — Add a portrait dictionary and preloads at script top

In `coffee_brewing.gd`, near the existing `PROMPT_TEXTURES` and `CUP_TEXTURES`
constants, add:

```gdscript
const BUFF_TO_PORTRAIT: Dictionary = {
    "procedurally_alert_plus": preload("res://art/portraits/barista/perfect.png"),
    "procedurally_alert":      preload("res://art/portraits/barista/good.png"),
    "caffeinated":             preload("res://art/portraits/barista/okay.png"),
    "over_caffeinated":        preload("res://art/portraits/barista/bad.png"),
    ## F-grade override handled in code — see _show_result()
}
const PORTRAIT_MACHINE_OBJECTS: Texture2D = preload("res://art/portraits/barista/machine_objects.png")

const BITTER_FOAM_TEXTURE: Texture2D = preload("res://art/minigames/coffee/bitter_foam.png")
const PUFF_OFFENDED_TEXTURE: Texture2D = preload("res://art/minigames/coffee/puff_offended.png")
```

Cache the portrait node in `_ready` alongside the other node references:

```gdscript
_reaction_portrait = get_node_or_null("BackgroundPanel/CharacterReactionPortrait") as Sprite2D
```

Add the corresponding `var _reaction_portrait: Sprite2D` near the other node
member declarations.

### Step 4 — Wire portrait selection in `_show_result()`

Find `_show_result()`. Right after the existing stamp-selection block (where
`StampAdmitted` or `StampObjected` becomes visible), add portrait selection
keyed off the result's buff string AND the grade. The F-grade case overrides
to `PORTRAIT_MACHINE_OBJECTS` regardless of buff:

```gdscript
if _reaction_portrait:
    var portrait_tex: Texture2D = null
    if grade_string == "F":
        portrait_tex = PORTRAIT_MACHINE_OBJECTS
    else:
        portrait_tex = BUFF_TO_PORTRAIT.get(buff_string)
    if portrait_tex:
        _reaction_portrait.texture = portrait_tex
        _reaction_portrait.visible = true
```

Use whatever local variable names the existing function already has for the
buff and grade strings. If those variables aren't already named
`buff_string` / `grade_string`, adapt the snippet.

### Step 5 — Add a one-shot fade-out spawn helper

In `coffee_brewing.gd`, add a private helper:

```gdscript
func _spawn_fade_sprite(texture: Texture2D, at_position: Vector2, duration: float = 0.45) -> void:
    if texture == null:
        return
    var sprite := Sprite2D.new()
    sprite.texture = texture
    sprite.position = at_position
    sprite.z_index = 5
    _prompt_spawner.add_child(sprite)
    var tween := create_tween()
    tween.tween_property(sprite, "modulate:a", 0.0, duration)
    tween.tween_callback(sprite.queue_free)
```

Parent under `_prompt_spawner` so it shares the same coordinate space as the
falling prompts. Use `z_index = 5` so it draws above lanes but below UI.

### Step 6 — Spawn bitter_foam on Miss

In `_register_judgment()`, find the `"miss"` branch (the one currently
calling `_play("note_miss")` and `_play_anim("machine_angry")`). Add one
line after those:

```gdscript
_spawn_fade_sprite(BITTER_FOAM_TEXTURE, _note_position_or_timing_line(note_data))
```

Author the helper that extracts a position from `note_data` (the dict that
`_register_judgment` already receives). If the note's tracked sprite still
exists in `_active_notes` metadata, use its current position; otherwise fall
back to the timing line's center on the relevant lane:

```gdscript
func _note_position_or_timing_line(note_data: Dictionary) -> Vector2:
    var lane: int = int(note_data.get("lane", 0))
    var lane_x: float = 475.0 + float(lane) * 100.0
    var timing_y: float = 400.0
    var sprite = note_data.get("sprite")
    if sprite is Sprite2D and is_instance_valid(sprite):
        return sprite.position
    return Vector2(lane_x, timing_y)
```

(If the engine's `_active_notes` doesn't store a `sprite` field, omit that
branch and just return the lane/timing-line position. Find out by reading
how `_spawn_note` records the note.)

Also add the same line to the miss case in `_check_missed_notes()` (where
notes that scrolled past the timing line without input get registered as
misses).

### Step 7 — Spawn puff_offended on wrong input

Find the three call sites where `_wrong_hits += 1`. After each, add:

```gdscript
_spawn_fade_sprite(PUFF_OFFENDED_TEXTURE, _coffee_machine_position())
```

Helper:

```gdscript
func _coffee_machine_position() -> Vector2:
    if _machine_sprite and is_instance_valid(_machine_sprite):
        return _machine_sprite.position + Vector2(0, -60)
    return Vector2(160, 240)
```

(Replace `_machine_sprite` with whatever cached reference the engine already
holds for `CoffeeMachineSprite`. If none is cached, cache it in `_ready` as
part of this work — one new line.)

### Step 8 — Verify

Run:
```
godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/coffee_v2_smoke.log
godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/coffee_v2_runner.log
```
Both exit 0. No new GDScript parser warnings.

## What to leave alone

- Phase state machine, timing windows, judgment logic
- Audio dictionary and `_play()` helper
- Save schema (v10, stable)
- Existing animations, stamp logic, sparkle particles
- All other portrait files in `art/portraits/` (cula.png, asia.png, etc.) —
  those are for the dialogue system, not this minigame
- The orphan-but-now-unused fields, if any — don't refactor

## Acceptance

Mechanical:
- Smoke + runner exit 0
- No new parser warnings introduced
- The five new ext_resources are present and the load_steps count matches

Visual (delegated to human playtest):
- On the result screen, the appropriate barista expression appears
  next to the result stamps (perfect / good / okay / bad / machine_objects
  by buff and grade)
- On every Miss, a foam splat appears at the missed prompt's last position
  and fades out
- On every Wrong input, an offended puff appears above the coffee machine
  and fades out

## Sprint log

Append a dated paragraph to `godot/SPRINT_LOG.md` following the existing
format. Title it as a follow-up to Session 16's "Human action needed" item.
Note that the portraits on disk are still the geometric placeholders — the
wiring is in place so a future portrait swap will land automatically.
