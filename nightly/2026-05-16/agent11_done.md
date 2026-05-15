# Agent 11 — CONVENTIONS / AGENTS Sync Audit

**Commit.** `[pending]` — Proposal: CONVENTIONS and AGENTS sync after v17 player-driven argument cohort.

## Summary
Produced a structured sync proposal at `nightly/2026-05-16/conventions_sync_proposal.md` auditing the v17 player-driven argument pivot. The proposal captures 10 distinct governance updates across `CONVENTIONS.md`, `AGENTS.md`, and `PROPOSALS.md`.

## Section Density
1. **§1 Schema:** High (7 flags + registry drift note).
2. **§2 Triggers:** Low (best-practice note).
3. **§3 Options:** Medium (Dialogue Editor enum contract).
4. **§4 Ownership:** Medium (5 new directory/file rows).
5. **§5 Migration:** low (confirmed v16->v17 discipline).
6. **§6 Invariants:** low (confirmed no violations).
7. **§7 Proposals:** Medium (1 update, 1 new entry).
8. **§8 Exclusions:** Medium (Audit of non-changed surfaces).
9. **§9 Priority:** High (Schema and Ownership top priority).
10. **§10 Agents:** High (Ingested reports from 8 agents).

## Statistics
- **Proposed CONVENTIONS.md additions:** 8 (7 flags + 1 enum contract).
- **Proposed AGENTS.md additions:** 6 (5 ownership rows + 1 migration confirmation).
- **Proposed PROPOSALS.md updates:** 2 (1 status note + 1 new entry).
- **Agents ingested:** 8 (Agents 2, 3, 4, 5, 6, 8, 10, 12).
- **Governance drift:** None found. All agents adhered to human-only edit rules.

## Notes for Piotr
- **Highest Priority:** Land the **CONVENTIONS.md §Chapter 1 state schema** additions first. Future agents reading the state bag need to know the semantic owners of `proposed_frame` and `judicial_patience` to avoid "guessing" logic.
- **Agent 9 (QA):** This proposal is documentation-only; it does not affect runtime. QA audit can proceed independently.
- **Scratch relocation:** Agent 10 moved 17 scripts to `godot/scratch/`. This is reflected in the proposed ownership table as workspace-only/not-runtime.
