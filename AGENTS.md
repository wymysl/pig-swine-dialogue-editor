# AGENTS.md - Pig & Swine RPG

This is the repo-level operating guide for coding agents. The detailed Godot
constitution still lives in `godot/AGENTS.md`; read this file first, then the
Godot-specific files for any game work.

## Project Identity

Pig & Swine RPG is a top-down 2D legal-comedy RPG built in Godot 4.6.2 with
GDScript. The tone is precise absurdism: post-Soviet legal practice played for
comedy, with jokes grounded in real-ish procedure rather than random nonsense.

The active implementation is under `godot/`. The older JavaScript prototype and
archival material under `_legacy/` are frozen reference material unless a human
explicitly asks otherwise.

## Required Reading

For any non-trivial task, read in this order:

1. `AGENTS.md` at repo root.
2. `godot/AGENTS.md` for project constitution, cast names, ownership, and taste
   rules.
3. `godot/CONVENTIONS.md` for current runtime and asset conventions.
4. Last five entries of `godot/SPRINT_LOG.md`.
5. `godot/PLAN.md`, especially vertical slice plan and out-of-scope sections.
6. `godot/PROPOSALS.md` for editorial decisions log and proposal status. Most
   "should we do X" questions are already answered here; check before pitching.
7. The relevant role skill under `godot/.antigravity/skills/`:
   `code.md`, `design.md`, `art.md`, or `qa.md`.
8. Relevant sections of the root spec files:
   `story.txt`, `world.txt`, `minigames.txt`, `battle_mechanics.txt`,
   `style_canon.txt`.
9. The source files you intend to edit.

`godot/CURATION_BOARD.md` is a live human tracker. Read it when planning
multi-step work, but do not edit it unless the user specifically asks.

## Source Of Truth

- Creative canon: the five root `.txt` files.
- Current implementation conventions: `godot/CONVENTIONS.md`.
- Role ownership and hard governance: `godot/AGENTS.md` plus the role skill
  files in `godot/.antigravity/skills/`.
- Scope and build plan: `godot/PLAN.md`.
- Editorial decisions and proposal status: `godot/PROPOSALS.md`.
- Recent reality: `godot/SPRINT_LOG.md` and `godot/BUILD_NOTES.md`.

When sources disagree, do not smooth it over silently. For creative canon,
follow the root `.txt` specs. For current runtime numbers and asset dimensions,
follow `godot/CONVENTIONS.md`. For file ownership, follow `godot/AGENTS.md`.
If a conflict still matters, stop and ask the human.

## Current Technical Baseline

- Engine: Godot 4.6.2.
- Language: GDScript only. No C#, GDExtension, or third-party runtime plugins
  without human approval.
- Target: web export first.
- Main project path: `godot/project.godot`.
- Main scene: `res://scenes/Main.tscn`.
- Autoloads: `State`, `Signals`, `Casebook`, `DialogueRunner`. The Godot AI
  development addon also registers `_mcp_game_helper` (approved 2026-05-21,
  see `godot/AGENTS.md` §"Approved development addons"); it is a dev-time
  affordance, not a game system.
- Current viewport: 1280x720, with 2560x1440 editor preview override.
- Current tile layout convention: 64x64.
- Current canonical character sprites: 64x64.
- Movement: free 8-way `CharacterBody2D`, normalized diagonals, sprint support.
- Cross-system communication: use the `Signals` autoload. Avoid direct
  system-to-system imports.

Some older docs still mention earlier 960x640, 32x32 tile, or 32x48 sprite
assumptions. Treat `godot/CONVENTIONS.md` as the newer runtime authority.

## Repository Map

- `godot/`: active Godot project.
- `godot/scripts/autoload/`: global state, signal bus, casebook, dialogue runner.
- `godot/scripts/systems/`: gameplay systems, saves, room transitions,
  minigames, Casebook battle logic.
- `godot/scripts/actors/`: player, NPCs, doors, pickups, interaction actors.
- `godot/scenes/`: Godot scenes for main shell, interiors, world routes, UI,
  minigames.
- `godot/data/`: runtime JSON data for dialogue, chapter flags, doors, items,
  judgments, opponents, voice references.
- `godot/art/` and `godot/audio/`: committed game assets.
- `godot/tests/`: headless Godot tests and fixtures.
- `tools/`: repo-level helper scripts, especially `tools/voice_audit.py`.
- `narrative_revision/`: writing and revision support material.
- `_legacy/`: frozen old prototype/archive unless explicitly requested.

## Operating Principles

These rules apply to every task in this project unless explicitly overridden.
Bias: caution over speed on non-trivial work.

### Rule 1 — Think Before Coding

State assumptions explicitly. Ask rather than guess.
Push back when a simpler approach exists. Stop when confused.

### Rule 2 — Simplicity First

Minimum code that solves the problem. Nothing speculative.
No abstractions for single-use code.

### Rule 3 — Surgical Changes

Touch only what you must. Don't improve adjacent code.
Match existing style. Don't refactor what isn't broken.

### Rule 4 — Goal-Driven Execution

Define success criteria. Loop until verified.
Strong success criteria let the agent loop independently.

### Rule 5 — Use the model only for judgment calls

Use for: classification, drafting, summarization, extraction.
Do NOT use for: routing, retries, deterministic transforms.
If code can answer, code answers.

### Rule 6 — Watch context, summarize before overrun

