extends Node
## Save — versioned save/load for State.data.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Versioning policy: bump State.SAVE_VERSION whenever State.reset_state()
## shape changes. Add a matching branch in migrate_save().
##
## Version history:
##   1 — initial structure (room_transition keys only)
##   2 — (no shape change; version bumped in sprint 2 for housekeeping)
##   3 — sprint 3: adds chapter1 sub-dictionary
##   4 — adds met_crab, met_whimsy to chapter1
##   5 — adds has_rights_memo to chapter1
##   6 — phase 7: adds met_asia, viewed_family_photo to chapter1
##   7 — phase 8: adds met_asia_via_behind to chapter1
##   8 — chapter 1 phase A: full Beat 7-14 flag set, top-level badges +
##       routes_unlocked dictionaries (see state.gd reset_state())
##   9 — coffee brewing: chapter1.coffee_buff, chapter1.coffee_brew_grade,
##       top-level coffee{} dict for cross-chapter coffee state
##   10 — coffee accessibility settings: settings.coffee_accessibility
##   11 — halina trust meter: chapter1.halina_trust, halina_r0_done,
##         halina_r1_choice, halina_r1_done, halina_r2_choice, halina_r2_done,
##         halina_close_done, landlord_tip_received
##   12 — dialogue once-states: top-level dialogue_states_seen Array
##   13 — dangling-flag declarations: chapter1.won_court (bool) and
##         chapter1.coffee_retry_decision (string). Both were referenced by
##         dialogue JSON (asia_hint_states_ch1.json states 10/11;
##         barista.json coffee_retry_prompt options write_path) without a
##         State slot, so triggers / write_paths silently no-opped. Slot-only
##         fix; writer plumbing pending.
##   14 — state-id namespacing: scrubs legacy collider ids from
##         dialogue_states_seen. Seven state ids (`first_meeting`,
##         `coffee_reaction_perfect`, `coffee_reaction_bad`,
##         `coffee_reaction_perfect_recruited`, `coffee_reaction_bad_recruited`,
##         `coffee_reaction_perfect_pre_recruit`, `coffee_reaction_bad_pre_recruit`)
##         were duplicated across files; v14 renames them with NPC prefixes
##         (e.g. `murrow_first_meeting`, `crab_coffee_reaction_perfect_recruited`)
##         so once:true no longer cross-file-ghosts. No content uses once:true
##         today; the scrub is defensive against any save authored against an
##         early-adopter once-state.
##   15 — chapter1.state_choice string declaration
##   16 — chapter1.murrow_choice string declaration
##   17 — player-driven argument scaffolding:
##         binder_read_*, proposed_frame, whimsy_co_counsel_posture,
##         judicial_patience, witness_cooperation
##   18 — motion-packet foundation:
##         surfaced_* evidence booleans + element_* / decoy_* packet-slot
##         booleans for Chapter 1 synthesis flow
##   19 — packet assembly persistence:
##         packet_slot_* evidence-id strings + packet_requested_remedy
##   20 — Blue Folder foundation:
##         chapter1.has_case_folder, top-level case_folder{}, inventory{},
##         and active_case_id
##   21 — postcard Cula reaction:
##         chapter1.cula_postcard_reaction_shown (bool)
##   22 — rename bonus_evidence_collected → client_meeting_evidence:
##         same string-enum semantics, clearer name
##   23 — Phase 2 citation persistence: chapter1.phase2_round_results (Array)
##   24 — judgment pickup flags: chapter1.picked_up_article_8 +
##         chapter1.picked_up_article_10 (bool)
##   25 — Beat 13 close flags: chapter1.client_fee_collected (bool) +
##         chapter1.pig_court_win_acknowledged (bool). Both default false.
##         The first records Pig's Beat-13 acknowledgement of the 5,000 PLN
##         Sikorska fee; the second is a sequencing flag that lets the
##         coffee_machine_ch1.json env-beat trigger *after* Pig has spoken.
##         Together they unblock promotion of two PENDING drafts that have
##         been waiting for the declaration since 2026-05-14 and 2026-05-17.
##   26 — Murrow rehearsal: chapter1.rehearsal_accepted (bool, edge-trigger),
##         chapter1.rehearsal_complete (bool, persistent), and
##         chapter1.rehearsal_declined (bool, persistent). Design plan
##         2026-05-26 Step 4.1 (Phase 4 verb-teaching rehearsal).
##         rehearsal_complete persists so the offer does not repeat after the
##         player completes the rehearsal. rehearsal_declined persists so the
##         offer does not repeat after the player explicitly skips it.
##   27 — halina_trust rename (Step 5.3, design plan 2026-05-26):
##         chapter1.halina_trust (int) replaced by chapter1.halina_stance
##         (String enum: "high"/"blunt"/"technical"/"") and
##         chapter1.incapacity_penalty (bool). Migration: ≥ 5 → "high",
##         0–4 → "blunt", negative → "blunt" + incapacity_penalty = true.
##         halina_stance is set by Beat 8 r0-response on_dismiss (halina.json).
##         incapacity_penalty is written by battle_controller on incapacity
##         blunder. The old integer never lived in interesting territory; the
##         ≥ 5 threshold was equivalent to picking the sympathetic opener.

