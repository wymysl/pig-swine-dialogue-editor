# Pass 3 Multi-Speaker Conversion Integration Report

**Date:** 2026-05-06
**Pass:** Phase 7 pass 3 — chapter-1 NPC dialogue trees -> multi-speaker schema (option 1)
**Authority sources:** V1.1 pass 2, V1.2 pass 3, V1.3 pass 3

---

## Per-File Change Summary

### pig.json

| | Before | After |
|---|---|---|
| State converted | `first_meeting` | `first_meeting` |
| Lines before | 8 (Pig-only strings) | 11 (mixed) |
| Speaker-override objects added | 0 | 3 (cula x 3) |
| `_comment_multi_speaker` removed | - | yes |
| `on_dismiss` changed | no | no |
| `trigger` changed | no | no |

**Lines added:** Cula interjections from V1.1 pass 2 restored at entries 1, 8, 10:
- `"Mr. Pig. Good morning."` (Beat 1 arrival greeting)
- `"Six weeks. Understood."` (Beat 2 crisis reception)
- `"I'll find him."` (Beat 2 task acceptance / exit -- pass 2 addition)

**Em-dash verification:** Entry 9 (`"Mr. Murrow has the folder. Mr. Murrow knows the\u2014 ask Mr. Murrow."`) retains Unicode em-dash U+2014 (`\u2014`) exactly as in the original and in V1.1 pass 2.

---

### murrow.json

| | Before | After |
|---|---|---|
| State converted | `first_meeting` | `first_meeting` |
| Lines before | 9 (Murrow-only strings) | 14 (mixed) |
| Speaker-override objects added | 0 | 5 (cula x 5) |
| `_comment_multi_speaker` removed | - | yes |
| `_comment_borowski_title` retained | yes | yes |
| New state added | - | `court_readiness_check` (11 lines, 5 speaker-override objects) |

**first_meeting interjections restored (V1.2 pass 3):**
- Entry 0: Cula `"Mr. Murrow. I was told you'd have the Borowski file."`
- Entry 6: Cula `"The client's current address. Is it on file with the court?"`
- Entry 8: Cula `"Thank you, Mr. Murrow."`
- Entry 10: Cula `"Then it's Cula."`
- Entry 12: Cula `"She'll be relieved either way."`

**court_readiness_check (NEW -- Beat 8, V1.3 pass 3):**
- Trigger: `chapter1.has_law_binder == true && chapter1.has_rights_memo == true && chapter1.recruited_crab == true && chapter1.recruited_whimsy == true && chapter1.court_ready == false`
- 11 entries: Murrow (5 strings) + Cula (3 objects) + Pig (2 objects) + Asia (1 object)
- Position: after `has_binder_pre_crab`, before `idle_flavor`
- `on_dismiss`: sets `chapter1.court_ready = true`

---

### whimsy.json

| | Before | After |
|---|---|---|
| State converted | `before_meeting` | `before_meeting` |
| Lines before | 4 (Whimsy-only strings) | 7 (mixed) |
| Speaker-override objects added | 0 | 3 (cula x 3) |
| `_comment_multi_speaker` removed | - | yes |

**Cula interjections restored (V1.3 pass 3 Beat 7):**
- Entry 0: Cula `"Mr. Whimsy. Cula, Pig & Swine. We need a second voice in court tomorrow."`
- Entry 2: Cula case statement (semicolon construction per V1.3 pass 3)
- Entry 4: Cula `"The Rights Memo."`

---

### crab.json

| | Before | After |
|---|---|---|
| States converted | `before_binder`, `after_binder_first_engagement` | both |
| `before_binder` lines before | 2 (Crab-only strings) | 4 (mixed) |
| `after_binder_first_engagement` before | 1 (single `line` key) | 3 (mixed `lines` array) |
| Speaker-override objects added | 0 | 3 (cula x 3) |
| `after_engagement` state | unchanged | unchanged |

**before_binder:** Entry 0 Cula opener; entry 3 Cula reaction `"Right."`

**after_binder_first_engagement:** Converted from `"line"` to `"lines"` [Cula `"Here."`, Crab engagement, Cula `"Good."`]

