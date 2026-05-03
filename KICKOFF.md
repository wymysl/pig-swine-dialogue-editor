# Kickoff prompts — paste these into Antigravity Manager view

This file contains the exact prompts to dispatch the first agent tasks. Paste them into Antigravity Manager view as new agent conversations. Run them in the order given.

---

## Step 0 — Codebase audit (before any sprint starts)

**Spawn:** one agent in Manager view. Model: Gemini 3.1 Pro (large context). No skill activation needed yet — this is orientation.

**Prompt:**

```
Read AGENTS.md, design_bible.md, and the entire src/ directory of this repo. Do not modify any files. Produce an Artifact with:

1. A complete file inventory under src/ with one-line descriptions of what each file does.
2. A list of every exported symbol from src/state.js with its current type and default value.
3. A list of every NPC currently defined in src/data/dialogues.js with their current dialogue states.
4. A list of every room currently defined in src/data/maps.js with their dimensions and door connections.
5. A list of every existing test in test_story.py (or wherever tests live) with what each one verifies.
6. A list of any discrepancies between what AGENTS.md's "File ownership table" expects and what actually exists in the repo (e.g. paths that don't exist, files that exist but aren't owned).
7. A list of any discrepancies between what design_bible.md describes and what's currently in the dialogue/data files.

Then append one paragraph to SPRINT_LOG.md under "Sprint 0 — Foundation" stating: "Codebase audit complete. See [Artifact ID]." Note any discrepancies in the entry.

Do not start any sprint work. This is orientation only.
```

**Expected outcome:** an inventory Artifact and one SPRINT_LOG entry. Read the inventory carefully. Resolve any discrepancies (rename a file, update AGENTS.md ownership table, update the chapter outline) before proceeding.

---

## Step 1 — Sprint 0 parallel fan-out

After the audit clears, branch and spawn parallel agents.

```bash
git checkout -b sprint-0-foundation
```

**In Antigravity Manager view, spawn 4 agents simultaneously:**

### 1A — Systems Agent (P0): Room transition system + expanded save/load

Model: Claude Opus 4.6.

```
Activate the systems-agent skill.

Task: implement the room transition system and expand save/load with chapter progress tracking.

Reference: implementation_plan.md Part 6 Sprint 0 (lines 26515–26529) and docs/chapters/1.md (Chapter 1 quest flags section).

Specific deliverables:
1. A room transition system in src/systems/transitions.js: fade-to-black, load interior, place player at door. Should support both overworld→interior and interior→overworld.
2. Expand save/load in src/systems/save.js: SAVE_VERSION constant, migrateSave(oldSave) function, support for the chapter1 flag block from docs/chapters/1.md.
3. Add the chapter1 state shape to src/state.js, initialized in resetState().

Follow your skill's Output schema exactly: Artifact must include state delta, migration spec, integration request for main.js / input.js, and the save/load round-trip test.

If src/systems/save.js does not exist yet, create it.
```

### 1B — Graphics Agent (P0): Portrait v2 with expressions

Model: Gemini 3.1 Pro.

```
Activate the graphics-agent skill.

Task: implement Portrait v2 — drawPortraitV2(npcId, x, y, expression) supporting all 5 expressions for the Tier 1 main cast.

Reference: design_bible.md §3 (Tier 1: Kula, Pig, Swine, Muraś, Rak, Wymysl — 5 expressions each) and §6 (visual style canon).

Specific deliverables:
1. A new drawPortraitV2() function in src/characters.js that takes (ctx, x, y, expression) and renders the appropriate Tier 1 character at 64×64.
2. Updated PORTRAIT_PALETTES with 4–6 colors per Tier 1 NPC. Reuse colors across NPCs where possible.
3. The screenshot Artifact your skill requires: render every Tier 1 portrait at all 5 expressions on a test canvas, save as a single PNG.

Do NOT replace the existing drawPortrait() — additive only. Integration will swap call sites.
```

### 1C — Audio Agent (P0): Procedural music engine

Model: Claude Sonnet 4.6.

