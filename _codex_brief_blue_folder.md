# Codex Task — Build the Blue Folder (`case_folder.tscn`)

## Mission

Build a new Godot UI scene `case_folder.tscn` — Dr. A. Cula's persistent personal binder. **Distinct from** the existing per-case Motion Packet UI (`scenes/ui/blue_binder.tscn`), which stays as-is.

The Blue Folder is opened with hotkey `B` from any gameplay scene, has four tabs, and is the surface where the player views collected evidence, collected Casebook judgments, drafted argument fragments, and the current case's Motion Packet (the existing `blue_binder.tscn`, embedded or launched as the fourth tab).

This closes a real story gap: Asia's existing dialogue references "your blue folder," but Cula never picks one up or uses one. The new pickup interactable + hotkey + UI fix that.

## Required reading (consult in this order before writing code)

1. `/Users/piotr/Documents/Silly projects/pig-swine-rpg/AGENTS.md` — repo-level operating rules
2. `/Users/piotr/Documents/Silly projects/pig-swine-rpg/godot/AGENTS.md` — project constitution, file ownership, address-form rules
3. `/Users/piotr/Documents/Silly projects/pig-swine-rpg/godot/CONVENTIONS.md` — runtime conventions, viewport, palette
4. Last 5 entries of `/Users/piotr/Documents/Silly projects/pig-swine-rpg/godot/SPRINT_LOG.md`
5. `/Users/piotr/Documents/Silly projects/pig-swine-rpg/godot/PLAN.md` §Vertical slice plan, §Out of scope
6. `/Users/piotr/Documents/Silly projects/pig-swine-rpg/godot/PROPOSALS.md` — editorial decisions log; check before pitching
7. **Existing patterns to mirror (do not duplicate, reference for style consistency):**
   - `godot/scenes/ui/blue_binder.tscn` + `godot/scripts/ui/blue_binder.gd` — the per-case Motion Packet UI (you embed/launch this in the Motion Packet tab; do NOT reimplement it)
   - `godot/scenes/ui/dialogue_box.tscn` + `godot/scripts/ui/dialogue_box.gd` — modal show/hide, pause-on-open, input handling
   - `godot/scripts/autoload/casebook.gd` — collected-judgments source for the Casebook tab
   - `godot/scripts/autoload/state.gd` — State schema, `reset_state()`, `SAVE_VERSION` constant
   - `godot/scripts/systems/save.gd` — save migration pattern; mirror existing migration function naming
   - `godot/scripts/autoload/dialogue_runner.gd` — see how `award_badge` and `unlock_route` actions are implemented; add `add_argument_fragment` in the same shape with the same unknown-id rejection pattern
   - `godot/data/items.json` — evidence/inventory shape for the Evidence tab
   - `godot/data/dialogues/asia.json` — Asia's hint states; you will add a `hint_blue_folder` state priority-ordered after `met_asia`
8. **Save fixtures:** list `godot/tests/fixtures/` and use the most recent as the migration baseline. Do NOT modify existing fixtures — add a new one.

## Hard constraints

- Godot 4.6.2, typed GDScript only. No C#, addons, or GDExtension.
- **File ownership.** This work is Code role per `godot/AGENTS.md` §"File ownership table". You write `scenes/ui/case_folder.tscn`, `scripts/ui/case_folder.gd`, the State/save migration, the new signals, the input action, and the data file structure. You do NOT author player-facing strings in `.gd` or `.tscn` — every visible string flows through JSON. The new `data/case_folder_strings.json` and `data/argument_fragments.json` should have stub entries marked `"_doc": "DRAFT — human to finalize"` for text fields.
- **No hardcoded player-facing strings** in `.gd` or `.tscn`. Strings load from JSON.
- Cross-system communication via the `Signals` autoload only. Declare new signals at the top of `signals.gd` with a one-line payload comment.
- **Save migration is mandatory.** Bump `SAVE_VERSION`, add a migration step in `save.gd`, add a new test fixture (do NOT modify existing ones), add a migration test asserting `SAVE_VERSION >= N` (NOT `== N` — this is a project rule).
- **Address-form discipline** per `godot/AGENTS.md` §"Address forms in dialogue". Asia uses "Dr. A. Cula" and "Mr. Murrow". Any Asia line you draft as a placeholder must respect this even though Design will finalize the wording.
- **Dialogue JSON pretty-print contract.** Any edit to `data/dialogues/*.json` must roundtrip through `tools/verify_dialogue_roundtrip.js` (4-space indent, INLINE_LIMIT=300, trailing newline). Python `json.dumps(indent=2)` produces drift — do not use it.
- **Respect the dirty worktree.** Do not revert, rename, or normalize unrelated modified or untracked files.
- Hard build invariants must pass — see `godot/AGENTS.md` §"Hard build invariants".

