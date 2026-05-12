# Narrative Revision — Methodology

**Date:** 2026-05-05
**Scope:** how we execute the thematic reframe captured in `00_decisions.md`. This file is the playbook; the `00_decisions.md` is the contract.

The phases below are sequential. Skipping one to save time tends to cost the next one twice. Each phase has a defined input, a defined output, a working method, a done-criterion, and a list of things not to do during it.

A working principle that runs through all phases: **chat is the divergent space, the workspace is the convergent space.** End every significant brainstorming session by writing conclusions into `narrative_revision/`, even rough, so the next session starts from artifacts rather than from chat memory. `PROPOSALS.md` for genuine editorial decisions; `narrative_revision/notes/` for in-progress thinking that may get overwritten.

---

## Phase 1 — Capture decisions (DONE, 2026-05-05)

Already complete. `00_decisions.md` written; `PROPOSALS.md §9` filed.

---

## Phase 2 — Audit `story.txt` and `style_canon.txt` against the spine

**Goal.** Produce a punch list of what survives, what reframes, what cuts. Mechanical, not creative.

**Inputs.** `story.txt`, `style_canon.txt`, `00_decisions.md` (especially the spine, the tonal exclusions, and the no-cathartic-ending forbid).

**Output.** One audit file per chapter at `narrative_revision/audit/chapter_1.md` through `chapter_5.md`, plus `audit/style_canon.md` for tonal/voice content. Each file is a flat list of beats from the source, each tagged:

- **(K)** keep — survives unchanged
- **(R)** reframe — survives with adjustment, with one-line note on what changes
- **(C)** cut — does not serve the spine; one-line reason
- **(?)** uncertain — flag for discussion

**Working method.** Read source linearly. For every beat, ask: does this serve the central question, contradict it, or distract from it? Tag accordingly. **Do not fix anything during the audit.** Fixing during audit collapses two passes into one and the punch list is lost. The audit's job is to produce a list, not revisions.

Pay particular attention to: beats where Mr. Pig is currently flat (cynical-marketer or pure-idealist readings); beats where the union currently functions as the answer rather than texture; beats that resolve the central question rather than pose it; cathartic-resolution moments; protective-irony slips.

**Done-criterion.** Every beat in source is tagged. No beat marked uncertain has been silently dropped. Estimated cut percentage and reframe percentage tallied at top of each file.

**Do not.**
- Rewrite during audit.
- Add new content during audit.
- Argue with the source while reading; just tag.
- Promote (?) to (R) without explicit decision.

**Estimated effort.** Three to five focused sessions. `story.txt` is ~90k tokens; chapters 1-2 will move faster than 3-5 because the existing material thins out in later chapters.

---

## Phase 3 — Per-character contradiction bibles

**Goal.** A document type the project doesn't yet have. Voice references cover *how* characters speak; bibles cover *what they know, when they know it, what they can admit to themselves at each chapter,* and *what they've said publicly that they'll later have to walk back or recontextualize.* Bibles prevent random contradictions in chapter 5.

**Inputs.** `00_decisions.md`, the audit punch list from phase 2, existing voice references in `godot/data/voice_references/` for stylistic continuity.

**Output.** One file per major character at `narrative_revision/bibles/<character_id>.md`. Major characters at minimum:

- `pig.md` (Mr. Pig)
- `cula.md` (player; constrained but still has a bible — what he comes in believing, what each player choice shifts)
- `crab.md`
- `whimsy.md`
- `murrow.md`
- `asia.md`
- `white_collar_client.md` (new; needs a name and specific charges)
- `swine.md`
- Recurring opposing counsel / judges if any matter across chapters

**Format.** Each bible is a five-row table (one row per chapter) with columns:

| Chapter | Stated belief | Private belief | Actions taken | Hidden from self / others | Relation to central question |

Plus a short prose preamble describing the character's overall arc shape and the contradiction they carry.

**Working method.** **Write Mr. Pig's bible first.** It's the hardest and the most load-bearing. If you can't fill in his row for chapter 4 without him reading as either purely admirable or purely venal, the spine isn't yet sharp enough and you must come back to `00_decisions.md` and refine before continuing. Pig's bible is the canary; if it breaks, everything downstream breaks.

