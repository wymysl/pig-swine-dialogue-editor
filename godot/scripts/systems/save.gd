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

const SAVE_PATH: String = "user://save.json"


## _state — runtime accessor for the State autoload.
## Using a runtime lookup (rather than the compile-time `State` global)
## lets save.gd be loaded standalone by tests via load(); the compile-time
## identifier `State` isn't visible to scripts loaded that way in --script
## mode. Pattern mirrors dialogue_runner.gd's `_state_data()`.
func _state() -> Node:
	return get_node_or_null("/root/State")


## save_game — serialises State.data to disk with version metadata.
func save_game() -> void:
	var st: Node = _state()
	if st == null:
		push_error("Save: State autoload missing; cannot save.")
		return
	var payload: Dictionary = {
		"version": st.SAVE_VERSION,
		"data": st.data,
	}
	var user_dir: String = ProjectSettings.globalize_path("user://")
	if not DirAccess.dir_exists_absolute(user_dir):
		var dir_err: Error = DirAccess.make_dir_recursive_absolute(user_dir)
		if dir_err != OK:
			push_error("Save: cannot create save directory: " + user_dir)
			return
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		push_error("Save: cannot open save path for writing: " + SAVE_PATH)
		return
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()


## load_game — reads save file, migrates if needed, applies to State.data.
## Returns true on success, false if file missing or unrecoverable.
func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var st: Node = _state()
	if st == null:
		push_error("Save: State autoload missing; cannot load.")
		return false

	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		push_error("Save: cannot open save file for reading.")
		return false
	var text: String = file.get_as_text()
	file.close()

	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("Save: corrupt save file (JSON parse failed). Resetting.")
		st.data = st.reset_state()
		return false

	var version: int = int(parsed.get("version", 1))
	var saved_data: Dictionary = parsed.get("data", {})

	saved_data = migrate_save(saved_data, version)
	st.data = saved_data
	return true


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

	return saved_data
