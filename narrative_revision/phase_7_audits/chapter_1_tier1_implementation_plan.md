# Chapter 1 — Tier 1 implementation plan

**Goal:** ship chapter 1 end-to-end playable. The drafting work is mostly done; the engine wiring is mostly not. Right now the playable surface ends at Beat 10 (readiness check); Beats 8 (Halina), 11 (walk), 12 (court), 13 (office payoff), and 14 (postcard) exist as drafts and partial dialogue files but are not reachable from gameplay.

**Source:** `narrative_revision/phase_7_audits/chapter_1_tier1_implementation_plan.md` (this file). Cross-references: V1.4 (Halina meeting), V1.6 (court rounds), V1.7 (office payoff + postcard), V1.A (Asia hint states); the chapter-1 audit produced 2026-05-09.

**Methodology:** five phases (A–E) in dependency order. Each phase has discrete deliverables, explicit dependencies, identified risks, and an effort estimate. Tier 2 / Tier 3 items not in this plan: Beat 9 archive research with Murrow (no draft pack yet), cardiologist-plant Ch4 wiring, badge UI polish, route-unlock UX beyond the minimum, and `chapter1.json` `steps` array population. Tier 2 items pulled into Tier 1 where they unblock playability: Beat 7 stance-pick UI (without it, Beat 8's stance branches are dead), Beat 11 walk transition (the chapter doesn't read as one experience without something connecting Beat 10 to Beat 12).

**Estimated total effort:** 3–5 working days of focused engine work, depending on how much polish goes into the Beat 11 transition and the badge / route-unlock UI. The drafting work is already done; this is engine-only.

---

## Phase A — Foundation (engine prep)

**Goal:** unblock all downstream phases by extending state, adding two missing dialogue-runner action types, and resolving the V1.A hint dispatch question. No new content authored in this phase; pure plumbing.

**Estimated effort:** 0.5–1 day.

### A.1 — Extend `state.gd` chapter1 block

Add the missing flags every downstream dialogue file references. The full set, gathered from `halina.json`, `judge_district_ch1.json`, `postcard_swine_ch1.json`, and `asia_hint_states_ch1.json`:

- `halina_met` (Beat 8 entry; sets on dismiss of `halina.json` `client_meeting_*`)
- `client_meeting_stance` (string; one of `sympathetic` / `blunt_procedural` / `technical`; set by Beat 7 stance-pick UI)
- `bonus_evidence_collected` (string; one of `wojcik_witness_statement` / `return_to_sender_slip` / `lease_1962_inheritance_1987`; set by `halina.json` on dismiss)
- `cardiologist_plant_landed` (Beat 8 plant; consumed by Ch4 corridor sighting — flag stays through chapter; not consumed in chapter 1)
- `client_fee_agreed` (Beat 8; sets on dismiss)
- `archive_research_complete` (Beat 9 — flag exists but Beat 9 dialogue not yet authored; declare the flag now so V1.A state 8 hint dispatches correctly)
- `casebook_judge_state` (string; one of `round_1_open` / `round_1_react` / `round_2_open` / `round_2_react` / `round_3_open` / `round_3_remedy` / empty; set by court orchestration system; `judge_district_ch1.json` reads it)
- `court_won_procedural_reset` (Beat 12 close; set by court orchestration on remedy)
- `beat13_complete` (Beat 13 close; sets postcard trigger gate)
- `received_swine_postcard` (V1.A state 11 — gates Asia hint between Beat 13 and Beat 14)
- `postcard_asia_announced` (Beat 14 progression flag)
- `postcard_readaloud_cue_shown` (Beat 14 progression flag)
- `postcard_body_read` (Beat 14 progression flag)
- `pig_postcard_reaction_shown` (Beat 14 progression flag)
- `whimsy_postcard_deflection_shown` (Beat 14 progression flag)
- `complete` (chapter-close gate; awarded by `postcard_swine_ch1.json` chapter_close)

Also add chapter-state dictionaries for badges and routes (the engine has neither system today; declare a minimal flat shape now so `award_badge` / `unlock_route` actions in A.2 have somewhere to write):

