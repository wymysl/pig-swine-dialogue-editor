# Chapter 1 — Phase B prompt (B.1 + B.2 + B.3)

Beat 7 stance-pick UI + Halina NPC + meeting-room area + Beat 8 trigger pipeline. Single Antigravity prompt covering all three sub-prompts in dependency order. A.4 (badge popup UI) is deferred to polish pass per current ordering.

**Copy from the line below into Antigravity.**

---

## Prompt: Chapter 1 Phase B — Beat 7-8 client meeting wiring

**Model: Claude Opus 4.6** (multi-file trigger pipeline coordination across Asia, Halina NPC, meeting-room area, stance UI, and the halina.json three-stance dispatch — load-bearing chapter narrative work).

**Source plan.** `narrative_revision/phase_7_audits/chapter_1_tier1_implementation_plan.md` Phase B, sub-prompts B.1, B.2, B.3. Read that section first; it is authoritative. Phase A (state extension + dialogue runner extension + Asia hint dispatch) is complete — every flag this prompt references already exists in `State.data.chapter1`.

**Goal.** Wire Beat 7 → Beat 8 of chapter 1 end-to-end. Three deliverables in dependency order:

1. **B.1 — Beat 7 stance-pick UI.** Three-button prompt that writes `State.data.chapter1.client_meeting_stance` to one of `sympathetic` / `blunt_procedural` / `technical`. Fires when Cula enters the meeting-room area.
2. **B.2 — Halina NPC + meeting-room area.** Halina exists as an NPC instance in `pig_swine_office.tscn` using her existing sprite assets. The meeting-room becomes a navigable sub-area of the office, with an entry trigger that gates on `recruited_whimsy && halina_arrived && !halina_met` and fires the stance-pick UI before allowing entry.
3. **B.3 — Beat 8 trigger pipeline.** Asia delivers a one-shot announcement when Cula returns to the office post-Whimsy-recruitment. Full sequence plays: Asia line → Cula approaches meeting-room → stance UI → stance committed → meeting-room unlocks → Cula enters → `halina.json` `client_meeting_<stance>` fires → on dismiss, flags write correctly.

**Stale note in the plan to ignore.** Plan §B.2 says "Halina sprite is missing — placeholder rectangle acceptable." That's outdated — written before the 2026-05-11 sprite regen. Halina's 8-direction idles exist at `godot/art/sprites/halina/halina_idle_*.png` and her `halina_sprite_frames.tres` was generated. Use her existing assets via `npc_walking_canon.tscn` template. Do NOT create placeholder rectangles.

### Required reading

