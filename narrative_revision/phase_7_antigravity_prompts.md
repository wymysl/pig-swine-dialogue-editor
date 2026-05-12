# Antigravity prompts — Phase 7 V1.x implementation steps 2-4

Drafted 2026-05-06. Three self-contained prompts, one per scope. Each prompt assumes the agent has read access to the full repo at the project root and can write to it.

## Model recommendation

Use **Claude Sonnet 4.6** for all three prompts.

Reasoning: each prompt involves multi-file code reading, schema discipline, and voice-judgment calls against documented constraints. Sonnet 4.6 is the right balance of capability and cost for this kind of agentic work in Antigravity.

Exception: if **Claude Opus 4.6** is available in your Antigravity model picker, use it for **Prompt 1 (audit)** specifically. The audit is the most judgment-heavy step — it asks the agent to classify each existing line as HOLD/REWRITE/CUT against discipline rules, which benefits from Opus's deeper reasoning. Run Prompts 2 and 3 on Sonnet 4.6.

If neither is offered, the strongest available Gemini coding model (Gemini 3 Pro or equivalent) is a reasonable fallback. Prefer Anthropic models if available — the V1.x drafts were authored against Claude's voice-discipline output and a Claude agent will pattern-match more cleanly to the same constraints.

---

## Prompt 1 — Audit existing chapter-1 dialogue trees for staleness

**Use this prompt when:** you want a comprehensive read of how much of the existing in-engine dialogue still meets phase-7 voice discipline, before deciding what to rewrite.

**Recommended model:** Claude Opus 4.6 (or Sonnet 4.6 if Opus unavailable).