- `badges` (Dictionary; key = badge id, value = bool; `day_one_survivor` declared with default `false`)
- `routes_unlocked` (Dictionary; keys = `residential` / `business_district` / `court_plaza` / etc.; values = bool; defaults `false`)

**Save migration:** bump `SAVE_VERSION` from 7 to 8. Add a migration step in `save.gd` that rewrites pre-v8 saves by adding the new keys with their default values; existing playthroughs at Beat 10 should resume cleanly.

**Deliverables:**

1. `godot/scripts/autoload/state.gd` updated `reset_state()` returns the extended chapter1 dict + `badges` + `routes_unlocked`
2. `godot/scripts/systems/save.gd` migration step from v7 → v8
3. `godot/data/chapters/chapter1.json` `new_state_flags` array updated to list the new flags (currently lists only `met_asia` and `viewed_family_photo` from phase 7)

**Dependencies:** none — runs first.

**Risks:**

- Save-file backward compat: any pre-v8 saves the user has from prior playthroughs need migration. Test the v7 → v8 migration with a dummy save before committing
- Flag-name drift: the dialogue files all reference these names already; double-check spelling against grep before committing (e.g., `halina_met` vs `met_halina`)

### A.2 — Extend `DialogueRunner` action handler

`_on_dialogue_dismissed` currently implements only the `set` mutation type (`dialogue_runner.gd:62-64`). The `postcard_swine_ch1.json` chapter-close `on_dismiss` declares `award_badge` and `unlock_route` — both silently dropped today.

Add two new action types:

- `{ "award_badge": "<badge_id>" }` → writes `state.data.badges[<badge_id>] = true`
- `{ "unlock_route": "<route_id>" }` → writes `state.data.routes_unlocked[<route_id>] = true`

Both actions emit a signal so UI/badge-popup/route-unlock systems can react when those exist. For the minimum-viable shipping path the signals are nice-to-have; the state mutations are the load-bearing thing.

**Deliverables:**

1. `godot/scripts/autoload/dialogue_runner.gd` updated `_on_dialogue_dismissed` handles `award_badge` and `unlock_route` keys in addition to `set`
2. New signals on `signals.gd` autoload: `badge_awarded(badge_id: String)` and `route_unlocked(route_id: String)` (optional this phase; required if A.4 stub UI is built)

**Dependencies:** A.1 (the badges / routes_unlocked dicts must exist before the action can write to them).

**Risks:**

- Tests: `tests/test_dialogue_runner.gd` exists; add cases for the two new action types so the regression doesn't sneak in later

### A.3 — Resolve Asia hint NPC dispatch

The current state contradicts itself: `dialogue_runner.gd:35` loads `asia_hints.json` (legacy 10-state, with neutral/agitated/deadpan tone variants) explicitly under the `"asia"` catalogue key, while V1.A's `asia_hint_states_ch1.json` (new 12-state, single committed lines) loads under its own `npc_id` and is unreachable from any NPC instance.

Two options. Pick one; do not ship both.

**Option 1 (recommended): replace `asia_hints.json` with V1.A lines.** V1.A is the committed canonical surface from phase-7 voice work; the legacy 10-state hint file is the pre-phase-7 baseline. Either author tone-variant triplets (neutral/agitated/deadpan) for each of V1.A's 12 lines, or accept single-line hints and remove the tone-variant system. The committed V1.A lines have no canonical tone-variant authorship; producing triplets would be net-new drafting work outside V1.A's scope. Recommendation: drop the tone-variant system, accept single committed lines, simplify the NPC code path. The tone-variant system was never tested against the address-form rule; the V1.A-pass-2 critique is the authoritative voice work.

**Option 2: keep tone variants, re-author V1.A as triplets.** More work; produces richer hint variety; requires a new V1.A.1 pack to author the agitated/deadpan facets. Defer until after chapter 1 ships.

**Recommendation:** Option 1. Concrete steps:

