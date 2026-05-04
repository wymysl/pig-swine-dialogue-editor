# Consistency Audit
Date: 2026-05-04

## Summary

Files scanned: 25
(story.txt, world.txt, minigames.txt, battle_mechanics.txt, dialogue_samples.txt, style_canon.txt; AGENTS.md, PLAN.md, MANAGING_AGENTS.md, CURATION_BOARD.md, PROPOSALS.md, SPRINT_LOG.md, BUILD_NOTES.md; design.md, code.md, art.md, qa.md; tag_taxonomy.json, asia_hints.json, chapter1.json, dialogues.json, items.json, doors.json, judgments.json, argument_opponents.json)

Issues found: 22
By severity: BLOCKER 6 / IMPORTANT 13 / NIT 3

---

## CHECK 1 — Cross-references

**B1 — BLOCKER | story.txt → dialogue_samples.txt §Crab and §Whimsy**

story.txt lines 317, 353, 355, 442 contain `(see dialogue_samples.txt §Crab)` and `(see dialogue_samples.txt §Whimsy)`. dialogue_samples.txt has three cast sections only: `### Mr. Pig`, `### Murrow`, `### Asia`. There is no `### Crab` and no `### Whimsy` section. Any Design agent following these pointers will find nothing and must either halt or invent lines without a voice reference.

**B2 — BLOCKER | design.md line 38 → design_bible.md §3**

> "Writing content for an NPC whose voice has not been established in `design_bible.md` §3 — file a voice-spec request artifact first"

`design_bible.md` does not exist in the current project. It lives in `_legacy/design/design_bible.md`, which is explicitly out of scope per AGENTS.md. This halt condition will cause Design agents to look for a file that isn't there, then either silently skip the check or permanently halt. Voice profiles now live in `../style_canon.txt §2. Voice references`. The line should point there.

**B3 — BLOCKER | MANAGING_AGENTS.md line 23 briefing template → legacy files**

The copy-paste briefing template contains:

> "Spec: [pointer to the relevant section of `../design/chapters/N.md` and `design_bible.md`]."

Both `../design/chapters/N.md` and `design_bible.md` are legacy files. The source of truth is `../story.txt`, `../world.txt`, `../minigames.txt`, `../battle_mechanics.txt`. A human using this template verbatim will direct agents to files that do not contain current spec. This poisons every sprint brief.

**I1 — IMPORTANT | world.txt line 728 → PLAN.md §Out of scope (section name mismatch)**

> "Fast travel is deferred until after Chapter 2 ships; see godot/PLAN.md §Out of scope."

PLAN.md has no section called `§Out of scope`. The nearest match is `## Out of scope until Chapter 1 ships` (line 188). The pointer resolves informationally, but an agent doing exact-section lookup will not find `§Out of scope`. Minor but the briefing template cites the same section with the same abbreviation — standardize to "§Out of scope until Chapter 1 ships" or "§Out of scope permanently".

**I2 — IMPORTANT | code.md line 91 → design-bible**

> "A request asks Code to extend Polish legal doctrine — bounce to Design (which will file a design-bible extension if needed)."

"design-bible extension" refers to a legacy artifact type. The living equivalent is a `SPEC_PROPOSAL` artifact targeting the Human (who edits `story.txt`), per design.md §Halt conditions. Inconsistent escalation paths between the two skill files.

**I3 — IMPORTANT | art.md line 57 → design_bible**

> "For every new sprite: a thumbnail or ASCII preview, dimensions, palette colors used, the canonical voice/personality reference from design_bible."

`design_bible.md` is legacy. The canonical voice/personality reference is now `../style_canon.txt §2. Voice references`. An Art agent will produce output citing a file that does not exist.

**I4 — IMPORTANT | MANAGING_AGENTS.md line 84 → ../design/CURATION_BOARD.md**

> "Every two weeks, re-read `../design/CURATION_BOARD.md` and ask: does the 'Next Best Task' still match…"

`../design/CURATION_BOARD.md` is the frozen legacy board. The live board is `godot/CURATION_BOARD.md`. The human is being directed to read the wrong file for sprint health checks.

Note: line 8 of the same file correctly labels `../design/CURATION_BOARD.md` as "frozen". Line 84 then actively instructs reading it. These two instructions conflict within MANAGING_AGENTS.md itself.

