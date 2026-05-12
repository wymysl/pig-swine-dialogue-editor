# Phase-7 Rewrite-and-Replace Pass — Integration Report

**Date:** 2026-05-06  
**Files modified:** `godot/data/dialogues/pig.json`, `murrow.json`, `whimsy.json`  
**Files unchanged:** `crab.json`, `asia.json`, `cula.json`  
**Authority:** `dialogue_tree_staleness.md` (audit), V1.1 pass 2, V1.2 pass 3, V1.3 pass 3

---

## Validation results

```
JSON validity:    PASS — all three files parse cleanly
Scenario tests:   11 / 11 PASS (4 Pig, 4 Murrow, 3 Whimsy)
```

---

## pig.json — per-state diff

### `first_meeting` (trigger: `met_pig == false`) — REPLACED

Old 2-line array (1× REWRITE, 1× CUT) → 8-line V1.1 pass 2 Beat 1+2 Pig-only sequence (verbatim).

`_comment_multi_speaker` added: Cula's 3 interjection lines absent pending option 1.

`on_dismiss` unchanged (sets `met_pig`, `pig_revealed_crisis`).

### `post_meeting_pre_murrow` — REPLACED

Old (1× REWRITE) → `"Yes. Mr. Murrow. As I said. Apologies for the noise."`

### `met_murrow_pre_binder`, `has_binder` — HOLD

### `idle_flavor` — 1 REPLACED, 2 HELD

Old: `"How goes the voyage? Are we navigating toward justice..."` (REWRITE — consumed §A.5 navigate exception)  
New: `"Has anyone seen my optimism? It was here this morning."`

---

## murrow.json — per-state diff

### `before_pig` (trigger: `met_pig == false`) — REPLACED

Old (1× REWRITE) → `"Doctor Cula. Mr. Pig is expecting you. The case can wait the ten minutes Mr. Pig requires for opening remarks."`

### `first_meeting` (trigger: `met_pig == true && met_murrow == false`) — REPLACED

Old 3-line array (2× CUT, 1× REWRITE) → 9-line V1.2 pass 3 Beat 3 Murrow-only sequence (verbatim).

`_comment_multi_speaker` added: lines 6–8 are Murrow's responses to absent Cula interjections.  
`_comment_borowski_title` added: "Mrs." in line 2 is provisional.

`on_dismiss`: sets `met_murrow = true`.

### `post_briefing_pre_binder` — REPLACED

Old (1× REWRITE) → `"You're back without the binder. The shelf has not moved."`

### `has_binder_pre_crab` — REPLACED

Old (1× REWRITE) → `"Now Crab. Nothing else moves until service is checked."`

### `idle_flavor` — 1 CUT REMOVED, 1 REPLACED, 1 HELD. Final: 2 lines.

Removed: `"Procedure is the poetry of the law."` (CUT — Whimsy register, not Murrow)  
Replaced: `"We do not guess in this office. We deduce."` → `"The paperwork is current. Whether it is correct is a separate question."`  
Held: `"Ensure every form is stamped in triplicate."`

---

## whimsy.json — per-state diff

### `before_meeting` (trigger: `met_whimsy == false`) — REPLACED

Old 2-line array (1× REWRITE, 1× CUT) → 4-line V1.3 pass 3 Beat 7 Whimsy-only sequence (verbatim).

`_comment_multi_speaker` added: Cula's case statement and Rights Memo recognition absent pending option 1.

`on_dismiss`: now sets **both** `met_whimsy = true` AND `recruited_whimsy = true`.

### `after_meeting` — REMOVED ENTIRELY

**Decision: removed** (not stubbed).

Rationale: an empty stub with trigger `met_whimsy == true` would emit the hard-coded fallback `"..."` string on every post-recruited re-approach. Without it, the runner falls through to `idle_flavor`, which is correct behavior. The HOLD idle_flavor line serves as the repeat-visit response.

Old CUT line (`"Find the right rhetorical flourish and the judge will not even notice the missing evidence."`) removed. No `_legacy` field (CUT-class; no archival convention for this pass per prompt).

### `idle_flavor` — HOLD

---

## Verbatim confirmation

- V1.1 pass 2: 8 Pig lines — verbatim ✓  
- V1.2 pass 3: 9 Murrow lines — verbatim ✓  
- V1.3 pass 3: 4 Whimsy lines — verbatim ✓  
- 6 newly-authored lines — verbatim as specified ✓

No lines paraphrased or altered.

---

## Open questions for human review

1. **Pig em-dash (U+2014)** — `"Mr. Murrow knows the— ask Mr. Murrow."` uses U+2014. Confirm glyph renders correctly in the dialogue box at target resolution.

2. **Murrow `first_meeting` lines 6–8 as monologue** — These are response lines to Cula's unseen interjections. Contextually incomplete in single-speaker mode. When option 1 (multi-speaker runner) lands, gate these as reply-states behind Cula's triggering lines.

3. **Whimsy double-flag on single dismiss** — No intermediate state where Whimsy is met-but-not-recruited. All existing routing gates (`asia_hints.json`, `murrow.json`) gate on `recruited_whimsy`, so no existing gate breaks. Confirm acceptable for chapter-1 progression.

4. **Murrow `idle_flavor` thinned to 2 lines** — Sufficient for random-pick but thin. Candidate for future flavor-line pass.

5. **Mrs. Borowski "Mrs." title** — Provisional in both `murrow.json` (first_meeting line 2) and `asia.json` (readiness_borowski_confirmed). Confirm before audio lock.
