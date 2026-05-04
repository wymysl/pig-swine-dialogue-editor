# AGENTS.md — Pig & Swine RPG

This is the project constitution. **Every agent reads this first, every invocation, before any code change.** If a directive here conflicts with a sprint task, the constitution wins; halt and ask the human (Orchestrator).

## Project identity

Pig & Swine RPG is a **canvas-based isometric legal comedy RPG** built with Vite + ES modules. Single-developer hobby project. The game's identity is: a parody of post-Soviet legal practice that takes its law seriously and its dignity not at all. The comedy has a legal spine — every joke must rest on a real-ish doctrinal foundation. We are not making a random absurd game; we are making a precise absurd game.

## Stack invariants (never violate)

- Vite + vanilla ES modules. No frameworks added without human approval.
- All visuals are procedural canvas drawing. No PNG/JPG/SVG/WebP asset files imported.
- All audio is Web Audio API (oscillators + envelopes). No MP3/OGG/WAV/FLAC files imported.
- Save/load via localStorage. Save format must remain backward-compatible — see "Save migration" below.
- Canvas dimensions: 960×640. Portrait resolution: 64×64.
- PWA-ready; no breaking that.

## The Taste Standard

Every dialogue line, item description, quest text, and flavor string must pass five tests:

1. **Laugh** — there is something funny in it (joke, oddity, deadpan, wordplay).
2. **Clever** — the funny thing has a real referent: a procedural rule, a Polish legal absurdity, a recurring office detail. Not random absurdity.
3. **Alive** — the line sounds like a person said it, not a system message.
4. **Clear** — the player can tell what the line means and what to do next, even with no legal background.
5. **Future-proof** — the line doesn't break if a later chapter adds context. No jokes about content not yet built. No contradictions with established lore.

A line that passes 4 of 5 is rejected. Edge case: "Clear" can be relaxed for deliberate confusion that the next NPC clears up.

### Three pass / three reject examples

PASS:
- "The firm is not bankrupt. Bankruptcy has paperwork. We are currently in the pre-paperwork screaming phase." (Mr. Pig)
- "Law is mostly memory, deadlines, and finding the document everyone swears was 'just here.'" (Muraś)
- "The notice says delivered. The address says impossible. That is not service. That is postal theatre." (Rak)

REJECT:
- "LOL pigs are funny" — random, no referent.
- "By the venerable doctrine of paragraphus inexpressus..." — fake Latin, no legal anchor.
- "Wait until you see Chapter 4!" — breaks future-proof.

## Humor rules

- **Polish-legal flavor** is the core. References to real procedure (KPC, KPK, KPA), real institutions (Trybunał Konstytucyjny, KRS, RPO, prokuratura), real documents (zaświadczenie, pełnomocnictwo, doręczenie zastępcze, postanowienie) are the raw material. Always parody, never explain.
- **Running jokes** to maintain: the coffee machine is sentient and resentful; Mr. Swine sends only postcards from inexplicable places; Wymysl proposes legally innovative arguments that almost work; Muraś knows where everything is but won't say where without being asked correctly.
- **Pig & Swine is incompetent but morally worth saving.** This is the core joke. Never let the firm look actively corrupt or actively malicious. Cuttable corners and forgotten paperwork — yes. Bribery, fraud, harming clients on purpose — no.
- **The legal system is funny because it is real**, not because it is fake. Real procedures, twisted slightly, beat invented ones every time.
- **No fourth-wall jokes** about being a game. The game world is the world.
- **No sex jokes, no scatological jokes, no slurs.** This includes legal slurs against ethnic, regional, or professional groups.
- Ace Attorney-style typewriter delivery. Keep individual lines under ~140 characters where possible; break longer thoughts across consecutive lines.

## File ownership table

Hard rule: agents only write files they own. To touch a file owned by another persona, write a diff proposal as an Artifact and stop.

| Path | Owner | Notes |
|---|---|---|
| `src/state.js` | Systems | Single-writer. Migration required for shape changes. |
| `src/main.js` | Integration | Single-writer. Glue only. |
| `src/input.js` | Integration | Single-writer. Key bindings. |
| `src/data/dialogues.js` | Story | All dialogue and quest text. |
| `src/data/quests.js` (text fields) | Story | Description, label, hint only. |
| `src/data/quests.js` (state machine) | Systems | Steps, gates, transitions. |
| `src/data/maps.js` | Map | Tile maps, room generators, doors. |
| `src/data/decorations.js` | Map | Decoration arrays. |
| `src/renderer.js` | Graphics | Drawing pipeline. |
| `src/characters.js` | Graphics | Portraits + sprite functions. |
| `src/effects.js` | Graphics | Particle systems if added. |
| `src/audio.js` | Audio | SFX dispatcher. |
| `src/audio/music.js` | Audio | Procedural music engine. |
| `src/systems/*` | Systems | All game systems. |
| `src/minigames/*` | Mini-Game | One file per mini-game. |
| `test_story.py` | QA | Append tests, never remove. |
| `BUILD_NOTES.md` | QA | Append-only. |
| `SPRINT_LOG.md` | All | Append-only. Every agent on completion. |
| `docs/chapters/*.md` | Story | Chapter scripts. |

If a file you need is not in this table, halt and emit an Artifact asking the Orchestrator (human) to assign ownership.

## Save migration policy

Any change to the shape of saved state in `src/state.js` requires:

1. A `migrateSave(oldSave) → newSave` function added to `src/systems/save.js`.
2. A version bump on the save format (`SAVE_VERSION` constant).
3. A test: load a save from the previous sprint's `main` branch, verify migration succeeds, verify the migrated save loads cleanly into the new build.

No exceptions. A broken save eats the playtest cycle.

## Hard build invariants

Every Artifact that modifies code must end with all of the following passing:

- `node --check` on every modified `.js` file.
- `python test_story.py`.
- For Integration and Systems Artifacts: a save/load round-trip verification.
- For Story Artifacts: a `grep`-based check confirming no broken cross-references in the dialogue tree (no missing topic IDs, no missing NPC IDs, no missing quest IDs).

If any of these fail, the Artifact is not done. The agent fixes and re-runs before requesting review.

## Module conventions

- ES modules only. Named exports preferred over default exports.
- File names: kebab-case for files, camelCase for functions, PascalCase for classes.
- No `console.log` in committed code. Use the existing `debugLog()` helper if it exists; otherwise none.
- All new exported functions get a one-line JSDoc comment.
- No new runtime dependencies in `package.json` without human approval.

## Reading order on every invocation

1. AGENTS.md (this file).
2. Last 5 entries of SPRINT_LOG.md.
3. The persona-specific Required Reading list (in the skill file).
4. Then the task.

## Dispute escalation

If two agents' Artifacts disagree (e.g., Story wrote a dialogue branch that Systems didn't gate), the Integration Agent files a `DISPUTE` Artifact and stops. The Orchestrator (human) resolves before any further work.