const SAVE_PATH: String = "user://save.json"
const STRINGS_PATH: String = "res://data/case_folder_strings.json"

var _save_path: String = SAVE_PATH
## _save_reasons — lazily loaded from case_folder_strings.json::save_reasons.
## Inline literals in _fail_save / _fail_load act as defensive fallbacks if
## the strings file can't be read.
var _save_reasons: Dictionary = {}
var _save_reasons_loaded: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("manual_save_requested"):
		sigs.manual_save_requested.connect(save_game)


func set_save_path_for_tests(path: String) -> void:
	_save_path = path if path != "" else SAVE_PATH


## _state — runtime accessor for the State autoload.
## Using a runtime lookup (rather than the compile-time `State` global)
## lets save.gd be loaded standalone by tests via load(); the compile-time
## identifier `State` isn't visible to scripts loaded that way in --script
## mode. Pattern mirrors dialogue_runner.gd's `_state_data()`.
func _state() -> Node:
	return get_node_or_null("/root/State")


## save_game — serialises State.data to disk with version metadata.
func save_game() -> bool:
	var st: Node = _state()
	if st == null:
		_fail_save(_reason("state_unavailable", "State data is unavailable."))
		return false
	var payload: Dictionary = {
		"version": st.SAVE_VERSION,
		"data": st.data,
	}
	var user_dir: String = ProjectSettings.globalize_path("user://")
	if not DirAccess.dir_exists_absolute(user_dir):
		var dir_err: Error = DirAccess.make_dir_recursive_absolute(user_dir)
		if dir_err != OK:
			_fail_save(_reason("cannot_create_dir", "Cannot create the save directory."))
			return false
	var file := FileAccess.open(_save_path, FileAccess.WRITE)
	if file == null:
		_fail_save(_reason("cannot_open_write", "Cannot open the save file for writing."))
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()
	_emit_save_completed()
	return true


## load_game — reads save file, migrates if needed, applies to State.data.
## Returns true on success, false if file missing or unrecoverable.
func load_game() -> bool:
	if not FileAccess.file_exists(_save_path):
		return false

	var st: Node = _state()
	if st == null:
		_fail_load(_reason("state_unavailable", "State data is unavailable."))
		return false

	var file := FileAccess.open(_save_path, FileAccess.READ)
	if file == null:
		_fail_load(_reason("cannot_open_read", "Cannot open the save file for reading."))
		return false
	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		_fail_load(_reason("corrupt_reset", "The save file is corrupt; progress was reset."))
		st.data = st.reset_state()
		return false

	var version: int = int(parsed.get("version", 1))
	var saved_data: Dictionary = parsed.get("data", {})

	saved_data = migrate_save(saved_data, version)
	st.data = saved_data
	return true


## _reason — lazily load and look up a failure-reason string keyed by
## case_folder_strings.json::save_reasons.<key>. Inline fallbacks ship with
## each call site so a strings-file load failure still produces a readable
## toast.
func _reason(key: String, fallback: String) -> String:
	if not _save_reasons_loaded:
		_load_save_reasons()
	return str(_save_reasons.get(key, fallback))