```
Activate the audio-agent skill.

Task: implement the MusicEngine class.

Reference: design_bible.md §5.5 (per-location musical character) and §7 (audio canon).

Specific deliverables:
1. New file src/audio/music.js exporting a MusicEngine class with: play(trackName), stop(), crossfade(trackName, durationMs).
2. Initial track set: office, court, cafe, archive (the four Chapter 1 locations). Each track must loop seamlessly without click.
3. Integration with the existing global mute toggle.

Tracks must match the per-location character described in design_bible.md §5.5. Office is "stressed, slightly wonky, off-meter." Court is "stately, minor key, mock-serious." Café is "warm, jazz-inflected, unhurried." Archive is "sparse, ambient, simulated tape hiss."

Follow your skill's Output schema: track manifest, audio test plan for QA's browser subagent.
```

### 1D — QA Agent (P0): Test harness expansion

Model: Gemini 3.1 Pro.

```
Activate the qa-agent skill.

Task: expand the test harness to support Sprint 0 verification.

Reference: docs/chapters/1.md acceptance criteria.

Specific deliverables:
1. Extend test_story.py with tests for: (a) every chapter1 flag is reachable, (b) every NPC dialogue state declared in docs/chapters/1.md exists, (c) save/load round-trip preserves all chapter1 fields.
2. A browser-subagent test plan document (artifacts/qa/sprint-0-plan.md) describing exactly what runtime checks the browser subagent should perform after Sprint 0 wiring completes.

Do NOT touch any src/ file. Tests only.
```

---

## Step 2 — After all four ship: Integration

Wait until all four Sprint 0 agents have produced Artifacts and you have approved them. Then spawn one Integration agent.

Model: Claude Opus 4.6.

```
Activate the integration-agent skill.

Task: wire the Sprint 0 Systems, Graphics, Audio, and (any) QA-test deliverables into the Pig & Swine build.

Reference: every Artifact produced this sprint, plus the Integration requests embedded in each one.

Specific deliverables follow your skill's Output schema exactly. Glue only. If any specialist Artifact contradicts another, file DISPUTE and halt.
```

---

## Step 3 — Sprint 0 QA pass

After Integration ships, re-spawn the QA agent for the runtime verification.

Model: Gemini 3.1 Pro + browser subagent.

```
Activate the qa-agent skill.

Task: run the full Sprint 0 verification.

Three layers in order:
1. node --check on every .js file modified this sprint.
2. python test_story.py.
3. Dispatch the browser subagent: launch `npm run dev`, load a Chapter 1 save (or start new game), verify all room transitions work with fade-to-black, verify Tier 1 portraits render at all 5 expressions, verify music changes on room transition with 500ms crossfade, save mid-Chapter 1, reload, verify continuity.

File any bugs as separate Artifacts targeting the responsible persona. Append BUILD_NOTES.md and SPRINT_LOG.md.
```

---

## Step 4 — Sprint review (you)

Read all Artifacts. Watch the QA browser subagent video. If clean:

```bash
git add -A && git commit -m "Sprint 0: foundation systems"
git checkout main
git merge sprint-0-foundation
```

Then proceed to Sprint 1 (Chapter 2). Same workflow: branch, parallel content fan-out (Story, Map, Graphics, Audio for Chapter 2 deliverables), serial Systems pass (Evidence Board), serial Mini-Game pass (Document Chase), Integration, QA, review.

The chapter outlines in `docs/chapters/2.md` through `docs/chapters/5.md` give you the per-sprint inputs.

---

## Notes on Antigravity-specific quirks

- **If a skill doesn't activate when expected**, mention it explicitly: "Activate the systems-agent skill." Antigravity decides on description match; an explicit name override forces it.
- **If the agent edits a file outside its allowed-writes list**, abort the run, file feedback in the Artifact, and re-spawn with the constraint repeated in the prompt. Don't accept the bad output.
- **Manager view lets you approve Artifacts incrementally** — don't wait for all 4 parallel agents to finish before reviewing the first one to ship. Approving early means the next-sprint planning starts sooner.
- **The browser subagent** runs a different model than your main agent (Antigravity assigns it). It can launch `vite dev`, navigate the page, click, screenshot, and record video. It cannot edit files.
- **Sandbox is critical.** Settings → Agent → Enable Terminal Sandbox: ON, Agent Non-Workspace File Access: OFF, Artifact Review Policy: Asks for Review, Terminal Command Auto Execution: Request Review. Verify these before the first dispatch.
