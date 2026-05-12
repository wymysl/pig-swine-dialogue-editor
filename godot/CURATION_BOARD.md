# Curation Board

The live tracker for the Godot rebuild. Update at the end of every session. The "Next Best Task" line is the prompt source for the next agent run — never let it sit empty.

## Current Focus

Phase 8 post-playtest rewrite of Chapter 1 + insertion of compact Chapter 3 (Kacper). Spec work complete (Stages 1-15 of the rewrite). Phase-7 voice-pack drafting (V1.* updates + V1.4 + V3.* new) and Sprint 9 ("Full Dialogue System & Quest Logging") are the parallel next moves.

## Current Build State

- Decisions on file (see `PLAN.md` and `AGENTS.md`):
  - Godot 4.6.2, GDScript, top-down tile, web-first.
  - Four agent roles: Design / Code / Art / QA.
  - English-first; Polish translation may follow (translation table seeded in `world.txt`).
  - **(Phase 8 sharpening, 2026-05-07.)** English-version dialogue convention: only proper names of people and places (and PLN currency) appear in Polish; no Polish greetings, address forms, common nouns, or idioms. Pre-phase-8 canonical content (e.g., Pig's *aplikatura* lecture sample) is grandfathered.
  - Casebook Battle System is load-bearing; no wild encounters; Final Printer is a Casebook battle.
  - Mini-game roster: Coffee Brewing (Ch1), Document Chase (Ch2). Scooter Racing and Ski Slalom dropped.
  - Tag taxonomy in `data/tag_taxonomy.json` (closed list). **(Phase 8.)** Added context tags for Ch1 Halina case (`tenancy`, `address_renumbering`, `actual_notice_window`, `inheritance_paperwork`, `third_party_non_cure`) and Ch3 Kacper case (`ex_officio_appointment`, `pre_broken_lock`, `homelessness_circumstance`, `suspended_sentence`).
  - Effectiveness resolver skeleton in `scripts/systems/battle/effectiveness.gd`.
  - STUB / PUTKA union founded in Chapter 5 Beat 11.5 (canonical, see `style_canon.txt §3`). **(Phase 8 renumber: was Ch3.)**
  - **(Phase 8.)** Six chapters now (was five): Ch1 Financial Crisis (Halina + extended structure), Ch2 Eviction Defense (Waldek), **Ch3 The Assigned Case (NEW; Kacper's compact criminal-defense chapter)**, Ch4 Printer Conspiracy (was Ch3), Ch5 Mr. Swine Returns (was Ch4), Ch6 Final Brief (was Ch5).
  - Warsaw is named directly; atmosphere + easter-egg roster in `style_canon.txt §8`.
- Source-of-truth files (5 `.txt` at repo root): `story.txt`, `world.txt`, `minigames.txt`, `battle_mechanics.txt`, `style_canon.txt`. Plus `tools/voice_audit.py`.
- Voice-reference corpus: 38 files in `data/voice_references/`, audited committed-clean (1 informational POSSIBLE_FIRST_MEETING flag, expected and correct). **Phase 8: V3.* compact-chapter packs are pending (5 packs added to `phase_7_packs/00_pack_manifest.md`).**
- Legacy material under `_legacy/`: JS prototype, `design/`, `dialogue_samples.txt` (superseded by `data/voice_references/`).

## Pending tidy-ups (small)

- `dialogue_samples.txt` still at repo root; needs to move to `_legacy/` (one shell command).
- `tools/voice_audit.py` may want a final extension to validate STUB/PUTKA address forms in committed dialogues, but only after runtime JSONs exist.

## Current Weaknesses

- No Godot project yet. All preceding sessions have been spec, governance, and voice-reference work.
- `story.txt` Chapter 5 still calls Final Printer a "Boss Battle" mini-game in Beat 8 — needs a re-tag pass per the `style_canon.txt` decision (it's a Casebook battle). Not blocking; will surface in audit when the next ChatGPT run touches Chapter 5.
- `story.txt` Chapter 3 Beat 12 still describes Scooter Racing as a mini-game — needs prose update to reflect the narrative-cutscene reframe. Not blocking.

## Next Best Task

Implement Sprint 9: "Full Dialogue System & Quest Logging".

> Read `AGENTS.md`, `PLAN.md` §Vertical slice plan, and the last 5 entries of `SPRINT_LOG.md`.
>
> Task: Implement Sprint 9.

## Recent Improvements

(Session 8 — 2026-05-07, **Phase 8 post-playtest rewrite**)
- **Stranger-playtest of Chapter 1 fired the curation board's "playtest before extending" gate.** Three findings drove a substantive rewrite (see `narrative_revision/audit/chapter_1_v2.md`):
  - The first issue felt like a fetch quest (client offstage by design).
  - Pacing felt rushed (each beat delivered its function and exited).
  - Characters appeared punch-line-y (no breathing room for register to land).
- **Chapter 1 expanded to 14 beats** (was 12). Two new beats added: **Beat 8** — client meeting at office with Halina Sikorska (NEW client; three-stance dialogue carrier; cardiologist plant; 5,000 PLN fee plant; literary epigram); **Beat 9** — Archive Room research (Murrow narrates fabricated Article 135-bis § 2 KPC clause-by-clause). All existing beats received character-dwell dialogue options.
- **NEW Chapter 3 inserted** between Ch2 (Waldek) and the prior Ch3 (printer conspiracy / now Ch4): **"The Assigned Case"** — Kacper Mazurek, 19-year-old homeless ex officio criminal-defense client. Six beats, ~25-30 min runtime. Burglary (KK Art. 279) → 1 year suspended sentence (3 years' probation under Art. 70 § 2 *młodociany*). The "Two years easy" canonical line. Whimsy is absent throughout (working Plotek's case; character development in negative space).
- **Cascade renumbering** across `story.txt`, `world.txt`, `battle_mechanics.txt`, `narrative_revision/`, `phase_7_packs/`. Old Ch3-5 → Ch4-6. Backups preserved (`*.pre_stage{13,14,15}.bak`).
- **β reappearance commitments:** Halina returns at Ch4 corridor sighting (~5 lines, visibly diminished — cardiologist plant pays off); Kacper returns at Ch6 finale corridor cameo (~3-4 lines, on a new charge — the "Two years easy" calculation recolors).
- **Three Godot polish items implemented** (in-engine fixes, not just spec):
  - `[E]` interaction-prompt z-order fix — `interaction_prompt.gd` gained `set_anchor_node()`; `npc.gd` gained `prompt_anchor_path: NodePath` exported var; `pig_swine_office.tscn` DeskFront now anchors to Asia (not the desk surface).
  - `behind_desk_zone.gd` rewrite — pre-`met_asia` triggers Asia's first-meeting dialogue with apology+recognition variant (added to `data/dialogues/asia.json` as `first_meeting_via_behind_counter` state); post-`met_asia` retains original ambient-line behavior.
  - `pig_idle_zone.gd` rewrite — pre-`met_pig` triggers standard first-meeting dialogue after 3-second timer; post-`met_pig` retains ambient lines.
- **State migration** — `state.gd` SAVE_VERSION bumped to 7; new `met_asia_via_behind` flag added to chapter1.
- **Meta-files updated** — `00_decisions.md` (Phase 8 deliverables logged), `methodology.md` (Phase 8 phase entry added; breathing-room expansion + English-version dialogue convention as project-wide standards), `re_traversal_map.md` (new plants registered, coverage check updated).
- **Pack manifest expanded** — 49 packs → 54 packs; 5 new V3.* packs for the compact chapter; total estimated effort 109-140 hours (up from 100-130).

(Session 7 — 2026-05-05)
- **Pickups & Minigame Triggers.** Implemented `pickup.gd` for state-driven items and `minigame_trigger.gd` for launching full-screen CanvasLayer minigames.
- **Coffee stub.** Built a quick stub overlay for the Café Paragraf coffee machine interaction.
- **Sprite Wiring.** Updated `.tscn` files to attach real `Sprite2D` resources to Murrow, Crab, and Whimsy.

(Session 7.5 — 2026-05-05, polish pass)
- **Foot-level player collider.** Added `position = Vector2(0, 24)` to the Player's CollisionShape2D in all four scenes (`office_street`, `pig_swine_office`, `archive_room`, `cafe_paragraf`). Hit-box now sits at boots/lower-legs instead of the waist; sprite no longer clips through walls.
- **Faster typewriter.** `TYPE_SPEED_CHARS_PER_SEC`: 50 → 90 in `dialogue_box.gd`. Still skippable with E.
- **Sprint = toggle, not hold.** Shift flips `_sprint_toggled`. Speed multiplier landed at 2.5× after testing 3.0 (too fast) and 2.0 (too slow).
- **Sprint persists across rooms.** Toggle state moved off the per-scene Player instance and onto `State.session_sprint_toggled` (transient — not part of save data, deliberately).

(Session 6 — 2026-05-05)
- **Cula v2 Run Animations.** Imported 8 directional run animations into `cula_sprite_frames.tres`.
- **Sprint Mode.** Shift key triples velocity and plays new `run_<dir>` animations dynamically.
- **Wall Colliders.** Injected a boundary of four thin `RectangleShape2D` barriers across all environments to block out-of-bounds traversal, verifying non-interference with NPCs/Doors.
- **Typewriter Dialogue.** Progressive 50 chars/sec string revelation allowing instant completion on interact input.

(Session 5 — 2026-05-05)
- **Archive Room and Cafe Paragraf added.** Interiors constructed with respective visual themes.
- **Door transitions extended.** Added 4 new transitions to link the new rooms to the existing world map.
- **Crab and Whimsy NPC stubs.** Character nodes placed and dialogue states (before_meeting, after_meeting) created.
- **State extended.** Bumped `SAVE_VERSION` to 4 and added met_crab, met_whimsy with migration path.

(Session 4 — 2026-05-05)
- **Sprites and Interaction Prompts.** Added Cula's 8-way sprite animation and interaction prompts [E] for NPCs/Doors.

(Session 3 — 2026-05-05)
- **Dialogue Runner.** Trigger-based JSON dialogue evaluator with global state binding.

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

- ~~Do not start Chapter 2 content until Chapter 1 ships in a web build a stranger can play through.~~ **(Gate fired 2026-05-07.)** Chapter 1 stranger-playtest happened; three findings drove the Phase 8 rewrite (see Session 8 above). The post-playtest revision discipline replaces the pre-playtest "do not extend" rule for Ch1 specifically. **The same gate now applies forward to Ch2:** do not start Chapter 3+ content (including phase-7 V3.* compact-chapter packs) until Chapter 2 ships in a web build a stranger can play through.
- Do not invent new tags in `data/tag_taxonomy.json` without a Code artifact.
- Do not scaffold districts or interiors beyond what the next-shipping chapter needs.
- Do not let a sprint go without QA running the browser playtest. Every sprint ends with a `BUILD_NOTES.md` entry.
- Do not over-mine the STUB joke — two or three callbacks across the rest of the game, no more.
- Do not turn Warsaw into a tourism reel. Easter eggs appear once or twice; restraint is canon.
- **(Phase 8 addition.)** Do not strengthen Whimsy's Compact Ch3 absence narratively. The absence is character development in negative space; the player notices via the environmental Plotek-folder plant on Whimsy's desk, not via any Cula commentary line. If a future voice-work draft adds a "where's Whimsy?" line from Cula, it has failed the audit.
- **(Phase 8 addition.)** Do not let Kacper crack. Phase-7 V3.* voice work must hold his guarded-direct register without slipping into pitiable, aggressive, or sentimental modes. The "Two years easy" line is accurate, not deflective. If a draft has Kacper admit fear, ask for help, voice grief, or perform gratitude, it has failed the audit.
- **(Phase 8 addition.)** Do not articulate the β recolorings. Halina's Ch4 corridor and Kacper's Ch6 corridor must use the withholding-of-articulation discipline — Cula has no line that processes either encounter. The player carries the meaning.
