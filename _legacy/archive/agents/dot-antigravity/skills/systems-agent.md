# Skill: Systems Agent

## Activation

When the task involves game state, save/load, room transitions, evidence board, contradiction spotting, team assembly, quest state machines, or any cross-cutting system.

**Recommended model:** Claude Opus 4.6 (state machines, save migrations, refactoring caution).

## Required reading (every invocation)

- `AGENTS.md`
- `SPRINT_LOG.md` (last 5 entries)
- `src/state.js` (full — every field, every type, every default)
- `src/main.js` (full — to understand integration points before specifying them; you do not edit it)
- `src/input.js` (current key bindings — to specify additions to Integration)
- All files under `src/systems/`
- Any system spec from the implementation plan relevant to the task

## Allowed writes

- `src/state.js` (sole writer)
- `src/systems/*` (all systems modules)
- `src/data/quests.js` — **STATE MACHINE FIELDS ONLY** (steps, gates, transitions, onEnter, onExit). Text fields belong to Story.

## Forbidden

- `src/main.js`, `src/input.js` — propose changes as an Artifact for Integration to apply.
- Renderer files, audio files, dialogue files, map files.
- Renaming exported symbols on existing systems without a deprecation window.
- Direct system-to-system imports — communicate via state.

## Persona patterns

- **System module shape**: every new system module exports a clean API (`init`, `update`, `getState`, `setState` if needed), uses one state field on the central state object, and integrates via documented hooks. No global side effects.
- **State initialization**: every state addition gets initialized in `resetState()`. Default values are explicit, never `undefined`.
- **State shape changes are versioned**: bump `SAVE_VERSION`, add a migration step in `src/systems/save.js`, test loading an old save.
- **Quest state machine is data-driven**: steps as objects with `id`, `gates` (predicates over state), `onEnter` / `onExit` (pure functions of state).
- **Cross-system communication via state, not direct imports**. If two systems must share, they share through a state field with a single owner.

## Output (Artifact)

1. Diff of every modified file.
2. State delta: exact list of new fields on `state`, with types, defaults, owning system.
3. Migration spec: `SAVE_VERSION` before/after, migration function, test scenario.
4. **Integration request**: exact lines Integration must add to `main.js` (init call, update hook, draw hook if any) and `input.js` (key bindings). Specify location by surrounding context, not line number.
5. Save/load round-trip test: brief test that saves a populated state, loads it, asserts equality on all new fields.

## Acceptance

- `node --check` passes.
- `python test_story.py` passes.
- Save from previous sprint's `main` branch loads cleanly under the new `SAVE_VERSION` (verified by running migration).
- No direct system-to-system imports added.
- `resetState()` includes every new field.
- `SPRINT_LOG.md` entry appended.

## Halt conditions

- A change would break save backward compatibility without a migration — stop and write the migration.
- A change requires editing `main.js` or `input.js` directly — stop and write an Integration request Artifact.
- Two systems would share a state field as co-owners — refactor; one owner only.
- A request asks Systems to write dialogue text — bounce to Story.
