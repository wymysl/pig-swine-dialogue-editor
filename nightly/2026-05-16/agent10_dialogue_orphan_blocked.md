# Agent 10: Category 3 (Orphan Rewrite JSONs) — HALTED

**Status: BLOCKED — Substantive In-Flight Work**

Three orphan rewrite JSONs in `godot/data/dialogues/` have pending changes that represent real authoring work. All three should be committed before any move or cleanup.

## Files Blocked

### 1. `godot/data/dialogues/asia_rewrite.json`

**Status:** Modified (M), pending changes.

**Diff Summary:**
- Before: Empty stub (4 lines, empty `states: []`, `idle_flavor: []`)
- After: Full voice pack rewrite (66 lines, complete dialogue states with provenance notes)

**Content:** Reauthored Asia voice pack with:
- Two first-meeting states (`first_meeting_via_behind_counter`, `first_welcome`)
- Full lines matching Asia's voice spec
- Address-form corrections
- Functional reception-desk texture

**Archive Counterpart:** `godot/data/_drafts/asia_rewrite_2026-05-14.json` (389 bytes, stub)

**Recommendation:** Commit the working asia_rewrite.json as-is before cleanup. The file represents a candidate voice pack iteration that the human may want to merge into asia.json or keep as a draft.

---

### 2. `godot/data/dialogues/murrow_v2.json`

**Status:** Modified (M), pending changes.

**Diff Summary:**
- Before: Empty stub (4 lines, empty `states: []`)
- After: Full voice pack rewrite (124 lines, 9 dialogue states)

**Content:** Reauthored Murrow voice pack with:
- `before_pig`, `first_meeting`, `post_meeting_pre_murrow`, `met_murrow_pre_binder`, `has_binder_only`
- `coffee_reaction_perfect` and other coffee reactions
- Full procedural briefing on the Sikorska case
- Address-form compliance with invitation to first-name terms
- Mrożek aside (one per chapter) planted per design budget

**Archive Counterpart:** `godot/data/_drafts/murrow_v2_2026-05-14.json` (392 bytes, stub)

**Related Drafts:** `godot/data/_drafts/murrow_player_driven_2026-05-15.json` also exists (separate voice iteration).

**Recommendation:** This file represents a distinct Murrow voice iteration. Do not delete or move without human review. May coexist with the _drafts/ version if both are valid branches.

---

### 3. `godot/data/dialogues/pig_rewrite.json`

**Status:** Modified (M), pending changes.

**Diff Summary:**
- Before: Empty stub (4 lines, empty `states: []`)
- After: Full voice pack rewrite (52 lines, 6 dialogue states + coffee reactions)

**Content:** Reauthored Mr. Pig voice pack with:
- `first_meeting`, `post_meeting_pre_murrow`, `met_murrow_pre_binder`, `has_binder_only`
- `coffee_reaction_perfect` (S-grade) and other coffee reactions
- Composed-then-collapsing sentence shape, specific objects (rent envelope, printer lease)
- Address-form compliance
- V1.4 coffee logic preserved

**Archive Counterpart:** `godot/data/_drafts/pig_rewrite_2026-05-14.json` (389 bytes, stub)

**Recommendation:** Commit as-is. Candidate voice pack for merging or as a draft reference.

---

## Worktree Respect

Per Session 30 notes and instructions: "The three orphan JSONs are `M` in `git status` — they have uncommitted changes. Use `git diff HEAD -- <file>` to see the pending changes BEFORE deciding action. If the pending changes look substantive (more than docstring updates), halt that specific file and document — the human may want to commit those changes before you move the file."

All three files contain substantive changes:
- Full voice pack rewrites (not just docstring updates)
- Dialogue content that is load-bearing for voice development
- Possible merges into canonical files or side-by-side comparisons

**Action:** Halt Category 3 and defer to human. These files should either be:
1. Committed to preserve the voice work
2. Compared against other draft versions for consolidation
3. Explicitly abandoned with a `git rm`

Agent 10 does not have authority to decide which.

---

## Next Steps

Before Commit 3 (orphan rewrite JSON resolution) can proceed:

1. Human reviews the three modified files
2. Human decides whether to:
   - Commit them as-is (preserve voice work)
   - Merge them into canonical files
   - Delete them
   - Move them to _drafts/ with date stamps

After human decision, Agent 10 (or a follow-up agent) can execute Commit 3.

---

**Generated:** 2026-05-16 (Agent 10, Cowork Haiku)
