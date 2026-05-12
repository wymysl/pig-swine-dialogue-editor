# Phase 7 Dialogue Tree Staleness Audit

**Auditor:** Antigravity (automated)
**Date:** 2026-05-06
**Source discipline:** V1.1 pass 2, V1.2 pass 3, V1.3 pass 3, voice_profile meta records, General §A Scrub List
**Scope:** `godot/data/dialogues/pig.json`, `murrow.json`, `crab.json`, `whimsy.json`

---

## Mr. Pig (`pig.json`)

### State: `first_meeting`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 1 | "Dr. A. Cula! Thank every harbour authority." | **REWRITE** | V1.1 pass 2 replaces the first-meeting lines entirely. The canonical Beat 1 idle is "It would appear that we are..." (fragmentary, trailing off). "Thank every harbour authority" is wall-to-wall maritime in an opening that should mix direct and metaphorical lines per Pig voice rules. |
| 2 | "This ship is sinking, the lifeboats are unlabelled, and Mr. Swine has taken the map to Japan." | **CUT** | Rule-of-three financial list (ship/lifeboats/map). Also cites "Mr. Swine" and Japan in Beat 1, which is too early — V1.1 pass 2 confines Beat 2 to rent only. The missing-Swine-retainer theme belongs to later beats (V1.3 onward). |

### State: `post_meeting_pre_murrow`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 3 | "Find Mr. Murrow. He knows what the case is actually about. I know only that the hull is making financial noises." | **REWRITE** | Direction is correct (defer to Murrow), but Pig should not explain the case — "what the case is actually about" borders on explanation. V1.1 pass 2 canonical deflection is fragmentary: "Mr. Murrow has the folder. Mr. Murrow knows the— ask Mr. Murrow." The self-aware comic framing ("hull is making financial noises") is charming but pre-dates phase-7 discipline on Beat 2 density. |

### State: `met_murrow_pre_binder`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 4 | "The procedural binder is in the archive, unless it has finally achieved sentience and crawled below deck." | **HOLD** | On-register maritime metaphor with comic payoff. Does not violate §A scrub. Does not cite printer-lease or missing-Swine-retainer. Single em-dash (none — the comma carries). Acceptable as a state-specific nudge line not covered by V1.x drafts. |

### State: `has_binder`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 5 | "The binder and the memo. Excellent. Two anchors. One may crush the deck, but morally anchors." | **HOLD** | Maritime metaphor, punchy, does not violate §A. The pun ("morally anchors" / "moral anchors") is Pig-register comedy. No banned vocabulary. No rule-of-three. Acceptable as a post-binder reaction not covered in V1.x drafts. |

### `idle_flavor`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 6 | "For the first time today, the ship is not actively sinking. It is merely making exploratory gurgling noises." | **HOLD** | On-register, comic maritime, no §A violations. Good idle line. |
| 7 | "How goes the voyage? Are we navigating toward justice, or have we struck another procedural reef?" | **REWRITE** | Contains "navigating" — the word "navigate" is permitted exactly once in V1.3 Pig's apprentice lecture ("We navigated by panic alone") per §A.5 exception. This idle line uses it in a different context, consuming the single permitted use. Must be rewritten to remove "navigating." |
| 8 | "We cannot sail into court with a hole in the hull and optimism as our only oar." | **HOLD** | On-register maritime. No §A violations. No banned vocabulary. |

### Pig Summary

| Verdict | Count |
|---------|-------|
| HOLD | 4 |
| REWRITE | 3 |
| CUT | 1 |
| **Total** | **8** |

---

## Mr. Murrow (`murrow.json`)

### State: `before_pig`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 1 | "Dr. A. Cula. Speak to Mr. Pig first. He needs to vent his panic before we can address the procedural realities." | **REWRITE** | Too warm/explanatory for Murrow. "He needs to vent his panic" is psychological narration — Murrow's register is dry-procedural, not diagnostic. V1.2 pass 3 shows Murrow never explains Pig's emotional state; he simply works around it. A tighter logistical redirect without the psychology would be on-register. |

