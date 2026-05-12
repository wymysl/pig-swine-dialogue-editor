# AGENTS.md — Pig & Swine RPG (Godot)

This is the project constitution. **Every agent reads this first, every invocation, before any code change.** If a directive here conflicts with a sprint task, the constitution wins; halt and ask the human (Orchestrator).

## Project identity

Pig & Swine RPG is a top-down tile legal-comedy RPG built in Godot 4.6.2 with GDScript. Single-developer hobby project. The game's identity: **a parody of post-Soviet legal practice that takes its law seriously and its dignity not at all.** The comedy has a legal spine — every joke must rest on a real-ish doctrinal foundation. We are not making a random absurd game; we are making a precise absurd game.

## Source of truth

The unified game spec lives in five `.txt` files at the repo root, read in this order:

1. `../story.txt` — chapters, beats, NPC behavior, gates, court structure. Authoritative for what happens.
2. `../world.txt` — overworld structure, 128×128 coordinate system, district scenes, route blockers, chapter-based unlocking, English↔Polish place-name translation table.
3. `../minigames.txt` — Coffee Brewing, Document Chase. (Scooter Racing, Ski Slalom dropped; Final Printer is a Casebook battle.)
4. `../battle_mechanics.txt` — the Casebook Battle System.
5. `../style_canon.txt` — Taste Standard examples, voice references, visual style canon, audio canon, court design principles, Warsaw atmosphere and easter-egg roster. Authoritative for how things sound and look.

Voice references for individual characters live in `data/voice_references/<character_id>.jsonl`. These are illustrative draft lines, NOT committed game text; Design agents read them when authoring per-NPC dialogue files in `data/dialogues/<npc_id>.json`. Every committed line still goes through the Taste Standard pass at JSON-authoring time.

The `_legacy/archive/` JS prototype, the `_legacy/design/` folder, and `_legacy/dialogue_samples.txt` (superseded by `data/voice_references/`) are out-of-scope. Do not reference them; do not cite `design_bible.md` — its useful material has been ported into `style_canon.txt` and this file.

## Cast — canonical names

In narration, spec docs, code identifiers, JSON keys, autoload paths, and these governance docs, use the canonical reference exactly. The in-dialogue address form may differ — see §Address forms in dialogue.

- **Dr. A. Cula** — player character. Canonical reference. Never "Kula", never "Doctor Cula", never "the doctor" alone.
- **Mr. Pig** — panicked founder.
- **Mr. Swine** — absent founder.
- **Murrow** — fully-qualified *adwokat* (lawyer); functions as the firm's archivist by temperament. Canonical reference. Never "Muraś". Late 20s; same generation as Cula, Crab, Whimsy.
- **Crab** — *aplikant adwokacki* (legal apprentice); the firm's de-facto investigator. Not "Rak". Late 20s.
- **Whimsy** — *aplikant adwokacki*; rhetorical associate, deployed for courtroom flourish. Not "Wymysl". Late 20s.
- **Asia** — front-desk secretary. Permanent office NPC, repeatable hint source.

Other named NPCs are introduced per chapter; their names live in `../story.txt`.

## Address forms in dialogue

These rules apply ONLY to in-game dialogue lines (`data/dialogues/dialogues.json`, `data/asia_hints.json`, judgment flavor lines, sign text, postcard text, court statements). They do NOT apply to spec, narration, code, or these governance docs — those always use the canonical reference.

**Dr. A. Cula** is addressed as:
- "**Dr. A. Cula**" by every NPC, by default.
- "**Cula**" by **Crab** and **Whimsy** only — and only after their respective Chapter 1 recruitment scenes. Before recruitment, even Crab and Whimsy use "Dr. A. Cula".