## Scope

### IN SCOPE

1. **`scenes/ui/case_folder.tscn`** — the Blue Folder UI scene with four tabs.
2. **`scripts/ui/case_folder.gd`** — open/close, tab switching, input handling, pause-on-open, data binding to State / Casebook / inventory.
3. **Hotkey wiring.** Add an input action `case_folder_toggle` mapped to `B` in `project.godot`. Pressing the action opens/closes the folder. Suppress the action until `chapter1.has_case_folder == true`.
4. **Pickup interactable.** Add a `BlueFolder` Area2D + Sprite2D + pickup-script node tree to `scenes/interiors/pig_swine_office.tscn`. Place on Cula's desk within the bullpen zone (cols 13–17, rows 0–4). Interaction sets `chapter1.has_case_folder = true`, emits `Signals.case_folder_acquired`, and despawns/hides the pickup. Use a placeholder ColorRect for the visual until art lands.
5. **State schema additions** (mirror the field ownership pattern in `state.gd`):
   - `chapter1.has_case_folder: bool` (default `false`) — owned by the BlueFolder pickup.
   - `case_folder.argument_fragments: Array[Dictionary]` (top-level, NOT under `chapter1` — survives chapters). Each fragment: `{ "id": String, "title": String, "body": String, "tags": Array[String], "source_state": String, "added_at_chapter": int }`.
   - `case_folder.notes_seen: Dictionary` (top-level, `{ fragment_id: bool }`) so the UI can show NEW badges on unseen fragments.
6. **`SAVE_VERSION` bump + migration.** Check current value in `state.gd`, bump to the next integer, add migration step in `save.gd` named consistently with existing migrations, default-populate the new fields for old saves.
7. **New save fixture** in `tests/fixtures/` named after the new save version. Minimal contents — just enough for the migration test.
8. **Migration test** in `tests/test_save_load.gd` (or the existing save-migration test file): assert `SAVE_VERSION >= N`, load the previous-version fixture, assert it migrates cleanly and the new fields exist with correct defaults.
9. **Dialogue runner integration.** Add a new dialogue action `add_argument_fragment` taking a fragment id. When fired from `on_dismiss`:
   - Looks up the id in `data/argument_fragments.json`.
   - Appends the fragment to `State.data.case_folder.argument_fragments` (idempotent by id — adding the same fragment twice is a no-op).
   - Emits `Signals.case_folder_fragment_added(fragment_id)`.
   - Unknown ids warn and fail, matching the pattern already used for `award_badge` and `unlock_route` in `dialogue_runner.gd`.
10. **`data/argument_fragments.json`** — new data file. Schema below. Stub with 2–3 chapter-1-relevant fragments marked `"draft": true`. Code owns the file's existence and the loader; Design owns text fields.
11. **`data/case_folder_strings.json`** — new data file holding all UI strings (tab labels, empty-state copy, title strip text). Stub with `_doc: "DRAFT — human to finalize"` placeholders.
12. **Four tabs implemented:**
    - **Notes tab (default)** — lists collected argument fragments from `State.data.case_folder.argument_fragments`. Read-only viewer: title, tags, body. Entries with id absent from `case_folder.notes_seen` show a NEW badge. Marking an entry as viewed sets `notes_seen[fragment_id] = true`. Empty state pulls from `case_folder_strings.json`.
    - **Evidence tab** — lists items the player currently holds, read from `State.data.inventory` (check existing inventory key in `state.gd`; mirror the items.json shape). Read-only viewer: id, name, flavor. Empty state from strings file.
    - **Casebook tab** — lists judgments from the `Casebook` autoload. Read-only viewer: `judgment_name`, `case_summary`, `principle_moves[].name`. Skip entries marked `draft: true`. Empty state from strings file.
    - **Motion Packet tab** — embeds or launches `scenes/ui/blue_binder.tscn` for the current active case (read active case id from State; if none, show empty state from strings file). Reuse the existing scene; do NOT reimplement its packet-assembly logic.