1. Delete or rename `data/asia_hints.json` to `data/asia_hints.json.bak` (preserve as legacy reference)
2. Wire `dialogue_runner.gd:35` to load `asia_hint_states_ch1.json` under the `"asia"` catalogue key (or remove the explicit asia_hints loader and let the directory-load pick it up — but the latter requires renaming `asia_hint_states_ch1.json` to be sub-keyed appropriately; explicit load is cleaner)
3. Decide whether V1.A states map to the existing `hint` Dict shape or to the simple `lines` array shape. The existing engine reads `hint.neutral` for tone-variant NPCs; V1.A's file uses `lines: [...]`. Cleanest engine path: accept both shapes in the runner, or rewrite V1.A's JSON to nest single lines under `hint.neutral` for engine compatibility. **Current V1.A JSON is shaped for the `lines` schema (per `judge_district_ch1.json`); engine reads `hint.<tone>` for hint NPCs. Mismatch needs resolution.**

**Sub-decision required:** keep V1.A's current `lines` shape and update the runner to support hint NPCs without tone variants, OR rewrite V1.A's JSON to nest under `hint.neutral`. The first is more engine work; the second is more JSON authoring but uses the existing hint pipeline.

**Deliverables:**

1. Decision recorded (Option 1 / Option 2; sub-decision on shape)
2. `dialogue_runner.gd` updated to dispatch Asia hints to the new file
3. `asia_hint_states_ch1.json` reshape if the sub-decision goes that way
4. Manual test: walk through the chapter and confirm Asia's hint changes correctly across each gate

**Dependencies:** A.1 (V1.A states 7, 8, 11 reference flags only added in A.1).

**Risks:**

- Asia patrols toward the cabinet (`asia.gd`); confirm the patrol AI doesn't break the hint dispatch (it shouldn't, but verify)
- The legacy hint NPC system may be referenced from places I haven't audited; grep for `asia_hints` before deleting

### A.4 — (Optional this phase) Minimal badge popup + route-unlock acknowledgment UI

Stub UI for badge award and route unlock. Without these, the player has no feedback when the postcard's chapter close fires. Could defer to a polish pass, but the chapter doesn't feel like it ends without some acknowledgment.

Minimum viable: a 2-second popup in `Main.tscn` that shows `badge.day_one_survivor.display_name` and the unlocked route names. No animation, no sound, no save indicator.

**Deliverables (optional):**

1. `scenes/ui/badge_popup.tscn` (one popup shared by badges and route unlocks; or two scenes — pick one)
2. `scripts/ui/badge_popup.gd` listening to `signals.badge_awarded` / `signals.route_unlocked`
3. Wire into `main_controller.gd` `_ready()`

**Dependencies:** A.1, A.2.

**Risks:** time sink — easy to over-engineer. Cap at 2 hours; stub harder if it runs over.

---

## Phase B — Beat 7-8 client meeting

**Goal:** make the Beat 8 Halina meeting reachable. Build the stance-pick UI for Beat 7, the Halina NPC, the meeting-room area, and wire the trigger pipeline.

**Estimated effort:** 1–1.5 days.

### B.1 — Beat 7 stance-pick UI

`halina.json` has three stance variants gated on `chapter1.client_meeting_stance`. The flag is set somewhere in Beat 7 — when Cula commits to a tone for interviewing Halina. The pack `V1.4_halina_meeting_research.md` (drafting) and the existing `whimsy.json` Beat 7 recruitment dialogue are upstream of this; the actual stance pick is its own UI moment.

Decision: make the stance pick a 3-button UI prompt at the moment Cula and Whimsy enter the meeting room (or — if the meeting room is a sub-area of `pig_swine_office.tscn` — at the doorway). The buttons are:

- Sympathetic: lead with how she's holding up
- Blunt-procedural: lead with the timeline
- Technical: lead with the lease history

(Wording per `bibles/cula.md` and the V1.4 pack §B.1 stance-aligned interview tones.)

**Deliverables:**