**B6 — BLOCKER | style_canon.txt and dialogue_samples.txt absent from §Source of truth**

Both files exist at the repo root and are referenced by other files:
- `dialogue_samples.txt` line 7 cites `style_canon.txt` for the Taste Standard.
- design.md line 14 directs agents to read `../story.txt` for "character voices, running jokes" — but those are now in `../style_canon.txt`.
- `dialogue_samples.txt` is the voice-reference library that Design agents need before authoring `dialogues.json`.

Neither file appears in AGENTS.md §Source of truth, PLAN.md §Source of truth, design.md §Required reading, art.md §Required reading, or qa.md §Required reading. Agents will not read them. The split described in PROPOSALS.md §4 is partially complete (dialogue_samples.txt and style_canon.txt exist), but the downstream update to required-reading lists was not made.

---

## CHECK 2 — Canonical names in narration

**B4 — BLOCKER | world.txt line 4791: "Rak" in narrative prose**

In the Chapter 5 §Team Assembly section of world.txt, within a code block listing correct ally assignments:

```
Rak to conflict of interest → sharp_focus
```

"Rak" is the legacy Polish form. AGENTS.md §Cast canonical names: "Crab — investigator. Not 'Rak'." This is active narration spec text in an in-scope source-of-truth file. Any agent reading this section for Chapter 5 context will use "Rak", which is a cast-name violation.

All other in-scope files (story.txt, minigames.txt, battle_mechanics.txt, dialogue_samples.txt, style_canon.txt, all .md files) are clean for "Rak", "Kula", "Muraś", and "Wymysl". The violation is isolated to this one line.

---

## CHECK 3 — Heading hierarchy

**I5 — IMPORTANT | story.txt: first heading is ####**

story.txt opens with `---` (frontmatter separator) followed immediately at line 3 by:

```
#### Chapter 1: "The Financial Crisis"
```

This is a level-4 heading as the document's first heading, skipping levels 1, 2, and 3. Every subsequent chapter heading is `# Chapter N` — so Chapter 1 is mis-levelled relative to Chapters 2–5. An agent or tool doing heading-based sectioning will mismatch Chapter 1.

**I6 — IMPORTANT | world.txt and minigames.txt: first heading is ##**

world.txt opens with `## Part 2: World & Map Design`. minigames.txt opens with `## Part 5 — Mini-Game Specifications`. Both are fragments of a conceptual master document (Parts 1–6), but as standalone files they lack a `#` title. This is intentional document architecture but breaks standard markdown structure. Note for any tool that processes these as self-contained files.

battle_mechanics.txt correctly opens with `# Part 6 — Casebook Battle System` and is well-formed.

All .md files in godot/ have clean heading hierarchies. No level-skip violations found in any markdown governance file.

**NIT1 — NIT | battle_mechanics.txt: `#` headings used for code block labels**

Lines like `# res://systems/casebook/judgment_definition.gd` (line 503) use top-level `#` headings as GDScript code-block labels inside an otherwise `##`-structured section. Not a hierarchy skip, but visually ambiguous; will produce spurious entries in any auto-generated table of contents.

---

## CHECK 4 — Decision drift

**B5 — BLOCKER | PLAN.md §What gets built once vs per-chapter contradicts §Out of scope permanently on Final Printer**

PLAN.md line 165:

> "Chapter 5's **final printer mini-game** is the climax of the mini-game stack."

PLAN.md line 203 (§Out of scope permanently):

> "**Final Printer as a one-off mini-game.** Reframed as a Casebook battle against an industrial-printer opponent in Chapter 5…"

AGENTS.md §Forbidden patterns:

> "Treating the Final Printer as a mini-game. It is a Casebook battle in Chapter 5."

The same document (PLAN.md) calls the Final Printer both a "mini-game" and "reframed as a Casebook battle." A Code agent reading §What gets built once will draw the wrong conclusion before reaching the correction six paragraphs later.

**I7 — IMPORTANT | AGENTS.md §Casebook authoring: tag taxonomy location**

AGENTS.md line 124:

> "Tag taxonomy is fixed in `scripts/systems/battle/effectiveness.gd`."

AGENTS.md line 64 (§Stack invariants):

> "Casebook: tag taxonomy is a closed list in **`data/tag_taxonomy.json`**."