```
You are auditing the existing chapter-1 dialogue tree files in a Godot RPG project (Pig & Swine RPG, a legal-comedy RPG). Phase 7 of the project produced a set of revised voice-pack drafts (V1.1 pass 2, V1.2 pass 3, V1.3 pass 3) that establish stricter voice discipline for each character. Many of the existing in-engine dialogue lines predate this rework and are likely stale. Your task is to produce a comprehensive audit report identifying which lines should be HELD, REWRITTEN, or CUT.

Read these files first, in this order:

1. narrative_revision/phase_7_drafts/V1.1_office_opening_pig_crisis_draft_pass2.md
2. narrative_revision/phase_7_drafts/V1.2_find_murrow_binder_crab_draft_pass3.md
3. narrative_revision/phase_7_drafts/V1_3_draft_pass3.md
4. The voice_profile meta records (line 1) of each:
   - godot/data/voice_references/dialogue_samples_mr_pig.jsonl
   - godot/data/voice_references/dialogue_samples_mr_murrow.jsonl
   - godot/data/voice_references/dialogue_samples_crab.jsonl
   - godot/data/voice_references/dialogue_samples_whimsy.jsonl
5. The existing dialogue trees being audited:
   - godot/data/dialogues/pig.json
   - godot/data/dialogues/murrow.json
   - godot/data/dialogues/crab.json
   - godot/data/dialogues/whimsy.json

Discipline checklist to apply (each character has both general rules and character-specific rules):

GENERAL §A SCRUB LIST — BANNED ACROSS ALL CHARACTERS:
- Vocabulary: "delve", "tapestry", "myriad", "vibrant", "navigate", "showcase", "essence of", "heart of", "rich" (as adjective), "deeply", "robust", "intricate", "weave", "intersection"
- Connectors: "indeed", "moreover", "furthermore"
- Hedge preambles: "let me be clear", "to be honest", "I won't pretend"
- Contrastive antithesis ("not X but Y" where Y negates X) — NOTE: descriptive parallelism where both states are simultaneously true is allowed (e.g. "present in paper and absent from the record")
- Rule-of-three financial lists
- Generic uplifting closers
- Em-dashes more than 1 per paragraph
- EXCEPTION: the word "navigate" is permitted exactly once in Mr. Pig's V1.3 apprentice lecture as canonical maritime tinge per pack §A.5. Any other use of "navigate" is a violation.

CHARACTER-SPECIFIC RULES (drawn from voice_profile.avoid and the V1.x drafts):

Mr. Pig:
- Maritime metaphor concentrated, not wall-to-wall — direct lines must coexist with metaphorical lines
- Crisis lines (pre-Cula-meets-Murrow) cite ONLY rent; printer-lease and missing-Swine-retainer lines belong to later beats (V1.3 onward)
- Does not explain the case (he defers to Murrow)
- No back-in-my-day lectures before V1.3 Beat 8
- No "delve", "navigate" (except canonical V1.3 instance), etc.

Mr. Murrow:
- Dry-procedural, not warm-welcoming; warmth is implied by invitations existing, not by language carrying it
- No reassurance, no panic, no flamboyance
- Jokes are small, dry, sound like filing advice with disappointment attached
- No over-explanation of legal doctrine where a checklist will do
- Does NOT make every line sarcastic

Crab:
- No self-explaining stance, motivation, principle, compensation, exit-planning, or commitment language. THIS IS PHASE-6 HIT #3 — load-bearing.
- Comedy from factual mismatch (date, address, signature, invoice, log, sequence, wording), not from stance
- Sounds competent even when joking
- Rare use of metaphors; if used, blunt and concrete
- NOT a trenchcoat-noir parody. NOT cruel to clients.
- Lines like "If anyone asks, I was already suspicious before the facts arrived" or "I check the facts. I do not arrange them to look prettier" — these are the exact kind of self-explaining-stance lines Phase-6 Hit #3 rejects. Mark such lines REWRITE or CUT.

Whimsy:
- Theatrical with metaphors that clarify fairness, proportionality, access to court, dignity, abuse of process
- Not random for randomness's sake
- Not cruel to clients, Pig, Asia, Crab, or Cula
- Sarcasm punches up at institutions, landlords, rival lawyers, automation, bureaucracy
- Strongest court lines should become suddenly precise (not theatrical)
- Short theatrical cuts often funnier than speeches

Produce a single audit report at: narrative_revision/phase_7_audits/dialogue_tree_staleness.md

Format the report with one section per character. Within each section, list each existing dialogue line (or state-grouped set of lines) verbatim, then assign a verdict — HOLD, REWRITE, or CUT — with one sentence of justification citing the specific discipline rule the line does or does not respect.

At the end of each character's section, give a count summary: "X lines HOLD, Y lines REWRITE, Z lines CUT, total N." At the end of the report, give an overall summary table.

DO NOT modify any dialogue tree files in this pass. The output is the audit report only. A separate pass will rewrite based on the audit.

Do not invent new lines. Do not propose replacement text. The audit is classification, not authoring.

Report length: roughly 800-1500 words depending on the number of lines in the trees.
```

---

## Prompt 2 — Author asia.json and cula.json dialogue trees

**Use this prompt when:** the audit is complete and you want to fill in the two character dialogue tree files that don't yet exist.

**Recommended model:** Claude Sonnet 4.6.

