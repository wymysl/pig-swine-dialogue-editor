# Code Quality Audit — 2026-05-24

## Untyped Function Parameters

| File:Line | Function | Untyped Param |
|-----------|----------|---------------|
| scripts/actors/meeting_room_trigger.gd:106 | `_on_chapter1_flag_changed` | `_value` |
| scripts/actors/pickup.gd:165 | `_pickup_state_value` | `current_value` |

## Missing Return Annotations

| File:Line | Function Signature |
|-----------|--------------------|
| scripts/actors/pickup.gd:150 | `func _read_state_value(path: String):` |
| scripts/actors/pickup.gd:165 | `func _pickup_state_value(current_value):` |

## Undefined Signal References

PASS. All six `Signals.*` accessors in `scripts/` map to declarations in `signals.gd`:
`chapter1_flag_changed`, `dialogue_dismissed`, `dialogue_line_ready`, `dialogue_requested`, `room_transition_finished`, `room_transition_started`.

Note: `signals.gd` declares 22 signals; the 16 unused-direct ones are accessed via the dynamic `get_node_or_null("/root/Signals")` pattern in `save.gd` and similar, and are not visible to this audit's pattern. Coverage of those routes is out of scope.

## Hardcoded Player-Facing Strings

| File:Line | String | Why Flagged |
|-----------|--------|-------------|
| scripts/ui/blue_binder.gd:30 | "Address non-current" | UI element label — belongs in `argument_frames_ch1.json` or i18n. |
| scripts/ui/blue_binder.gd:31 | "Landlord knowledge" | UI element label. |
| scripts/ui/blue_binder.gd:32 | "Actual-notice window" | UI element label. |
| scripts/ui/blue_binder.gd:33 | "No third-party authority" | UI element label. |
| scripts/ui/blue_binder.gd:45 | "Procedural reset" | UI remedy label. |
| scripts/ui/blue_binder.gd:46 | "Merits dismissal" | UI remedy label. |
| scripts/ui/blue_binder.gd:48 | "Dismissal with prejudice" | UI remedy label. |
| scripts/ui/blue_binder.gd:61 | "Notice-period fallback" | UI frame label. |
| scripts/ui/blue_binder.gd:67 | "Standing / wrong party" | UI frame label. |
| scripts/ui/blue_binder.gd:73 | "Overbroad remedy" | UI frame label. |
| scripts/ui/blue_binder.gd:79 | "Incapacity by age (blunder)" | UI frame label. |
| scripts/ui/blue_binder.gd:206 | "Need at least %d required elements before filing." | Player-facing toast/banner. |
| scripts/ui/blue_binder.gd:217 | "Packet applied: %d/%d elements, remedy '%s'." | Player-facing toast. |
| scripts/ui/blue_binder.gd:263 | "That evidence does not support %s." | Player-facing toast. |
| scripts/ui/blue_binder.gd:356 | "No surfaced evidence yet" | Player-facing empty-state. |
| scripts/ui/blue_binder.gd:357 | "Surface evidence through dialogue and investigation, then return to the binder." | Player-facing empty-state copy. |
| scripts/ui/blue_binder.gd:436 | "Summary pending in evidence_ch1.json." | Player-facing placeholder. |
| scripts/ui/save_status_toast.gd:39 | "Press [%s] to open your case folder." | Player-facing tutorial toast. |
| scripts/ui/client_stance_menu.gd:36 | "Lead with how she's holding up." | Player-facing menu prompt. |
| scripts/ui/client_stance_menu.gd:37 | "Lead with the timeline." | Player-facing menu prompt. |
| scripts/ui/client_stance_menu.gd:37 | "Blunt-procedural" | Player-facing label. |
| scripts/ui/client_stance_menu.gd:38 | "Lead with the lease history." | Player-facing menu prompt. |
| scripts/actors/behind_desk_zone.gd:21 | "Dr. A. Cula? Are you looking for paperclips?" | Asia NPC dialogue line — belongs in `asia.json`. |
| scripts/actors/behind_desk_zone.gd:22 | "If you need to print something, just ask." | Asia NPC dialogue line. |
| scripts/actors/behind_desk_zone.gd:24 | "Have you lost something?" | Asia NPC dialogue line. |
| scripts/actors/pig_idle_zone.gd:22 | "Every second you stand still, a client somewhere is also standing still…" | Mr. Pig NPC barb — belongs in `pig.json`. |
| scripts/actors/pig_idle_zone.gd:23 | "Standing still is a philosophical position, Dr. A. Cula. I do not endorse it professionally." | Mr. Pig NPC barb. |
| scripts/systems/save.gd:84 | "State data is unavailable." | Reaches player via `save_failed` signal payload (rendered in toast). |
| scripts/systems/save.gd:94 | "Cannot create the save directory." | Reaches player via `save_failed`. |
| scripts/systems/save.gd:98 | "Cannot open the save file for writing." | Reaches player via `save_failed`. |
| scripts/systems/save.gd:114 | "State data is unavailable." | Reaches player via `save_failed`. |
| scripts/systems/save.gd:119 | "Cannot open the save file for reading." | Reaches player via `save_failed`. |
| scripts/systems/save.gd:126 | "The save file is corrupt; progress was reset." | Reaches player via `save_failed`. |
| scripts/systems/minigames/coffee_brewing.gd:1171 | "Quality: %d  Bitterness: %d  Combo: %d" | Likely a player-facing HUD readout. Verify context. |