### State: `first_meeting`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 2 | "Dr. A. Cula. You're here. Mr. Pig has already briefed you on the emotional state of the firm. Let us discuss the legal state." | **CUT** | Contrastive antithesis ("the emotional state... the legal state") — the "not X but Y" structure where Y repositions X. Also warm-welcoming ("You're here") which contradicts Murrow's register. V1.2 pass 3 canonical opening is: "Doctor Cula. Welcome to Pig & Swine. You've picked a noisy day to begin." — dry, not warm. |
| 3 | "We are defending a client who believes an invoice is a philosophical suggestion." | **CUT** | Flamboyant comic framing. This is Whimsy's register, not Murrow's. Murrow's V1.2 pass 3 case-framing is plain-language procedural: "The case is a tenancy dispute. Mrs. Borowski moved out of the flat two years ago..." Murrow does not editorialize the client's beliefs. |
| 4 | "I need you to review the case binder and gather the necessary memos before we approach the bench." | **REWRITE** | Direction is correct (binder + memos), but phrasing is too instructional/warm. V1.2 pass 3 canonical logistics: "The procedural binder is on the second shelf, blue spine. The rights memo is clipped inside the front cover." Murrow gives locations, not instructions. The "I need you to" preamble is a hedge that Murrow's register avoids. |

### State: `post_briefing_pre_binder`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 5 | "I will not discuss strategy until you have retrieved the procedural binder from the archive. We need facts, not improvisation." | **REWRITE** | Contrastive antithesis: "facts, not improvisation" is exactly the banned "not X but Y" construction. The first sentence's conditional refusal is on-register, but the closer is a stance declaration that Murrow's voice profile avoids. |

### State: `has_binder_pre_crab`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 6 | "You have the binder. Good. Now find Crab. We have a service of process issue, and Crab's skepticism is exactly what we require." | **REWRITE** | "Crab's skepticism is exactly what we require" is over-explanation of why Crab is being recruited — Murrow's V1.2/V1.3 register gives logistical instructions without justifying personnel choices. The first half ("You have the binder. Good. Now find Crab.") is acceptable. The second half editorializes. |

### `idle_flavor`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 7 | "Procedure is the poetry of the law." | **CUT** | Flamboyant; this is Whimsy's register. Murrow's voice profile specifies he is "not flamboyant; that is Whimsy's function." Murrow would not aestheticize procedure. |
| 8 | "We do not guess in this office. We deduce." | **REWRITE** | Contrastive antithesis: "not guess... deduce" is the banned "not X but Y" pattern. Also a stance declaration that sounds like a tagline rather than Murrow's dry-procedural register. |
| 9 | "Ensure every form is stamped in triplicate." | **HOLD** | On-register: dry, procedural, mildly sardonic bureaucratic instruction. No §A violations. Acceptable as idle flavor. |

### Murrow Summary

| Verdict | Count |
|---------|-------|
| HOLD | 1 |
| REWRITE | 4 |
| CUT | 3 |
| **Total** | **8** (1 state line counted per state entry) |

---

## Crab (`crab.json`)

### State: `before_meeting`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 1 | "Dr. A. Cula. If anyone asks, I was already suspicious before the facts arrived." | **CUT** | Self-explaining-stance line — Phase-6 Hit #3 load-bearing violation. "I was already suspicious before the facts arrived" is exactly the kind of pre-announced-principle line the discipline rejects. V1.2 pass 3 canonical acknowledgment is simply: "Cula. Heard." No self-positioning. |
| 2 | "I check the facts. I do not arrange them to look prettier." | **CUT** | Self-explaining-stance line — Phase-6 Hit #3 again. "I check the facts. I do not arrange them" is a mission statement, not a working line. Also contrastive antithesis (implied "not arrange... check"). V1.2 pass 3 explicitly flags this pattern as the kind of line to reject. |

### State: `after_meeting`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 3 | "The facts are not beautiful, but they are standing in the right order." | **CUT** | Self-explaining-stance. "Standing in the right order" is a satisfaction-declaration about one's own work. Also contrastive antithesis ("not beautiful, but... standing"). Crab's V1.2 pass 3 lines are task-oriented factual observations, not self-assessments. |