The taxonomy data lives in the JSON file. `effectiveness.gd` contains the resolver logic, not the taxonomy list. A Code agent reading §Casebook authoring literally will look for the taxonomy in the wrong place.

**I8 — IMPORTANT | PLAN.md §Project structure shows scooter_racing.gd and ski_slalom.gd**

The project structure tree at PLAN.md lines 74–75 lists:

```
scooter_racing.gd
ski_slalom.gd
```

Both are permanently out of scope per PLAN.md §Out of scope permanently. A Code agent scaffolding the project from this tree would create stub files for forbidden mini-games.

**I9 — IMPORTANT | PROPOSALS.md status stale for items #4 and #7**

PROPOSALS.md §Status (post-approval) shows:
- Item #4 (story.txt split): **PENDING** — but `dialogue_samples.txt` already exists and story.txt already uses `(see dialogue_samples.txt §X)` delegation throughout. The split is substantially done.
- Item #7 (design/ consolidation → style_canon.txt): **PENDING** — but `style_canon.txt` already exists at the repo root with full voice profiles, running jokes, visual style, audio canon, and court design principles.

Stale PENDING status could cause a human to schedule a session for work that has already been done.

**I10 — IMPORTANT | design.md line 50: voice profiles location is stale**

> "Voice profiles live in `../story.txt`."

Voice profiles are now in `../style_canon.txt §2. Voice references`, which has per-NPC voice entries for Dr. A. Cula, Mr. Pig, Mr. Swine, Murrow, Crab, Whimsy, Asia, and all Chapter 2–4 NPCs. story.txt does not contain voice profiles in tabular form. A Design agent following design.md line 50 will not find the voice profiles.

All other key decisions are consistent across governance docs:
- English-first language: AGENTS.md, PLAN.md, PROPOSALS.md, CURATION_BOARD.md ✓
- One save slot + autosave: AGENTS.md, PLAN.md ✓
- Court-loss never blocks: PLAN.md ✓
- Minimal tutorial: PLAN.md ✓
- WCAG AA: AGENTS.md, PLAN.md ✓
- No wild encounters: AGENTS.md §Forbidden, PLAN.md §Out of scope permanently, CURATION_BOARD.md ✓
- Scooter Racing and Ski Slalom dropped: AGENTS.md §Forbidden, PLAN.md §Out of scope permanently ✓
- Closed tag taxonomy in data/tag_taxonomy.json: AGENTS.md, PLAN.md, CURATION_BOARD.md ✓
- Rule A (Dr. A. Cula canonical): AGENTS.md, all skill files, MANAGING_AGENTS.md ✓

---

## CHECK 5 — File-ownership-table accuracy

Reference: inventory matrix from Prompt 2 (Placeholder Creation run, 2026-05-04).

The ownership table in AGENTS.md §File ownership table is accurate as written: every listed path either EXISTS or is properly DEFERRED (DEFERRED-BOOTSTRAP for autoloads/scenes/test scripts; DEFERRED-CHAPTER for multi-chapter content). No path in the table is factually wrong.

Two path-accuracy issues exist in the **skill files** (not the ownership table itself):

