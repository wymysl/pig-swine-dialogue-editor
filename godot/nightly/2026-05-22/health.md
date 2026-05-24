# Nightly Health — 2026-05-22

(Second run of the day — overwrites the earlier report, which incorrectly
flagged the Godot MCP as terminated. The MCP is in fact connected; only
the underlying test discovery path is incompatible. See below.)

## Test Results

| Test | Result | Note |
|------|--------|------|
| all 56 `test_*.gd` | NOT RUN | no `godot` binary in sandbox; MCP `test_run` discovery is incompatible with this project's `--script` runners |

The bash sandbox is Linux-only and ships no `godot` executable, so
`godot --headless --path godot --script tests/<name>.gd` cannot be
invoked from this scheduled task. The Godot AI MCP exposes `test_run`,
but it discovers classes with `test_*` methods; the pig-swine suite is
top-level `--script` runners executing via `_init()` / `_ready()`, so
all 56 files were reported as `"cannot instantiate — abstract or broken"`
— a discovery-model false negative, not a real failure signal.

## Voice Audit

PASS — 40 files / 24 812 records scanned, 0 violations, 0 JSON errors,
0 duplicates, 0 files needing normalization.

## JSON Validity

PASS — all 53 `.json` files under `godot/data/` parsed cleanly.

## Print Statements (runtime only)

None — no `print(` matches in any `.gd` under `godot/scripts/` (root
file + `actors/`, `autoload/`, `systems/`).

## Godot MCP

Connected — Godot 4.6.2-stable (official). Editor `ready`,
`is_playing=false`. Current scene:
`res://scenes/world/routes/office_street.tscn`. Queried via
`mcp__godot-ai__editor_state`; the task spec asked for the legacy
`mcp__godot__get_project_info`, which no longer exists after the
2026-05-21 plugin migration.

## Reversibility Snapshot

SKIPPED — `.git/HEAD.lock` (0 bytes) is owned by the host user and
cannot be removed from the sandbox (`Operation not permitted`). No
source files were modified by this run; the only new artifact is this
report under `godot/nightly/2026-05-22/`, so the missing snapshot has
no rollback consequence today. Earlier note from today's first run
also mentions a stale `.git/index.lock.stale.*` from 2026-05-16 worth
cleaning up.

## Action Required

1. **Headless Godot is unreachable from the scheduled-task sandbox.**
   The current task design assumes a shell with `godot` on `PATH`; this
   host has no such binary. Options, in rough order of cost:
   (a) Move the nightly to a launchd/cron job on Piotr's Mac where
       Godot is installed, and have the scheduled-task agent just read
       the resulting log;
   (b) Reach the engine via MCP — but `test_run` does not fit this
       suite (see below);
   (c) Bake a Godot binary into the sandbox image.
2. **MCP `test_run` is incompatible with `--script` style suites.**
   The plugin requires `class X extends RefCounted` with `test_*`
   methods. Adopting it would mean rewriting every existing test —
   large surface area; not recommended unless there's an independent
   reason to standardise on the MCP test framework.
3. **Remove stale `.git/HEAD.lock`** (and any
   `.git/index.lock.stale.*` left behind) so future nightlies can
   create the reversibility snapshot commit:
   `rm "/Users/piotr/Documents/Silly projects/pig-swine-rpg/.git/HEAD.lock"`.
4. Static checks (voice audit, JSON validity, print scan) — all clear.
