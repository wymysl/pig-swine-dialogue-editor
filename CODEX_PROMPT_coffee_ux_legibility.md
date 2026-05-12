# Codex prompt — coffee minigame UX legibility pass

Paste everything below the line into Codex (after attaching the
`/Users/piotr/Documents/Silly projects/pig-swine-rpg/` folder).

This addresses the "I have no idea what to do" playtest feedback by
adding a pre-game instruction card, beefing up the phase label, and
showing a key-hint row. Code-only — no new art assets needed.

---

You are working on Pig & Swine RPG, a Godot 4.6.2 GDScript project. The
coffee minigame is mechanically complete and visually wired but a
human playtester reported they had no idea what to do when the
minigame started. The phase labels are too small, no instructions are
shown at game start, and the player can't tell which keys do what
during play. Your job is to make the minigame readable on first play
without changing any mechanics.

## Required reading

1. Repo root `AGENTS.md`.
2. `godot/AGENTS.md` §File ownership.
3. `minigames.txt` §Mini-Game 1 §Controls and §UI layout.
4. `godot/scenes/minigames/coffee_brewing.tscn` end-to-end. Locate:
   - `PhaseLabel` (Label, around line 128)
   - The existing `PromptSpawner` (Node2D)
   - The result panel layout (you'll mirror its overlay pattern for
     the instruction card)
5. `godot/scripts/systems/minigames/coffee_brewing.gd` — focus on the
   `Phase` enum, `_start_phase()`, and the very beginning of the run
   lifecycle (`_ready()` and whatever transitions to `Phase.GRIND`).
6. `godot/data/minigames/coffee_text.json` — Design's authored text
   strings. You may add new keys to this file but only those listed
   below in step 1; do not author any new dialogue lines.

## Files you may modify

- `godot/scenes/minigames/coffee_brewing.tscn`
- `godot/scripts/systems/minigames/coffee_brewing.gd`
- `godot/data/minigames/coffee_text.json` — additions only, no edits to
  existing keys

## Files you may NOT modify

- `godot/scenes/interiors/pig_swine_office.tscn` (uncommitted state at risk)
- `godot/scenes/interiors/cafe_paragraf.tscn`
- Any `.txt` file at repo root
- `godot/scripts/autoload/state.gd` or `save.gd`
- Any other `.tscn` or `.gd` file
- Any test file
- Any art or audio asset

## Critical guardrails

- **No `git checkout` or `git restore` on any file.**
- **No Godot scripts that load/pack/save scene files.** Edit `.tscn`
  directly as plain text.
- **Don't change mechanics.** Timing windows, scoring, grade thresholds,
  pattern data — all stay as-is.

## Build steps

### Step 1 — Add UX strings to `coffee_text.json`

Add these keys, all under the existing dictionary structure (don't
introduce a new top-level key unless `coffee_text.json` is flat — match
the existing shape):

```
"intro_title":         "Court Coffee"
"intro_instructions":  "Hit A or D when icons reach the line. Hold E during the pour. Press E on the final stamp."
"intro_start_hint":    "[E] to start"
"keyhint_lane_left":   "A"
"keyhint_lane_right":  "D"
"keyhint_lane_up":     "W"
"keyhint_lane_down":   "S"
"keyhint_pour":        "[E] hold"
"keyhint_stamp":       "[E]"
"keyhint_quit":        "[Esc] pause"
"phase_grind_label":   "Grind"
"phase_pour_label":    "Pour"
"phase_serve_label":   "Serve"
```

Leave any existing keys untouched. If `coffee_text.json` already defines
phase labels under different keys, reuse those — don't duplicate.

### Step 2 — Add a `Phase.INTRO` state before GRIND

In `coffee_brewing.gd`, the `Phase` enum probably has values like
`READY, GRIND, POUR, SERVE, RESULT, EXIT`. Add `INTRO` as the FIRST
value (before READY/GRIND). The flow becomes:

```
INTRO → READY → GRIND → POUR → SERVE → RESULT → EXIT
```

