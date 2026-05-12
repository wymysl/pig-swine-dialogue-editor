# CLAUDE.md - Claude Code Entry Point

Claude should treat `AGENTS.md` as the shared source of operating rules for
this repository. This file is the Claude-specific quick start.

## First Moves

1. Start by reading root `AGENTS.md`.
2. For anything under `godot/`, also read `godot/AGENTS.md`,
   `godot/CONVENTIONS.md`, the last five entries of `godot/SPRINT_LOG.md`, and
   the relevant role skill in `godot/.antigravity/skills/`.
3. Inspect before editing. Use `rg` and targeted file reads.
4. Preserve existing worktree changes. Assume unrelated modified or untracked
   files belong to the human or another tool.
5. Keep edits scoped. Do not clean up surrounding files opportunistically.

## Claude Workflow

- Be decisive once the relevant files are understood.
- Before editing, state briefly what you are about to change.
- Use `apply_patch` for manual text edits.
- Prefer small, reviewable changes over broad refactors.
- Do not rewrite `.tscn`, `.tres`, `.import`, binary art, or generated files
  unless the task specifically requires it and you have inspected the current
  format.
- Do not alter root source specs (`story.txt`, `world.txt`,
  `minigames.txt`, `battle_mechanics.txt`, `style_canon.txt`) unless explicitly
  requested.
- Do not add dependencies, Godot addons, or external services without approval.
- If a request crosses Code, Design, Art, or QA ownership, honor the ownership
  rules in `godot/AGENTS.md` and call out any handoff needed.

## Project Snapshot

- Active app: Godot 4.6.2 project in `godot/`.
- Main scene: `godot/scenes/Main.tscn`.
- Primary language: typed GDScript.
- Primary target: web export.
- Current runtime convention: 1280x720 viewport, 64x64 layout tiles, 112x112
  character sprites.
- Key autoloads: `State`, `Signals`, `Casebook`, `DialogueRunner`.
- Core rule: content is data, code is engine. Dialogue, doors, chapters,
  judgments, opponents, and item text live in JSON.

## Common Commands

From repo root:

```bash
godot --headless --path godot --script tests/test_smoke.gd
godot --headless --path godot --script tests/test_runner.gd
godot --headless --path godot --export-release "Web" exports/web/index.html
python tools/voice_audit.py godot/data/voice_references/
```

From inside `godot/`:

```bash
godot --headless --path . --script tests/test_smoke.gd
godot --headless --path . --script tests/test_runner.gd
godot --headless --path . --export-release "Web" exports/web/index.html
```

If Godot crashes early on macOS because the custom user directory has not been
created, open the project once in the Godot editor or add `--log-file /tmp/...`
to the CLI command.

## Coding Expectations

- GDScript uses `snake_case` for variables/functions, `PascalCase` for classes,
  and `SCREAMING_SNAKE_CASE` for constants.
- Type function parameters and returns.
- Use `Signals` for cross-system communication.
- Keep player-facing text out of `.gd` and in JSON.
- Save-state changes require defaults, version bump, migration, and tests.
- No `print()` or `printerr()` in committed runtime code outside tests unless
  the project already uses it for that specific diagnostic path.

## Writing Expectations

- Canonical names are strict: Dr. A. Cula, Mr. Pig, Mr. Swine, Murrow, Crab,
  Whimsy, Asia.
- Dialogue address forms are strict; check `godot/AGENTS.md` before authoring
  lines.
- Every player-facing line should pass the Taste Standard: funny, clever,
  alive, clear, future-proof.
- Legal jokes need a real procedural or institutional anchor.
- Use legal Casebook terminology, not generic RPG combat terms.

## Final Response

End with a compact summary of changed files and verification performed. If a
test or export was expected but not run, say why. Do not claim a build passed
unless the command actually ran and exited successfully.
