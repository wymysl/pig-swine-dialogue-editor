# Nightly Health — 2026-05-20

(Second run of the day; overwrites the earlier 2026-05-20 report.)

## Snapshot Commit
PASS — `git commit --allow-empty -m "nightly-snapshot-2026-05-20"` succeeded as `[main 0020418]` (28 files changed, 281 insertions, 236 deletions). Several `tmp_obj_*` and `HEAD.lock` "Operation not permitted" warnings appeared but did not block the commit. Note: this run picked up substantial uncommitted host-side work — sprite folder renames under `art/sprites/_legacy/cula_walk_alt/`, deletion of `art/sprites/sikorska/PROMPT.txt` and `sikorska_sprite_frames.tres`, plus the earlier-today `critiques/2026-05-20-art.md`, `nightly/2026-05-20/dialogue_audit.md`, and `nightly/2026-05-20/health.md` (the latter is overwritten by this report).

## Test Results
| Test | Result | Note |
|------|--------|------|
| (all 53 `tests/test_*.gd`) | NOT RUN | Godot binary unavailable in this sandbox; same structural blocker as 2026-05-14 through 2026-05-18. The `mcp__godot__*` toolset exposes `run_project` only, not a `--script` runner for individual test files. |

Test file count: 53 (+2 since 2026-05-18 report which listed 51). New files observed: `test_dialogue_box_dismissal_signal`, `test_save_failure_signal`, `test_save_migration_v20_v21`, `test_ui_critique_regressions`. No removals.

## Voice Audit
PASS — 40 files audited, 24,812 records scanned, 0 violations, 0 JSON errors, 0 normalization issues, 0 duplicates. Unchanged from 2026-05-18.

## JSON Validity
PASS — 53/53 `.json` files under `godot/data/` parse cleanly (−1 vs the earlier 2026-05-20 report, which counted 54; one JSON file was removed or moved out of `data/` during the day).

## Print Statements (runtime only)
None — 36 `.gd` files under `godot/scripts/` scanned (+2 since 2026-05-18); zero `print(` matches outside `tests/`.

## Godot MCP
Connected — Godot 4.6.2.stable.official.71f334935. Project info: 15 scenes, 110 scripts, 994 assets (unchanged scenes/assets vs 2026-05-18; +8 scripts).

## Action Required
1. **Headless test suite still not running.** Sixth consecutive night the structural blocker has not been addressed. Options remain unchanged: (a) install Godot in the sandbox, (b) run the suite on the host and have this task only consume results, or (c) drop the test-run step from this nightly. No code change can fix this from inside the sandbox.
2. **Host-side housekeeping picked up in snapshot.** The 28-file commit includes the `cula/walk/_alt → _legacy/cula_walk_alt` sprite rename and the `sikorska/` cleanup. Both look intentional but were uncommitted before this run; confirm they belong on `main` and were not WIP from another tool.
3. **Stale `.git` object tmp files** triggered "Operation not permitted" warnings during the commit. Non-blocking this time, but if these accumulate they may eventually wedge git. Consider clearing `.git/objects/*/tmp_obj_*` on the host.