Excluded as dev-diagnostic (push_error/push_warning prefixed `ScriptName:`): ~100 strings in `dialogue_runner.gd`, `casebook.gd`, `battle_controller.gd`, `door.gd`, `meeting_room_trigger.gd`, `pickup.gd`, `room_transition.gd`, `main_controller.gd`, `effectiveness.gd`. Also excluded: node-path string literals in `coffee_brewing.gd` (`BackgroundPanel/...`).

## SAVE_VERSION Migration Chain

PASS (1→21 complete).
Current SAVE_VERSION: 21.

Verified: every step from `old_version < 2` through `old_version < 21` exists in `save.gd::migrate_save`.

## State Flag Multiple Writers

None (after excluding `state.gd` defaults and `save.gd` migration defaults — those are infrastructure, not gameplay writers). Every chapter1 flag has exactly one gameplay writer.

Raw scan (no exclusions) flagged 5 flags shared between `save.gd` migration code and the canonical writer; this is the expected pattern for defaults-on-load and is not a violation.

## Naming Convention Violations

None. No camelCase identifiers detected in `scripts/`.

## TODO / FIXME / HACK Comments

| File:Line | Text |
|-----------|------|
| scripts/autoload/signals.gd:11 | `## TODO(consumer): Badge/toast feedback is deferred; see 2026-05-19 tech critique F5.` |
| scripts/autoload/signals.gd:16 | `## TODO(consumer): Pickup acknowledgment UI is deferred; see 2026-05-19 tech critique F5.` |
| scripts/autoload/signals.gd:22 | `## TODO(consumer): Pause/HUD affordance is deferred; see 2026-05-19 tech critique F5.` |
| scripts/autoload/signals.gd:151 | `## TODO(consumer): Judge-skepticism camera/HUD response is deferred; see 2026-05-19 tech critique F5.` |

All four are tracked deferrals from the 2026-05-19 tech critique (F5).

## Print Statements in Runtime Code

None.

## Summary

39 total issues. Breakdown: 2 untyped params, 2 missing return annotations, 34 hardcoded player-facing strings, 4 tracked TODOs. Migration chain, signals, multi-writer, naming, and `print()` checks all PASS.

Top priority: extract the ~34 player-facing strings out of `.gd` files into the JSON data layer. `scripts/ui/blue_binder.gd` is the largest offender (17 strings — element/remedy labels and toast copy) and is the cleanest fix: most of the labels duplicate ids that already exist in `argument_frames_ch1.json` / `judgments.json`. `behind_desk_zone.gd` and `pig_idle_zone.gd` are smaller but more important to fix — they're NPC dialogue lines living outside the dialogue system, which means they bypass the speaker registry, `once: true` plumbing, and trust-meter/flag wiring that the rest of the dialogue layer enforces.

Secondary: the two `pickup.gd` annotation gaps (`_read_state_value`, `_pickup_state_value`) are a one-line fix — `current_value` is a `Variant` and the return is also `Variant`; type both explicitly.