func _load_save_reasons() -> void:
	_save_reasons_loaded = true
	var file: FileAccess = FileAccess.open(STRINGS_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return
	var reasons: Variant = parsed.get("save_reasons", {})
	if reasons is Dictionary:
		_save_reasons = reasons


func _fail_save(reason: String) -> void:
	push_error("Save: " + reason)
	_emit_save_failed(reason)


func _fail_load(reason: String) -> void:
	push_error("Save: " + reason)
	_emit_save_failed(reason)


func _emit_save_completed() -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("save_completed"):
		sigs.save_completed.emit()


func _emit_save_failed(reason: String) -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("save_failed"):
		sigs.save_failed.emit(reason)


## migrate_save — advances saved_data from old_version to State.SAVE_VERSION.
## Each version step must be idempotent and non-destructive.
func migrate_save(saved_data: Dictionary, old_version: int) -> Dictionary:
	## v1 -> v2: no structural change; nothing to do.
	if old_version < 2:
		pass

	## v2 -> v3: add chapter1 sub-dictionary if missing.
	if old_version < 3:
		if not saved_data.has("chapter1"):
			saved_data["chapter1"] = {
				"met_pig": false,
				"pig_revealed_crisis": false,
				"met_murrow": false,
				"has_law_binder": false,
				"recruited_crab": false,
				"recruited_whimsy": false,
				"coffee_tutorial_seen": false,
				"court_ready": false,
				"entered_court": false,
				"court_outcome": "",
			}

	## v3 -> v4: add met_crab and met_whimsy to chapter1.
	if old_version < 4:
		if saved_data.has("chapter1"):
			if not saved_data["chapter1"].has("met_crab"):
				saved_data["chapter1"]["met_crab"] = false
			if not saved_data["chapter1"].has("met_whimsy"):
				saved_data["chapter1"]["met_whimsy"] = false

	## v4 -> v5: add has_rights_memo to chapter1.
	if old_version < 5:
		if saved_data.has("chapter1"):
			if not saved_data["chapter1"].has("has_rights_memo"):
				saved_data["chapter1"]["has_rights_memo"] = false

	## v5 -> v6: add met_asia and viewed_family_photo to chapter1.
	if old_version < 6:
		if saved_data.has("chapter1"):
			if not saved_data["chapter1"].has("met_asia"):
				saved_data["chapter1"]["met_asia"] = false
			if not saved_data["chapter1"].has("viewed_family_photo"):
				saved_data["chapter1"]["viewed_family_photo"] = false

	## v6 -> v7: add met_asia_via_behind to chapter1.
	if old_version < 7:
		if saved_data.has("chapter1"):
			if not saved_data["chapter1"].has("met_asia_via_behind"):
				saved_data["chapter1"]["met_asia_via_behind"] = false

	## v7 -> v8: chapter 1 Phase A. Add full Beat 7-14 chapter1 flag set,
	## badges, and routes_unlocked dictionaries. Existing chapter1 keys are
	## preserved untouched; only missing keys are added with their defaults.
	if old_version < 8:
		if not saved_data.has("chapter1"):
			saved_data["chapter1"] = {}
		var ch1: Dictionary = saved_data["chapter1"]
		var ch1_v8_defaults: Dictionary = {
			"halina_met": false,
			"halina_arrived": false,
			"client_meeting_stance": "",
			"client_meeting_evidence": "",
			"cardiologist_plant_landed": false,
			"client_fee_agreed": false,
			"archive_research_complete": false,
			"casebook_judge_state": "",
			"court_won_procedural_reset": false,
			"beat13_complete": false,
			"received_swine_postcard": false,
			"postcard_asia_announced": false,
			"postcard_readaloud_cue_shown": false,
			"postcard_body_read": false,
			"pig_postcard_reaction_shown": false,
			"whimsy_postcard_deflection_shown": false,
			"complete": false,
		}
		for key in ch1_v8_defaults:
			if not ch1.has(key):
				ch1[key] = ch1_v8_defaults[key]

		## Top-level badges dictionary; declared keys default false.
		if not saved_data.has("badges"):
			saved_data["badges"] = {}
		if not saved_data["badges"].has("day_one_survivor"):
			saved_data["badges"]["day_one_survivor"] = false

		## Top-level routes_unlocked dictionary; declared keys default false.
		if not saved_data.has("routes_unlocked"):
			saved_data["routes_unlocked"] = {}
		for route_id in ["residential", "business_district", "court_plaza"]:
			if not saved_data["routes_unlocked"].has(route_id):
				saved_data["routes_unlocked"][route_id] = false

	## v8 -> v9: coffee brewing state additions.
	if old_version < 9:
		if not saved_data.has("chapter1"):
			saved_data["chapter1"] = {}
		if not saved_data["chapter1"].has("coffee_buff"):
			saved_data["chapter1"]["coffee_buff"] = ""
		if not saved_data["chapter1"].has("coffee_brew_grade"):
			saved_data["chapter1"]["coffee_brew_grade"] = ""

		if not saved_data.has("coffee"):
			saved_data["coffee"] = {}
		var coffee_defaults: Dictionary = {
			"tutorial_seen": false,
			"last_result": "",
			"last_grade": "",
			"last_buff": "",
			"assist_used": false,
			"times_brewed": 0,
			"best_grade": "",
		}
		for key in coffee_defaults:
			if not saved_data["coffee"].has(key):
				saved_data["coffee"][key] = coffee_defaults[key]

	## v9 -> v10: coffee accessibility settings.
	if old_version < 10:
		if not saved_data.has("settings") or not saved_data["settings"] is Dictionary:
			saved_data["settings"] = {}
		var settings: Dictionary = saved_data["settings"]
		if not settings.has("coffee_accessibility") or not settings["coffee_accessibility"] is Dictionary:
			settings["coffee_accessibility"] = {}
		var coffee_accessibility: Dictionary = settings["coffee_accessibility"]
		var accessibility_defaults: Dictionary = {
			"slower_notes": false,
			"wider_timing": false,
			"single_button": false,
		}
		for key in accessibility_defaults:
			if not coffee_accessibility.has(key):
				coffee_accessibility[key] = accessibility_defaults[key]

	## v10 -> v11: Halina trust meter — eight new chapter1 flags.
	if old_version < 11:
		if not saved_data.has("chapter1"):
			saved_data["chapter1"] = {}
		var ch1_v11: Dictionary = saved_data["chapter1"]
		var v11_defaults: Dictionary = {
			"halina_trust": 0,
			"halina_r0_done": false,
			"halina_r1_choice": "",
			"halina_r1_done": false,
			"halina_r2_choice": "",
			"halina_r2_done": false,
			"halina_close_done": false,
			"landlord_tip_received": false,
		}
		for key in v11_defaults:
			if not ch1_v11.has(key):
				ch1_v11[key] = v11_defaults[key]

	## v11 -> v12: dialogue once-states — top-level Array[String] of state
	## ids that have already fired. Empty for any save predating v12 (no
	## once: true states existed yet, so nothing to backfill).
	if old_version < 12:
		if not saved_data.has("dialogue_states_seen") \
				or not saved_data["dialogue_states_seen"] is Array:
			saved_data["dialogue_states_seen"] = []

	## v12 -> v13: bug fix — declare two flags referenced by dialogue JSON
	## without a State slot. chapter1.won_court (bool, default false) is
	## read by asia_hint_states_ch1.json states 10/11; the bare-truthiness
	## clause `!chapter1.won_court` resolved to null on the missing slot
	## and the runner returned false, so those hint states could never
	## match. chapter1.coffee_retry_decision (string, default "") is the
	## options write_path of barista.json coffee_retry_prompt; the runner
	## silently no-opped on _set_state_value for the missing slot, so the
	## player's choice was never persisted. v13 declares both; writer
	## plumbing (court-orchestration setter, coffee acknowledgement-flag
	## system) is still pending per PROPOSAL_coffee_engine_followups.md §1.
	if old_version < 13:
		if not saved_data.has("chapter1"):
			saved_data["chapter1"] = {}
		var ch1_v13: Dictionary = saved_data["chapter1"]
		if not ch1_v13.has("won_court"):
			ch1_v13["won_court"] = false
		if not ch1_v13.has("coffee_retry_decision"):
			ch1_v13["coffee_retry_decision"] = ""

	## v13 -> v14: scrub legacy colliding state ids from dialogue_states_seen.
	## Seven dialogue state ids that previously collided across files were
	## renamed (`first_meeting` -> `murrow_first_meeting` / `pig_first_meeting`,
	## the three coffee_reaction_* pairs, and the four coffee_reaction_*_recruit
	## pairs). dialogue_states_seen is a flat Array<String>; a legacy collider
	## id in a save could now mean either npc, so the safe migration is to drop
	## it and let the new once-state fire fresh. No committed content uses
	## once:true today, so real saves will have empty arrays — this is
	## defensive against any early-adopter once-state save in flight.
	if old_version < 14:
		if not saved_data.has("dialogue_states_seen") \
				or not saved_data["dialogue_states_seen"] is Array:
			saved_data["dialogue_states_seen"] = []
		var legacy_colliders: Array = [
			"first_meeting",
			"coffee_reaction_perfect",
			"coffee_reaction_bad",
			"coffee_reaction_perfect_recruited",
			"coffee_reaction_bad_recruited",
			"coffee_reaction_perfect_pre_recruit",
			"coffee_reaction_bad_pre_recruit",
		]
		var seen: Array = saved_data["dialogue_states_seen"]
		var kept: Array = []
		for sid in seen:
			if not legacy_colliders.has(str(sid)):
				kept.append(sid)
		saved_data["dialogue_states_seen"] = kept


	## v14 -> v15: auto-added by dialogue editor for chapter1.state_choice.
	if old_version < 15:
		if saved_data.has("chapter1"):
			if not saved_data["chapter1"].has("state_choice"):
				saved_data["chapter1"]["state_choice"] = ""

	## v15 -> v16: auto-added by dialogue editor for chapter1.murrow_choice.
	if old_version < 16:
		if saved_data.has("chapter1"):
			if not saved_data["chapter1"].has("murrow_choice"):
				saved_data["chapter1"]["murrow_choice"] = ""

	## v16 -> v17: Player-driven argument scaffolding per
	## PROPOSAL_player_driven_argument.md §3. Adds three binder_read_* read-
	## state booleans, the proposed_frame and whimsy_co_counsel_posture string
	## enums, and the two PROPOSALS.md §10 resource counters (judicial_patience
	## defaults to 5, witness_cooperation to 0). Idempotent; defaults match
	## State.reset_state().
	if old_version < 17:
		if saved_data.has("chapter1"):
			var ch1: Dictionary = saved_data["chapter1"]
			if not ch1.has("binder_read_envelope"):
				ch1["binder_read_envelope"] = false
			if not ch1.has("binder_read_renewal"):
				ch1["binder_read_renewal"] = false
			if not ch1.has("binder_read_renumbering"):
				ch1["binder_read_renumbering"] = false
			if not ch1.has("proposed_frame"):
				ch1["proposed_frame"] = ""
			if not ch1.has("whimsy_co_counsel_posture"):
				ch1["whimsy_co_counsel_posture"] = ""
			if not ch1.has("judicial_patience"):
				ch1["judicial_patience"] = 5
			if not ch1.has("witness_cooperation"):
				ch1["witness_cooperation"] = 0

	## v17 -> v18: motion-packet foundation. Adds explicit surfaced-evidence
	## booleans (the deferred v2 surfaced_* set plus surfaced_resident_no_authority)
	## and explicit packet-slot booleans (four required elements + five decoys).
	if old_version < 18:
		if saved_data.has("chapter1"):
			var ch1_v18: Dictionary = saved_data["chapter1"]
			var v18_defaults: Dictionary = {
				"surfaced_payment_receipts": false,
				"surfaced_notice_timeline": false,
				"surfaced_tenancy_act_window": false,
				"surfaced_property_transfer": false,
				"surfaced_sikorska_age": false,
				"surfaced_resident_no_authority": false,
				"element_non_current_address": false,
				"element_landlord_knowledge": false,
				"element_timely_actual_notice_motion": false,
				"element_no_third_party_cure": false,
				"decoy_merits": false,
				"decoy_notice_period": false,
				"decoy_standing_wrong_party": false,
				"decoy_overbroad_remedy": false,
				"decoy_incapacity": false,
			}
			for key in v18_defaults:
				if not ch1_v18.has(key):
					ch1_v18[key] = v18_defaults[key]

	## v18 -> v19: persistent packet assembly fields for BlueBinder v1.
	if old_version < 19:
		if saved_data.has("chapter1"):
			var ch1_v19: Dictionary = saved_data["chapter1"]
			var v19_defaults: Dictionary = {
				"packet_slot_address_non_current": "",
				"packet_slot_landlord_knowledge": "",
				"packet_slot_actual_notice_window": "",
				"packet_slot_no_third_party_authority": "",
				"packet_requested_remedy": "procedural_reset",
			}
			for key in v19_defaults:
				if not ch1_v19.has(key):
					ch1_v19[key] = v19_defaults[key]

	## v19 -> v20: Blue Folder foundation. Adds the pickup gate,
	## persistent argument-fragment storage, read-state map, inventory
	## membership map, and active case id used by the Motion Packet tab.
	if old_version < 20:
		var ch1_v20: Dictionary = {}
		if saved_data.has("chapter1") and saved_data["chapter1"] is Dictionary:
			ch1_v20 = saved_data["chapter1"]
			if not ch1_v20.has("has_case_folder"):
				ch1_v20["has_case_folder"] = false

		if not saved_data.has("case_folder") or not saved_data["case_folder"] is Dictionary:
			saved_data["case_folder"] = {}
		var folder: Dictionary = saved_data["case_folder"]
		if not folder.has("argument_fragments") or not folder["argument_fragments"] is Array:
			folder["argument_fragments"] = []
		if not folder.has("notes_seen") or not folder["notes_seen"] is Dictionary:
			folder["notes_seen"] = {}

		if not saved_data.has("inventory") or not saved_data["inventory"] is Dictionary:
			saved_data["inventory"] = {}
		var inventory: Dictionary = saved_data["inventory"]
		if bool(ch1_v20.get("has_law_binder", false)):
			inventory["procedural_binder"] = true
		if bool(ch1_v20.get("has_rights_memo", false)):
			inventory["rights_memo"] = true
		var bonus_id: String = str(ch1_v20.get("bonus_evidence_collected", ""))
		if bonus_id != "":
			inventory[bonus_id] = true
		if not saved_data.has("active_case_id") or not saved_data["active_case_id"] is String:
			saved_data["active_case_id"] = ""
		if str(saved_data["active_case_id"]) == "" and bool(ch1_v20.get("has_law_binder", false)):
			saved_data["active_case_id"] = "chapter1_sikorska"

	## v20 -> v21: 2026-05-19 critique F4 partial. Inlines Cula's Beat 14
	## postcard reaction (previously orphaned in cula.json) into
	## postcard_swine_ch1.json; gates Whimsy's deflection on the new flag.
	## Migration: add cula_postcard_reaction_shown defaulting to false.
	## Saved games at v20 that have already completed Ch1 will not retro-
	## fire Cula's reaction; the line is only seen by playthroughs that
	## reach Beat 14 after the migration.
	if old_version < 21:
		if saved_data.has("chapter1") and saved_data["chapter1"] is Dictionary:
			var ch1_v21: Dictionary = saved_data["chapter1"]
			if not ch1_v21.has("cula_postcard_reaction_shown"):
				ch1_v21["cula_postcard_reaction_shown"] = false

	## v21 -> v22: 2026-05-26 design-plan Phase 0 Step 0.2. Rename
	## chapter1.bonus_evidence_collected → chapter1.client_meeting_evidence.
	## The flag records which bonus evidence item the player collected during
	## the client meeting. Old name described acquisition; new name reflects
	## narrative role (the item comes from the client meeting, not from some
	## generic bonus-collection mechanic).
	if old_version < 22:
		if saved_data.has("chapter1") and saved_data["chapter1"] is Dictionary:
			var ch1_v22: Dictionary = saved_data["chapter1"]
			if ch1_v22.has("bonus_evidence_collected"):
				ch1_v22["client_meeting_evidence"] = ch1_v22["bonus_evidence_collected"]
				ch1_v22.erase("bonus_evidence_collected")
			elif not ch1_v22.has("client_meeting_evidence"):
				ch1_v22["client_meeting_evidence"] = ""

	## v22 -> v23: Phase 2 citation persistence (Step 1.1). Add
	## chapter1.phase2_round_results as empty Array. court_outcome is no longer
	## written by consume_assembled_packet(); the dispositive outcome is computed
	## at end-of-round-3 via _compute_court_outcome().
	if old_version < 23:
		if saved_data.has("chapter1") and saved_data["chapter1"] is Dictionary:
			var ch1_v23: Dictionary = saved_data["chapter1"]
			if not ch1_v23.has("phase2_round_results") \
					or not ch1_v23["phase2_round_results"] is Array:
				ch1_v23["phase2_round_results"] = []

	## v23 -> v24: Judgment pickup flags (Step 2.2). Add
	## chapter1.picked_up_article_8 and chapter1.picked_up_article_10 as false.
	## These gate the home_and_family_ch8 and expression_and_press_ch10
	## Casebook conditions in judgments.json.
	if old_version < 24:
		if saved_data.has("chapter1") and saved_data["chapter1"] is Dictionary:
			var ch1_v24: Dictionary = saved_data["chapter1"]
			if not ch1_v24.has("picked_up_article_8"):
				ch1_v24["picked_up_article_8"] = false
			if not ch1_v24.has("picked_up_article_10"):
				ch1_v24["picked_up_article_10"] = false

	## v24 -> v25: Beat 13 close flags. Unblocks promotion of the Pig/Murrow/
	## Crab/Whimsy Beat-13 ensemble drafts (data/_drafts/
	## nightly_design_pig_2026-05-14.json) and the coffee-machine env-beat
	## (data/_drafts/nightly_design_beat13_close_2026-05-17.json), both of
	## which had been waiting on these flag declarations. Both bools default
	## false; client_fee_collected anchors Pig's celebration to story.txt
	## Beat 13, and pig_court_win_acknowledged sequences the env-beat after
	## Pig has spoken.
	if old_version < 25:
		if saved_data.has("chapter1") and saved_data["chapter1"] is Dictionary:
			var ch1_v25: Dictionary = saved_data["chapter1"]
			if not ch1_v25.has("client_fee_collected"):
				ch1_v25["client_fee_collected"] = false
			if not ch1_v25.has("pig_court_win_acknowledged"):
				ch1_v25["pig_court_win_acknowledged"] = false

	## v25 -> v26: Murrow rehearsal flags. rehearsal_accepted is an edge-trigger
	## (cleared by orchestration on scene entry); rehearsal_complete persists so
	## the offer does not repeat after the player has done it once. rehearsal_declined
	## is written by murrow_rehearsal_skip and silences the offer + debrief without
	## marking the rehearsal as completed — so the debrief can gate on
	## rehearsal_complete && !rehearsal_declined. All three default false on
	## existing saves (pre-v26 player has not seen any rehearsal state yet).
	if old_version < 26:
		if saved_data.has("chapter1") and saved_data["chapter1"] is Dictionary:
			var ch1_v26: Dictionary = saved_data["chapter1"]
			if not ch1_v26.has("rehearsal_accepted"):
				ch1_v26["rehearsal_accepted"] = false
			if not ch1_v26.has("rehearsal_complete"):
				ch1_v26["rehearsal_complete"] = false
			if not ch1_v26.has("rehearsal_declined"):
				ch1_v26["rehearsal_declined"] = false

	## v26 -> v27: halina_trust (int) renamed to halina_stance (String) +
	## incapacity_penalty (bool). halina_stance is derived from the old integer
	## via threshold: ≥ 5 → "high" (sympathetic opener + consistent warm choices),
	## 0–4 → "blunt" (procedural/technical opener, or sympathetic without follow-
	## through), negative → "blunt" + incapacity_penalty = true (incapacity blunder
	## was filed, which applied a -4 penalty). The old halina_trust key is erased.
	if old_version < 27:
		if saved_data.has("chapter1") and saved_data["chapter1"] is Dictionary:
			var ch1_v27: Dictionary = saved_data["chapter1"]
			if ch1_v27.has("halina_trust"):
				var old_trust: int = int(ch1_v27["halina_trust"])
				var migrated_stance: String = "blunt"
				var migrated_penalty: bool = false
				if old_trust >= 5:
					migrated_stance = "high"
				elif old_trust < 0:
					migrated_penalty = true
				ch1_v27.erase("halina_trust")
				if not ch1_v27.has("halina_stance"):
					ch1_v27["halina_stance"] = migrated_stance
				if not ch1_v27.has("incapacity_penalty"):
					ch1_v27["incapacity_penalty"] = migrated_penalty
				if not ch1_v27.has("incapacity_reflection_seen"):
					ch1_v27["incapacity_reflection_seen"] = false
			else:
				if not ch1_v27.has("halina_stance"):
					ch1_v27["halina_stance"] = ""
				if not ch1_v27.has("incapacity_penalty"):
					ch1_v27["incapacity_penalty"] = false
				if not ch1_v27.has("incapacity_reflection_seen"):
					ch1_v27["incapacity_reflection_seen"] = false
	return saved_data