```
Create two new dialogue tree files in a Godot RPG project (Pig & Swine RPG): godot/data/dialogues/asia.json and godot/data/dialogues/cula.json. Both files don't currently exist. They must match the schema and conventions of the existing dialogue tree files in the same directory and draw their lines exclusively from already-drafted phase-7 voice packs.

Read these files first, in this order:

1. The schema by example — read all four existing dialogue trees:
   - godot/data/dialogues/pig.json
   - godot/data/dialogues/murrow.json
   - godot/data/dialogues/crab.json
   - godot/data/dialogues/whimsy.json
   Note the state-machine structure: top-level fields like version, npc_id, states (array of state objects with id/trigger/lines or line/on_dismiss), idle_flavor.

2. Engine state-flag conventions — read:
   - godot/scripts/systems/dialogue_runner.gd (the dialogue runner) — confirm what trigger expression syntax it supports and what on_dismiss operations it accepts
   - godot/data/chapters/chapter1.json — see what state flags chapter 1 already declares; new flags should follow the same naming convention (e.g. chapter1.met_<character>, chapter1.has_<item>)

3. The phase-7 pass drafts (these contain the only lines you may use):
   - narrative_revision/phase_7_drafts/V1.1_office_opening_pig_crisis_draft_pass2.md (Asia: Beat 1 welcome lines; Cula: arrival, reaction, exit, family-photo)
   - narrative_revision/phase_7_drafts/V1.2_find_murrow_binder_crab_draft_pass3.md (Cula: Beat 3 + 4 + 5 lines)
   - narrative_revision/phase_7_drafts/V1_3_draft_pass3.md (Asia: Beat 8 closing; Cula: Beat 7 + coffee + Beat 8 lines)

4. Voice profiles — line 1 of each:
   - godot/data/voice_references/dialogue_samples_asia.jsonl
   - godot/data/voice_references/dialogue_samples_dr_a_cula.jsonl

What to produce:

asia.json — a state machine covering at minimum:
- Greeting / first welcome at scene start (Beat 1 V1.1 pass 2 lines: "Dr. A. Cula, good morning. We've been expecting you." / "Your blue folder is on the second pile from the left..." / "Mr. Pig is at the case board. He'll want to say hello first.")
- Post-Mr.-Pig-meeting hint pointing player to Murrow
- Post-binder-pickup reaction
- Pre-readiness Beat 8 closing: "She rang an hour ago, Mr. Cula. She'll be there at quarter to." (Mrs. Borowski phone-call confirmation)

cula.json — Cula's environmental and player-triggered observations:
- Family-photo interactable: "A family photo. Mr. Pig appears to be the youngest in it." (chapter-1 only; chapter-5 retraversal is out of scope)
- Any other ambient observation lines from the V1.1-V1.3 drafts
- Cula's beats inside scenes (greeting Pig at the case board, replying to Murrow, recruiting Crab/Whimsy, etc.) belong in scene-staged dialogue, not idle/state-triggered NPC trees. If you find a separate scene-staging system in the codebase that handles those, do not duplicate them in cula.json. If unclear, leave a comment block at the top of cula.json documenting which lines are out-of-scope for this file and where they should live.

Constraints:
- Match the JSON schema and field names exactly as used in the existing files. Same indent style, same key order.
- Use only state flags that already exist in chapter1.json or follow the same naming convention. If you need a new flag, add it to chapter1.json in the same pass.
- Do not invent new lines. Use only lines from the V1.1-V1.3 pass drafts. If a state needs coverage that no draft line fills, leave a `// TODO` comment in JSON5-style (or use a "_comment" field if the runner tolerates extra fields) and omit the line.
- Mrs. Borowski's title ("Mrs.") was added to canon at V1.2 pass 3 / V1.3 pass 3 but is flagged as uncommitted. Where her name appears, add a comment field noting the title is provisional and should be confirmed against any earlier chapter-1 source material.

Verification step (run after writing both files):
1. Validate JSON: run `python3 -c "import json; json.load(open('godot/data/dialogues/asia.json')); json.load(open('godot/data/dialogues/cula.json')); print('valid')"`
2. Cross-check trigger expressions: grep dialogue_runner.gd to confirm every trigger and on_dismiss field uses keys/operations the runner recognises.
3. Output a short integration note: which state flags you used (and whether any are new), which beats from the drafts went unmapped (and why), and any open questions for human review.

Do not modify pig.json, murrow.json, crab.json, or whimsy.json in this pass.
```

---

## Prompt 3 — Wire binder-gate logic into Crab's dialogue

**Use this prompt when:** you want the V1.2 pass 3 two-pass Crab gate (refusal without binder, engagement with binder) actually working in-engine.

**Recommended model:** Claude Sonnet 4.6.

```
Implement binder-gated dialogue branching for the NPC Crab in a Godot RPG project (Pig & Swine RPG). The V1.2 pass 3 voice pack draft specifies that Crab refuses if approached without the procedural binder ("The binder is not in the room. I cannot check service without the binder.") and engages if approached with it ("The binder cites Article 132. The notice mentions service. I can check that."). The current crab.json doesn't implement this gate. Your task is to wire it.

Read these files first:

