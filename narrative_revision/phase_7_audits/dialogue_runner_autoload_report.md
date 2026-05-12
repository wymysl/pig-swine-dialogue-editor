# DialogueRunner Autoload Migration Report

**Date:** 2026-05-06  
**Task:** Convert DialogueRunner from a child node of Main.tscn into a project-level autoload.

---

## Files Changed

| File | Change | Summary |
|------|--------|---------|
| `godot/scripts/autoload/dialogue_runner.gd` | **NEW** (moved) | Copied from `scripts/systems/dialogue_runner.gd`; contents unchanged. |
| `godot/scripts/autoload/dialogue_runner.gd.uid` | **NEW** (moved) | UID sidecar `uid://cuuaq07ttxuav` preserved to avoid breaking any cached references. |
| `godot/scripts/systems/dialogue_runner.gd` | **DELETED** | Old location removed after copy confirmed. |
| `godot/scripts/systems/dialogue_runner.gd.uid` | **DELETED** | Old UID sidecar removed alongside script. |
| `godot/project.godot` | **MODIFIED** | Added `DialogueRunner="*res://scripts/autoload/dialogue_runner.gd"` to `[autoload]` section. |
| `godot/scenes/Main.tscn` | **MODIFIED** | Removed `ext_resource` declaration for `dialogue_runner.gd` and the `[node name="DialogueRunner"]` child; `load_steps` decremented from 5 to 4. |
| `godot/tests/test_dialogue_runner.gd` | **MODIFIED** | Updated `load()` path on line 26: `scripts/systems/` → `scripts/autoload/`. |
| `godot/tests/test_asia_progression.gd` | **MODIFIED** | Updated `load()` path on line 13: `scripts/systems/` → `scripts/autoload/`. |

---

## [autoload] Order Confirmed

```ini
[autoload]

State="*res://scripts/autoload/state.gd"
Signals="*res://scripts/autoload/signals.gd"
Casebook="*res://scripts/autoload/casebook.gd"
DialogueRunner="*res://scripts/autoload/dialogue_runner.gd"
```

**4 entries.** DialogueRunner is last, ensuring `State` and `Signals` are initialised before `DialogueRunner._ready()` runs (which calls `get_node_or_null("/root/Signals")` and `get_node_or_null("/root/State")`).

---

## Code Paths Assuming /root/Main/DialogueRunner

**Grep result: no matches found** for `Main/DialogueRunner` anywhere in `godot/scripts/` or `godot/scenes/`.

`dialogue_box.gd` line 71 already uses `get_node_or_null("/root/DialogueRunner")` — this now resolves correctly with DialogueRunner as a true autoload. **No modification required.**

---

## Test Results

Test suite location: `godot/tests/test_dialogue_runner.gd`  
Both test files (`test_dialogue_runner.gd`, `test_asia_progression.gd`) had their `load()` paths updated.

> [!NOTE]
> Headless Godot execution was not available in this environment. The test suite was verified structurally:
> - The `load("res://scripts/autoload/dialogue_runner.gd")` path now resolves to the moved file.
> - No internal logic in `dialogue_runner.gd` was changed; all 12 tests in `test_dialogue_runner.gd` are expected to pass unchanged.
> - The UID sidecar was preserved (`uid://cuuaq07ttxuav`) so the Godot import cache will not require recomputation.

To run the tests manually:
```bash
godot --headless --script tests/test_dialogue_runner.gd
godot --headless --script tests/test_asia_progression.gd
```

---

## Stale Reference Sweep

| Pattern | Files with matches (scripts/ + scenes/) |
|---------|------------------------------------------|
| `Main/DialogueRunner` | **0** |
| `scripts/systems/dialogue_runner` | **0** |

The only remaining reference is in `SPRINT_LOG.md` (documentation, not code) — left unchanged per scope constraints.

---

## Open Questions for Human Review

1. **Godot editor resync:** When the project is next opened in the Godot editor, it will detect the moved file via the preserved UID and update its internal import cache automatically. A one-time "reimport" prompt may appear — this is expected and safe to accept.

2. **`dialogue_box.gd` direct private method call:** Line 72 calls `runner._resolve_speaker(...)` — a private-by-convention method. This works correctly at runtime but bypasses encapsulation. Flagged here for a future refactor pass (out of scope for this migration).

3. **Casebook dependency check:** A grep for `Casebook` in `dialogue_runner.gd` returned zero hits, confirming DialogueRunner does not depend on Casebook. The ordering (DialogueRunner after Casebook) is conservative and has no downside.
