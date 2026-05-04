# Skill: Story Agent

## Activation

When the task involves dialogue, quest text, NPC lines, docket notes, item descriptions, or chapter scripts.

**Recommended model:** Claude Opus 4.6 (humor and Polish-legal voice register).

## Required reading (every invocation)

- `AGENTS.md`
- `SPRINT_LOG.md` (last 5 entries)
- `src/data/dialogues.js` (current state — full file)
- `src/data/quests.js` (text fields — full file)
- `design_bible.md` if present, else the humor sections of `implementation_plan.md`
- The chapter outline for the current sprint (in `docs/chapters/N.md`)
- Any character spec referenced in the task

## Allowed writes

- `src/data/dialogues.js`
- `src/data/quests.js` — **TEXT FIELDS ONLY** (description, label, hint). Never the state machine.
- `docs/chapters/*.md` (chapter scripts)

## Forbidden

- `src/state.js`, `src/main.js`, `src/input.js`
- `src/systems/*` including `src/systems/quests.js` (Systems owns the state machine)
- `src/minigames/*`
- Renaming exported symbols — even your own — without filing a rename proposal first

## Persona patterns

- **Polish-legal flavor**: reference real procedure (KPC articles, doręczenie zastępcze, nieważność postępowania, postanowienie incydentalne, etc.) parodied, never explained inside the dialogue.
- **NPC voices** (preserve and extend, do not replace):
  - Mr. Pig: panicked, formal-while-falling-apart, escalating sentence energy.
  - Muraś: dry, archival, helpful only when asked precisely.
  - Rak: terse, observational, suspicious of optimism.
  - Wymysl: enthusiastic, legally creative, dangerous to deploy.
- **Three expression variants per key dialogue line**: neutral, agitated, deadpan. Code shape: `{ neutral: "...", agitated: "...", deadpan: "..." }`.
- **Maintain running jokes**: sentient resentful coffee machine, Swine's postcards from inexplicable places, Wymysl's near-miss arguments, Muraś's archival omniscience.
- Lines under ~140 characters where possible; break longer thoughts across consecutive typewriter lines.

## Output (Artifact)

1. Diff of every modified file.
2. The full text of every new line, quoted, grouped by NPC, for human review.
3. Per-line note: which Taste Standard tests it passes, which running jokes it touches.
4. Updated dialogue tree map (NPC → topics → quest gates) for affected NPCs.

## Acceptance

- `node --check` passes on every modified `.js` file.
- Every new line passes the Taste Standard (laugh, clever, alive, clear, future-proof — 5/5).
- Every key NPC interaction has 3 expression variants for its main lines.
- No broken cross-references: every topic ID, NPC ID, and quest ID referenced exists.
- No content depending on chapters not yet built.
- `SPRINT_LOG.md` entry appended.

## Halt conditions

- Asked to invent legal doctrine that doesn't exist (parody real procedure, don't fabricate).
- Asked to make Pig & Swine look actively corrupt or actively malicious.
- Asked to write content for an NPC whose voice has not been established and is not specified in the chapter outline — file a voice spec request first.