### `idle_flavor`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 4 | "The office is quiet. Either nothing happened, or the evidence is hiding better than usual." | **REWRITE** | Borderline. The observation-then-dry-cut structure is on-register for Crab. But "the evidence is hiding" personifies evidence in a noir-parody way that Crab's voice profile warns against ("NOT a trenchcoat-noir parody"). The factual mismatch should come from a document, date, or address — not from evidence having agency. Rewrite to ground the humor in something concrete. |

### Crab Summary

| Verdict | Count |
|---------|-------|
| HOLD | 0 |
| REWRITE | 1 |
| CUT | 3 |
| **Total** | **4** |

---

## Whimsy (`whimsy.json`)

### State: `before_meeting`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 1 | "Dr. A. Cula! The courtroom is a stage, and we must bring the finest metaphors." | **REWRITE** | Exclamation-mark warmth is too eager — V1.3 pass 3 canonical opening is the restrained "Cula. Sit." (not even "Dr. A. Cula"). "The courtroom is a stage" is a cliché metaphor that doesn't clarify fairness, proportionality, or access to court. Whimsy's metaphors should do legal work, not just be theatrical for theatre's sake ("not random for randomness's sake"). |
| 2 | "Facts are merely the strings on the violin. We must play the music!" | **CUT** | Random-for-randomness metaphor. Does not clarify any legal concept. "Merely" dismisses facts, which undermines Whimsy's role as a serious legal ally who happens to be theatrical. V1.3 pass 3 shows Whimsy engaging with specific legal concepts (fair-hearing doctrine, service defects, throat/song metaphor). This line has no legal content. |

### State: `after_meeting`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 3 | "Find the right rhetorical flourish and the judge will not even notice the missing evidence." | **CUT** | Suggests hiding evidence through rhetoric — antithetical to Whimsy's character, who is protective of clients and rights. His sarcasm punches up at institutions, not at the truth. This line makes him sound unethical rather than theatrical. V1.3 pass 3 shows Whimsy making genuine legal arguments dressed in theatrical language. |

### `idle_flavor`

| # | Line | Verdict | Justification |
|---|------|---------|---------------|
| 4 | "A procedural argument without a metaphor is like coffee without water. Dry and slightly offensive." | **HOLD** | On-register: theatrical, self-aware about rhetoric, the coffee reference echoes the Café Paragraf setting. The simile clarifies Whimsy's approach to procedure. No §A violations. "Dry and slightly offensive" is a short theatrical cut — the type the voice profile endorses. |

### Whimsy Summary

| Verdict | Count |
|---------|-------|
| HOLD | 1 |
| REWRITE | 1 |
| CUT | 2 |
| **Total** | **4** |

---

## Overall Summary

| Character | HOLD | REWRITE | CUT | Total |
|-----------|------|---------|-----|-------|
| Mr. Pig | 4 | 3 | 1 | 8 |
| Mr. Murrow | 1 | 4 | 3 | 8 |
| Crab | 0 | 1 | 3 | 4 |
| Whimsy | 1 | 1 | 2 | 4 |
| **All** | **6** | **9** | **9** | **24** |

### Key Findings

1. **Crab is the most stale.** All three dialogue-state lines are CUT — every one is a self-explaining-stance violation (Phase-6 Hit #3). The entire state machine needs replacing with V1.2 pass 3 binder-gated content.

2. **Murrow is second-most stale.** Three CUT, four REWRITE. The existing lines are too warm, too explanatory, and contain multiple contrastive-antithesis violations. Only one idle-flavor line survives.

3. **Pig has the best survival rate** (4 HOLD), but the first-meeting state is entirely stale and the idle-flavor "navigating" line must be rewritten to preserve the §A.5 single-use exception for V1.3.

4. **Whimsy's surviving line** (the coffee idle-flavor) is the only one that does legal-concept work through metaphor. The rest are random-theatre or ethics-violating.

5. **Systemic violations across all trees:**
   - Contrastive antithesis ("not X but Y"): found in Murrow (×3), Crab (×1)
   - Self-explaining stance (Phase-6 Hit #3): found in Crab (×3)
   - Wrong-register lines (character voice leaking into another character's territory): Murrow lines 3, 7 read as Whimsy
   - Premature content (themes appearing before their canonical beat): Pig line 2 (Swine/Japan in Beat 1)
