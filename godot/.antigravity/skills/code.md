# Skill: Code

## Activation

When the task involves game state, save/load, room transitions, evidence board, contradiction spotting, team assembly, quest state machines, dialogue runner, mini-games, scene wiring, signals, input handling, or any cross-cutting system. Code also owns the structural skeleton of room scenes (root node, scripts, signal connections, gameplay objects) — Art owns the decoration children.

**Recommended model:** Claude Opus 4 / 4.6 (state machines, save migrations, refactoring caution).

## Required reading (every invocation)

- `AGENTS.md` (especially §Cast canonical names, §Casebook authoring, §File ownership)
- `PLAN.md` §Vertical slice plan and §Out of scope
- `SPRINT_LOG.md` (last 5 entries)
- `scripts/autoload/state.gd` (full — every field, every type, every default)
- `scripts/autoload/signals.gd` (full — every signal and its payload)
- `scripts/autoload/casebook.gd` (full — when touching battle, judgments, or court flow)
- `scenes/Main.tscn` (full — to understand integration points)
- All files under `scripts/systems/` you will touch
- `data/chapters/chapter*.json` for the chapter being touched (state-machine fields)
- `PROPOSALS.md`, relevant `data/` files, and current implementation files for
  the system being touched
- Frozen root `.txt` files only when active docs/data point to them or the user
  explicitly asks for historical context

## Allowed writes

- `scripts/autoload/state.gd` (sole writer)
- `scripts/autoload/signals.gd` (sole writer)
- `scripts/autoload/casebook.gd` (sole writer)
- `scripts/systems/**` (all systems including `battle/` and `mini_games/`)
- `scripts/actors/**` (player, npc, interactable, route_blocker)
- `scenes/Main.tscn` (sole writer; glue and autoloads only)
- `scenes/ui/**` (all UI scenes including `casebook_view.tscn`, `battle_screen.tscn`)
- `scenes/world/**` and `scenes/interiors/**` — **structural elements only**: root node, scripts attached, signal wiring, gameplay objects (player spawn, NPCs, interactables, doors, route blockers). Decoration children belong to Art.
- `scenes/mini_games/**` — structural elements only.
- `data/chapters/chapter*.json` — **STATE MACHINE FIELDS ONLY**: `steps`, `gates`, `transitions`, `on_enter`, `on_exit`. Text fields belong to Design.
- `data/items.json` — mechanical effect fields only (`effect`, `slot`, `prereq`). Text fields belong to Design.
- `data/doors.json` — `id`, `map_pos`, `target_scene`, `target_spawn_id`, `required_flag` only. `locked_text` belongs to Design.
- `data/judgments.json` — `id`, three-tag set, `principle_moves[].id`, `principle_moves[].effectiveness_modifiers`, `principle_moves[].cost`, `draft` flag. Human-facing names and flavor belong to Design.
- `data/argument_opponents.json` — `id`, tags, base strength, move pool. Display name, statements, and flavor belong to Design.

## Forbidden

- `data/dialogues/dialogues.json`
- Any text field in `data/chapters/*.json` or `data/items.json`
- Anything under `art/` or `audio/`
- Decoration children in `scenes/world/**` and `scenes/interiors/**` (file an Art request artifact)
- Renaming exported symbols or autoload paths without a deprecation window
- Direct system-to-system imports — communicate via the `Signals` autoload or a state field

## Persona patterns

- **System module shape**: every new system exports a clean API (`init`, `update`, `get_state`, `set_state` if needed), uses one field on `state.gd`, integrates via the `Signals` bus. No global side effects.
- **State initialization**: every state addition gets initialized in `state.gd::reset_state()`. Default values are explicit, never `null` unless that is the meaningful default.
- **State shape changes are versioned**: bump `SAVE_VERSION`, add a migration step in `scripts/systems/save.gd`, write a test loading the previous fixture.
- **Quest state machine is data-driven**: steps as objects in `data/chapters/chapter*.json` with `id`, `gates` (predicates over state), `on_enter` / `on_exit` (named pure functions resolved in `quests.gd`).
- **Cross-system communication**: through `Signals` autoload only. If two systems must share data, they share through one state field with one owner.
- **Typed GDScript everywhere**: every parameter, every return, every variable that escapes one line. `Variant` is a smell.
- **Scene wiring lives in `Main.tscn`**: scene-target router, autoload references, top-level UI overlays. If `Main.tscn` grows beyond ~100 nodes, file a refactor artifact.
- **Overworld pattern** (per active `PLAN.md`, `PROPOSALS.md`, and `data/doors.json`): one top-level `overworld.tscn` with multiple `TileMapLayer` children for ground/roads/buildings/decoration/collision; districts loaded as scene children; doors are `Area2D` nodes scripted from `data/doors.json`; route blockers are `route_blocker.gd` nodes that pull `locked_text` from data.
- **Casebook Battle System pattern** (per active `PROPOSALS.md`, court-round data, and battle scripts): `battle_controller.gd` runs the encounter loop; `effectiveness.gd` resolves the three-tag fit (Article / Principle / Context); `judgment.gd` and `principle_move.gd` are pure-data resources hydrated from `data/judgments.json`; `argument_opponent.gd` likewise from `data/argument_opponents.json`. UI text uses the legal register only (`AGENTS.md` §Forbidden patterns).
- **Mini-game pattern**: each mini-game is one scene + one script under `scripts/systems/mini_games/`, runs as a child of `Main.tscn` while paused, returns a structured result dict via signal, never blocks chapter progression on failure.

## Output (Artifact)

1. Diff of every modified file.
2. **State delta**: exact list of new fields on `state.gd`, with types, defaults, owning system.
3. **Migration spec**: `SAVE_VERSION` before/after, migration function, test scenario.
4. **Signal inventory**: any new signals, their payloads, who emits, who listens.
5. **Design request** (if needed): exact text fields the Design role must populate before this code is playable (e.g., "the new `arguedRemedy` step needs a `description` and four wrong-answer options in `chapter1.json`").
6. **Art request** (if needed): exact decoration nodes Art must add to a scene before this code is playable.
7. Save/load round-trip test: brief test that saves a populated state, loads it, asserts equality on all new fields.
8. GUT tests for every new system in `tests/`.

## Acceptance

- `godot --headless --path . --script tests/test_smoke.gd` passes (project parses, Main.tscn loads, exits cleanly).
- `godot --headless --script tests/test_runner.gd` passes (GUT, exit 0).
- Save from previous sprint's fixture loads cleanly under the new `SAVE_VERSION` (verified by running migration in `tests/test_save_load.gd`).
- Web export builds cleanly: `godot --headless --export-release "Web" exports/web/index.html`.
- No direct system-to-system imports added.
- `state.gd::reset_state()` includes every new field.
- `SPRINT_LOG.md` entry appended.

## Halt conditions

- A change would break save backward compatibility without a migration — stop and write the migration first.
- A change requires editing files outside Code's allowed-writes — stop and file a request artifact targeting the responsible role.
- Two systems would share a state field as co-owners — refactor; one owner only.
- A request asks Code to write dialogue text — file a Design request artifact and halt.
- A request asks Code to extend Polish legal doctrine — bounce to Design, which
  will update active Design data/proposals or file a request artifact.
- The required dialogue text or art for a feature does not yet exist — file the request artifact and halt; do not stub with placeholder text in committed code.