13. **Pause-on-open.** While the Blue Folder is visible: `get_tree().paused = true`, and the folder's `process_mode` is set so it continues to receive input. Player movement and ambient dialogue triggers pause. Mirror `dialogue_box.gd`'s pattern.
14. **Input handling:**
    - `case_folder_toggle` (B) — toggle open/close.
    - `Escape` (`ui_cancel`) — close.
    - Tab cycling — left/right (`ui_left`/`ui_right`) or shoulder buttons (gamepad).
    - Entry navigation — up/down (`ui_up`/`ui_down`) within the current tab.
    - `Enter` (`ui_accept`) — open entry detail panel (Notes / Evidence / Casebook tabs only).
15. **Placeholder visuals** (final art is a follow-up Art role task; use these placeholders):
    - Background dimmer ColorRect — `Color(0, 0, 0, 0.6)`, full-screen.
    - Folder body ColorRect — `Color(0.18, 0.28, 0.52, 1.0)` (placeholder blue, represents the eventual lever-arch binder cover).
    - Page area ColorRect — `Color(0.92, 0.86, 0.72, 1.0)` (placeholder manila).
    - Tab bar — HBoxContainer with four Buttons, labels from `case_folder_strings.json`.
    - Title strip — Label at top, text key like `"folder_title"` from the strings file (placeholder content: `"CASE FOLDER — DR. A. CULA"`).
    - Selected tab indicator — color shift on the active Button.
16. **Asia hint state.** Add a new state to `data/dialogues/asia.json`, priority-ordered ahead of post-pickup states. Trigger: `met_asia && !chapter1.has_case_folder`. Lines: placeholder marked `"_doc": "DRAFT — human to author Taste Standard line pointing Cula at his blue folder on his desk"`. The `on_dismiss` does NOT set `has_case_folder` — only the pickup itself does. Verify via `tools/verify_dialogue_roundtrip.js`.
17. **Smoke test stub.** Add `tests/test_case_folder.gd` that loads `case_folder.tscn` headlessly, asserts the four tabs exist as children, asserts `case_folder_strings.json` and `argument_fragments.json` parse without error, asserts the `case_folder_toggle` action exists in `InputMap`.
18. **`SPRINT_LOG.md`** — append a dated entry summarising what was built.

### OUT OF SCOPE (defer to follow-up tasks)

- Final art (binder cover, manila paper, paper tabs, blue lever-arch graphics, stamp, NEW-badge icon). Placeholders only.
- Player free-text authoring of notes. Fragments are dialogue-driven only.
- Chapter 2+ fragment population. Stub 2–3 chapter-1 fragments only.
- Replacing or refactoring `scenes/ui/blue_binder.tscn`. The Motion Packet tab embeds/launches it as-is.
- Localisation. English-first per CONVENTIONS.
- Animations / transitions beyond simple show/hide.

## Schema specifications

### `data/argument_fragments.json`

```json
{
  "version": 1,
  "_doc": "Cula's collected argument fragments. Design owns text fields; Code owns structure and the loader.",
  "fragments": [
    {
      "id": "fragment_ch1_actual_notice",
      "title": "_doc: DRAFT — short title (≤8 words)",
      "body": "_doc: DRAFT — 1–3 sentence argument fragment",
      "tags": ["procedural", "notice"],
      "source_state": "_doc: DRAFT — dialogue state that added this fragment",
      "draft": true
    }
  ]
}
```

### `data/case_folder_strings.json`

```json
{
  "version": 1,
  "_doc": "All player-facing strings for the Blue Folder UI. Code owns keys; Design owns values.",
  "folder_title": "_doc: DRAFT — title strip text",
  "tab_labels": {
    "notes": "_doc: DRAFT",
    "evidence": "_doc: DRAFT",
    "casebook": "_doc: DRAFT",
    "motion_packet": "_doc: DRAFT"
  },
  "empty_states": {
    "notes": "_doc: DRAFT — shown when no fragments yet",
    "evidence": "_doc: DRAFT — shown when inventory empty",
    "casebook": "_doc: DRAFT — shown when no judgments collected",
    "motion_packet": "_doc: DRAFT — shown when no active case"
  },
  "new_badge_label": "_doc: DRAFT — e.g., 'NEW' or 'NIE PRZECZYTANE'"
}
```

### Dialogue action — `add_argument_fragment`

JSON shape used in a state's `on_dismiss` block:

```json
{
  "on_dismiss": [
    { "set": "chapter1.met_murrow", "to": true },
    { "add_argument_fragment": "fragment_ch1_actual_notice" }
  ]
}
```

### State additions (illustrative — match the actual `state.gd` patterns)

