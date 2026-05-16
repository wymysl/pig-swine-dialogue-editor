# Build Notes

Append dated entries per QA browser-playtest run and per human
playtest. See godot/.antigravity/skills/qa.md.

## 2026-05-04 — Voice-reference audit complete

Voice-reference corpus audited and committed-clean. 38 files, 24,544 records.
Final audit shows 1 POSSIBLE_FIRST_MEETING flag on `dialogue_samples_dr_a_cula.jsonl` L12 — verified as the canonical Beat 3 first-meeting opener per story.txt; address form is correct as written. No further action needed on voice references.

## 2026-05-05 — Sprint 8 Pickups & Minigames

Automated build and smoke tests passed (EXIT 0). Manual playtest pending human review.
Pending verification:
- [ ] Murrow, Crab, Whimsy all show their idle_front sprites, not blank ColorRects.
- [ ] Walk to ProceduralBinder in office, press E → pickup line shows, binder disappears, State.data.chapter1.has_law_binder == true.
- [ ] Walk to RightsMemo in archive, press E → pickup line shows, memo disappears, State.data.chapter1.has_rights_memo == true.
- [ ] Re-enter both rooms → already-collected items do not re-appear.
- [ ] Walk to CoffeeMachine in café, press E → stub overlay opens, press E → closes, State.data.chapter1.coffee_tutorial_seen == true.
- [ ] Save/load round-trip preserves all three flags.

## 2026-05-16 — Session 46: project test runner contract repaired (VERIFIED)

`tests/test_runner.gd` was a no-op skeleton returning exit 0 unconditionally. Every "EXIT 0" line in SPRINT_LOG against the runner up through Session 45 was therefore a false green. Focused-test coverage (44/44, 21/21, 25/25, 15/15, ...) was real, but the aggregate runner the AGENTS.md hard build invariant points at was not exercising any of it.

Runner rewritten to discover `tests/test_*.gd` (excluding self + smoke), spawn each via `OS.execute()` with the running godot binary, and aggregate child exit codes. Exit contract: 0 iff every discovered test exited 0; 1 if any child failed; 2 if zero tests were discovered.

Verified on macOS dev machine: baseline run discovered 43 tests in 13.3s and returned **EXIT 1** with `40/43 passed`. The runner's red path is proven by real failures, not a planted one. Three real test failures were uncovered that the old skeleton had been hiding — see Session 46 SPRINT_LOG entry for the per-test diagnosis.

Triage outcomes after Session 46 close — **all P1 items closed under Orchestrator authorization**:

- [x] `test_dialogue_runner.gd` — **CLOSED.** T17 stale test fixed (set `met_asia` before invoking the hint state).
- [x] `test_chapter1_v17_flag_coverage.gd` — **CLOSED.** Line-246 type-guard fixes the SCRIPT ERROR. T2/T6 registry-drift assertions now pass after the chapter1.json catch-up (below).
- [x] `test_chapter1_flag_coverage.gd` — **CLOSED.** Setup crash fixed by deleting the Array-shaped fixes manifest from `data/dialogues/`. Inverse-coverage assertions now pass after the registry annotation pass (below).
- [x] **Code handoff CLOSED:** chapter1.json registry catch-up landed. 14 missing keys added with `_type`/`default` matching `state.gd::reset_state()`. 12 pre-existing entries got engine markers in `set_by`; 2 aspirational entries (`proposed_frame`, `whimsy_co_counsel_posture`) marked "not yet authored". No save migration.
- [x] **Design handoff CLOSED:** 13 draft-duplicate dialogue files removed from `data/dialogues/` (each byte-identical with its existing `_drafts/` copy). Two non-loaded stragglers (`asia_hints_player_driven_2026-05-16_v2.json`, `halina.json.bak`) left for user triage; they don't affect runtime or test signal.

**Final state: `[TestRunner] Summary: 43/43 passed in 13282 ms. ALL PASS.` Runner output is clean — no duplicate-state-id spam at boot or shutdown.**

Updated AGENTS.md build invariant `godot --headless --script tests/test_runner.gd` (GUT, exit 0) is now substantively correct: the runner aggregates the corpus, exits 0 only when every focused test passes, and reports nameable failures otherwise. GUT is still not installed; if/when the corpus outgrows the simple PASS/FAIL-per-file granularity the existing tests provide, GUT migration becomes the right next move — but it is a full-corpus migration, not partial.
