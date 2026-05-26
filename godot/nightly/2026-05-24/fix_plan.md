# Fix Plan — 2026-05-24 Code Audit

Companion to `code_audit.md`. Ordered by risk-adjusted value: quick type fixes first, then label extraction (mechanical, high-volume, low-risk), then dialogue migration (moderate, design-sensitive), then string-table consolidation (cross-cutting), then deferral decisions.

## Phase 1 — Type annotations (quick wins, ~15 min)

Single-file edits, no behavior change. Run `test_smoke.gd` + `test_runner.gd` after.

1. `scripts/actors/pickup.gd:150` — change `func _read_state_value(path: String):` to `func _read_state_value(path: String) -> Variant:`. Variant is correct: callers consume it as bool/string/int.
2. `scripts/actors/pickup.gd:165` — change `func _pickup_state_value(current_value):` to `func _pickup_state_value(current_value: Variant) -> Variant:`. Same reasoning.
3. `scripts/actors/meeting_room_trigger.gd:106` — change `_value` to `_value: Variant`. Matches `signals.gd::chapter1_flag_changed(flag_name: String, new_value: Variant)`. Parameter is intentionally unused (leading underscore), so no body change needed.

## Phase 2 — Blue Binder labels into JSON (~1–2 h)

The 11 element/remedy/frame labels in `blue_binder.gd` lines 30–79 duplicate ids that already exist in `data/argument_frames_ch1.json` and `data/judgments.json`. The 6 banner/toast strings (lines 206, 217, 263, 356, 357, 436) need a new home.

Approach:

1. Audit the three JSON files. Confirm each label key maps 1:1 to an existing `id` field. Memory note: `reference_pig_swine_judgments_schema.md` says move entries declare `name` and `flavor_line` — `name` is the player-facing label and is already authoritative. Use it.
2. In `blue_binder.gd`, replace the inline label arrays with a JSON lookup at `_ready()`. Cache the resulting `Dictionary[id -> label]` on the node. Avoid per-frame I/O.
3. For the 6 banner/toast strings, add `data/ui/blue_binder_strings.json`:
   ```json
   {
     "need_min_elements": "Need at least %d required elements before filing.",
     "packet_applied": "Packet applied: %d/%d elements, remedy '%s'.",
     "evidence_does_not_support": "That evidence does not support %s.",
     "empty_state_title": "No surfaced evidence yet",
     "empty_state_body": "Surface evidence through dialogue and investigation, then return to the binder.",
     "summary_pending": "Summary pending in evidence_ch1.json."
   }
   ```
4. Load this file via the existing JSON-load pattern in `blue_binder.gd::_ready()` (it already opens `evidence_ch1.json` and `argument_frames_ch1.json`).
5. Verify: open binder in-game, cycle through tabs, trigger each banner condition (apply incomplete packet, mismatch an element, view empty state).

Risk: low. No save shape change. No dialogue runner touch.

## Phase 3 — Zone-trigger NPC lines into dialogue system (~1–2 h, design-sensitive)

`behind_desk_zone.gd` and `pig_idle_zone.gd` hold NPC dialogue inline. This bypasses the speaker registry, `once: true` plumbing, address-form audit, and the voice_audit toolchain. Memory note: `feedback_pig_swine_voice_pack_execution.md` and `feedback_pig_swine_address_forms.md` apply — these lines must pass voice_audit.

Approach:

