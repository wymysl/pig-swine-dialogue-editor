extends Node
## State autoload — single writer. Owns all persistent game state and save/load.
## Migration required for every shape change (see AGENTS.md §Save migration policy).

const SAVE_VERSION: int = 21

const TILE_SIZE := 64
const CHAR_HEIGHT := 64
const VIEWPORT_SIZE := Vector2i(1280, 720)

## data — the live persistent game state. Updated by systems; read by UI and actors.
var data: Dictionary = {}

## session_sprint_toggled — transient sprint-toggle state.
## Persists across scene transitions but NOT across save/load (deliberately session-only).
var session_sprint_toggled: bool = false

func _ready() -> void:
	data = reset_state()

## reset_state — returns the canonical empty-state Dictionary.
## Every key must have an explicit default; never rely on null.
## New fields added: current_scene_path, current_spawn_id (room_transition system).
## Sprint 3: chapter1 NPC interaction flags added.
## Phase 7: met_asia, viewed_family_photo added (see asia.json, cula.json).
## Phase 8: met_asia_via_behind added — set when player crosses behind Asia's
##          counter before pressing E; gates the apology+recognition first-
##          meeting variant in asia.json.
## Chapter 1 Phase A (SAVE_VERSION 8): full Beat 7-14 flag set, badges,
##          routes_unlocked. See CONVENTIONS.md §Chapter 1 state schema for
##          semantic owners and value enumerations.
## Coffee Brewing (SAVE_VERSION 9): chapter1.coffee_buff, chapter1.coffee_brew_grade,
##          and top-level coffee{} dict for cross-chapter coffee state.
## Coffee Accessibility (SAVE_VERSION 10): settings.coffee_accessibility stores
##          mini-game assist toggles.
## Halina Trust Meter (SAVE_VERSION 11): chapter1.halina_trust (int), halina_r0_done,
##          halina_r1_choice, halina_r1_done, halina_r2_choice, halina_r2_done,
##          halina_close_done, landlord_tip_received — drive the Beat 8 trust-
##          tiered client meeting (see halina.json Session 29 restructure).
## Dialogue once-states (SAVE_VERSION 12): top-level dialogue_states_seen — an
##          Array[String] of state ids that have fired once already. Populated
##          by dialogue_runner when a state declares "once": true. Subsequent
##          matches against those state ids are skipped, and the runner falls
##          through to the next-matching state. NPC-agnostic; ids must be
##          unique across all dialogue files for the skip to behave correctly.
## Dangling-flag declarations (SAVE_VERSION 13): two pre-existing bug fixes.
##          chapter1.won_court (bool, default false): referenced by
##          asia_hint_states_ch1.json states 10/11 ("hint_won_court",
##          "hint_received_swine_postcard") but never declared, so the
##          bare-truthiness clause `!chapter1.won_court` resolved to null in
##          the runner and those states could never match. Owner: future
##          court orchestration; set true on Chapter 1 court win. Sits
##          alongside the existing court_outcome (string) and
##          court_won_procedural_reset (bool) — won_court is the simpler
##          gate for hint-state truthiness checks.
##          chapter1.coffee_retry_decision (string, default ""): referenced
##          by barista.json coffee_retry_prompt options write_path
##          ("retry"/"accept"); _set_state_value silently no-opped because
##          the slot did not exist. Owner: future coffee_brewing.gd retry
##          plumbing (PROPOSAL_coffee_engine_followups.md §1). The
##          acknowledgement-flag system that makes the retry prompt reachable
##          is still pending; v13 only removes the silent write-no-op floor.
## State-id namespacing (SAVE_VERSION 14): seven dialogue state ids that
##          collided across files were renamed with their owning npc as a
##          prefix so that `once: true` (which keys on a flat global
##          dialogue_states_seen Array) cannot ghost-skip a same-named state
##          in another file. Save migration scrubs any legacy collider ids
##          from dialogue_states_seen on load. No content currently sets
##          once:true, so real saves will have empty arrays — the scrub is
##          defensive coverage for early-adopter once-states authored before
##          v14 landed. Rename map and rationale: see godot/PROPOSALS.md /
##          godot/data/dialogues/_schema.md §Validation.
## Player-driven argument scaffolding (SAVE_VERSION 17): seven new chapter1
##          flags supporting the synthesis pivot specified in
##          PROPOSAL_player_driven_argument.md §3. Three read-state flags
##          (binder_read_envelope, binder_read_renewal, binder_read_renumbering)
##          track what evidence Cula has actually surfaced from the procedural
##          binder; gated by the dialogue/binder-UI surface, consumed by the
##          synthesis dialogue and Asia's hint surface. Two synthesis-output
##          flags (proposed_frame, whimsy_co_counsel_posture) carry what
##          argument shape Cula committed to in the Crab/Whimsy dialogues into
##          the eventual court round. Two §10 resource counters
##          (judicial_patience, witness_cooperation) are pre-declared so
##          dialogue/court systems can read/write them cleanly once the
##          battle controller is restored.
## Motion-packet foundation (SAVE_VERSION 18): explicit chapter1 booleans for
##          surfaced evidence (the deferred surfaced_* set plus
##          surfaced_resident_no_authority) and packet-slot selection
##          (element_* and decoy_*). This keeps packet assembly, frame/blunder
##          proposal, and court readiness state explicit in save data.
## Packet assembly persistence (SAVE_VERSION 19): four explicit evidence-slot
##          strings + one requested-remedy string for the in-game motion packet
##          UI. This keeps the player's assembled packet visible and stable
##          across save/load before court.
## Blue Folder foundation (SAVE_VERSION 20): chapter1.has_case_folder,
##          top-level case_folder{}, inventory{}, and active_case_id.
func reset_state() -> Dictionary:
	return {
		## room_transition.gd: which scene is currently loaded.
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		## room_transition.gd: which spawn point the player last entered through.
		"current_spawn_id": "default",
		## Current case key used by cross-case UI surfaces. Empty string means
		## no motion packet is active.
		"active_case_id": "",
		## Chapter 1 NPC encounter, beat-progression, and item flags.
		"chapter1": {
			## Phase 7 / sprint 3 baseline flags.
			"met_pig": false,
			"pig_revealed_crisis": false,
			"met_murrow": false,
			"met_crab": false,
			"met_whimsy": false,
			## Blue Folder pickup gate. Owner: blue_folder_pickup.gd.
			"has_case_folder": false,
			"has_law_binder": false,
			"has_rights_memo": false,
			"recruited_crab": false,
			"recruited_whimsy": false,
			"coffee_tutorial_seen": false,
			## Coffee result strings; set by coffee_brewing.gd on exit.
			"coffee_buff": "",
			"coffee_brew_grade": "",
			"court_ready": false,
			"entered_court": false,
			## Court packet result enum: strong / standard / narrow /
			## blunder-recovered. The procedural reset remains the Chapter 1
			## floor; this string records quality, not pass/fail progression.
			"court_outcome": "",
			"met_asia": false,
			"met_asia_via_behind": false,
			"viewed_family_photo": false,
			## Chapter 1 Phase A additions — Beat 7-8 client meeting.
			"halina_met": false,
			"halina_arrived": false,
			"client_meeting_stance": "",
			"bonus_evidence_collected": "",
			"cardiologist_plant_landed": false,
			"client_fee_agreed": false,
			## Halina trust meter (SAVE_VERSION 11). halina_trust accumulates from
			## trust_delta values on each options.choices entry during the meeting.
			## halina_rN_choice guards re-fire during chain; halina_rN_done gates the
			## next round. landlord_tip_received gates the post-close reveal state.
			"halina_trust": 0,
			"halina_r0_done": false,
			"halina_r1_choice": "",
			"halina_r1_done": false,
			"halina_r2_choice": "",
			"halina_r2_done": false,
			"halina_close_done": false,
			"landlord_tip_received": false,
			## Beat 9 archive research.
			"archive_research_complete": false,
			## Beat 12 court rounds (string enum; see judge_district_ch1.json).
			"casebook_judge_state": "",
			"court_won_procedural_reset": false,
			## Set true when the player wins the Chapter 1 court hearing.
			## Referenced by asia_hint_states_ch1.json hint_won_court /
			## hint_received_swine_postcard. Owner: future court orchestration.
			"won_court": false,
			## Player's choice in barista.json coffee_retry_prompt options
			## ("retry" / "accept"). Owner: future coffee_brewing.gd retry
			## plumbing. The acknowledgement-flag system needed to make the
			## prompt actually reachable is pending — see
			## PROPOSAL_coffee_engine_followups.md §1.
			"coffee_retry_decision": "",
			## Beat 13-14 payoff + postcard.
			"beat13_complete": false,
			"received_swine_postcard": false,
			"postcard_asia_announced": false,
			"postcard_readaloud_cue_shown": false,
			"postcard_body_read": false,
			"pig_postcard_reaction_shown": false,
			## Added 2026-05-19 per critique F4 partial: gates Cula's stinger
			## reaction to the postcard body. See postcard_swine_ch1.json
			## ::cula_postcard_reaction. Inlines orphaned cula.json
			## ::cula_b14_postcard_reaction.
			"cula_postcard_reaction_shown": false,
			"whimsy_postcard_deflection_shown": false,
			## Chapter-close gate.
			"complete": false,
			"state_choice": "",
			"murrow_choice": "",
			## Player-driven argument scaffolding (SAVE_VERSION 17).
			## binder_read_* — set true when the corresponding evidence card has
			## been surfaced (via dialogue read-line or binder UI). Required
			## for proposing the matching argument frame in the Crab synthesis
			## dialogue. Owners: dialogue runner (via on_dismiss set actions
			## in crab.json / murrow.json) and the v2 binder UI.
			"binder_read_envelope": false,
			"binder_read_renewal": false,
			"binder_read_renumbering": false,
			## Explicit surfaced-evidence booleans (SAVE_VERSION 18).
			"surfaced_payment_receipts": false,
			"surfaced_notice_timeline": false,
			"surfaced_tenancy_act_window": false,
			"surfaced_property_transfer": false,
			"surfaced_sikorska_age": false,
			"surfaced_resident_no_authority": false,
			## Motion-packet selected slots (SAVE_VERSION 18).
			"element_non_current_address": false,
			"element_landlord_knowledge": false,
			"element_timely_actual_notice_motion": false,
			"element_no_third_party_cure": false,
			## Explicit selected evidence ids for each required packet slot
			## (SAVE_VERSION 19). Empty string means unassigned.
			"packet_slot_address_non_current": "",
			"packet_slot_landlord_knowledge": "",
			"packet_slot_actual_notice_window": "",
			"packet_slot_no_third_party_authority": "",
			## Requested remedy selected in the packet UI. Canonical values:
			## procedural_reset / merits_dismissal / tenancy_ruling /
			## dismissal_with_prejudice.
			"packet_requested_remedy": "procedural_reset",
			"decoy_merits": false,
			"decoy_notice_period": false,
			"decoy_standing_wrong_party": false,
			"decoy_overbroad_remedy": false,
			"decoy_incapacity": false,
			## proposed_frame — string enum. Shared frame/blunder selector set
			## by synthesis dialogue. Consumed by court-round orchestration.
			## Enum values declared in data/argument_frames_ch1.json:
			## "" / "defective_service_135bis" / "substantive_defense" /
			## "notice_period_failure" / "standing_wrong_party" /
			## "overbroad_remedy" / "incapacity_defense".
			"proposed_frame": "",
			## whimsy_co_counsel_posture — string enum. The rhetorical posture
			## Whimsy adopted when recruited. Affects Phase 2 closing-argument
			## flavor lines. Enum: "" / "procedural_throat" / "merits_pivot"
			## / "open_register". Owner: whimsy.json before_meeting options.
			"whimsy_co_counsel_posture": "",
			## judicial_patience — PROPOSALS.md §10 Phase 2 resource. Judge's
			## willingness to accept further argument. Default 5; Phase 2
			## controller decrements on wrong citations. Owner: future
			## battle_controller.gd Phase 2 sub-controller.
			"judicial_patience": 5,
			## witness_cooperation — PROPOSALS.md §10 Phase 1 resource.
			## Per-witness cooperation budget. Default 0 (per-witness
			## initialisation happens at Phase 1 start). Owner: future
			## battle_controller.gd Phase 1 sub-controller.
			"witness_cooperation": 0,
		},
		## Badges awarded across the game. Keys declared at reset; value is
		## flipped true by DialogueRunner award_badge actions. Unknown keys
		## are rejected with a warning (see dialogue_runner.gd).
		"badges": {
			"day_one_survivor": false,
		},
		## Routes unlocked for free-roam. Keys declared at reset; value is
		## flipped true by DialogueRunner unlock_route actions. Unknown keys
		## are rejected with a warning (see dialogue_runner.gd).
		"routes_unlocked": {
			"residential": false,
			"business_district": false,
			"court_plaza": false,
		},
		## Inventory item ids currently held by the player. Values are true for
		## quick membership checks; item display data still lives in items.json.
		"inventory": {},
		## Persistent Blue Folder data. Argument fragments are dialogue-driven;
		## notes_seen maps fragment_id -> true after the player opens a note.
		"case_folder": {
			"argument_fragments": [],
			"notes_seen": {},
		},
		## Cross-chapter coffee state. Persists across replays; updated by
		## coffee_brewing.gd on exit. Keys mirror minigames.txt §Game state.
		"coffee": {
			"tutorial_seen": false,
			"last_result": "",
			"last_grade": "",
			"last_buff": "",
			"assist_used": false,
			"times_brewed": 0,
			"best_grade": "",
		},
		## Player settings. Coffee accessibility is intentionally scoped to the
		## coffee mini-game pause panel for v1.
		"settings": {
			"coffee_accessibility": {
				"slower_notes": false,
				"wider_timing": false,
				"single_button": false,
			},
		},
		## Dialogue state ids that have fired once. Populated by dialogue_runner
		## when a state declares "once": true. Stored as Array[String] (no
		## per-NPC scoping; state ids must be unique across all dialogue files
		## for the skip to be reliable).
		"dialogue_states_seen": [],
	}

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var current_mode = DisplayServer.window_get_mode()
		if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN or current_mode == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