**Murrow** is addressed as:
- "**Murrow**" by **Crab** and **Whimsy** always. They have known him for years; they are first-name terms.
- "**Mr. Murrow**" by **Dr. A. Cula** at the first meeting. Cula is a new junior; he opens with the honorific. During that first conversation in Chapter 1, Murrow explicitly invites informality with a line on the order of *"It is Murrow, to friends. The 'Mister' I keep for invoices."* From that scene forward, Cula says "Murrow". Before that beat, Cula must use "Mr. Murrow".
- "**Mr. Murrow**" by **Asia**, with a comic running ambivalence. Murrow's invitation to Cula is conspicuously *not* extended to Asia in the same scene; he hedges, says something like *"I am still deciding whether reception staff qualify as friends or as workplace constellations."* Asia then keeps "Mr. Murrow" as her form, and may reference the unresolved status whenever it serves a joke (e.g., *"Mr. Murrow — I am still officially under review for first-name privileges, but the binder is on his desk"*).
- "**Mr. Murrow**" by every other character — Mr. Pig, Mr. Swine, every chapter NPC, every judge, every opponent.

Quest objective strings, docket entries, and system messages address the player directly ("Find the procedural binder" / "Speak to Mr. Pig") and do not use the player's name except in the rare case where a name is needed — there, use "Dr. A. Cula".

A line that violates these address rules fails the Taste Standard automatically. Design's authoring acceptance gate checks every quoted line against the speaker.

## First-meeting introductions

The first dialogue exchange between Dr. A. Cula and any named NPC must include a recognisable greeting before the conversation pivots to task content. A state that violates this rule fails the Taste Standard automatically.

Concretely:

- Cula opens with the NPC's name plus a self-identification or address-form. Examples in current canon: *"Crab. I'm Cula."* / *"Mr. Murrow. I was told you'd have the Sikorska file."* / *"Mr. Whimsy. Cula, Pig & Swine."* / *"Good morning, Mrs. Sikorska. Dr. A. Cula."*
- The NPC acknowledges Cula by name or honorific before any task hand-off.
- Any state whose trigger gates only on inventory or quest flags (e.g. `chapter1.has_law_binder == true`) must additionally check the corresponding `met_<npc>` flag, or be preceded in JSON order by a state that does. Otherwise a player who satisfies the inventory condition before ever speaking to the NPC will skip the introduction beat. The dialogue runner picks the first state in JSON order whose trigger evaluates true (`scripts/autoload/dialogue_runner.gd`), so JSON-order priority is a legitimate defence — but explicit `met_<npc>` clauses on the later states are preferred for self-documentation.
- When the canonical first-meeting and a parallel inventory hand-off can both legitimately happen on first contact (e.g. Cula acquires the procedural binder before ever speaking to Crab), author a *fused* state that does both at once. Do not let an inventory-handoff line stand as the first word spoken between Cula and the NPC.

Carve-out: purely transactional NPCs (counter staff, vendors, ticket sellers) where the order itself *is* the social opening. The barista's *"Black coffee."* satisfies this rule because ordering at a counter is the recognised first move; no name exchange is expected.

Authoring acceptance: when adding or modifying states for an NPC with an introduction beat, verify that no later state can fire while `met_<npc> == false`. As of phase-7, NPCs with introduction beats are: `pig`, `murrow`, `crab`, `whimsy`, `asia`, `halina`. Future chapter NPCs that recur or carry standalone identity inherit this rule; the transactional carve-out applies only to one-shot service interactions.

## Stack invariants (never violate)

- Godot 4.6.2, GDScript only. No C#, no GDExtension, no third-party engine plugins without human approval.
- Top-down 2D. `Camera2D` follows the player; orthogonal grid; tile size 32×32 by default, sprites 32×48 for upright NPCs.
- 128×128 overworld coordinate system from day one. Districts and routes are individual scenes loaded under one `overworld.tscn`. Chapter 1 only populates the Office Street corridor; later chapters extend into other districts.
- Content is data, code is engine: dialogue lives in `data/dialogues/<npc_id>.json` (one file per NPC); voice references in `data/voice_references/<character_id>.jsonl`; quest steps in `data/chapters/chapter*.json`; doors in `data/doors.json`; Casebook judgments in `data/judgments.json`; opposing arguments in `data/argument_opponents.json`. Code reads these; designers edit these.
- Cross-system communication via the `Signals` autoload only. No direct imports between systems.
- Save/load via `user://save.json`. Save format must remain backward-compatible — see "Save migration".
- Web export is the primary target. Every PR must pass a clean Web export.
- Resolution: 960×640 viewport, integer scaling. Pixel-perfect snapping on.
- Asset rules: small committed PNG sprites and short OGG audio loops only. No proprietary fonts. No copyrighted melodies. Total `art/` budget under 5MB until further notice.
- Language: English-first. All player-facing strings live in JSON for future i18n. No hardcoded strings in `.gd` or `.tscn`. Polish institutional names appear with correct diacritics (KPC, doręczenie zastępcze, Trybunał Konstytucyjny).
- Accessibility: every UI text passes WCAG AA contrast. No information conveyed by color alone — Casebook effectiveness is shown by color *and* text label.
- Save: one slot. Autosave on chapter transitions and major quest milestones; one manual save from the case bag.
- Casebook: tag taxonomy is a closed list in `data/tag_taxonomy.json`. New tags require a Code artifact. Effectiveness logic lives only in `scripts/systems/battle/effectiveness.gd` — never per-judgment.

