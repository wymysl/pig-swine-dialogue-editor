# Nightly Health — 2026-05-26

## Test Results (from launchd job)
NOT AVAILABLE — test_results.md missing (launchd job failed to run)

The `godot/nightly/2026-05-26/` directory did not exist at task start; the launchd job
(`com.piotr.pigswine.nightly-tests`) did not produce `test_results.md` for today.
Most recent available results are from 2026-05-25.

To investigate: check `/tmp/pigswine-nightly-tests.err` and run
`launchctl print gui/$(id -u)/com.piotr.pigswine.nightly-tests` from the host.

## Voice Audit
PASS — 40 files audited, 24 812 records scanned, 0 violations, 0 JSON errors,
0 files needing normalization, 0 duplicates.

## JSON Validity
PASS — all 63 `.json` files under `godot/data/` parsed without error (includes
live data, court rounds, dialogues, and `_drafts/`).

## Print Statements (runtime only)
None — `rg 'print\('` across `godot/scripts/**/*.gd` returned no matches.

## Godot MCP
Error: `mcp__godot-ai__editor_state` tool not available in this sandbox session.
The Godot AI addon MCP namespace (`mcp__godot-ai__*`) was not exposed to the
nightly agent's tool list. This is a sandbox connectivity issue, not a game
defect. The addon itself (installed 2026-05-21) should still be present in the
editor on the host.

## Reversibility Snapshot
Committed as `nightly-snapshot-2026-05-26` (73790d2). Two files were staged
from `_legacy/archive/docs-process/artifacts/qa/` that were uncommitted:
`bug_integration_dev_server 2.md` and `sprint-0-plan 2.md`. These appear to be
duplicate archive copies with spaces in filenames — worth a quick look but
not blocking.

Note: `.git/HEAD.lock` was present at snapshot time (operation not permitted to
unlink). The commit itself succeeded. If future snapshots fail, this lock will
need to be cleared manually on the host: `rm .git/HEAD.lock`.

## Action Required
1. **Launchd job did not run today** — `test_results.md` missing for 2026-05-26.
   Check `/tmp/pigswine-nightly-tests.err` and launchctl status on the host.
2. **`.git/HEAD.lock` present** — cannot be removed from sandbox. Clear with
   `rm .git/HEAD.lock` from the repo root on the host if it persists.
3. **Godot MCP unreachable** — editor state check skipped; verify addon status
   manually if needed.
4. **Stale duplicate archive files** staged in snapshot:
   `_legacy/archive/docs-process/artifacts/qa/bug_integration_dev_server 2.md`
   and `sprint-0-plan 2.md` — filenames contain spaces, likely unintentional
   duplicates of existing files. Consider deleting.