```gdscript
# In State.reset_state()
data["case_folder"] = {
    "argument_fragments": [],
    "notes_seen": {},
}
data["chapter1"]["has_case_folder"] = false
```

### Save migration step (illustrative — match the actual `save.gd` naming pattern)

```gdscript
# In save.gd — new migration function for version (N-1) -> N
func _migrate_v<prev>_to_v<new>(save: Dictionary) -> Dictionary:
    if not save.has("case_folder"):
        save["case_folder"] = {
            "argument_fragments": [],
            "notes_seen": {},
        }
    var data: Dictionary = save.get("data", {})
    var chapter1: Dictionary = data.get("chapter1", {})
    if not chapter1.has("has_case_folder"):
        chapter1["has_case_folder"] = false
    return save
```

### New signals in `signals.gd`

```gdscript
# Emitted when an argument fragment is added to the Blue Folder
signal case_folder_fragment_added(fragment_id: String)

# Emitted when the player picks up the Blue Folder for the first time
signal case_folder_acquired()

# Emitted when the Blue Folder UI opens or closes (for systems gating input)
signal case_folder_toggled(is_open: bool)
```

## Acceptance criteria

The task is complete when all of the following hold:

1. Pressing `B` in any gameplay scene opens the Blue Folder. Pressing `B` or `Escape` closes it. Movement and dialogue triggers pause while open.
2. Before Asia's `hint_blue_folder` fires and before the player interacts with the BlueFolder pickup in `pig_swine_office.tscn`, the `B` hotkey is suppressed (no folder opens). After pickup, it works for the rest of the game.
3. All four tabs render with placeholder visuals. Empty states display the strings from `data/case_folder_strings.json`.
4. The Notes tab reflects fragments added via `add_argument_fragment` dialogue actions. Adding the same fragment twice is a no-op.
5. The Evidence tab reflects the player's current inventory.
6. The Casebook tab reflects judgments in the `Casebook` autoload, skipping `draft: true` entries.
7. The Motion Packet tab opens or embeds the existing `blue_binder.tscn` without breaking its existing behaviour. If no active case is set, the empty state from the strings file is shown instead.
8. `SAVE_VERSION` is bumped. The new migration step runs against the new test fixture and a save round-trip succeeds.
9. All hard build invariants pass:
   - `godot --headless --path godot --script tests/test_smoke.gd` — clean exit
   - `godot --headless --path godot --script tests/test_runner.gd` — exit 0
   - Save round-trip against the new fixture
   - `godot --headless --path godot --export-release "Web" exports/web/index.html` — non-empty, no errors
10. `node tools/verify_dialogue_roundtrip.js` reports no drift after the `asia.json` edit.
11. `python tools/voice_audit.py godot/data/voice_references/` reports no new failures.
12. `SPRINT_LOG.md` has a new dated entry summarising what was built.

## Verification commands

Run from repo root:

```bash
godot --headless --path godot --script tests/test_smoke.gd
godot --headless --path godot --script tests/test_runner.gd
godot --headless --path godot --export-release "Web" exports/web/index.html
node tools/verify_dialogue_roundtrip.js
python tools/voice_audit.py godot/data/voice_references/
```

On macOS, if Godot crashes before the engine boots, open the project once in the editor (see `godot/AGENTS.md` §"macOS userdata permissions"), or add `--log-file /tmp/godot.log` to the CLI invocation.

If any expected verification step cannot run, say so in the final response with the reason. Do NOT claim a build passed unless the command actually ran and exited successfully.

## Module conventions reminders

- `snake_case` vars/functions, `PascalCase` classes, `SCREAMING_SNAKE_CASE` constants.
- Type every function parameter and return; `Variant` only when truly necessary.
- `class_name` only when the class is referenced from elsewhere.
- No `print()` or `printerr()` in committed runtime code outside `tests/`.
- Signals declared at top of script with a one-line comment describing payload.
- One node, one responsibility. Split scripts >300 lines.
- For `.tscn` edits, preserve existing node names, signal wiring, and ownership boundaries.

## Final response format

End with a compact summary of:

- Files created (with paths)
- Files modified (with paths)
- Save version bump (old → new)
- New signals added (names + signatures)
- New input actions added (name + binding)
- Verification commands run and their pass/fail status

Do NOT claim work is complete if any verification step was skipped — surface the gap.

---

If a directive here conflicts with `godot/AGENTS.md`, the constitution wins — stop and ask the human. If you encounter ambiguity that blocks progress, file a clarifying note in your final response rather than guessing.