## The Taste Standard

Every dialogue line, item description, quest text, and flavor string must pass five tests:

1. **Laugh** — there is something funny in it.
2. **Clever** — the funny thing has a real referent (a procedural rule, a Polish legal absurdity, a recurring office detail). Not random absurdity.
3. **Alive** — the line sounds like a person said it, not a system message.
4. **Clear** — the player understands the meaning and the next step.
5. **Future-proof** — the line doesn't break when later chapters add context.

A line that passes 4 of 5 is rejected. Edge case: "Clear" can be relaxed for deliberate confusion that the next NPC clears up.

## Humor rules

- **Polish-legal flavor** is the core. Real procedure (KPC, KPK, KPA), real institutions (Trybunał Konstytucyjny, KRS, RPO, prokuratura), real documents (doręczenie zastępcze, postanowienie, pełnomocnictwo) — always parodied in motion, never explained.
- **Pig & Swine is incompetent but morally worth saving.** Cuttable corners — yes. Bribery, fraud, harming clients on purpose — no.
- **No fake Latin.** No fourth-wall jokes about being a game. No modern internet voice ("yikes", "tbh", emoji). No sex jokes, scatological jokes, slurs.
- **Real people forbidden.** Invent fictional analogues. Real Polish institutions named directly are permitted, never libelous.
- **Asia tone**: warm, dry, practical. She is the front-desk secretary, not a lawyer. She softens player confusion without breaking immersion.
- **Casebook UI register**: legal, not gamey. Use "Argument Strength" not "HP", "Legal Encounter" not "Battle", "Authority" not "Element". See `battle_mechanics.txt` §Player-facing terminology.

## File ownership table

Hard rule: agents only write files they own. To touch a file owned by another role, write a diff proposal artifact and stop.

