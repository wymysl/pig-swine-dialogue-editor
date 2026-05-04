# Pig & Swine RPG — Godot Build Plan

This plan governs a fresh Godot 4.6.2 build of Pig & Swine RPG, with Google Antigravity as the primary agent IDE.

## Source of truth

The unified spec lives in five `.txt` files at the repo root:

- `../story.txt` — chapters, beats, NPC behavior, gates, court structure (Parts 1, 3, 4).
- `../world.txt` — overworld structure, 128×128 coordinate system, district scenes, route blockers, chapter-based unlocking, English↔Polish place-name translation table (Part 2).
- `../minigames.txt` — Coffee Brewing and Document Chase (Part 5). Scooter Racing and Ski Slalom are dropped; Final Printer is reframed as a Casebook battle.
- `../battle_mechanics.txt` — the Casebook Battle System (Part 6).
- `../style_canon.txt` — Taste Standard examples, voice references, visual/audio canon, court design principles, Warsaw atmosphere and easter-egg roster.

Voice-reference drafts per character live in `godot/data/voice_references/<character_id>.jsonl` (audited, committed-clean). The previous JS prototype, the legacy `design/` canon, and the legacy `dialogue_samples.txt` are under `_legacy/` and explicitly out-of-scope.

## Decisions on file

- **Engine:** Godot 4.6.2, GDScript.
- **Perspective:** top-down tile, with `Camera2D` follow.
- **Coordinate system:** 128×128 overworld from day one (per `world.txt`). Districts populated chapter by chapter, blocked routes visible from minute one.
- **Primary export target:** HTML5/web. Native exports come after Chapter 1 ships.
- **Agent roles:** Design, Code, Art, QA. Four collapsed roles, see `.antigravity/skills/`.
- **Asset rule:** small committed PNG sprites and short OGG loops are allowed. Aesthetic constraints (32×48 sprites, ~40-color palette, original audio only, pixelated-readable-warm) remain. See `AGENTS.md`.
- **Casebook Battle System** is a core Code-owned system, not a one-off Chapter 1 feature. See `../battle_mechanics.txt` and `AGENTS.md` §"File ownership".

## Why a fresh build, not a port

The valuable assets are the five `.txt` files at repo root and the audited voice-reference corpus in `godot/data/voice_references/`. The JS code in `_legacy/archive/` is throwaway. Read the spec; build it new.

## Project structure

The Godot tree below combines what `world.txt` prescribes (district and route scenes) with the standard project hygiene (autoloads, systems, data directories).

```
pig-swine-rpg/
  _legacy/                         # frozen — JS prototype, old design canon, dialogue_samples.txt
  story.txt                        # SOURCE OF TRUTH
  world.txt
  minigames.txt
  battle_mechanics.txt
  style_canon.txt
  tools/
    voice_audit.py                 # mechanical audit + auto-fix for voice JSONLs
    README.md
  godot/                           # this project
    project.godot
    AGENTS.md                      # constitution
    PLAN.md                        # this file
    MANAGING_AGENTS.md             # human playbook
    CURATION_BOARD.md              # live session tracker
    PROPOSALS.md                   # editorial decisions log
    SPRINT_LOG.md                  # append-only
    BUILD_NOTES.md                 # append-only
    VOICE_AUDIT.md                 # latest voice-reference audit report
    .antigravity/skills/
      design.md
      code.md
      art.md
      qa.md
    scripts/
      autoload/
        state.gd                   # singleton state, save/load owner
        signals.gd                 # global signal bus
        casebook.gd                # player's collected judgments
      systems/
        quests.gd
        room_transition.gd
        dialogue_runner.gd
        evidence_board.gd
        save.gd
        battle/                    # Casebook Battle System
          battle_controller.gd
          effectiveness.gd
          judgment.gd
          principle_move.gd
          argument_opponent.gd
        mini_games/
          coffee.gd
          document_chase.gd
          # Final Printer is a Casebook battle, not a mini-game (see §Out of scope permanently)
          # Scooter Racing and Ski Slalom are dropped; cutscenes replace them in Chapter 4
      actors/
        player.gd
        npc.gd
        interactable.gd
        route_blocker.gd
    scenes/
      Main.tscn                    # boot, autoload glue
      world/
        overworld/
          overworld.tscn
          overworld_controller.gd
        districts/                  # populated chapter by chapter
        routes/                     # populated chapter by chapter
      interiors/                    # populated chapter by chapter
      ui/
        dialogue_box.tscn
        docket.tscn
        case_bag.tscn
        casebook_view.tscn          # Pokédex-equivalent for judgments
        battle_screen.tscn
      mini_games/
        coffee.tscn                 # Chapter 1
        document_chase.tscn         # Chapter 2
    data/
      chapters/
        chapter1.json               # quest steps, gates (Code) + text fields (Design)
        chapter2.json               # ... per chapter
      dialogues/
        <npc_id>.json               # one file per NPC (per AGENTS.md ownership table)
        _schema.md                  # schema reference
      voice_references/
        dialogue_samples_<character>.jsonl   # 38 files; voice-reference drafts
      asia_hints.json               # Asia's progress-keyed hint table
      tag_taxonomy.json             # closed Casebook tag list (Code-owned)
      items.json
      doors.json                    # door_id → target_scene + spawn + required_flag
      judgments.json                # Casebook entries
      argument_opponents.json       # opposing arguments by chapter
    art/
      sprites/                     # NPC sprites, 32×48 default
      portraits/                   # 64×64 dialogue busts
      tiles/                       # tilesets
      palettes.tres
    audio/
      music/                       # per-location loops
      sfx/                         # short SFX
    tests/
      test_runner.gd               # GUT entrypoint
      test_quests.gd
      test_save_load.gd
      test_battle.gd
      fixtures/                    # save fixtures from prior sprints
    exports/
      web/                         # build output, gitignored
```

