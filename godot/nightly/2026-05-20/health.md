# Nightly Health — 2026-05-20

## Test Results
| Test | Result | Note |
|------|--------|------|
| (all 51 test_*.gd files) | SKIPPED | Godot binary not available in this run's shell sandbox — headless test suite could not be executed. See Action Required. |

## Voice Audit
PASS — 40 files / 24812 records scanned, 0 violations, 0 JSON errors.

## JSON Validity
PASS — 54/54 files under `godot/data/` parsed cleanly.

## Print Statements (runtime only)
None.

## Godot MCP
Connected — Godot 4.6.2.stable.official.71f334935. Project info: 15 scenes, 110 scripts, 994 assets.

## Action Required
- Headless test suite (`tests/test_*.gd` × 51) was NOT executed this run. The nightly shell sandbox is Linux/aarch64 with no `godot` binary on PATH, and the available `mcp__godot__*` toolset does not expose a `--script` runner. Either (a) run the suite manually from a macOS shell that has Godot installed, or (b) extend the Godot MCP with a script-execution tool so this nightly can cover it.
- Reversibility snapshot (`git commit --allow-empty`) failed: `.git/HEAD.lock` exists, suggesting a stale or concurrent git process. No files were modified by this run (only the report file was created), so no rollback is needed, but the lock file should be cleared before the next git operation.
