# Curation Board

The live tracker for the Godot rebuild. Update at the end of every session. The "Next Best Task" line is the prompt source for the next agent run — never let it sit empty.

## Current Focus

Sprint 2 — Office Street + Pig & Swine interior. Project skeleton is up and web-export-verified.

## Current Build State

- Decisions on file (see `PLAN.md` and `AGENTS.md`):
  - Godot 4.6.2, GDScript, top-down tile, web-first.
  - Four agent roles: Design / Code / Art / QA.
  - English-first; Polish translation may follow (translation table seeded in `world.txt`).
  - Casebook Battle System is load-bearing; no wild encounters; Final Printer is a Casebook battle.
  - Mini-game roster: Coffee Brewing (Ch1), Document Chase (Ch2). Scooter Racing and Ski Slalom dropped.
  - Tag taxonomy in `data/tag_taxonomy.json` (closed list).
  - Effectiveness resolver skeleton in `scripts/systems/battle/effectiveness.gd`.
  - STUB / PUTKA union founded in Chapter 3 Beat 11.5 (canonical, see `style_canon.txt §3`).
  - Warsaw is named directly; atmosphere + easter-egg roster in `style_canon.txt §8`.
- Source-of-truth files (5 `.txt` at repo root): `story.txt`, `world.txt`, `minigames.txt`, `battle_mechanics.txt`, `style_canon.txt`. Plus `tools/voice_audit.py`.
- Voice-reference corpus: 38 files in `data/voice_references/`, audited committed-clean (1 informational POSSIBLE_FIRST_MEETING flag, expected and correct).
- Legacy material under `_legacy/`: JS prototype, `design/`, `dialogue_samples.txt` (superseded by `data/voice_references/`).

## Pending tidy-ups (small)

- `dialogue_samples.txt` still at repo root; needs to move to `_legacy/` (one shell command).
- `tools/voice_audit.py` may want a final extension to validate STUB/PUTKA address forms in committed dialogues, but only after runtime JSONs exist.

## Current Weaknesses

- No Godot project yet. All preceding sessions have been spec, governance, and voice-reference work.
- `story.txt` Chapter 5 still calls Final Printer a "Boss Battle" mini-game in Beat 8 — needs a re-tag pass per the `style_canon.txt` decision (it's a Casebook battle). Not blocking; will surface in audit when the next ChatGPT run touches Chapter 5.
- `story.txt` Chapter 3 Beat 12 still describes Scooter Racing as a mini-game — needs prose update to reflect the narrative-cutscene reframe. Not blocking.

## Next Best Task

Implement Sprint 5: "Asia hint progression + Murrow case-briefing dialogue".

> Read `AGENTS.md`, `PLAN.md` §Vertical slice plan, and the last 5 entries of `SPRINT_LOG.md`.
>
> Task: Implement Asia's hint progression logic based on `chapter1` state flags and add Murrow's case-briefing dialogue. Verify via tests and visual confirmation.

## Recent Improvements

(Session 2 — 2026-05-04)
- **Room Transition System implemented.** `room_transition.gd` handles fade-to-black (500ms total), scene swapping, and player placement at named spawn points.
- **State Management improved.** `State.gd` now has a `data` dictionary for live state tracking.
- **Door system functional.** `door.gd` triggers transitions via `Area2D` interaction (E). Data-driven via `data/doors.json`.
- **Pig & Swine Interior added.** `pig_swine_office.tscn` with warm ochre floor.
- **Office Street updated.** Door to interior and return spawn point configured.
- **Headless Test Suite expanded.** `MainController` now handles `--smoke-test`, `--inspect`, and `--test-room-transition` CLI flags for robust automated verification.

(Session 1 — 2026-05-04)
- **Godot 4.6.2 project bootstrapped.** `project.godot` wired: 960×640, integer scaling, pixel-perfect, GL Compatibility, custom userdata dir `pig_swine_rpg`.
- Autoloads: `state.gd` (SAVE_VERSION=1), `signals.gd` (empty bus), `casebook.gd` (empty stub).
- `scenes/Main.tscn` with MainController (prints version on ready) and CurrentScene slot.
- `scenes/world/routes/office_street.tscn`: 960×640 dark ColorRect floor, Player (CharacterBody2D + Sprite2D + Camera2D), WASD+arrows movement.
- `scripts/actors/player.gd`: raw-position grid movement, sprint-1 stub.
- `tests/test_runner.gd`: GUT-compatible skeleton, exits 0 without GUT.
- `tests/test_smoke.gd`: loads Main.tscn, waits one frame, exits 0 — CI headless check.
- `export_presets.cfg`: Web export preset committed.
- `exports/web/.gitignore`: build artefacts excluded.
- All five acceptance commands pass (EXIT 0). Web export produces index.html (5.4 KB) + index.wasm (36 MB) + index.pck (30 KB).
- Known issue logged in SPRINT_LOG.md: macOS TCC blocks bare headless commands; `--log-file /tmp/godot.log` workaround in use.

(Session 1 — earlier)
- Governance docs created.
- Casebook taxonomy committed.
- Effectiveness resolver skeleton committed.

## Curation Warnings

- Do not start Chapter 2 content until Chapter 1 ships in a web build a stranger can play through.
- Do not invent new tags in `data/tag_taxonomy.json` without a Code artifact.
- Do not scaffold districts or interiors beyond what Chapter 1 needs.
- Do not let a sprint go without QA running the browser playtest. Every sprint ends with a `BUILD_NOTES.md` entry.
- Do not over-mine the STUB joke — two or three callbacks across the rest of the game, no more.
- Do not turn Warsaw into a tourism reel. Easter eggs appear once or twice; restraint is canon.
