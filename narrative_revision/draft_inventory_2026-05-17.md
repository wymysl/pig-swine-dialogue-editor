# Draft Staging Inventory — 2026-05-17

Audited by task 0.1 (generated inline, no prior artifact). Covers:
- `godot/data/_drafts/` — 15 files
- `godot/data/dialogues/_drafts/` — 3 files

Canonical baseline: `godot/data/dialogues/*.json`, `godot/data/*.json`.

**Awaiting human approval before task 0.2 executes any deletions.**

---

## Classification key

| Tag | Meaning | Action |
|-----|---------|--------|
| STUB | Zero states, self-declares inert | `git rm` |
| SUPERSEDED | A later draft replaces this one (same state IDs) | `git rm` |
| ABSORBED | All content now present in canonical | `git rm` after diff confirms |
| PENDING | Real content not yet merged; keep | Leave; add `_status` if missing |

No EXPLORATORY files found (no dead-end design experiments without a stated promotion path).

---

## Inventory table

### godot/data/_drafts/

| File | Classification | Superseded by / Canonical ref | Evidence | Action |
|------|---------------|-------------------------------|----------|--------|
| `asia_rewrite_2026-05-14.json` | STUB | — | 0 states; `_scope` self-declares "git rm whenever abandoned or merged"; state IDs would collide with `asia.json` | `git rm` |
| `asia_hints_player_driven_2026-05-16.json` | SUPERSEDED | `asia_hints_player_driven_2026-05-16_v2.json` | Single trigger uses stale enum `merits_defence`; v2 corrected to `substantive_defense` per decoy revision rename; otherwise identical | `git rm` |
| `asia_hints_player_driven_2026-05-16_v2.json` | PENDING | Merges into `dialogues/asia_hint_states_ch1.json` | 6/15 states already in canonical; 9 new states (`hint_binder_unread_renumbering`, `hint_crab_quiet_wrong_shape`, 3 whimsy-posture hints, 3 post-court hints, `hint_court_ready_assembled`) not yet merged | Leave; add `_status` |
| `crab_player_driven_2026-05-15.json` | SUPERSEDED | `crab_player_driven_final_2026-05-16.json` | Identical state IDs; final is the voice-polished cut (ai_voice_constraints pass + scrub-list audit done) | `git rm` |
| `crab_player_driven_final_2026-05-16.json` | PENDING | Merges into `dialogues/crab.json` | `before_binder_briefing` differs from canonical; `crab_post_pitch_response_wrong_shape` + `crab_post_pitch_response` are new states not yet in canonical | Leave; add `_status` |
| `halina_with_trust_meter.json` | ABSORBED | `dialogues/halina.json` | All 13 draft states present in canonical; only diff is `post_meeting_ch1` uses old `"line":` key vs canonical `"lines":` array — content byte-for-byte identical; canonical has evolved further with one additional state (`halina_post_meeting_decoy_incapacity_cold`) | `git rm` (diff confirms) |
| `murrow_player_driven_2026-05-15.json` | SUPERSEDED | `murrow_player_driven_final_2026-05-16.json` | Identical state IDs; final adds has_binder_pre_crab reshape + two new post-frame states; voice pass done | `git rm` |
| `murrow_player_driven_final_2026-05-16.json` | PENDING | Merges into `dialogues/murrow.json` | `has_binder_pre_crab` differs from canonical; `murrow_post_frame_attaches_motion` + `murrow_post_frame_walks_back` are new states not yet in canonical | Leave; add `_status` |
| `murrow_v2_2026-05-14.json` | STUB | — | 0 states; `_scope` self-declares "git rm whenever abandoned or merged"; state IDs would collide with `murrow.json` | `git rm` |
| `nightly_design_beat13_close_2026-05-17.json` | PENDING | Merges into `dialogues/asia.json` + env-beat (coffee machine) | Today's draft; explicitly "not yet promoted to runtime"; covers 2 Beat-13 close pieces not in `nightly_design_pig_2026-05-14.json`; new flag `pig_court_win_acknowledged` requires Code pass first | Leave; add `_status` |
| `nightly_design_murrow_beat9_2026-05-15.json` | PENDING | Merges into `dialogues/murrow.json` | 4 Beat-9 archive-room states; "not yet promoted to runtime"; blocked on Code declaring two missing flags (`murrow_beat9_dwell`, `article_135bis_understood`) in `state.gd` | Leave; add `_status` |
| `nightly_design_pig_2026-05-14.json` | PENDING | Merges into `dialogues/pig.json` (+ murrow/crab/whimsy reference lines) | Beat-13 post-court lines; "not yet promoted to runtime"; blocked on Code declaring `chapter1.client_fee_collected` flag | Leave; add `_status` |
| `nightly_dialogue_fixes_2026-05-15.json` | PENDING | Two targeted line fixes | Fix 1 (murrow.json `court_readiness_check` asia speaker "Mr. Cula" → "Dr. A. Cula") **already applied** in canonical; Fix 2 (asia.json `cula_approach` "Dr. A Cula" → "Dr. A. Cula" missing period) **not yet applied** | Leave; add `_status` noting Fix 1 done, Fix 2 pending |
| `pig_rewrite_2026-05-14.json` | STUB | — | 0 states; `_scope` self-declares "git rm whenever abandoned or merged"; state IDs would collide with `pig.json` | `git rm` |
| `whimsy_player_driven_2026-05-15.json` | SUPERSEDED | `whimsy_player_driven_final_2026-05-16.json` | Identical state IDs; final adds 3 new response states; voice pass done | `git rm` |
| `whimsy_player_driven_final_2026-05-16.json` | PENDING | Merges into `dialogues/whimsy.json` | `before_meeting` matches canonical; 3 new response states (`whimsy_response_procedural_throat`, `whimsy_response_merits_pivot`, `whimsy_response_open_register`) not yet in canonical | Leave; add `_status` |

