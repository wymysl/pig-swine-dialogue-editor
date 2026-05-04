# Skill: Design

## Activation

When the task involves dialogue, quest text, NPC lines, docket notes, item descriptions, chapter scripts, style-canon extensions, or audio motif briefs (the description text given to the Art role to generate music/SFX).

**Recommended model:** Claude Opus 4 / 4.6 (humor and Polish-legal voice register).

## Required reading (every invocation)

- `AGENTS.md` (especially §Source of truth, §Cast canonical names, §Address forms in dialogue, §Humor rules)
- `PLAN.md` §Vertical slice plan and §Out of scope
- `SPRINT_LOG.md` (last 5 entries)
- `../story.txt` — the relevant chapter section: beats, NPC behavior, gates
- `../style_canon.txt` — Taste Standard pass/reject examples, voice references, court line templates, running jokes catalogue
- `data/voice_references/<character_id>.jsonl` — per-character voice-reference drafts (audited corpus). NOT committed game text; use as voice reference, then author fresh lines into the runtime `data/dialogues/<npc_id>.json`
- `../battle_mechanics.txt` §Player-facing terminology — when writing Casebook judgment names, summaries, principle moves, or opponent statements
- `../minigames.txt` — when writing mini-game flavor text
- `data/dialogues/<npc_id>.json` files (one per NPC; see AGENTS.md ownership table)
- `data/asia_hints.json` when working on Asia content
- `data/chapters/chapter*.json` (text fields you will modify)
- `data/items.json`, `data/judgments.json`, `data/argument_opponents.json` (text fields)

## Allowed writes

- `data/dialogues/dialogues.json`
- `data/chapters/chapter*.json` — **TEXT FIELDS ONLY** (`description`, `label`, `hint`, `flavor`). Never `steps`, `gates`, `on_enter`, `on_exit`.
- `data/items.json` — text fields only.
- `data/doors.json` — `locked_text` field only. Never `target_scene`, `required_flag`, etc.
- `data/judgments.json` — `judgment_name`, `case_summary`, per-move `name`, per-move `flavor_line` only. Tags and effectiveness modifiers belong to Code.
- `data/argument_opponents.json` — `display_name`, opening statement, taunts, defeat lines only. Tags and strength belong to Code.

## Forbidden

- `scripts/**` (all GDScript)
- `scenes/**` (all scenes)
- `state.gd`, `signals.gd`
- `data/chapters/*.json` state-machine fields
- Renaming any topic_id, npc_id, item_id, or quest_step_id without filing a rename proposal first
- Inventing legal doctrine that doesn't exist (parody real procedure or halt)
- Writing content for an NPC whose voice has not been established in `../story.txt`, `../style_canon.txt`, or `data/voice_references/<character_id>.jsonl` — file a voice-spec request artifact first

## Persona patterns

- **Address forms**: every dialogue line you author must comply
  with `AGENTS.md` §Address forms in dialogue. Asia and Mr. Pig
  say "Dr. A. Cula" and "Mr. Murrow"; Dr. A. Cula, Crab, and
  Whimsy say "Murrow"; Crab and Whimsy say "Cula" only after
  their Chapter 1 recruitment scenes. A line that gets the
  address form wrong fails the Taste Standard.

- **Polish-legal flavor**: reference real procedure (KPC articles, doręczenie zastępcze, nieważność postępowania, postanowienie incydentalne, KPA) parodied, never explained inside dialogue.
- **NPC voices**: preserve and extend, do not replace. Use the canonical names — **Dr. A. Cula**, **Mr. Pig**, **Mr. Swine**, **Murrow**, **Crab**, **Whimsy**, **Asia**. Voice profiles live in `../style_canon.txt`; per-character draft lines in `data/voice_references/<character_id>.jsonl`; chapter-specific voice context in `../story.txt`.
  - Dr. A. Cula: observational, dry, occasionally surprised by his own competence.
  - Mr. Pig: panicked, formal-while-falling-apart, escalating sentence energy.
  - Murrow: dry, archival, helpful only when asked precisely; almost never uses adjectives.
  - Crab: terse, observational, suspicious of optimism.
  - Whimsy: grandiose, theatrical, brilliant-when-aimed; loves a flourish; occasionally near-correct.
  - Asia: warm, dry, practical; the only person in the office who knows where things are.
  Every line must read as that NPC even with the speaker tag stripped.
- **Three expression variants** per key dialogue line where supported by the dialogue runner: `{ "neutral": "...", "agitated": "...", "deadpan": "..." }`.
- **Maintain running jokes**: sentient resentful coffee machine, Swine's postcards from inexplicable places, Whimsy's near-miss arguments, Murrow's archival omniscience, the printer with feelings, judges' restrained surprise.
- **Lines under ~140 characters** where possible. Break longer thoughts across consecutive typewriter lines.
- **Four dialogue states** per recurring NPC: before-quest / during-investigation / ready-for-court / after-victory. Asia additionally has per-progress hint states (one per major beat) per `../story.txt`.
- **Wrong Casebook moves must be funny but not totally nonsensical**. Templates: "client was spiritually present", "envelope looked guilty", "deadline was emotionally unreasonable".
- **Casebook flavor**: judgment summaries are one sentence, plain language. Principle move flavor lines are ≤80 characters. Judges' restrained-surprise reactions stay dry — "Counsel, surprisingly, that is a point", never "well done".

## Output (Artifact)

1. Diff of every modified file.
2. **Full text of every new line, quoted, grouped by NPC**, for human review. The reviewer must be able to read the dialogue without reading the diff.
3. Per-line note: which Taste Standard tests it passes (1–5), which running jokes it touches.
4. Updated dialogue tree map (NPC → topics → quest gates) for affected NPCs.
5. List of any new topic_id, npc_id, item_id, or quest_step_id introduced — flagged for Code to wire.

## Acceptance

- `grep` check passes: every `topic_id`, `npc_id`, `item_id`, `quest_step_id` referenced in `dialogues.json` exists somewhere.
- JSON validity: `python -m json.tool` passes on every modified `.json`.
- Every new line passes the Taste Standard (5/5).
- Every key NPC interaction has 3 expression variants on its main lines, where the dialogue runner supports them.
- No content depending on chapters not yet built per `PLAN.md` §Vertical slice plan.
- `SPRINT_LOG.md` entry appended.

## Halt conditions

- Asked to invent Polish legal doctrine that doesn't exist — parody a real one or halt.
- Asked to make Pig & Swine look actively corrupt or actively malicious — halt.
- Asked to write content for an NPC whose voice is not established in `../story.txt` — file a voice-spec request artifact and halt.
- Asked to silently rewrite the four `.txt` source files — those are human-only edits; file a `SPEC_PROPOSAL` artifact and halt.
- Asked to use Pokémon-style game terminology in player-facing Casebook text — use the legal register from `../battle_mechanics.txt` or halt.
- Required reading missing or unreadable — halt and ask the human.
