# Nightly Health — 2026-05-24

## Reversibility Snapshot
SKIPPED — `.git/HEAD.lock` (May 24 21:03, 0 bytes) present and not removable from the sandbox. `git commit --allow-empty` fails with `fatal: cannot lock ref 'HEAD'` and `unable to unlink .git/objects/04/tmp_obj_hmPRq1`. Must be cleared on the host with `rm -f .git/HEAD.lock` before any git op (manual or scheduled) can run.

## Test Results (from launchd job)
NOT AVAILABLE — `godot/nightly/2026-05-24/test_results.md` is missing. The macOS launchd job `com.piotr.pigswine.nightly-tests` did not produce output today. Check `/tmp/pigswine-nightly-tests.err` and `launchctl print gui/$(id -u)/com.piotr.pigswine.nightly-tests` on the host. (Same gap noted on prior nights — no `test_results.md` exists for any date in `godot/nightly/`.)

## Voice Audit
PASS — 40 files / 24,812 records / 0 violations / 0 JSON errors / 0 needing normalization / 0 duplicates.

## JSON Validity
PASS — 55 files under `godot/data/`, all parse cleanly.

## Print Statements (runtime only)
None — no `print(` matches under `godot/scripts/` outside `tests/`.

## Godot MCP
Connected — Godot 4.6.2-stable (official); project "Pig & Swine RPG"; current scene `res://scenes/world/routes/office_street.tscn`; not playing; editor ready.

## Action Required
1. Remove stale git lock on host: `cd ~/Documents/Silly\ projects/pig-swine-rpg && rm -f .git/HEAD.lock`. Until cleared, nightly snapshots will keep failing and interactive git commits will also be blocked.
2. Investigate why the `com.piotr.pigswine.nightly-tests` launchd job is not writing `test_results.md`. No `test_results.md` exists in any `godot/nightly/<date>/` directory — the test-coverage half of the nightly pipeline has never produced output from this runner. Inspect `/tmp/pigswine-nightly-tests.err` and the launchd job status on the host.
