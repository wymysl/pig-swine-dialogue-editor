# Code Quality Audit — 2026-05-17

Scope: `godot/scripts/**/*.gd`. Tests excluded. Snapshot commit attempt failed (`Operation not permitted` on `.git/objects/tmp_obj_*`, concurrent git process) — audit is read-only so this is non-blocking; flagging for the human to retry `git add -A && git commit --allow-empty` manually next run.

## Untyped Function Parameters
| File:Line | Function | Untyped Param |
|-----------|----------|---------------|
| scripts/actors/meeting_room_trigger.gd:106 | _on_chapter1_flag_changed | _value |
| scripts/actors/pickup.gd:162 | _pickup_state_value | current_value |

## Missing Return Annotations
| File:Line | Function Signature |
|-----------|--------------------|
| scripts/actors/pickup.gd:147 | `func _read_state_value(path: String):` |
| scripts/actors/pickup.gd:162 | `func _pickup_state_value(current_value):` |

## Undefined Signal References
| Signal Name | Used In | Not in signals.gd |
|-------------|---------|-------------------|
| _(none)_ | — | All 15 signals emitted/connected in runtime code are declared in `scripts/autoload/signals.gd`. |

## Hardcoded Player-Facing Strings
The convention (AGENTS.md §Stack invariants, §Forbidden patterns) requires all player-facing text live in JSON. The following strings are baked into `.gd` code and visible to players:

| File:Line | String | Why Flagged |
|-----------|--------|-------------|
| scripts/actors/behind_desk_zone.gd:21 | "Dr. A. Cula? Are you looking for paperclips?" | Asia dialogue line — should be in `data/dialogues/asia.json` or a Cula/Asia hint JSON. |
| scripts/actors/behind_desk_zone.gd:22 | "If you need to print something, just ask." | Same — Asia dialogue line baked into actor script. |
| scripts/actors/behind_desk_zone.gd:24 | "Have you lost something?" | Same. |
| scripts/actors/pig_idle_zone.gd:22 | "Every second you stand still, a client somewhere is also standing still. This is a coincidence I cannot afford." | Mr. Pig idle barb — should live in `data/dialogues/pig.json`. |
| scripts/actors/pig_idle_zone.gd:23 | "Standing still is a philosophical position, Dr. A. Cula. I do not endorse it professionally." | Same. |
| scripts/ui/blue_binder.gd:29-32 | "Address non-current", "Landlord knowledge", "Actual-notice window", "No third-party authority" | Packet-slot labels — should be sourced from `data/argument_frames_ch1.json` or a UI strings table. |
| scripts/ui/blue_binder.gd:44-47 | "Procedural reset", "Merits dismissal", "Tenancy ruling", "Dismissal with prejudice" | Remedy labels — same. |
| scripts/ui/blue_binder.gd:60,66,72,78 | "Notice-period fallback", "Standing / wrong party", "Overbroad remedy", "Incapacity by age (blunder)" | Frame-fallback labels — same. |
| scripts/ui/blue_binder.gd:264 | "Need at least %d required elements before filing." | UI status string — should be JSON-sourced. |
| scripts/ui/blue_binder.gd:275 | "Packet applied: %d/%d elements, remedy '%s'." | Same. |
| scripts/ui/blue_binder.gd:295 | "That evidence does not support %s." | Same. |
| scripts/ui/blue_binder.gd:388-389 | "No surfaced evidence yet" / "Surface evidence through dialogue and investigation, then return to the binder." | Empty-state UI copy — same. |
| scripts/ui/blue_binder.gd:468 | "Summary pending in evidence_ch1.json." | Placeholder copy in code — should be data-sourced placeholder. |
| scripts/ui/client_stance_menu.gd:36-38 | "Lead with how she's holding up." / "Lead with the timeline." / "Lead with the lease history." | Halina stance choices — duplicate the canonical `halina.json` `client_meeting_intro` options. `client_stance_menu.gd` is documented as retired (CONVENTIONS.md note) but still ships with hardcoded player text. |

`push_error` / `push_warning` diagnostic strings and `get_node_or_null("res://…")` / Node-path literals were excluded — those are not player-facing.

## SAVE_VERSION Migration Chain
PASS. Current `SAVE_VERSION = 19` (`state.gd:5`). `migrate_save` in `scripts/systems/save.gd` carries explicit `if old_version < N` blocks for every N from 2 through 19. No gaps detected.

## State Flag Multiple Writers
| Flag | Writer 1 | Writer 2 |
|------|----------|----------|
| _(none)_ | — | No `chapter1.<flag>` is assigned by more than one `.gd` file. Dialogue-driven flags route through `dialogue_runner.gd` (single engine writer) per design. |

## Naming Convention Violations
| File:Line | Found | Should Be |
|-----------|-------|-----------|
| scripts/autoload/binder_ui.gd:23 | `const BinderScenePath: String = "res://scenes/ui/blue_binder.tscn"` | `const BINDER_SCENE_PATH` (SCREAMING_SNAKE_CASE per AGENTS.md §Module conventions) |

## TODO / FIXME / HACK Comments
| File:Line | Text |
|-----------|------|
| _(none)_ | No `TODO`, `FIXME`, `HACK`, or `XXX` markers in `scripts/`. |

## Print Statements in Runtime Code
None.

## Summary
17 total issues. Top priority: **hardcoded player-facing strings in `behind_desk_zone.gd`, `pig_idle_zone.gd`, `blue_binder.gd`, and `client_stance_menu.gd`** — these violate a core architectural invariant ("Content is data, code is engine") and block i18n. Recommend lifting all 16 string-flagged lines into the appropriate JSON surfaces (`asia.json` / `pig.json` for idle barbs; a new `data/ui/binder_strings.json` or extending `argument_frames_ch1.json` for the binder UI; deletion of `client_stance_menu.gd` per the retirement note in CONVENTIONS.md §Dialogue option schema). The two missing return-type annotations and one camelCase const are 5-minute fixes and should land in the same sprint.

Notes:
- Snapshot commit failed due to `.git/objects` permission denial; manual `git commit --allow-empty` recommended.
- Several "Hardcoded player-facing strings" hits in `blue_binder.gd` rows 60/66/72/78 (`fallback_label`) and 29-32 (slot labels) are part of a Dictionary literal that already mirrors `argument_frames_ch1.json` taxonomy — the cleanest fix is to read the labels from that JSON rather than maintain a parallel table in code.