---

### asia.json -- `readiness_borowski_confirmed` Decision

**Decision: REMOVED.**

**Rationale:** Beat 8 (`court_readiness_check` in `murrow.json`) embeds Asia's confirmation line as a multi-speaker object at entry 10. The standalone state would only fire after `court_ready` becomes true (after Beat 8 has already played), reachable only by walking back to reception -- a gameplay dead-end duplicating Beat 8's information.

**States remaining:** `first_welcome`, `post_pig_pre_murrow`, `post_binder`.

---

### cula.json

No changes. Scope note in `_comment_scope` remains accurate.

---

### barista.json (NEW)

**Coffee tutorial scope: Option (c) -- stub only -- 2-state split.**

Investigation: `coffee_brewing.tscn` and `coffee_brewing.gd` are stubs. No dialogue hardcoded. Minigame sets `chapter1.coffee_tutorial_seen = true` and emits `minigame_finished`. Runner has no mid-state pause-on-input support.

**Decision: 2-state split** (smallest change; no runner extension; no minigame refactoring):
- `coffee_order` (trigger: `chapter1.coffee_tutorial_seen == false`) -- Cula order + Barista strength prompt
- `coffee_outcome` (trigger: `chapter1.coffee_tutorial_seen == true`) -- Barista success line + Whimsy quip

**Outcome variant:** Defaults to success (`"Strong it is. Two zloty."`) because stub always emits `"success"`. Soft-fail variant documented in `_comment_strength_flag` for future extension.

**Runner wiring:** Not implemented (content-only pass). Wiring the counter interactable is a separate Code task.

---

## Test Results

### JSON Validity

All 7 files pass `json.load()`: pig, murrow, crab, whimsy, asia, cula, barista. OK.

### Speaker Resolution

All speaker IDs (`cula`, `pig`, `asia`, `whimsy`, `barista`) resolve in `character_registry.json`. No additions required.

### Python Simulation: 73/73 checks pass

| Section | Checks | Result |
|---|---|---|
| A. pig.json first_meeting | 13 | 13/13 |
| B. murrow.json first_meeting | 14 | 14/14 |
| B2. murrow.json court_readiness_check | 11 | 11/11 |
| C. whimsy.json before_meeting | 9 | 9/9 |
| D. crab.json before_binder | 7 | 7/7 |
| D2. crab.json after_binder_first_engagement | 8 | 8/8 |
| E. asia.json readiness_borowski_confirmed removed | 3 | 3/3 |
| F. barista.json coffee tutorial | 11 | 11/11 |
| **Total** | **73** | **73/73** |

Verified: (a) correct entry order, (b) correct speaker switches, (c) correct on_dismiss, (d) triggers unchanged.

### Engine Tests (T1-T12)

Runner not modified in this pass. Converted trees use only the existing API (strings and `{speaker, text}` dicts in `lines`). T1-T12 should pass unchanged. Run: `godot --headless --script tests/test_dialogue_runner.gd` from project root.

---

## Open Questions for Human Review

1. **`has_rights_memo` flag.** `court_readiness_check` trigger gates on this flag, which is not in `chapter1.json`'s `new_state_flags` and may be absent from `state.gd` reset. Add it or the readiness-check will never fire.

2. **`chapter1.coffee_tutorial_seen` in State reset.** Written directly by `coffee_brewing.gd`; not in `chapter1.json`'s `new_state_flags`. Add to prevent runner warnings on first boot.

3. **Barista runner wiring.** Nothing triggers `dialogue_requested("barista", "Barista")` from the cafe scene. Wiring is a separate Code task.

4. **`coffee_strong` flag (future).** If minigame is extended to produce win/lose, split `coffee_outcome` into two states gated on this flag. See `_comment_strength_flag` in barista.json.

5. **`Mrs. Borowski` title provisional.** All entries referencing Mrs. Borowski carry the provisional flag from V1.2 pass 3. Confirm against any earlier chapter-1 source before locking.

6. **V1.4 courtroom cross-check.** Joinder defect was cut in V1.2 pass 3 (two defects remain). Confirm V1.4 pack does not reference joinder as an established prior beat.