**I11 — IMPORTANT | code.md line 47 and art.md line 34: scenes/rooms/** path does not exist**

code.md §Forbidden, line 47:
> "Decoration children in `scenes/rooms/**`"

art.md §Forbidden, line 34:
> "Scene root nodes, attached scripts, gameplay objects in `scenes/rooms/**`"

The project uses `scenes/world/**` and `scenes/interiors/**` (per PLAN.md §Project structure and AGENTS.md §File ownership table). No `scenes/rooms/` directory is defined anywhere in the project. An agent enforcing these forbidden-writes rules against the actual file tree will find the constraint targets a non-existent path, weakening the constraint.

**NIT2 — NIT | Governance gaps from Prompt 2 remain open**

Prompt 2 identified four paths present on disk with no ownership table row: `data/tag_taxonomy.json`, `data/asia_hints.json`, `CURATION_BOARD.md`, and `exports/web/`. These proposed rows were not applied (correctly — Prompt 2 said the human applies them). Still unresolved as of this audit.

---

## CHECK 6 — Stale legacy references

**B4 — see CHECK 2 above | world.txt line 4791: "Rak"**

**B3 — see CHECK 1 above | MANAGING_AGENTS.md briefing template: `../design/chapters/N.md` and `design_bible.md`**

**B2 — see CHECK 1 above | design.md line 38: `design_bible.md §3`**

**I3 — see CHECK 1 above | art.md line 57: `design_bible`**

**I4 — see CHECK 1 above | MANAGING_AGENTS.md line 84: `../design/CURATION_BOARD.md`**

**I2 — see CHECK 1 above | code.md line 91: `design-bible extension`**

All occurrences of "Kula", "Muraś", "Wymysl", and the remaining "Rak" instances are confined to `_legacy/` (out of scope). No additional legacy references in the 25 in-scope files beyond those already catalogued above.

`battle_mechanics.txt` line 347 uses "archive/café/office" to describe in-game locations — not the JS prototype `archive/` directory. Not a stale reference.

---

## CHECK 7 — JSON schemas

All eight JSON files pass `python3 -m json.tool` (syntactically valid).

**I12 — IMPORTANT | tag_taxonomy.json: uses `_version` not `version`**

tag_taxonomy.json top-level key is `"_version": 1`. Every other data file uses `"version": 1`. If any loader or migration script reads `data.version`, it will get `null` from tag_taxonomy.json and miss the version check. The underscore prefix is inconsistent with the rest of the data layer.

**I13 — IMPORTANT | asia_hints.json trigger fields diverge from story.txt quest flag names**

asia_hints.json states reference:
- `chapter1.coffee_resolved` — not in story.txt quest flags (story.txt has `coffee_tutorial_seen` and `coffee_buff`, not `coffee_resolved`)
- `chapter1.court_outcome == "victory"` / `"weak_win"` — not in story.txt quest flags (story.txt has `won_court: false`, a boolean)
- `chapter1.met_pig` — story.txt uses `pig_revealed_crisis`, not `met_pig`

Until `state.gd` is written, any of these field names could be canonical. But the mismatch between story.txt §Chapter 1 quest flags (the spec) and asia_hints.json triggers (the content) means either Code must adopt the asia_hints.json naming or Design must update asia_hints.json before either file is relied upon. Left unresolved, the trigger conditions in the live hint system will silently not fire.

**NIT3 — NIT | asia_hints.json has no `_doc` field**

Every other data file (tag_taxonomy.json, chapter1.json, dialogues.json, items.json, doors.json, judgments.json, argument_opponents.json) has a `_doc` field explaining its schema. asia_hints.json has none. Minor but inconsistent with the established pattern.

Placeholder files (chapter1.json, dialogues.json, items.json, doors.json, judgments.json, argument_opponents.json): top-level keys are consistent with their `_doc` descriptions. Empty arrays/objects are correct for placeholders. ✓

---

## Recommendation

**The Godot bootstrap sprint (skeleton project, autoloads, placeholder office_street.tscn, web export) can proceed.** The Code skill's required reading does not reference any broken files, and none of the BLOCKERs block a skeleton Code run. However, **three BLOCKERs must be fixed before the first Design sprint:**

1. **B2 + B6**: Fix design.md §Forbidden and §Required reading. Replace `design_bible.md §3` with `../style_canon.txt §2. Voice references`; add `../style_canon.txt` and `../dialogue_samples.txt` to design.md §Required reading. Simultaneously update AGENTS.md §Source of truth to list all six root .txt files, not just four.

2. **B3**: Rewrite the MANAGING_AGENTS.md briefing template's Spec field to point to `../story.txt` (and `../world.txt` / `../battle_mechanics.txt` as needed), not `../design/chapters/N.md` or `design_bible.md`. Fix line 84 to reference `godot/CURATION_BOARD.md`, not `../design/CURATION_BOARD.md`.

3. **B1**: Add `### Crab` and `### Whimsy` sections to dialogue_samples.txt. Without them, the next Design agent writing Crab and Whimsy recruitment dialogue will have no voice reference and will either halt or produce lines that don't pass the Taste Standard.

**B4** (world.txt "Rak") and **B5** (PLAN.md Final Printer contradiction) are low urgency for the bootstrap sprint but should be fixed before any Chapter 5 or battle-system design work. **I13** (asia_hints.json field-name drift from story.txt) must be resolved before Code writes `state.gd` — either the JSON adapts to story.txt's flag names or story.txt's flags are updated to match the JSON, and only the human can make that call.