### godot/data/dialogues/_drafts/

| File | Classification | Notes | Action |
|------|---------------|-------|--------|
| `crab_decoys_2026-05-16.json` | PENDING | 16 states; decoy revision per PROPOSAL §3+§4; already has `_status`; not loaded by runner (subdir skip) | Leave (no change needed) |
| `murrow_decoys_2026-05-16.json` | PENDING | 16 states; decoy revision; already has `_status` | Leave (no change needed) |
| `whimsy_decoys_2026-05-16.json` | PENDING | 12 states; decoy revision; already has `_status` | Leave (no change needed) |

---

## Summary of planned mutations (pending approval)

**`git rm` (8 files):**
- `godot/data/_drafts/asia_rewrite_2026-05-14.json` (STUB)
- `godot/data/_drafts/murrow_v2_2026-05-14.json` (STUB)
- `godot/data/_drafts/pig_rewrite_2026-05-14.json` (STUB)
- `godot/data/_drafts/asia_hints_player_driven_2026-05-16.json` (SUPERSEDED)
- `godot/data/_drafts/crab_player_driven_2026-05-15.json` (SUPERSEDED)
- `godot/data/_drafts/murrow_player_driven_2026-05-15.json` (SUPERSEDED)
- `godot/data/_drafts/whimsy_player_driven_2026-05-15.json` (SUPERSEDED)
- `godot/data/_drafts/halina_with_trust_meter.json` (ABSORBED — diff verified above)

**Add `_status` field (7 files):**
- `godot/data/_drafts/asia_hints_player_driven_2026-05-16_v2.json`
- `godot/data/_drafts/crab_player_driven_final_2026-05-16.json`
- `godot/data/_drafts/murrow_player_driven_final_2026-05-16.json`
- `godot/data/_drafts/whimsy_player_driven_final_2026-05-16.json`
- `godot/data/_drafts/nightly_design_pig_2026-05-14.json`
- `godot/data/_drafts/nightly_design_murrow_beat9_2026-05-15.json`
- `godot/data/_drafts/nightly_design_beat13_close_2026-05-17.json`
- `godot/data/_drafts/nightly_dialogue_fixes_2026-05-15.json` (list type — `_status` cannot be added as a top-level key; will wrap in object or add a sibling `.status.md` file — flagging for human decision)

**No change (3 files):**
- `godot/data/dialogues/_drafts/crab_decoys_2026-05-16.json`
- `godot/data/dialogues/_drafts/murrow_decoys_2026-05-16.json`
- `godot/data/dialogues/_drafts/whimsy_decoys_2026-05-16.json`

---

## Open question before execution

`nightly_dialogue_fixes_2026-05-15.json` is a JSON array (not an object), so a `_status` top-level key cannot be added without changing its type. Options:
1. Leave it as-is and add a sibling `nightly_dialogue_fixes_2026-05-15.status.md` note.
2. Wrap it in an object: `{"_status": "...", "fixes": [...]}` (changes schema, breaks any tooling that expects an array).
3. `git rm` it since Fix 1 is done and Fix 2 is a trivial single-char correction that should just be applied to canonical (but task 0.2 forbids touching canonical).

Please confirm your preferred treatment before execution.
