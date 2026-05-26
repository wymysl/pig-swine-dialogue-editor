# Nightly Health — 2026-05-25

## Test Results (from launchd job)
NOT AVAILABLE — `test_results.md` missing for 2026-05-25. Last available results are from 2026-05-24 (launchd job has not produced a report for today, and none was produced yesterday for 2026-05-23 either — the most recent nightly directory before today is 2026-05-24's, which itself contains no `test_results.md`, only `health.md`, `code_audit.md`, and `design_proposals.md`).

See Action Required.

## Voice Audit
PASS — 40 files audited, 24812 records scanned, 0 violations, 0 JSON errors, 0 files needing normalization, 0 duplicates.

## JSON Validity
PASS — 56 `.json` files under `godot/data/` parsed cleanly.

## Print Statements (runtime only)
None — no `print(` matches in any `.gd` file under `godot/scripts/` (35 scripts scanned).

## Godot MCP
Connected — Godot 4.6.2-stable (official), project "Pig & Swine RPG", current scene `res://scenes/world/routes/office_street.tscn`, not playing, readiness `ready`.

## Action Required

1. **Reversibility snapshot did not run.** The Step 0 `git commit --allow-empty` failed because `.git/HEAD.lock` exists and the sandbox lacks permission to unlink it (`Operation not permitted` on `.git/objects/f2/tmp_obj_DFnVW6`). Clear the stale lock on the host:
   ```sh
   rm /Users/piotr/Documents/Silly\ projects/pig-swine-rpg/.git/HEAD.lock
   ```
   Then check for any other `.git/*.lock` files. A prior git process likely crashed or was interrupted.

2. **Headless test launchd job is not producing results.** No `test_results.md` exists in `godot/nightly/2026-05-25/`, and the 2026-05-24 directory also lacks one. Investigate on the host:
   ```sh
   cat /tmp/pigswine-nightly-tests.err
   launchctl print gui/$(id -u)/com.piotr.pigswine.nightly-tests
   ```
   The sandbox has no Godot binary and cannot run the suite as a fallback. Until the launchd job is restored, nightly health reports will lack test signal.