1. `scenes/ui/court_stance_menu.tscn` already exists for Beat 12; check if it's reusable or build a sibling `client_stance_menu.tscn`. Likely a sibling — Beat 12's stance menu is for argument carrier choice, not interview tone
2. `scripts/ui/client_stance_menu.gd` — captures the choice and writes `chapter1.client_meeting_stance` via `state.gd`
3. Trigger: fires when Cula attempts to enter the meeting-room area (or when interacting with Halina's first scene-entry NPC if she's standing outside the room — drafter's choice based on the scene layout in B.2)

**Dependencies:** A.1 (`client_meeting_stance` flag).

**Risks:**

- Players who haven't read the V1.4 pack won't understand what the three options *mean* mechanically — they just pick a vibe. That's fine: the choice is character-shaping, not strategic. But the button text matters; iterate until "sympathetic" / "blunt-procedural" / "technical" read as personality rather than mechanic. The bible's interior-register-range section gives precise wording

### B.2 — Halina NPC + meeting-room area

`halina.json` is already authored with three full Beat 8 flow variants. Two scene-architecture options:

**Option 2a (recommended): meeting-room as a sub-area of `pig_swine_office.tscn`.** The office scene already has `MeetingFloor` and `MeetingDivider` nodes (visible in the .tscn — they're declared but not yet used as a destination). Add an Area2D entry trigger; on enter, fire the stance-pick UI; on stance commit, advance to the Halina dialogue. The meeting room is visually present in the office scene; the player physically walks into it.

**Option 2b: separate `pig_swine_office_meeting_room.tscn` scene.** `chapter_1.md` mentions this as a phase-8 addition. More work; cleaner separation; allows distinct music or lighting. Recommended only if the in-office sub-area approach has visual or pathing problems.

Recommendation: Option 2a unless the meeting-floor area in the existing office scene proves too small for a believable staging. Building a new scene is a 4-hour task; sub-area entry trigger is a 1-hour task.

**Deliverables:**

1. Halina NPC instance: `Area2D` with `npc_id = "halina"`, sprite (use a placeholder or generate a Halina sprite — sprite art does not exist; check `art/sprites/` for missing folders), positioned in the meeting-room area
2. Entry trigger: `Area2D` at the meeting-room threshold; on body-entered, checks gating flags (`recruited_whimsy && halina_arrived && !halina_met`) and fires the stance-pick UI
3. `halina_arrived` flag: a new chapter1 flag set when the player completes Beat 7 and returns to the office. **Add this to A.1's flag list if not already there** (it isn't; add now)
4. Asia announces Halina's arrival: trigger a one-shot Asia line on Beat-7 completion ("Mrs. Sikorska is here. I've shown her into the meeting room.") — this line is already in `halina.json`'s `client_meeting_*` lines as the first line, but it needs to fire as an announcement BEFORE Cula enters the meeting room. Either move it to a separate Asia state or accept that it plays as the first line of the Halina dialogue once Cula enters

**Dependencies:** A.1 (flags), B.1 (stance-pick UI fires from this entry trigger).

**Risks:**

- Halina sprite is missing. Without it, she's a placeholder rectangle. Acceptable for first playthrough; flag for art pass
- The meeting-room area is small in the existing scene. Visual believability of Cula + Crab + Whimsy + Halina + Murrow all being in the room together may need scene tweaks

### B.3 — Beat 8 trigger pipeline + Asia announcement

After B.1 and B.2 are wired, verify the full Beat 8 sequence plays:

1. Cula recruits Whimsy at Café Paragraf (Beat 7; existing)
2. Cula returns to office (Beat 7 close)
3. Asia delivers her one-shot "Mrs. Sikorska is here" line (B.2)
4. Cula approaches the meeting-room area
5. Stance-pick UI fires (B.1)
6. Stance committed; meeting-room area unlocks
7. Cula enters; `halina.json` `client_meeting_<stance>` plays
8. On dismiss, `halina_met = true` + `client_fee_agreed = true` + `bonus_evidence_collected = <stance-mapped value>` + `cardiologist_plant_landed = true` (already in `halina.json` `on_dismiss`)

**Deliverables:**

1. Test the sequence end-to-end with each of the three stances
2. Save/load mid-meeting and confirm flags restore correctly

**Dependencies:** B.1, B.2.

**Risks:** Beat 8 is the longest single dialogue in chapter 1 (~70 lines). The DialogueRunner already handles long multi-speaker sequences, but verify performance and the dismiss flow.

---

## Phase C — Beat 11-12 walk + court rounds

**Goal:** make the District Court reachable and the three-round sequence playable. Build the court scene, the round-orchestration system, and the landlord-counsel NPC. Add a minimal Beat 11 walk transition.

**Estimated effort:** 1.5–2 days. The court orchestration system is the biggest single piece of new engine code in this plan.

### C.1 — Beat 11 walk transition

Two options:

**Option 1 (minimum viable): cut from office_street to district_court_plaza via fade.** No walk scene; no judgmental pigeons; no Halina-at-steps NPC. The chapter loses some atmosphere but the chapter ships.

**Option 2 (V1.5-faithful): build a walk scene with embankment / pigeons / Halina at the courthouse steps.** Authored content exists (V1.5 pass 1); scene work is moderate.

Recommendation: **Option 1 for first ship; Option 2 in a polish pass.** The walk is atmospheric but not narrative-load-bearing. Halina greeting at the steps is the only piece of authored dialogue that gets cut by Option 1; her dialogue continues at the Beat 12 court entrance, so the loss is one greeting beat. Acceptable for a first playthrough.

**Deliverables (Option 1):**

1. New transition trigger in `office_street.tscn`: an Area2D at the north edge that, when crossed, fires room transition to `district_court.tscn` (built in C.2)
2. `state.data.entered_court` set on transition completion (flag already exists)

**Dependencies:** C.2 (district_court scene).

### C.2 — `district_court.tscn` scene

Brand-new scene. Layout per V1.6 pack §A.6 / `chapter_1.md` Beat 12: a courtroom with a bench, a clerk's desk, a witness stand, two counsel tables (petitioner left, respondent right), a gallery row.

**Deliverables:**

1. `scenes/world/routes/district_court_plaza.tscn` — exterior plaza (optional; could be skipped if Option 1 of C.1 is taken — direct transition into the courtroom)
2. `scenes/interiors/district_court.tscn` — the courtroom interior. Player spawn at petitioner's table. NPC instances:
   - `District_Court_Judge` (Area2D, `npc_id = "judge_district_ch1"`)
   - `Landlord_Counsel` (Area2D, `npc_id = "landlord_counsel_ch1"`)
   - `Halina_Sikorska` (Area2D, `npc_id = "halina"`; gallery seat; silent in gallery per V1.6 pack §B.7)
   - `Murrow` (Area2D, `npc_id = "murrow"`; gallery seat; silent in gallery)
   - Crab and Whimsy (as already-recruited team members at counsel's table)
3. Static props: bench, tables, gallery rail, doors

**Dependencies:** A.1.

**Risks:**

- Sprite assets for the judge and landlord-counsel may not exist; check `art/sprites/`. Placeholder rectangles acceptable for first playthrough
- Court scene complexity is moderate; budget 4–6 hours

### C.3 — Court orchestration system

The biggest single piece of engine work in this plan. `judge_district_ch1.json`'s `_engine_flags_required` notes the engine must drive `casebook_judge_state` through the round sequence. No engine exists for this today; `casebook.gd` is a 6-line stub.

The system flow:

1. Player enters district_court → state machine starts at `round_1_open`
2. `casebook_judge_state = round_1_open` → judge fires "Counsel for the petitioner" (open state)
3. Crab argues service-and-knowledge per stance: needs a Crab dialogue file branch for Beat 12 Round 1 (currently NOT in `crab.json` — must be authored)
4. Cula tenders evidence: needs a Cula dialogue file branch (currently NOT in `cula.json`)
5. Landlord-counsel responds: needs a `landlord_counsel.json` dialogue file with the single canonical response line
6. `casebook_judge_state = round_1_react` → judge fires the stance-aligned dry-surprise reaction
7. Repeat for Round 2 (Whimsy fair-hearing) and Round 3 (Cula remedy)
8. After Round 3 remedy fires: `court_won_procedural_reset = true`; transition to office_street

**Deliverables:**

1. New script: `scripts/systems/court/court_orchestrator.gd` — drives `casebook_judge_state` through the round sequence; listens to `signals.dialogue_dismissed` and advances on appropriate dismiss events
2. New dialogue files (V1.6 voice-reference content not yet in playable form):
   - `data/dialogues/landlord_counsel_ch1.json` — single state with the canonical response line *"Your Honour. The respondent submits that the notice was accepted by an adult occupant at the address used for service. Service was therefore effective."* (committed at V1.6 pass 5)
   - `data/dialogues/crab_court_ch1.json` (or extend `crab.json`) — Round 1 three stance variants (sympathetic / blunt_procedural / technical)
   - `data/dialogues/whimsy_court_ch1.json` (or extend `whimsy.json`) — Round 2 single argument (third-clause non-cure preemption)
   - `data/dialogues/cula_court_ch1.json` (or extend `cula.json`) — Round 1 brief tenders (one per stance) + Round 3 three stance variants of the remedy ask
3. UI for player commits at each round transition: a "Mr. Crab will present the service-and-knowledge submission" → click-to-advance prompt, or auto-advance based on state. Probably auto-advance is cleaner; the player doesn't make tactical choices in the court rounds (the stance was committed at Beat 7); the rounds play out

**Dependencies:** A.1, B.3 (stance committed must persist), C.2.

**Risks:**

- This is the most complex engine work in the plan. Court orchestration is a state machine with branching on `client_meeting_stance` and progression on dialogue dismissal. Test each stance variant
- Authoring extension dialogue files for Crab, Whimsy, Cula is moderate work — the lines are committed in V1.6 pass 5 voice references; transcription is mechanical but error-prone (apostrophe drift watch). Use the V1.7 commit prompt convention: read pass 5; preserve verbatim
- The "auto-advance vs player-clicks-through" UX decision is real. Auto-advance feels cinematic; player-clicks-through feels like an RPG turn. Pick one and commit

### C.4 — Court close + transition to office_street

After Round 3 remedy fires:

- Brief stage-direction beat: judge exits, court rises (could be staged as a black-screen pause)
- Transition back to office_street
- `court_won_procedural_reset = true` set; this gates Beat 13

**Deliverables:**

1. `court_orchestrator.gd` listens for `casebook_judge_state == 'round_3_remedy'` dismiss; sets `court_won_procedural_reset = true` and triggers room transition to office_street
2. Optional: black-screen "Later that afternoon" beat between court and office (matches the V1.6 pack §A.6 closing transition)

**Dependencies:** C.3.

**Risks:** transition timing — make sure the remedy dialogue fully dismisses before the room transition, or the player misses the judge's final reading

---

## Phase D — Beat 13-14 office payoff

**Goal:** wire the V1.7 office payoff and the Sapporo postcard close. Author Beat 13 dialogue from V1.7 pass 5; trigger Beat 14 from the postcard arrival.

**Estimated effort:** 0.5–1 day.

### D.1 — Author `beat13_office_payoff.json` from V1.7 pass 5

The 14 lines from V1.7 pass 5 (Pig celebration; Murrow ledger update + post-update line; Crab observation; Whimsy musical proposal; Cula fragments; Pig exit) are committed only to `dialogue_samples_*.jsonl` voice references. They need a playable JSON.

Schema-match `judge_district_ch1.json` — a single dialogue file with sequenced states. Each state fires on a progression flag set by the previous state's dismiss. The flag chain mirrors the postcard chain (D.2):

- `beat13_team_returns` (entry trigger; gated by `court_won_procedural_reset == true && entered_court == true`)
- `beat13_pig_threshold` ("You are back. Good. Good.")
- `beat13_pig_celebration` (the H4 firm-first / client-second / return-to-anxiety paragraph)
- `beat13_pig_retainer_aside` (the missing-Swine-retainer aside)
- `beat13_asia_congratulation` (warm-while-sorting)
- `beat13_crab_observation` (renumbering as ground)
- `beat13_whimsy_musical` (chamber operetta)
- `beat13_murrow_ledger` (stage direction; visual; no dialogue)
- `beat13_murrow_post_update` ("Cula. The Borowski file is on your desk for tomorrow.")
- `beat13_cula_murrow_ack` ("Mr. Murrow.")
- `beat13_pig_exit` ("Yes. Yes, the next thing.")
- `beat13_complete = true` on dismiss of the final state

**Deliverables:**

1. `data/dialogues/beat13_office_payoff.json` with 11 sequenced states + the Cula `Thank you, Asia.` fragment threaded after Asia's congratulation
2. `state.gd` flag list extended for the progression flags (add to A.1's list)

**Dependencies:** A.1, C.4.

**Risks:**

- **Apostrophe drift watch.** The V1.A commit had this issue; the V1.7 Pig celebration text is the most em-dash-load-bearing string in the project. Preserve the canonical em-dashes flanking *"yes, the client"* and the canonical em-dash in *"is still — somewhere"*. Use the same Antigravity commit-prompt convention that worked for V1.7
- The Beat 13 sequence has no player choice — it's a 60-second cinematic sequence on chapter return. Auto-advance is the right pattern here (matches V1.6 court orchestration pattern)

### D.2 — Beat 14 postcard trigger + chapter close

`postcard_swine_ch1.json` already exists with 6 sequenced states. The trigger is `beat13_complete == true` (the state's first state, `asia_address_label`, gates on `court_won_procedural_reset == true && beat13_complete == true`). After D.1 sets `beat13_complete = true`, the postcard sequence fires automatically.

**Deliverables:**

1. Verify the postcard sequence fires after Beat 13 completes
2. Verify `chapter_close` `on_dismiss` fires `award_badge: day_one_survivor` + three `unlock_route` actions + `chapter1.complete = true`
3. Verify Phase A.4 stub UI displays the badge and the route unlocks (or, if A.4 was deferred, the chapter completes silently — acceptable for first playthrough)

**Dependencies:** A.1, A.2, D.1.

**Risks:**

- The postcard's 6-state progression chain (`postcard_asia_announced` → … → `whimsy_postcard_deflection_shown`) requires each state's `on_dismiss` to set the next gate flag. **Verify the existing `postcard_swine_ch1.json` has the right `on_dismiss` chain.** Spot-check: state `asia_address_label` should `set chapter1.postcard_asia_announced = true`; state `pig_readaloud_cue` should `set chapter1.postcard_readaloud_cue_shown = true`; etc. If any of those `set` actions are missing, the chain breaks. **This is a real risk** — the file was authored before A.1 added the flags; the on_dismiss chain may not be present
- Cross-check with the actual file before declaring D.2 done

---

## Phase E — Verification

**Goal:** confirm chapter 1 plays end-to-end across all three stance branches. Catch save/load regressions. Run the voice audit one final time.

**Estimated effort:** 0.5 day.

### E.1 — End-to-end playthrough × 3 stances

Play chapter 1 from new-game start through Day-One Survivor badge × 3 (sympathetic / blunt-procedural / technical). For each:

- Beat 2 Pig crisis fires
- Beat 3 Murrow briefing
- Beat 4 first-name invitation
- Beat 5 Crab recruitment (test both pre-binder and binder-in-hand variants)
- Beat 6/7 Whimsy at Café Paragraf
- Beat 7-close stance pick fires; correct stance variant of Beat 8 plays
- Beat 8 Halina meeting completes; correct bonus evidence flag set
- Beat 10 readiness check completes
- Beat 11 transition to court (Option 1 cut or Option 2 walk)
- Beat 12 Round 1 — correct stance variant of Crab argument; correct judge stance reaction
- Beat 12 Round 2 — Whimsy third-clause argument; judge metaphor-noted reaction
- Beat 12 Round 3 — correct stance variant of Cula remedy ask; correct judge remedy announcement (technical includes the "underlying tenancy not before the court" one-clause)
- Beat 13 office return celebration plays
- Beat 14 postcard reads aloud
- Day-One Survivor badge awarded; routes unlocked

**Deliverables:** verified playthrough, screenshots of Beat 14 close × 3.

### E.2 — Save/load verification

Save mid-Beat-8, mid-Beat-12, mid-Beat-13. Reload. Verify:

- Stance flag persists
- Bonus-evidence flag persists
- Court state machine resumes correctly (mid-Beat-12 save is the highest-risk case)
- Beat 13 progression flags resume correctly

**Deliverables:** save-load test passing across all three save points × three stances.

### E.3 — Voice audit final pass

Run `tools/voice_audit.py` against the full repo. Resolve any new flags. The remaining V1.3 Asia `Mr. Cula` legacy and the V1.A POSSIBLE_FIRST_MEETING informationals are pre-existing and out of scope.

**Deliverables:** clean audit (modulo pre-existing flags).

---

## Sequencing summary

| Phase | Deliverable | Effort | Blocks |
| --- | --- | --- | --- |
| A.1 | state.gd flag extension + save migration | 2h | everything |
| A.2 | DialogueRunner award_badge + unlock_route actions | 1h | D.2 chapter close |
| A.3 | Asia hint NPC dispatch resolved | 2h | none (cosmetic but should ship) |
| A.4 | (Optional) badge popup UI | 2h | nothing critical |
| B.1 | Beat 7 stance-pick UI | 2h | B.3 |
| B.2 | Halina NPC + meeting-room area | 4h | B.3 |
| B.3 | Beat 8 trigger pipeline + verification | 2h | C.3 (stance flag persistence) |
| C.1 | Beat 11 walk (Option 1 cut) | 1h | C.2 |
| C.2 | district_court.tscn scene | 4–6h | C.3 |
| C.3 | Court orchestration system + dialogue files | 6–8h | C.4 |
| C.4 | Court close + transition | 1h | D.1 |
| D.1 | beat13_office_payoff.json | 3h | D.2 |
| D.2 | Postcard trigger verification + chapter close | 1h | E.1 |
| E.1 | End-to-end playthrough × 3 stances | 3h | ship |
| E.2 | Save/load verification | 1h | ship |
| E.3 | Voice audit final pass | 0.5h | ship |

**Critical path:** A.1 → C.3 (8 hours) → C.4 → D.1 → D.2 → E.1.

**Parallelisable:** A.2, A.3, A.4, B.1, B.2 can all happen during C.3's longer build.

**Total effort:** 33–40 hours depending on Beat 11 walk option, badge UI scope, and court orchestration complexity. Realistic 4-day sprint with one developer; 2-day sprint with two developers paralleling the engine work and the dialogue-file authoring.

---

## Risks and decisions to record before starting

1. **Beat 11 walk** — Option 1 (cut) vs Option 2 (walk scene). Recommendation Option 1 for first ship.
2. **Halina sub-area** — Option 2a (sub-area in pig_swine_office.tscn) vs Option 2b (separate meeting-room scene). Recommendation 2a unless visual believability fails.
3. **Asia hint dispatch** — Option 1 (replace asia_hints.json with V1.A) vs Option 2 (re-author V1.A as tone triplets). Recommendation Option 1.
4. **Court round UX** — auto-advance vs player-clicks-through. Recommendation auto-advance (matches Beat 13 pattern).
5. **Badge popup UI** — Phase A.4 shipped or deferred. Recommendation: ship with stub UI (2h cap); polish later.
6. **Sprite art for Halina, judge, landlord-counsel** — placeholder rectangles acceptable for first playthrough; flag for art pass.
7. **Court orchestration: extend existing dialogue files vs new files** — recommendation new files (`crab_court_ch1.json`, `whimsy_court_ch1.json`, `cula_court_ch1.json`, `landlord_counsel_ch1.json`) to keep chapter-1 office content separate from court content. Alternative: extend with new states. Either works; new files are cleaner for chapter-vertical grep.

Record decisions in commit messages before starting each phase. Update this plan with decision-log notes if the implementation diverges from the recommendations.

---

## What's NOT in this plan

- **Beat 9 archive research with Murrow.** No V1-pack draft exists yet; needs a V1.B or V1.C pack first. Currently chapter 1 plays without it (the binder is collected from the archive but Murrow doesn't narrate Article 135-bis there). Acceptable for first ship; flag as Tier 3.
- **Cardiologist plant Ch4 wiring.** Flag is set in chapter 1 (`cardiologist_plant_landed`); consumed in chapter-4 corridor sighting. Out of scope for this plan; Ch4 implementation will reference it.
- **V2.x chapter 2 work.** Starts after chapter 1 ships per the manifest's recommended order.
- **`chapter1.json` `steps` array** population. Tier 3 polish.
- **Tone-variant authoring for Asia hints (Option 2 of A.3).** Deferred polish.
- **Walk-scene polish (Option 2 of C.1).** Deferred polish.
- **Sprite art for new NPCs.** Deferred art pass.

---

## End of plan

When implementation begins, work the phases in order. Phase A is the foundation; nothing else can land cleanly without it. After Phase E completes and chapter 1 plays end-to-end, the next item is the cumulative chapter-1 audit (option 3 of the prior list — read V1.1 through V1.7 + V1.A in sequence to confirm the chapter as a whole reads as one shippable unit), then V2.1 begins chapter 2.