1. **Inspect first.** Confirm current behavior: are these lines fired once, repeatable, or random-pool? Are they shown via the full dialogue box, or as a transient toast? Read both .gd files end-to-end before touching anything.
2. **Pick a delivery channel.**
   - If full dialogue box: add states to `asia.json` and `pig.json` with `silent: true` triggered by `met_<x>` flags or zone-specific flags. Emit `Signals.dialogue_requested(npc_id, display_name)` from the zone. Reuses existing infrastructure cleanly.
   - If ephemeral toast (overhead barb that doesn't pause the player): introduce a new `Signals.npc_barb_emitted(npc_id, line)` signal + a small toast renderer. Lines still live in JSON (e.g., `data/dialogues/asia_zone_barbs.json` shaped `{ "<zone_id>": ["line1", "line2"] }`).
3. Pick **one** channel per zone; do not mix. Lean toward the full dialogue box if the player currently presses to dismiss — the existing UI is the path of least resistance.
4. Move lines:
   - `behind_desk_zone.gd:21-24` → asia.json (canonical Asia voice; verify address-forms against `feedback_pig_swine_address_forms.md`: "Dr. A. Cula" with middle initial is correct here).
   - `pig_idle_zone.gd:22-23` → pig.json.
5. Run `python tools/voice_audit.py godot/data/voice_references/` after.

Risk: moderate. Touches dialogue runner load path if new files added — list them in the runner's dialogues directory or update the loader.

Premise check before doing this: confirm these zones are still in play. If `behind_desk_zone` is a legacy mechanic superseded by Asia's standard interactable, the lines may be dead code and the fix is deletion, not migration.

## Phase 4 — Remaining UI strings (~45 min)

Six save-error strings, four client-stance prompts, one save-status toast, possibly one coffee-brewing HUD readout. Small enough for a single shared file.

1. Create `data/ui/strings.json`:
   ```json
   {
     "save": {
       "state_unavailable": "State data is unavailable.",
       "cannot_create_dir": "Cannot create the save directory.",
       "cannot_write": "Cannot open the save file for writing.",
       "cannot_read": "Cannot open the save file for reading.",
       "corrupt_reset": "The save file is corrupt; progress was reset."
     },
     "save_status_toast": {
       "open_case_folder_hint": "Press [%s] to open your case folder."
     },
     "client_stance_menu": {
       "stance_holding_up": "Lead with how she's holding up.",
       "stance_timeline": "Lead with the timeline.",
       "stance_lease_history": "Lead with the lease history.",
       "stance_label_blunt_procedural": "Blunt-procedural"
     }
   }
   ```
2. Add a tiny `scripts/autoload/ui_strings.gd` autoload exposing `get(category: String, key: String) -> String`. Load lazily on first access; cache.
3. Update each call site to `UiStrings.get(...)`.
4. **`coffee_brewing.gd:1171` — investigate first.** "Quality: %d  Bitterness: %d  Combo: %d" reads like a debug HUD overlay. If it's a hidden dev readout, leave in `.gd` with a comment noting it is non-shipping. If it's player-visible, move into `strings.json::coffee_brewing.live_readout`.

Risk: low. New autoload is additive; no save shape change.

## Phase 5 — Deferred TODOs (decision, no code)

The four `TODO(consumer)` lines in `signals.gd` are tracked deferrals from the 2026-05-19 tech critique (F5): badge popup, pickup acknowledgment, pause/HUD, judge skepticism. They are not bugs.

Decide explicitly: keep deferred until F5 lands as a sprint, or close them out one by one. Recommend keeping the TODOs in place; they document an intentional gap and link the rationale. Audit will continue to list them, which is fine — the count goes to zero when F5 ships.

## Out of scope

- The `save.gd` migration default writes flagged in Phase 6 of the audit. These are infrastructure (idempotent backfill on load) and intentionally write the same default that `state.gd::reset_state()` declares. No change.
- The ~100 dev-diagnostic `push_error` strings prefixed with `ScriptName:`. They are appropriate where they are; moving them to JSON would obscure the script that produced them.

## Verification per phase

- Phase 1: `godot --headless --path godot --script tests/test_smoke.gd` + `test_runner.gd`.
- Phase 2: in-engine manual binder walkthrough; same tests.
- Phase 3: `python tools/voice_audit.py godot/data/voice_references/`; in-engine zone trigger; same tests.
- Phase 4: in-engine save-error toast (force-fail by `chmod -w user://`); same tests.
- All phases: confirm `test_save_migrations` still green — none of these changes should touch save shape, so this is a regression backstop.