| Path | Owner | Notes |
|---|---|---|
| `scripts/autoload/state.gd` | Code | Single writer. Migration required for shape changes. |
| `scripts/autoload/signals.gd` | Code | Single writer. Signal bus only. |
| `scripts/autoload/casebook.gd` | Code | Single writer. Player's collected judgments. |
| `scripts/systems/**` | Code | All gameplay systems including `battle/`. |
| `scripts/actors/**` | Code | Player, NPC, interactable, route_blocker controllers. |
| `scenes/Main.tscn` | Code | Single writer. Glue and autoloads only. |
| `scenes/world/**` | Code (structure) + Art (decoration nodes) | See split below. |
| `scenes/interiors/**` | Code (structure) + Art (decoration nodes) | See split below. |
| `scenes/ui/**` | Code | UI scenes including `casebook_view.tscn`, `battle_screen.tscn`. |
| `scenes/mini_games/**` | Code (structure) + Art (visuals/audio) | |
| `data/dialogues/<npc_id>.json` | Design | One file per NPC (e.g., `pig.json`, `murrow.json`, `crab.json`). Code's dialogue_runner loads every `.json` in this directory at boot. Per-NPC files keep parallel Design sprints conflict-free and mirror the per-NPC pattern already used by `data/asia_hints.json`. |
| `data/chapters/chapter*.json` (text fields) | Design | `description`, `label`, `hint`, `flavor`. |
| `data/chapters/chapter*.json` (state machine) | Code | `steps`, `gates`, `on_enter`, `on_exit`. |
| `data/items.json` | Design (text) + Code (mechanical effects) | |
| `data/doors.json` | Code (gates) + Design (`locked_text`) | |
| `data/judgments.json` | Design (name, summary, principles, flavor) + Code (tags) | Two-pass authoring; see Casebook section below. |
| `data/argument_opponents.json` | Design (name, statements, flavor) + Code (tags, strength) | |
| `data/tag_taxonomy.json` | Code | Single writer. Closed Casebook tag list. New tags require a Code artifact and an update to `scripts/systems/battle/effectiveness.gd`'s assertions. |
| `data/asia_hints.json` | Design | Asia's progress-keyed hint table. Schema mirrors `dialogues.json` per-NPC structure. Asia is outer-circle: she says "Dr. A. Cula" and "Mr. Murrow" per §Address forms. |
| `art/**` | Art | Sprites, portraits, tiles, palettes. |
| `audio/**` | Art | Music and SFX. (Audio collapsed into Art.) |
| `tests/**` | QA | Append-only. |
| `tests/fixtures/**` | QA | Append-only reference data — save fixtures, dialogue fixtures. Never modify a fixture in place; add a new one. |
| `exports/web/` | QA / build artifact | Web-export output dir. Built by `godot --headless --export-release "Web" exports/web/index.html`. Only `.gitkeep` is committed; build artifacts (`*.html`, `*.js`, `*.wasm`, `*.pck`) are gitignored. |
| `BUILD_NOTES.md` | QA | Append-only. |
| `SPRINT_LOG.md` | All | Append-only. Every agent on completion. |
| `CURATION_BOARD.md` | Human only | Live session tracker. Agents may read; agents do not edit. Read at the top of every multi-step task to see "Current Build State" and "Next Best Task". |
| `../story.txt`, `../world.txt`, `../minigames.txt`, `../battle_mechanics.txt`, `../style_canon.txt` | Human only | Spec source-of-truth. Agents read; agents propose changes via artifacts; the human edits. |
| `data/voice_references/<character_id>.jsonl` | Design (authoring) / Human (acceptance) | Voice-reference drafts per character. NOT committed game text. Read by Design when authoring `data/dialogues/<npc_id>.json`. |
| `PLAN.md`, `AGENTS.md`, `MANAGING_AGENTS.md`, `.antigravity/skills/**`, `PROPOSALS.md` | Human only | Project governance. |

Special note on `data/chapters/chapter*.json` while the file is a stub (only `version`, `chapter_id`, `title`, `_doc`, and empty `steps: []`): Code may add steps with their `id` and `gates`/`on_enter`/`on_exit` first; Design may then populate `description`, `label`, `hint`, `flavor` for any step Code has written. Design must not pre-populate text fields for steps Code has not yet defined.

For room and overworld scenes specifically: Code owns the scene's root node, scripts, signal connections, and gameplay objects (player spawn, NPCs, interactables, doors, route blockers). Art owns decoration `Sprite2D` and `TileMapLayer` children, palette `.tres` resources, and ambient audio nodes. If a change requires both, file a paired artifact.

## Casebook authoring (special two-pass)

Each judgment in `data/judgments.json` is authored in two passes:

1. **Code pass** writes the structural shape: `id`, three-tag set (Article tag, Principle tag, Context tag), `principle_moves[]` with `id`, `effectiveness_modifiers`, `cost`. Tag taxonomy is fixed in `scripts/systems/battle/effectiveness.gd`.
2. **Design pass** writes the human-facing fields: `judgment_name` (short citation), `case_summary` (one sentence, plain language, Taste Standard 5/5), per-move `name`, per-move `flavor_line` shown when invoked.

Neither pass overwrites the other's fields. New judgments require both passes before the entry is playable; partially authored entries stay flagged `draft: true` and are not loaded by `casebook.gd`.

## macOS userdata permissions (one-time setup)

The project uses `config/use_custom_user_dir=true` and `config/custom_user_dir_name="pig_swine_rpg"`. On first run, Godot creates `~/Library/Application Support/pig_swine_rpg/` for logs, saves, and runtime state. Due to macOS TCC sandboxing, this directory can only be created by the Godot `.app` itself — not by shell-launched Godot binaries or other tools.

