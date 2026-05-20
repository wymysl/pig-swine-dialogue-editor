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

const SAVE_PATH: String = "user://save.json"

var _save_path: String = SAVE_PATH


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
		_fail_save("State data is unavailable.")
		return false
	var payload: Dictionary = {
		"version": st.SAVE_VERSION,
		"data": st.data,
	}
	var user_dir: String = ProjectSettings.globalize_path("user://")
	if not DirAccess.dir_exists_absolute(user_dir):
		var dir_err: Error = DirAccess.make_dir_recursive_absolute(user_dir)
		if dir_err != OK:
			_fail_save("Cannot create the save directory.")
			return false
	var file := FileAccess.open(_save_path, FileAccess.WRITE)
	if file == null:
		_fail_save("Cannot open the save file for writing.")
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
		_fail_load("State data is unavailable.")
		return false

	var file := FileAccess.open(_save_path, FileAccess.READ)
	if file == null:
		_fail_load("Cannot open the save file for reading.")
		return false
	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		_fail_load("The save file is corrupt; progress was reset.")
		st.data = st.reset_state()
		return false

	var version: int = int(parsed.get("version", 1))
	var saved_data: Dictionary = parsed.get("data", {})

	saved_data = migrate_save(saved_data, version)
	st.data = saved_data
	return true


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
			"bonus_evidence_collected": "",
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
	return saved_data
