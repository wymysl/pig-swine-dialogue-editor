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