(Or if there's no READY, just `INTRO → GRIND → POUR → SERVE → RESULT → EXIT`.)

The INTRO phase:
- Shows the instruction card (step 3 wires it).
- Waits for the player to press `interact` (E) to start.
- On press, transitions to whatever phase was first before this change
  (GRIND or READY).
- Has no timing logic, no input judgment, no audio playback.

In `_ready()`, set the phase to INTRO instead of whatever it was, and
ensure the existing first-phase trigger (probably called from
`_start_phase(Phase.GRIND)` or similar) doesn't fire automatically.

Add input handling: in `_unhandled_input()`, when `_phase == Phase.INTRO`
and the event is `interact` pressed, call `_start_phase(<next phase>)`.

### Step 3 — Add the instruction card to the scene

In `coffee_brewing.tscn`, add a new node `IntroCard` as a sibling of
`ResultPanel` (both children of `BackgroundPanel`). Structure:

```
IntroCard (ColorRect, full-viewport overlay, alpha 0.85, dark color)
├── TitleLabel (Label, centered top, large font, "Court Coffee")
├── InstructionsLabel (Label, centered middle, readable font, the
│                      intro_instructions string)
└── StartHintLabel (Label, centered bottom, smaller, "[E] to start")
```

Positioning:
- IntroCard: anchors_preset = 15 (full rect), color = Color(0.08, 0.06, 0.1, 0.9)
- TitleLabel: position centered at ~(640, 220), font size ~48 px,
  horizontal_alignment = 1, vertical_alignment = 1
- InstructionsLabel: position centered at ~(640, 360), font size ~24 px,
  horizontal_alignment = 1, vertical_alignment = 1, autowrap_mode = 2
  (word wrap)
- StartHintLabel: position centered at ~(640, 500), font size ~20 px,
  modulate slightly dimmed so it reads as a hint

Set `IntroCard.visible = true` initially. The engine will set it to
false on phase transition out of INTRO.

### Step 4 — Wire the instruction card from the engine

In `coffee_brewing.gd`:

Cache:
```gdscript
var _intro_card: ColorRect
var _intro_title: Label
var _intro_instructions: Label
var _intro_start_hint: Label
```

In `_ready` (or wherever node refs are cached):
```gdscript
_intro_card = get_node_or_null("BackgroundPanel/IntroCard") as ColorRect
_intro_title = get_node_or_null("BackgroundPanel/IntroCard/TitleLabel") as Label
_intro_instructions = get_node_or_null("BackgroundPanel/IntroCard/InstructionsLabel") as Label
_intro_start_hint = get_node_or_null("BackgroundPanel/IntroCard/StartHintLabel") as Label

if _intro_title:
    _intro_title.text = _text("intro_title")
if _intro_instructions:
    _intro_instructions.text = _text("intro_instructions")
if _intro_start_hint:
    _intro_start_hint.text = _text("intro_start_hint")
```

Where `_text(key)` is the existing helper that reads from
`coffee_text.json`. If no such helper exists, add a minimal one:

```gdscript
const COFFEE_TEXT_PATH := "res://data/minigames/coffee_text.json"
var _text_dict: Dictionary = {}

func _load_text() -> void:
    var file := FileAccess.open(COFFEE_TEXT_PATH, FileAccess.READ)
    if file:
        var raw := file.get_as_text()
        file.close()
        var parsed = JSON.parse_string(raw)
        if parsed is Dictionary:
            _text_dict = parsed

func _text(key: String) -> String:
    return _text_dict.get(key, key)
```

Call `_load_text()` from `_ready` before applying the text.

In the function that transitions out of INTRO (probably the same
`_start_phase()` switch), hide the intro card:
```gdscript
if _intro_card:
    _intro_card.visible = false
```

### Step 5 — Beef up `PhaseLabel`

The existing PhaseLabel is a Label in the scene. Make these changes
directly in the .tscn:

- Move it to a more prominent position (center-bottom, around y=620
  and centered horizontally — use `anchor_left = 0.5; anchor_right = 0.5`
  with appropriate offsets, or anchor it as anchors_preset = 7 / 8 with
  margin tweaks).
- Increase the font size to ~36-40 px. If the scene uses a default
  theme, override the font_size via `theme_override_font_sizes/font_size`.
- Add modulation animation: when phase changes, the label should pop in.
  Author a new short Animation sub_resource `phase_label_pulse` in the
  existing AnimationPlayer that does a 0.25s scale 1.4 → 1.0 on the
  PhaseLabel. Call `_anim_player.play("phase_label_pulse")` from
  `_start_phase()` AFTER setting the new text.

The phase strings should come from `coffee_text.json` via:
```gdscript
"phase_grind_label" → "Grind"
"phase_pour_label" → "Pour"
"phase_serve_label" → "Serve"
```

If the engine currently hard-codes phase strings in code, replace with
`_text("phase_grind_label")` etc. as part of this change. (If the
strings already come from JSON, leave that alone — just verify they
display.)

### Step 6 — Add a key-hint row

In the scene, add a new node `KeyHintRow` as a sibling of `PhaseLabel`,
also under `BackgroundPanel`. Position it just under PhaseLabel
(around y=670, full horizontal width). Structure:

```
KeyHintRow (HBoxContainer or just a positioned Control with child Labels)
├── HintLeft (Label, "A")
├── HintRight (Label, "D")
├── HintUp (Label, "W")          # hidden in 2-lane tutorial
├── HintDown (Label, "S")        # hidden in 2-lane tutorial
├── HintPour (Label, "[E] hold")
├── HintStamp (Label, "[E]")
└── HintQuit (Label, "[Esc] pause")
```

Each label gets its text from the corresponding `keyhint_*` JSON key.

Style: small, dimmed (`modulate = Color(1,1,1,0.6)`), monospace if a
mono font exists in the project theme; otherwise default.

Phase-aware visibility (driven from the engine):
- During INTRO: HintQuit only visible. Everything else hidden.
- During GRIND: HintLeft, HintRight visible. HintUp/HintDown visible only
  if `_pattern.lanes == 4`. HintQuit visible. Rest hidden.
- During POUR: HintPour and HintQuit visible. Lane hints can stay
  visible at lower alpha or hide entirely — your call.
- During SERVE: HintStamp visible (probably already shown via the lane
  hints), HintQuit visible.
- During RESULT: HintStamp shows `"[E] continue"` (override the text
  temporarily), all lane hints hidden.

In `_start_phase()`, after the existing phase transition logic, call a
new helper `_update_key_hints(phase)` that toggles the visible flags on
each hint label.

### Step 7 — Pause hint

The pause panel exists but isn't discoverable. Either:
(a) The `HintQuit` label in the key-hint row already covers this (says
"[Esc] pause") — sufficient if it's always visible.
(b) Optionally add a small "[Esc] pause" hint in the top-right corner
that's always visible regardless of phase. Lower priority — skip if
the key-hint row covers it.

### Step 8 — Verify

Run:
```
godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/ux_smoke.log
godot --headless --path godot --script tests/test_runner.gd --log-file /tmp/ux_runner.log
godot --headless --path godot --script tests/test_save_migration_v9_v10.gd --log-file /tmp/v9v10.log
```

If `tests/test_coffee_brewing.gd` exists from a parallel sprint, also
run it; it may fail T3+ because the new INTRO phase changes timing. If
that happens, leave the test alone and flag in your sprint log — the
test will be updated separately.

All other tests must exit 0. No new GDScript parser warnings.

## What to leave alone

- Mechanics: timing windows, scoring, judgment logic, result grading
- Audio playback
- The pause/accessibility panel — content unchanged, only your
  HintQuit label needs to know it exists
- Save schema
- The art assets themselves

## Acceptance

Mechanical:
- Smoke + runner exit 0
- No new parser warnings

Human playtest (delegated):
- On entering the minigame, an instruction card appears explaining what
  to do. Pressing E starts the actual minigame.
- The phase label is visible and pops in on each phase transition.
- A row of key hints near the bottom shows what each input does, and
  changes per phase.
- Pause is discoverable (either via the key-hint row or a separate hint).

## Sprint log

Append a dated paragraph to `godot/SPRINT_LOG.md` listing files touched
(the three), tests run, and any deferred work.