Two principles. **Content is data, code is engine**: dialogue, doors, judgments, opponents, quest steps all live in JSON; code reads them. **Single-writer files**: `state.gd`, `casebook.gd`, `signals.gd`, `Main.tscn`, every `data/chapters/chapter*.json` state-machine — exactly one owner each.

## Vertical slice plan

Chapter 1, web-exported, playable end-to-end, no console errors. Chapter 1 from `story.txt` is detailed enough to drive ~6 sprints. Resist the temptation to scaffold all five chapters or implement the full overworld first.

1. **Skeleton** (1–2 sessions). Empty Godot project; autoloads `state.gd`, `signals.gd`, `casebook.gd`; placeholder Office Street with a player that walks; web export passes; QA writes `tests/test_runner.gd`.
2. **Office Street + Pig & Swine interior** (2–3 sessions). `office_street.tscn` and `pig_swine_office.tscn` with door transitions. Asia at reception. Mr. Pig pacing. Murrow hidden near files. Coffee machine that makes a noise admissible only under seal. Dialogue runner reads `dialogues.json`. Save/load round-trip works. Locked routes (Residential, Business, City Hall, Airport, Supreme Court) visible with `route_blocker.gd` flavor lines from `story.txt`.
3. **Investigation loop** (3–4 sessions). Asia hint states. Murrow's case briefing. Procedural Binder pickup in archive area. Crab and Whimsy recruitment. Café Paragraf scene with optional coffee mini-game. Docket (Q), Case Bag (I), Casebook view (C — placeholder until court).
4. **Casebook Battle System v1** (3–4 sessions). The minimum Casebook engine sufficient for Chapter 1 court: `judgment.gd`, `principle_move.gd`, `argument_opponent.gd`, `effectiveness.gd`, `battle_controller.gd`, `battle_screen.tscn`. Three-tag effectiveness resolver (Article + Principle + Context). One starter judgment delivered with the Procedural Binder. Court round = battle encounter. Wrong-but-funny moves from `story.txt`.
5. **Court + payoff** (2–3 sessions). Three court rounds wired as battle encounters. Result screen with stat deltas. Day-One Summary. Swine postcard. "Day-One Survivor" badge.
6. **Polish + writing pass** (2–3 sessions). Asia/Pig/Murrow/Crab/Whimsy expression sets. Per-location music loops. Coffee mini-game with rhythm-timing per `minigames.txt`. Four dialogue states per recurring NPC. Taste-Standard pass on every line.

A "session" is one focused agent run plus your review, ~30–90 minutes of human time. Total budget for the slice: ~14–20 sessions, ~4–8 weeks at one daily session.

When Chapter 1 ships in a web build a stranger can play through: stop. Playtest with two real humans. Only then start Chapter 2.

## What gets built once vs per-chapter

The Casebook Battle System, the dialogue runner, the room-transition system, and the docket/case-bag/casebook UI are **built once**, in Chapter 1, and reused across every later chapter. Chapter 2's Evidence Board is a new system; Chapter 3's contradiction-spotting and time-pressure layers extend the battle controller; Chapter 4's travel and translation mechanics are new; Chapter 5's Final Printer encounter is a Casebook battle (not a mini-game — see §Out of scope permanently) using accumulated judgments from Chapters 1–4. The vertical slice plan above is correct only if the Chapter 1 systems are designed reusable from day one.

