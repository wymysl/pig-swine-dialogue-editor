# Nightly Health — 2026-05-24

## Reversibility Snapshot
SKIPPED — `.git/index.lock` (May 22 21:46) and `.git/HEAD.lock` (May 21 21:05) present and not removable from the sandbox (bindfs mount permits write but not unlink). No git operation possible until a human removes them with `rm -f .git/index.lock .git/HEAD.lock` on the host.

## Test Results
NOT RUN — `godot` binary not available in sandbox PATH (`command not found`; not under `/usr/local/bin`, `/opt`, or `/Applications`). All 56 tests under `godot/tests/test_*.gd` were enumerated but none could be executed headless from this environment.

| Test | Result | Note |
|------|--------|------|
| (56 tests enumerated) | SKIP | godot CLI not installed in sandbox |

## Voice Audit
PASS — 40 files / 24,812 records / 0 violations / 0 JSON errors / 0 normalization needed / 0 duplicates.

## JSON Validity
PASS — 54 files under `godot/data/`, all parse cleanly.

## Print Statements (runtime only)
None — `rg 'print\(' godot/scripts/ -g '*.gd'` returns no matches outside `tests/`.

## Godot MCP
Connected — Godot 4.6.2-stable (official); project "Pig & Swine RPG"; current scene `res://scenes/world/routes/office_street.tscn`; not playing; editor ready. (Used `mcp__godot-ai__editor_state` — the `mcp__godot__get_project_info` named in the task instructions no longer exists; the active namespace is `mcp__godot-ai__*`, per the 2026-05-21 plugin swap.)

## Action Required
1. Remove stale git locks on host: `cd ~/Documents/Silly\ projects/pig-swine-rpg && rm -f .git/index.lock .git/HEAD.lock`. Until removed, nightly snapshots will keep failing and any interactive git commit will also be blocked.
2. Either install `godot` in the nightly sandbox (so the test suite can actually run) or rewrite the task SKILL.md to drop the headless-test step and rely on a separate runner. As-is, the most important check the script claims to perform is silently uncovered.
3. Update the task SKILL.md to call `mcp__godot-ai__editor_state` (or another `mcp__godot-ai__*` tool) instead of the removed `mcp__godot__get_project_info`.