1. godot/scripts/systems/dialogue_runner.gd — understand the current state-machine evaluation loop and trigger-expression syntax (what comparisons and flag references the runner supports)
2. godot/scripts/ui/dialogue_box.gd — UI integration; confirm whether it has any opinions about state-machine structure
3. godot/data/dialogues/crab.json (current state) — note the existing two-state machine (before_meeting / after_meeting) which contains stale phase-6 lines you'll be replacing
4. godot/data/items.json — find the procedural binder item id (likely something like procedural_binder, beat4_binder, or similar)
5. godot/data/chapters/chapter1.json — find any existing flag tracking binder collection, or determine that one needs to be added
6. narrative_revision/phase_7_drafts/V1.2_find_murrow_binder_crab_draft_pass3.md — confirm the exact lines and the two-pass gate semantics; the relevant section is "BEAT 5 — Crab recruitment"

What to implement:

A. State flag for binder possession:
   - If chapter1.json already has a flag like chapter1.has_procedural_binder or similar, use that.
   - If no such flag exists, add it to chapter1.json under the same conventions used for other chapter flags. Suggested name: chapter1.has_procedural_binder.
   - Wire the binder pickup interactable (or whichever Beat-4 trigger collects the binder in-game) to set this flag. Find the relevant interactable script — it's probably under godot/scripts/interactables/ or godot/scripts/world/.
   
B. New state machine in crab.json:
   - Replace the existing states array. Preserve the top-level fields (version, npc_id).
   - Three states minimum:
     - "before_binder": triggered when chapter1.has_procedural_binder == false (and chapter1.met_crab == false, OR remove the met_crab flag if redundant). Lines:
       - "Cula. Heard."
       - "The binder is not in the room. I cannot check service without the binder."
     - "after_binder_first_engagement": triggered when chapter1.has_procedural_binder == true and (some new flag like) chapter1.crab_binder_engaged == false. Line: "The binder cites Article 132. The notice mentions service. I can check that." On dismiss: set chapter1.crab_binder_engaged = true.
     - "after_engagement": triggered when chapter1.crab_binder_engaged == true. A short repeat/idle line. If no draft line exists for this state, leave a TODO comment.
   - Preserve idle_flavor if the runner uses it; populate from V1.x drafts only or leave as empty array.

C. Lines must come verbatim from the V1.2 pass 3 commit-candidates list. Do not paraphrase.

D. The previously-stale before_meeting / after_meeting content in crab.json predates phase 7 and contains self-explaining-stance lines that violate Phase-6 Hit #3 discipline. Do not preserve them in the active state machine. If the project has any convention for archiving deprecated content (e.g. _legacy fields), use it; otherwise note the removal in your integration report.

Constraints:
- Do not modify dialogue_runner.gd's expression grammar unless the existing grammar genuinely cannot express what you need. The existing crab.json shows that boolean-flag comparisons like "chapter1.met_crab == true" are supported.
- Match the JSON formatting style of the existing dialogue tree files (indentation, key order).
- The binder-pickup wiring change should be minimal — set one flag, do not refactor surrounding code.

Verification step:
1. Validate JSON: run `python3 -c "import json; json.load(open('godot/data/dialogues/crab.json'))"`
2. Run any existing tests. Look for godot/tests/ runners. Check godot/tests/fixtures/dialogue_fixture.json for whether any existing test exercises Crab's dialogue.
3. If a Godot headless launch is feasible, manually walk Crab dialogue with the binder flag set both ways and confirm correct branching.
4. Output a short integration report with:
   - Which file you set the binder flag in (the pickup interactable script or wherever)
   - The exact trigger expressions you used
   - Whether you needed to add chapter1.has_procedural_binder or used an existing flag
   - Any tests that pass or break
   - Any open questions for human review

Do not modify any other dialogue tree files (pig.json, murrow.json, whimsy.json, asia.json, cula.json) in this pass.
```

---

## Notes on running these prompts

- Run them in order: Prompt 1 (audit) → Prompt 2 (asia/cula authoring) → Prompt 3 (binder gate). The audit is upstream context for the next two; running 2 and 3 before 1 means the agent will be fixing forward-blind.
- Prompts 2 and 3 are independent and can run in parallel after Prompt 1 if Antigravity supports concurrent agent sessions.
- Each prompt has a verification step built in — read the agent's verification output before merging.
- All three prompts are written to be runnable on a clean repo state (assuming the V1.x pass drafts and the appended voice references from this session's "step 1" are in place).