After Pig: Cula, then Crab + Whimsy together (their stances mirror each other), then the white-collar client (his bible has different shape because he doesn't have an arc — he has a constant function and a gradual reveal of his structural reach), then the rest.

For the juniors, pin the stance assignments here. Recommendation in `00_decisions.md`: Cula = true believer, Whimsy = opportunist (by name-fit), Crab = cynic. Confirm or adjust during this phase.

**Done-criterion.** Every major character has a five-row bible. Mr. Pig's bible has been re-read and feels coherent to a hostile reader. Junior stances are pinned. The white-collar client has a name and specific charges.

**Do not.**
- Write dialogue during bible-writing. Bibles are about belief, not voice.
- Give every character a tragic backstory. Differentiate by stance, not trauma.
- Resolve characters' contradictions cleanly. The contradictions are the point; flatten them and the writing has nothing to do.
- Pin chapter-specific events here that aren't already fixed by source. The bibles describe *belief states* in each chapter; events come in phase 4.

**Estimated effort.** One to two sessions per bible, ten bibles. Pig's bible may take two on its own. Plan for two to three weeks of part-time work; this is the heaviest phase.

---

## Phase 4 — Chapter beat sheet, anchored on the mid-game inflection

**Goal.** A revised chapter outline in which every beat is traceable to a character's bible row and to the spine.

**Inputs.** Audit punch list from phase 2, bibles from phase 3, `world.txt` for spatial constraints, `battle_mechanics.txt` for Casebook integration points.

**Output.** `narrative_revision/beats/chapter_1.md` through `chapter_5.md`. Each is a beat-by-beat outline at the same density as the existing `story.txt` chapter sections, organized by quest gate and scene location.

**Working method.** Two-stage.

**Stage 4a — pin the inflection.** Before writing any chapter beats, pin the specific chapter-4 beat at which the player's frame shifts. Most likely candidate: the moment the firm's actual financial state becomes visible to the player (e.g., Cula sees a document he shouldn't have, or overhears a conversation, or the union has receipts), or Mr. Pig's voluntary austerity becomes legible as a class blind spot rather than a moral stance. Write a single page describing this beat: what the player sees, what they understand, what they can no longer un-see. Everything else in the beat sheet is structured around it.

**Stage 4b — write outward.** Chapter 1 plants what chapter 5 will recontextualize. Chapter 2 deepens character without yet revealing the gap. Chapter 4 contains the inflection. Chapter 5 is the recontextualization pass — the same spaces and people read differently. Chapter 6 lands the choice that doesn't resolve.

For each beat: check it against the bibles. If a character behaves in a way the bible doesn't support, either the beat is wrong or the bible is wrong; decide which and update the wrong one. This loop is normal; expect to revise bibles during phase 4.

**Done-criterion.** Every chapter has a beat sheet. The chapter-4 inflection is pinned with a specific scene. Every character action in every beat is supported by that character's bible row for that chapter. The chapter 6 ending is decided (player choice ungraded, or small private win — see `00_decisions.md`); the cathartic-exposure shape has not crept back in.

**Do not.**
- Write dialogue here. Beats are *what happens*, not *what is said*.
- Resolve open questions by inventing new content. If a beat needs a character who isn't in the roster, stop and make it a Proposal-grade decision before adding.
- Skip the bible-checking pass. It's the only thing preventing chapter 5 from drifting into incoherence.

**Estimated effort.** Three to four sessions. Chapter 4 will take longer than the others because of the inflection.

---

## Phase 5 — Re-traversal map

**Goal.** Confirm that the funny-in-hindsight commitment is structurally supported. List which spaces and recurring NPCs the player encounters before AND after the inflection, and what changes between encounters. This is the artifact that prevents the technique from degrading into authorial winks.

**Inputs.** Beat sheets from phase 4, `world.txt` for spatial layout, the existing room scenes in `godot/scenes/interiors/`.

**Output.** `narrative_revision/re_traversal_map.md`. Two tables:

- **Spaces.** For each physical space (Pig & Swine office, Café Paragraf, archive room, court rooms, etc.): chapters present in pre-inflection, chapters present post-inflection, what recolors, easter eggs to seed early.
- **NPCs.** For each recurring NPC: pre-inflection appearances, post-inflection appearances, what the player now reads differently in their dialogue, lines that need to be planted in early chapters to land later.

**Working method.** Walk through the beat sheet chapter by chapter. For every space and every recurring NPC, mark whether they appear before and after inflection. Spaces visited only pre-inflection are wasted (mark as candidates for re-use); spaces only post-inflection deny the player the recoloring effect (mark as candidates for earlier seeding). NPCs with one-shot appearances are evaluated for whether they can become recurring.

This is also the natural place to seed the easter eggs: the inspirational quote on Mr. Pig's wall in chapter 1 that reads grim in chapter 5, the junior's casual comment in chapter 1 that lands differently after the inflection, the documents in the archive room that look like clutter the first time and like evidence the second.

**Done-criterion.** Every space and every recurring NPC is on the table with pre/post-inflection coverage. At least 60% of significant spaces appear on both sides of the inflection. At least five concrete easter eggs are pinned with their chapter-1 plant and chapter-5 payoff.

**Do not.**
- Add new spaces to fix coverage gaps. Re-use existing ones.
- Treat the funny-in-hindsight technique as an excuse to add winks. Real recoloring shifts the player's interpretation of existing content; winks are authorial signaling.

**Estimated effort.** One to two sessions.

---

## Phase 6 — Adversarial pressure-test pass

**Goal.** Read the revised outline as if you wanted to dislike it. Catch failure modes before writing.

**Inputs.** Beat sheets, bibles, re-traversal map.

**Output.** `narrative_revision/pressure_test.md` — a list of failure-mode hits with location and one-line description, plus a remediation plan for each.

**Failure modes to hunt for.**
- Protective irony — the writer signaling distance from caring.
- Central question getting answered rather than posed.
- Characters contradicting each other randomly rather than coherently.
- A junior's stance treated as the Right Answer.
- Mr. Pig flattening to either pure sympathy or pure cynicism.
- A client flattening to pure tragedy or pure villainy.
- The union sliding into noble-collective-action territory.
- The white-collar client becoming a Hannibal Lecter (personal menace) rather than a structural threat.
- The cathartic-exposure ending creeping back in disguised form.
- Easter eggs that read as winks rather than recoloring.

**Working method.** Best done at a delay — write the revision, sit on it for at least a week, come back with hostile eyes. If you can't do it cold, ask me to run the pass; the outside-eye is the entire point. Read the beat sheets straight through chapter 1 to chapter 6 in one session, marking failure-mode hits as you go without stopping to fix.

**Done-criterion.** Pressure-test file has been written. Every flagged failure has a remediation plan. The remediations have been applied to the bibles / beat sheets / re-traversal map. A second pressure-test pass on the remediated version returns no critical hits.

**Do not.**
- Soften the critique because the work feels precious. The point of this phase is to be hostile.
- Skip the cold delay. Same-session pressure-testing is sympathetic to your own choices and catches less than half of what a delayed pass catches.

**Estimated effort.** One session for the read; one to two sessions for remediation; one session for the second pass.

---

## Phase 7 — Writing

**Goal.** Actual prose — dialogue trees, scene text, voice-reference updates, committed lines for `data/dialogues/<npc_id>.json`.

**Inputs.** Everything from phases 2-6.

**Output.** Updated `story.txt`, `style_canon.txt`, voice references, committed dialogue JSONs.

**Working method.** Chapter by chapter. Within each chapter, scene by scene. For each scene: read the beat sheet for the scene, read the bible rows for the characters present, draft the dialogue, run it through `tools/voice_audit.py`, revise. The scaffolding from phases 2-6 should make the writing fast; if it's slow, the scaffolding is incomplete and you're filling gaps live, which is the chapter-5-rewrite-spiral failure mode.

**Done-criterion.** Per-chapter; ship one chapter at a time. A chapter is done when its dialogue passes the voice audit, the beats are landed, the funny-in-hindsight payoffs are seeded or paid off as required, and a re-read by hostile eyes catches no critical issues.

**Do not.**
- Write dialogue without re-reading the bible row first. Voice continuity without belief continuity gives you characters who *sound* consistent and *act* incoherent.
- Commit lines that haven't passed `voice_audit.py`. The tool exists for this.

**Estimated effort.** This is the bulk of the project. Plan in chapters, not weeks.

---

## Phase 8 — Post-playtest rewrite (added 2026-05-07)

**Goal.** Repair issues identified by stranger-playtest after a chapter ships. Phase 8 is not a routine phase — it activates when playtest reveals that an earlier phase's commitments don't survive contact with players.

**Inputs.** Playtest findings (specific, observed); the original audit/beats/bibles for the affected chapter; the curation board's "playtest before extending" gate (which protects pre-playtest scope creep but explicitly anticipates post-playtest revision).

**Output.** Updated audit (delta document; supplements rather than replaces); updated beat sheet (rewrite if needed; the previous file's `_v1` rename is acceptable, but a clean overwrite with git as the version-control mechanism is also acceptable); updated story.txt section; updated bibles; updated voice-pack manifest entries; updated meta-files.

**Working method.**

1. **Document playtest findings.** Specific, observed, with the source noted. Generalizing playtest findings into design principles is a Phase 9 problem; Phase 8's job is to repair.
2. **Identify which prior commitments survive.** Most do. The audit/beats/bibles produced by Phases 2-4 represent significant work; treat them as load-bearing unless playtest specifically contradicts them.
3. **For each commitment that doesn't survive:** explicitly override it in the new audit-delta document. Name the rule being overridden (e.g., "phase-4 'no new beats' rule"), name the playtest evidence, name the override decision. The override is now canonical.
4. **For each plant inventory item:** preserve forward through the rewrite. Phase 8 does not get to drop chapter-3-inflection plants because Chapter 1 is being rewritten. The plants are re-staged within the new structure.
5. **Cascade renumbering** (if the rewrite includes inserting new chapters or beats): use sed-driven bulk replacement for chapter-number references across `story.txt`, `world.txt`, `battle_mechanics.txt`, and `narrative_revision/`. Reverse-order substitution (highest-number first) avoids cascade collisions. Exclude phase-8-authored files that already use post-rename numbering. Two passes — one for canonical patterns (`Chapter 5`, `Ch5`, `chapter-5`), one for lowercase abbreviated forms (`ch 5`, `ch.5`) that the first pass typically misses.
6. **Update meta-files** (`00_decisions.md`, `methodology.md` (this file), `re_traversal_map.md`, the curation board): log the phase-8 deliverables in `00_decisions.md`; register new plants in `re_traversal_map.md`; add a phase entry to `methodology.md` if appropriate; mark the curation board's playtest-gate as having fired for the chapter in question.

**Done-criterion.** The rewrite is structurally complete (all stages of the rewrite cycle delivered); the renumbering cascade is verified (no `Chapter 3` references remain where post-rename should be `Chapter 4`); the meta-files reflect the new state; the next phase-7 voice-work session can pick up from the rewritten material without further structural surprises.

**Do not.**

- Trigger Phase 8 from a single playtester's reaction. Wait for a pattern.
- Use Phase 8 as cover for adding content that was rejected in earlier phases. The Camilla-rejection still applies — adding a new chapter or NPC requires the same Proposal-grade gate as in earlier phases. The 2026-05-07 phase-8 cycle that added Halina (new client), Kacper (new chapter-3 client), and the compact criminal chapter passed the gate because all three additions were directly motivated by playtest findings. Future phase-8 cycles must clear the same bar.
- Skip the cascade renumbering check. Stale chapter references compound silently and surface during phase-7 voice work as wrong-chapter-name lines.

**Phase-8 register-standard expansion (2026-05-07; carried forward as project-wide standard).** The phase-8 rewrite of Chapter 1 introduced the *character-dwell options* pattern: every NPC scene receives 2-3 dialogue options that have no quest impact but produce a register-revealing line (mannerism, worldview, memory, tic). Character-dwell is not filler. Each option must produce a line that surfaces something specific about the character. Generic "tell me more" branches that produce paraphrased exposition are scrub-mode failures and should be flagged in phase-7 audit. The pattern applies to Ch2-6 dialogue work going forward; phase-7 voice packs for those chapters should plan dialogue volume accordingly (likely 2-3× the original phase-4 estimates). Sincerity-rationing rule (one canonical sincere line per character per chapter) is preserved — character-dwell options must respect register interior range without breaking sincerity rationing.

**Phase-8 English-version dialogue convention (2026-05-07; sharpened).** The English version of the game uses Polish only for proper names of people and places (and PLN currency). No Polish greetings, address forms, common nouns, or idioms in dialogue. This sharpens the V1.3 §A.5 "zero-to-one Polish flavor word per scene" rule. Pre-existing canonical content authored before phase 8 (e.g., Pig's *aplikatura* lecture sample shapes) is grandfathered; new work follows the strict rule. The project's eventual Polish-version translation can restore Polish texture; the English version reads cleanly for an English-speaking player without requiring a glossary.

---

## Working artifacts summary

```
narrative_revision/
  00_decisions.md              # the contract (DONE)
  methodology.md               # this file (DONE)
  audit/
    chapter_1.md               # phase 2
    chapter_2.md
    chapter_3.md
    chapter_4.md
    chapter_5.md
    style_canon.md
  bibles/
    pig.md                     # phase 3 — write first
    cula.md
    crab.md
    whimsy.md
    murrow.md
    asia.md
    white_collar_client.md
    swine.md
    [recurring others]
  beats/
    chapter_1.md               # phase 4
    chapter_2.md
    chapter_3.md
    chapter_4.md
    chapter_5.md
  re_traversal_map.md          # phase 5
  pressure_test.md             # phase 6
  notes/                       # rough thinking; may be overwritten
```

---

## Scope discipline

This methodology assumes the existing chapter structure (5 chapters) and roster largely survive the audit. If the audit reveals more cuts than reframes, the right move is to absorb the shrunk scope, not to invent new content to fill the gaps. Theme-driven revision often reveals that some prior content was load-bearing and some decorative; the decorative parts go.

If a beat needs a character not in the canonical roster, that's a Proposal-grade decision and goes through `PROPOSALS.md`, not a quiet addition during phase 4. Camilla was rejected for a reason; Camilla-shaped additions go through the same gate.
