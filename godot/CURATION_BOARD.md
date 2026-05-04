# Curation Board

The live tracker for the Godot rebuild. Update at the end of every session. The "Next Best Task" line is the prompt source for the next agent run — never let it sit empty.

## Current Focus

Bring up the empty Godot 4.4 project skeleton. All preparatory work is now complete.

## Current Build State

- Decisions on file (see `PLAN.md` and `AGENTS.md`):
  - Godot 4.4, GDScript, top-down tile, web-first.
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

Spawn the Godot 4.4 project. Code skill in Antigravity:

> Read `AGENTS.md`, `PLAN.md` (especially §Vertical slice plan and §Out of scope), and the last 5 entries of `SPRINT_LOG.md` (file may be empty).
>
> Adopt the **Code** skill at `.antigravity/skills/code.md`.
>
> Task: bring up the empty Godot 4.4 GDScript project at `/Users/piotr/Documents/Silly projects/pig-swine-rpg/godot/`.
>
> Deliverables:
>   - `project.godot` configured for 960×640 viewport, integer scaling, pixel-perfect snapping, top-down 2D rendering.
>   - Three autoloads registered: `scripts/autoload/state.gd`, `scripts/autoload/signals.gd`, `scripts/autoload/casebook.gd`. Each is a minimal stub.
>   - `scenes/Main.tscn` with a top-level `Node2D` controller and an empty `CurrentScene` slot.
>   - `scenes/world/routes/office_street.tscn` — minimal placeholder room with a `Player` node walking on a 32×32 grid (WASD + arrows).
>   - `exports/web/` with a committed Godot Web export preset; `.gitignore` exclude for build artifacts.
>   - `tests/test_runner.gd` skeleton.
>
> Acceptance:
>   - `godot --headless --check-only --path .` exits 0.
>   - `godot --headless --script tests/test_runner.gd` exits 0.
>   - `godot --headless --export-release "Web" exports/web/index.html` produces a non-empty file.
>   - Opening that index.html in a browser shows the placeholder room with a walking player. No console errors.
>
> Out of scope for this artifact: NPCs, dialogue runner, room transitions, save/load, Casebook UI, mini-games, chapter content. Code-only structural shell.

## Recent Improvements

(Session N — 2026-05-04)
- Voice-reference corpus audited and committed-clean (38 files, 24,544 records, 1 informational flag).
- `tools/voice_audit.py` extended with `--auto-fix` (Rule A/B + dropped-mini-game re-tag + legacy-name + Final Printer tag fixes).
- Address-form rules refined: Cula opens with "Mr. Murrow" at first meeting; Murrow invites informality (Beat 3); Asia hedged.
- STUB / PUTKA union added to canon (Chapter 3 Beat 11.5; Chapter 5 easter-egg dressing; running-joke entry in `style_canon.txt`).
- Warsaw atmosphere section added to `style_canon.txt §8` (per-NPC tonal anchors, day/night rules, easter-egg roster).
- English ↔ Polish translation table seeded in `world.txt`.
- Governance docs revised: AGENTS.md and PLAN.md now reflect 5 `.txt` source files, per-NPC dialogue schema, `_legacy/` layout, voice-reference corpus.

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