**One-time setup (per machine):** open the project once via Godot Editor (`open -a Godot`, then load the project). Quit. After that, the userdata directory exists with the right entitlements and all CLI commands work normally.

**If the userdata directory has not been created**, CLI commands will crash in `RotatedFileLogger` with signal 11 before the engine boots. Workaround until the editor has been opened: add `--log-file /tmp/godot.log` to every CLI invocation. Document this in the artifact's `SPRINT_LOG.md` entry so the next agent knows the editor open is still pending.

## Save migration policy

Any change to the shape of saved state requires:

1. A `migrate_save(old: Dictionary) -> Dictionary` function in `scripts/systems/save.gd`.
2. A version bump on `SAVE_VERSION` constant.
3. A test in `tests/test_save_load.gd`: load a fixture from the previous sprint, verify migration succeeds, verify the migrated save loads cleanly into the new build.

No exceptions. A broken save eats the playtest cycle.

## Hard build invariants

Every artifact that modifies code must end with all of the following passing:

- `godot --headless --path . --script tests/test_smoke.gd` (loads project, parses every script, runs Main.tscn for one frame, exits cleanly). The earlier spec command `godot --headless --check-only --path .` does NOT self-terminate in Godot 4.6 — `--check-only` requires `--script`. Use the smoke-test form.
- `godot --headless --script tests/test_runner.gd` (GUT, exit 0).
- For Code artifacts touching state or save: a save/load round-trip against the previous sprint's fixture.
- For Design artifacts: a cross-reference check confirming every `topic_id`, `npc_id`, `item_id`, `quest_step_id`, `judgment_id` referenced in `dialogues.json` and `chapter*.json` exists.
- A clean Web export: `godot --headless --export-release "Web" exports/web/index.html` produces a non-empty file with no errors.

If any of these fail, the artifact is not done.

## Module conventions

- GDScript style: `snake_case` for vars/functions, `PascalCase` for classes, `SCREAMING_SNAKE_CASE` for constants.
- Typed GDScript: every function signature has parameter and return types. `Variant` only when truly needed.
- `class_name` only when the class is referenced from elsewhere.
- One node, one responsibility. Long scripts (>300 lines) get split.
- No `print()` or `printerr()` in committed code outside `tests/`.
- Signals declared at top of script with a one-line comment describing payload.
- `tool` scripts only when the script genuinely needs editor execution.

## Reading order on every invocation

1. `AGENTS.md` (this file).
2. Last 5 entries of `SPRINT_LOG.md`.
3. `PLAN.md` §Vertical slice plan and §Out of scope.
4. The role-specific Required Reading list in `.antigravity/skills/<role>.md`.
5. The relevant section(s) of the five `.txt` source files (story, world, minigames, battle_mechanics, style_canon).
6. Then the task.

## Dispute escalation

If two agents' artifacts disagree (e.g., Design wrote a dialogue branch that Code didn't gate), the next agent that notices files a `DISPUTE` artifact and stops. The Orchestrator (human) resolves before any further work. Do not silently reconcile.

## Forbidden patterns

- Editing `state.gd`, `casebook.gd`, `signals.gd`, or `Main.tscn` from outside the Code role.
- Editing the five `.txt` source files at repo root (only the human edits these).
- Renaming any exported symbol or autoload path without a deprecation window.
- Adding a runtime dependency (Godot plugin, addon) without human approval.
- Building Chapter N+1 content while Chapter N is not yet shippable per `PLAN.md` §Vertical slice plan.
- Inventing Polish legal doctrine that does not exist. Parody real procedure or halt.
- Making Pig & Swine look actively corrupt or actively malicious.
- Using game-y terminology in Casebook UI text ("HP", "monster", "type advantage", "level up"). Use the legal register from `battle_mechanics.txt`.
- Building wild-argument overworld encounters. Battles only in scripted court rounds and scripted advocate challenges.
- Building Scooter Racing or Ski Slalom mini-games. Chapter 4 ships with travel-narrative cutscenes instead.
- Treating the Final Printer as a mini-game. It is a Casebook battle in Chapter 5.
- Adding a "Casebook completion" meter or collection-percentage UI.
- Hardcoding any player-facing string in `.gd` or `.tscn`. All strings flow from `data/`.