If a task is pulling in many large files or long tool outputs, stop and
summarize before continuing. Prefer a fresh session over a bloated one.
Surface when context is getting heavy. Do not silently overrun.

### Rule 7 — Surface conflicts, don't average them

If two patterns contradict, pick one (more recent / more tested).
Explain why. Flag the other for cleanup.

### Rule 8 — Read before you write

Before adding code, read exports, immediate callers, shared utilities.
If unsure why existing code is structured a certain way, ask.

### Rule 9 — Tests verify intent, not just behavior

Tests must encode WHY behavior matters, not just WHAT it does.
A test that can't fail when business logic changes is wrong.

### Rule 10 — Checkpoint after every significant step

Summarize what was done, what's verified, what's left.
Don't continue from a state you can't describe back.

### Rule 11 — Match the codebase's conventions, even if you disagree

Conformance > taste inside the codebase.
If you think a convention is harmful, surface it. Don't fork silently.

### Rule 12 — Fail loud

"Completed" is wrong if anything was skipped silently.
"Tests pass" is wrong if any were skipped.
Default to surfacing uncertainty, not hiding it.

## Working Rules

- Respect the dirty worktree. There may be user edits or generated assets
  already present. Do not revert, delete, rename, or normalize unrelated files.
- Keep changes narrowly scoped to the requested task.
- Prefer `rg`/`rg --files` for search.
- Use `apply_patch` for manual text edits.
- Do not use destructive git commands unless the user explicitly asks.
- Do not edit the five root source spec files unless the user explicitly asks.
  Normally propose changes instead.
- Do not add runtime dependencies, addons, or engine plugins without approval.
- Do not hardcode player-facing strings in `.gd`; runtime text belongs in JSON.
- Keep JSON valid and stable. Use structured parsing tools for non-trivial data
  edits.
- For `.tscn` scene edits, preserve existing node names, signal wiring, and
  ownership boundaries. Be extra cautious around generated/import metadata.

## Role Ownership

The detailed ownership table is in `godot/AGENTS.md`. In short:

- Code owns GDScript, autoloads, gameplay systems, structural scene wiring,
  state machines, save migrations, mechanical data fields.
- Design owns dialogue, quest/item flavor text, Casebook display text, and
  Taste Standard compliance.
- Art owns sprites, portraits, tiles, decoration scene children, music, and SFX.
- QA owns tests, build notes, web export verification, and bug artifacts.
- Human owns governance docs, root source specs, and curation direction unless
  they explicitly delegate a change.

If a task crosses roles, change only the files required for the requested role
or produce a clear request for the responsible role.

## Content Rules

- Canonical names: Dr. A. Cula, Mr. Pig, Mr. Swine, Murrow, Crab, Whimsy, Asia.
- Dialogue address forms are strict. Check `godot/AGENTS.md` before writing any
  in-game line involving Dr. A. Cula or Murrow.
- Every line should pass the Taste Standard: funny, clever, alive, clear, and
  future-proof.
- Legal humor should parody real procedure or recognizable institutional logic.
  Do not invent fake doctrine to make a joke work.
- Pig & Swine may be incompetent, anxious, theatrical, or disorganized. Do not
  make the firm actively malicious or corrupt.
- Casebook UI uses legal register, not RPG combat language. Prefer terms like
  "Argument Strength", "Legal Encounter", and "Authority".

## Save And State Policy

Any saved-state shape change requires all of the following:

- Add explicit defaults in `State.reset_state()`.
- Bump the save version constant.
- Add a migration step in `godot/scripts/systems/save.gd`.
- Add or update a migration test using the previous fixture.
- Verify a save/load round trip.

Do not introduce shared ownership of a state field. One system writes; others
read and react through `Signals`.

## Commands

Run these from the repo root:

```bash
godot --headless --path godot --script tests/test_smoke.gd
godot --headless --path godot --script tests/test_runner.gd
godot --headless --path godot --export-release "Web" exports/web/index.html
python tools/voice_audit.py godot/data/voice_references/
```

Equivalent commands from inside `godot/`:

```bash
godot --headless --path . --script tests/test_smoke.gd
godot --headless --path . --script tests/test_runner.gd
godot --headless --path . --export-release "Web" exports/web/index.html
```

Do not rely on `godot --headless --check-only --path .`; the project docs note
that this does not self-terminate reliably in Godot 4.6.

On macOS, first-run Godot userdata permissions can crash CLI invocations before
the engine boots. If this happens, open the project once in the Godot editor, or
add a temporary log path:

```bash
godot --headless --path godot --script tests/test_smoke.gd --log-file /tmp/pig_swine_smoke.log
```

## Verification Expectations

- Docs-only changes: no Godot test run is usually required; still check
  formatting and paths.
- Code or scene changes: run smoke test, test runner, and focused tests for the
  touched area.
- Save/state changes: also run the save migration or round-trip test.
- Web-facing changes: build the web export.
- Design JSON changes: validate JSON and run relevant cross-reference checks.
- Art/import changes: run Godot import if needed, then smoke/export checks.

If you cannot run an expected verification step, say so in the final response
with the reason.

## Completion Notes

For changes under `godot/`, append a concise dated entry to
`godot/SPRINT_LOG.md` when the role instructions require it. For small root
documentation edits, a final response summary is enough unless the user asks for
a sprint log entry.