## Tooling split

**Antigravity (primary).** Open `godot/` as a workspace. Cascade reads `AGENTS.md` and the four skill files. Use parallel subagents in worktrees only for safe pairs (Design + Art, Design + Code-not-touching-text, QA + anything). Antigravity's built-in browser verifies the web export every PR.

**Cowork (secondary).** Best for writing-heavy work that wants a fresh context: dialogue passes for one NPC, judgment-card writing (each Casebook entry is a small writing task), post-playtest review where you describe what went wrong and ask for a backlog rewrite. Cowork edits the same workspace folder.

**Codex (optional).** Second-opinion code review on save-migration PRs and battle-system PRs. Not part of the daily flow.

## Development loop

```
PLAYTEST → PICK ONE PROBLEM → SPEC → IMPLEMENT → REVIEW → WEB-VERIFY → NOTES
```

Substitutions for Godot:

- "JS syntax check" → `godot --headless --path . --script tests/test_smoke.gd` (parses every script, runs Main.tscn for one frame, exits cleanly). The naive `--check-only --path .` command does not self-terminate in Godot 4.6.
- "python test_story.py" → `godot --headless --script tests/test_runner.gd` (GUT).
- "browser verify" → `godot --headless --export-release "Web" exports/web/index.html`, open in Antigravity browser.
- "save/load round-trip" → `tests/test_save_load.gd` runs against the previous sprint's fixture in `tests/fixtures/`.

## Out of scope until Chapter 1 ships

- Chapter 2–5 scaffolding beyond the JSON file headers.
- Native Mac/iOS exports.
- True isometric perspective.
- Districts beyond what Chapter 1 needs (per `world.txt` chapter-based unlocking).
- Evidence Board, Document Chase, Scooter Racing, Ski Slalom, Final Printer.
- Fast travel / tram (defer per `world.txt` until after a chapter or two of manual walking).

If an agent proposes work in this list, reject the artifact with one line: "out of scope per PLAN.md §Out of scope". Do not negotiate.

## Out of scope permanently (per approved PROPOSALS.md)

- **Wild-argument overworld encounters.** The Casebook Battle System runs in scripted court rounds and a small number of scripted advocate-challenge encounters only. No wild encounters, no encounter-rate tuning, no overworld grass.
- **Scooter Racing and Ski Slalom mini-games.** Replaced by brief travel-narrative cutscenes in Chapter 4. May be revisited after Chapter 4 ships if the narrative cutscenes feel weak.
- **Final Printer as a one-off mini-game.** Reframed as a Casebook battle against an industrial-printer opponent in Chapter 5, using accumulated judgments. The office printer is *not* the antagonist.
- **"Collect 'em all" Casebook completion as a goal.** Casebook fills via fixed in-world rewards (each chapter delivers 2–4 judgments). Chapter 1 ships with 3–5 judgments total. No card-back-of-the-game completion meter.

## Standing decisions (per approved PROPOSALS.md)

- **Language: English-first.** All UI and dialogue in English. Polish institutional names spelled correctly (KPC, doręczenie zastępcze, etc.) with proper diacritics. Polish translation may follow after Chapter 1 ships; design strings for i18n now (no hardcoded strings in `.gd`, all text from `.json`).
- **Save slots: one slot.** Autosave on chapter transitions and major quest milestones. One manual save in the case bag. New Game prompts to overwrite.
- **Court-loss handling: never blocks.** Losing a court round produces a weaker variant — less reputation, no badge, weaker payoff scene. Chapter 1's weak-win is the floor; the player always advances.
- **Tutorial visibility: minimal.** A one-line floating prompt above the player for the first instance of each input (`[Space] to interact`, `[Q] for docket`, `[I] for case bag`, `[C] for casebook`), then never again. No modal tutorial, no popup. Asia carries the rest of the teaching diegetically.
- **Accessibility floor.** Every UI text passes WCAG AA contrast against its background. No information conveyed by color alone — Casebook effectiveness shown by both color and text label. QA enforces this.
- **Casebook taxonomy is closed.** Tags live in `data/tag_taxonomy.json` (single source). Adding a tag requires a Code artifact. Effectiveness resolver in `scripts/systems/battle/effectiveness.gd` is the single resolver; agents do not write per-judgment effectiveness logic.