- `narrative_revision/phase_7_audits/chapter_1_tier1_implementation_plan.md` (Phase B section, lines 132–207)
- `narrative_revision/bibles/halina_sikorska.md` (full bible — drives her NPC behaviour and the interview-tone register on each stance branch)
- `narrative_revision/phase_7_packs/V1.4_halina_meeting_research.md` (the V1.4 pack — stance carrier descriptions for B.1 button wording)
- `_legacy/design/design_bible.md` § 3.1 (Cula voice; the stance buttons should read in Cula's register)
- `godot/scenes/interiors/pig_swine_office.tscn` (the new TileMap-based office; specifically the `MeetingFloor` zone and `MeetingDivider` if present)
- `godot/scenes/ui/` directory listing — check whether `court_stance_menu.tscn` exists for Beat 12 reuse. If it does, study it as a template; build `client_stance_menu.tscn` as a sibling, not a copy.
- `godot/data/dialogues/halina.json` (the three Beat 8 stance flows; do NOT modify — read for the `on_dismiss` flag writes and the first-line "Mrs. Sikorska is here" content)
- `godot/data/dialogues/asia_hint_states_ch1.json` (V1.A — Asia hint surface; the announcement may live here as a new state or be a standalone one-shot)
- `godot/scripts/actors/asia.gd` (Asia's behaviour — exempt from the chapter1_flag_changed presence system, but needs the announcement hook)
- `godot/scripts/actors/npc.gd` (base NPC class with `presence_flags` from Phase A predecessor work)
- `godot/scripts/components/npc_walking_canon.tscn` (template Halina should use)
- `godot/scripts/autoload/dialogue_runner.gd` (how to invoke a dialogue from a trigger)
- `godot/scripts/autoload/state.gd` (the new chapter1 flags from Phase A; specifically `client_meeting_stance`, `halina_arrived`, `halina_met`, `client_fee_agreed`, `bonus_evidence_collected`, `cardiologist_plant_landed`)
- `godot/scripts/autoload/signals.gd` (the `chapter1_flag_changed` signal from Phase A predecessor work)
- `godot/CONVENTIONS.md` (canonical numbers, scene-structure conventions)

### B.1 — Beat 7 stance-pick UI

Build a 3-button UI prompt that captures Cula's interview tone. The choice writes `State.data.chapter1.client_meeting_stance`.

**Button wording** (per V1.4 pack §B.1 stance-aligned interview tones, rendered in Cula's register from his bible):

- **Lead with how she's holding up** (sets stance = `sympathetic`)
- **Lead with the timeline** (sets stance = `blunt_procedural`)
- **Lead with the lease history** (sets stance = `technical`)

The buttons read as personality choices, not mechanical labels. Do NOT label them "Sympathetic / Blunt-procedural / Technical" — those are internal taxonomy, not button text.

**Deliverables:**

1. `godot/scenes/ui/client_stance_menu.tscn` — a modal `Control` node with three large buttons stacked vertically. Style consistent with existing `dialogue_box.tscn`. Background dims the scene behind it.
2. `godot/scripts/ui/client_stance_menu.gd` — script that:
   - Exposes a `stance_picked(stance: String)` signal.
   - On button press, sets `State.data.chapter1.client_meeting_stance = <stance>`, emits `Signals.chapter1_flag_changed("client_meeting_stance", <stance>)`, emits `stance_picked`, and queue_frees itself.
3. If `court_stance_menu.tscn` exists for Beat 12, the two should share a base scene `stance_menu_base.tscn` or a common script — extract whatever's common. If `court_stance_menu.tscn` does NOT exist yet, just build `client_stance_menu.tscn` standalone for now; the Beat 12 menu is Phase C.

**Acceptance:** instantiating the scene, clicking each button, and confirming `State.data.chapter1.client_meeting_stance` is correctly written. Test in `test_chapter1_phase_b.gd`.

### B.2 — Halina NPC + meeting-room area

The office scene already has a `MeetingFloor` zone marked in its `FloorZones` group. Repurpose this area as the navigable meeting-room sub-area.

**Halina NPC instance.**

- Add a new `Halina` node under the `pig_swine_office.tscn` root, instanced from `npc_walking_canon.tscn`. Wire her `SpriteFrames` to `res://art/sprites/halina/halina_sprite_frames.tres`.
- Set her `npc_id = "halina"`, `presence_flags = ["halina_arrived"]`, `presence_logic = "all"` (so she appears only after Beat 7 close sets `halina_arrived`, and disappears after `halina_met` if you want — but presence is positive-flag-only, so dismissal of her node is by visibility toggle when `halina_met` flips, which a different presence rule covers — keep it simple: `presence_flags = ["halina_arrived"]`, accept she stays visible after meeting unless you add separate dismissal logic).
- Position her standing at the meeting-room table in `MeetingFloor`. Use the bible's posture spec: upright, controlled, slight age-stiffness. Initial facing: `front` (toward where Cula enters).
- Y-sort offset: per the alpha-scan rule from CONVENTIONS — let `npc_walking_canon.tscn` handle this.

**Meeting-room entry trigger.**

- Add an `Area2D` named `MeetingRoomEntryTrigger` at the threshold to `MeetingFloor` (one tile inside the meeting-room boundary, spanning the doorway width).
- On `body_entered`, check: `State.data.chapter1.recruited_whimsy && State.data.chapter1.halina_arrived && !State.data.chapter1.halina_met`.
  - If the gating passes AND `client_meeting_stance == ""`: pause the player, instantiate `client_stance_menu.tscn` as a child of the canvas layer. On stance-pick: dispatch `halina.json` with the corresponding `client_meeting_<stance>` state.
  - If `client_meeting_stance != ""` AND `!halina_met`: dispatch the Halina dialogue directly without re-showing the stance menu (handles re-entry between stance commit and meeting completion).
  - If `halina_met`: do nothing (allow free movement).

**Meeting-room invisible boundary.**

- Add a `StaticBody2D` + `CollisionShape2D` that blocks the player from entering `MeetingFloor` UNTIL `client_meeting_stance != ""`. Disable the collision once the stance is committed. This enforces the "stance must be picked before entering" flow.

**Deliverables:**

1. `Halina` node in `pig_swine_office.tscn` with proper sprite/script/`presence_flags`.
2. `MeetingRoomEntryTrigger` Area2D in `pig_swine_office.tscn`.
3. `MeetingRoomBoundary` StaticBody2D + CollisionShape2D, conditionally enabled.
4. Trigger script `scripts/actors/meeting_room_trigger.gd` (new) handling the gating logic above.

### B.3 — Beat 8 trigger pipeline + Asia announcement

Asia delivers a one-shot announcement when Cula returns to the office after Beat 7 closes (i.e., when `recruited_whimsy = true` becomes true AND the player is in `pig_swine_office`). The line is the first line of `halina.json` `client_meeting_*`, repositioned as a pre-meeting cue:

*"Mrs. Sikorska is here. I've shown her into the meeting room."*

**Implementation options for the Asia announcement:**

- **Option A (recommended):** Add a new state to `asia_hint_states_ch1.json` that triggers on `recruited_whimsy && !halina_arrived` and contains this single line. After the line fires, set `halina_arrived = true` (via `on_dismiss`). This integrates cleanly with the V1.A hint dispatch system from Phase A.
- **Option B:** Hook into `asia.gd` directly with a one-shot announcement method that fires on `chapter1_flag_changed("recruited_whimsy", true)`. More custom; bypasses the hint system.

Pick Option A unless the V1.A hint system can't accommodate a state with a single line that's not a hover-hint but an active announcement. If Option A doesn't fit, fall back to Option B and document the decision in `CONVENTIONS.md`.

**End-to-end sequence to verify:**

1. Cula recruits Whimsy at Café Paragraf (existing — `recruited_whimsy = true`).
2. Cula returns to `pig_swine_office`.
3. Asia delivers the announcement line. On dismiss, `halina_arrived = true`.
4. Halina appears in the meeting room (her `presence_flags` resolve).
5. Cula approaches the meeting-room entry trigger.
6. `client_stance_menu.tscn` instantiates (since `client_meeting_stance == ""`).
7. Cula commits a stance. `client_meeting_stance` writes. Menu dismisses. Meeting-room collision disables.
8. Cula enters the meeting room. The entry trigger detects the gating now allows dialogue dispatch. `halina.json` `client_meeting_<stance>` fires.
9. On dismiss, the `on_dismiss` block in `halina.json` writes `halina_met = true`, `client_fee_agreed = true`, `bonus_evidence_collected = <stance-mapped value>`, `cardiologist_plant_landed = true`.

**Deliverables:**

1. New Asia hint state in `asia_hint_states_ch1.json` (Option A) OR modification to `asia.gd` (Option B). Pick one. Document decision.
2. End-to-end test in `test_chapter1_phase_b.gd` covering steps 1–9 above with all three stance variants.
3. Save/load test mid-meeting: confirm flags restore correctly after a save during step 8.

### Allowed writes

- `godot/scenes/ui/client_stance_menu.tscn` (new)
- `godot/scripts/ui/client_stance_menu.gd` (new)
- `godot/scenes/ui/stance_menu_base.tscn` and `godot/scripts/ui/stance_menu_base.gd` ONLY IF `court_stance_menu.tscn` already exists; otherwise skip
- `godot/scenes/interiors/pig_swine_office.tscn` (add Halina node, entry trigger, meeting-room boundary)
- `godot/scripts/actors/meeting_room_trigger.gd` (new)
- `godot/scripts/actors/asia.gd` (Option B announcement only — skip if Option A chosen)
- `godot/data/dialogues/asia_hint_states_ch1.json` (Option A announcement only — append one state, do NOT modify existing states)
- `godot/tests/test_chapter1_phase_b.gd` (new)
- `godot/CONVENTIONS.md` (room-layout note about meeting-room sub-area; announcement-option decision)

### Forbidden

- Editing `halina.json` content (read-only).
- Editing any other dialogue JSON content beyond the optional `asia_hint_states_ch1.json` Option-A addition.
- Phase C/D/E work (court rounds, postcard, polish, badge popup).
- Schema changes to `State.data` (Phase A handled all of this).
- Creating Halina sprite art (it already exists — use `halina_sprite_frames.tres`).
- Modifying `casebook.gd` logic.

### Acceptance

- Stance menu shows three buttons with the V1.4-aligned wording above. Each button correctly writes `client_meeting_stance`.
- Halina is visible in `pig_swine_office` ONLY when `halina_arrived = true`. Before that, her node is hidden by the `presence_flags` system.
- Approaching the meeting-room threshold fires the stance menu (if stance not yet picked) or dispatches `halina.json` (if stance picked and meeting not yet held).
- Meeting-room boundary blocks entry until stance is committed.
- Full Beat 7→8 sequence plays cleanly for all three stances (sympathetic, blunt_procedural, technical).
- On dismiss of Halina meeting, all four expected flags write correctly.
- Save/load mid-meeting restores state correctly.
- `test_chapter1_phase_b.gd` enumerates all three stance paths and asserts each plays end-to-end.
- Existing tests still pass.

### Output artifact

- Diffs / new files for: `client_stance_menu.tscn`+`.gd`, `pig_swine_office.tscn` (Halina node + trigger + boundary), `meeting_room_trigger.gd`, `asia.gd` OR `asia_hint_states_ch1.json` (whichever option chosen), `test_chapter1_phase_b.gd`, `CONVENTIONS.md` update.
- A short report (in agent response, not a file) confirming Option A or B for Asia announcement, with one-sentence rationale.

### Follow-ups

- Halina should NOT re-trigger dialogue after `halina_met = true`. The current `presence_flags = ["halina_arrived"]` keeps her visible post-meeting; that's intentional for now (she's still in the room until she leaves at Beat 9 timing). If post-meeting dismissal behaviour is needed before Beat 9, that's a separate small follow-up.
- The meeting-room "small space" risk from the plan: if visual believability of Cula + Crab + Whimsy + Halina + Murrow in the meeting room area fails, that's a layout iteration — not blocking, flag for polish pass.

---

**Notes on running.** Opus 4.6 because Beat 8 is the longest dialogue in chapter 1 (~70 lines × 3 stances) and the trigger pipeline coordinates four nodes (Asia, Halina, entry trigger, boundary) plus a UI scene. The cost difference is worth it for the integration safety.

After the agent runs, walkthrough-verify by playing through Beat 7→8 in-engine. Specifically: start a fresh save → recruit Whimsy → return to office → confirm Asia speaks → approach meeting room → confirm stance menu appears → pick each of the three stances in separate playthroughs → confirm Halina dialogue plays end-to-end → confirm flags write. If all three stances play correctly, Phase B is done and you move to Phase C (court rounds).
