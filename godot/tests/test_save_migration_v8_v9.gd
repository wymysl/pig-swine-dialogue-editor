extends SceneTree
## tests/test_save_migration_v8_v9.gd — verifies coffee brewing save
## migration (v8 → v9). save.gd is loaded standalone; migrate_save is
## called on a freshly-instantiated node. State.SAVE_VERSION is read
## off the loaded state.gd script.
##
## Runs headless. Exits 0 on pass, 1 on fail.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestSaveMigrationV8V9] Starting...")

	var state_script: GDScript = load("res://scripts/autoload/state.gd") as GDScript
	if state_script == null:
		_fail("Could not load state.gd")
		_finish()
		return
	var save_script: GDScript = load("res://scripts/systems/save.gd") as GDScript
	if save_script == null:
		_fail("Could not load save.gd")
		_finish()
		return
	var save_inst: Object = save_script.new()

	## -------------------------------------------------------------------
	## Test 1: SAVE_VERSION constant on state.gd is >= 9.
	## (Later save-shape changes may advance the current tip; this test
	## verifies v8 -> v9 migration still works.)
	## -------------------------------------------------------------------
	var save_version_val: int = state_script.SAVE_VERSION
	if save_version_val >= 9:
		_pass("T1: state.gd SAVE_VERSION >= 9 (current: %d)" % save_version_val)
	else:
		_fail("T1: expected SAVE_VERSION >= 9, got " + str(save_version_val))

	## -------------------------------------------------------------------
	## Test 2: v8 save — pre-existing keys preserved through migration.
	## -------------------------------------------------------------------
	var v8_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"met_pig": true,
			"pig_revealed_crisis": true,
			"met_murrow": true,
			"met_crab": true,
			"met_whimsy": false,
			"has_law_binder": true,
			"has_rights_memo": false,
			"recruited_crab": true,
			"recruited_whimsy": false,
			"coffee_tutorial_seen": true,
			"court_ready": false,
			"entered_court": false,
			"court_outcome": "",
			"met_asia": true,
			"met_asia_via_behind": false,
			"viewed_family_photo": true,
			"halina_met": true,
			"halina_arrived": true,
			"client_meeting_stance": "blunt_procedural",
			"client_meeting_evidence": "cardiologist_note",  ## key renamed v22
			"cardiologist_plant_landed": true,
			"client_fee_agreed": true,
			"archive_research_complete": true,
			"casebook_judge_state": "round_3_remedy",
			"court_won_procedural_reset": true,
			"beat13_complete": true,
			"received_swine_postcard": true,
			"postcard_asia_announced": true,
			"postcard_readaloud_cue_shown": true,
			"postcard_body_read": true,
			"pig_postcard_reaction_shown": true,
			"whimsy_postcard_deflection_shown": true,
			"complete": false,
		},
		"badges": {
			"day_one_survivor": true,
		},
		"routes_unlocked": {
			"residential": true,
			"business_district": false,
			"court_plaza": true,
		},
	}
	var pre_ch1: Dictionary = v8_save["chapter1"].duplicate()
	var pre_badges: Dictionary = v8_save["badges"].duplicate()
	var pre_routes: Dictionary = v8_save["routes_unlocked"].duplicate()
	var migrated: Dictionary = save_inst.migrate_save(v8_save, 8)

	var preserved_ok: bool = true
	for key in pre_ch1:
		if not migrated["chapter1"].has(key):
			_fail("T2: pre-existing chapter1 key dropped: " + key)
			preserved_ok = false
		elif migrated["chapter1"][key] != pre_ch1[key]:
			_fail("T2: pre-existing chapter1 key mutated: %s (was %s, now %s)" % [
				key, str(pre_ch1[key]), str(migrated["chapter1"][key])
			])
			preserved_ok = false
	for key in pre_badges:
		if not migrated["badges"].has(key):
			_fail("T2: pre-existing badges key dropped: " + key)
			preserved_ok = false
		elif migrated["badges"][key] != pre_badges[key]:
			_fail("T2: pre-existing badges key mutated: %s (was %s, now %s)" % [
				key, str(pre_badges[key]), str(migrated["badges"][key])
			])
			preserved_ok = false
	for key in pre_routes:
		if not migrated["routes_unlocked"].has(key):
			_fail("T2: pre-existing routes_unlocked key dropped: " + key)
			preserved_ok = false
		elif migrated["routes_unlocked"][key] != pre_routes[key]:
			_fail("T2: pre-existing routes_unlocked key mutated: %s (was %s, now %s)" % [
				key, str(pre_routes[key]), str(migrated["routes_unlocked"][key])
			])
			preserved_ok = false
	if preserved_ok:
		_pass("T2: every pre-existing v8 key preserved with original value")

	## -------------------------------------------------------------------
	## Test 3: new chapter1 coffee fields present with default "".
	## -------------------------------------------------------------------
	var new_str_ok: bool = true
	for flag in ["coffee_buff", "coffee_brew_grade"]:
		if not migrated["chapter1"].has(flag):
			_fail("T3: missing chapter1." + flag)
			new_str_ok = false
		elif migrated["chapter1"][flag] != "":
			_fail("T3: chapter1.%s default should be '', got %s" % [flag, str(migrated["chapter1"][flag])])
			new_str_ok = false
	if new_str_ok:
		_pass("T3: chapter1.coffee_buff and coffee_brew_grade present with default ''")

	## -------------------------------------------------------------------
	## Test 4: top-level coffee dict present with correct defaults.
	## -------------------------------------------------------------------
	var coffee_ok: bool = true
	if not migrated.has("coffee") or not migrated["coffee"] is Dictionary:
		_fail("T4: top-level coffee dict missing or wrong type")
		coffee_ok = false
	else:
		var coffee: Dictionary = migrated["coffee"]
		var expected: Dictionary = {
			"tutorial_seen": false,
			"last_result": "",
			"last_grade": "",
			"last_buff": "",
			"assist_used": false,
			"times_brewed": 0,
			"best_grade": "",
		}
		for key in expected:
			if not coffee.has(key):
				_fail("T4: coffee missing key " + key)
				coffee_ok = false
			elif typeof(coffee[key]) != typeof(expected[key]):
				_fail("T4: coffee.%s expected type %s, got %s" % [
					key, str(typeof(expected[key])), str(typeof(coffee[key]))
				])
				coffee_ok = false
			elif coffee[key] != expected[key]:
				_fail("T4: coffee.%s expected %s, got %s" % [key, str(expected[key]), str(coffee[key])])
				coffee_ok = false
	if coffee_ok:
		_pass("T4: top-level coffee dict has all keys with correct defaults")

	## -------------------------------------------------------------------
	## Test 5: idempotency — re-running from v9 doesn't clobber.
	## -------------------------------------------------------------------
	migrated["chapter1"]["coffee_buff"] = "procedurally_alert"
	migrated["chapter1"]["coffee_brew_grade"] = "S"
	migrated["coffee"]["tutorial_seen"] = true
	migrated["coffee"]["last_result"] = "success"
	migrated["coffee"]["last_grade"] = "S"
	migrated["coffee"]["last_buff"] = "procedurally_alert"
	migrated["coffee"]["assist_used"] = true
	migrated["coffee"]["times_brewed"] = 3
	migrated["coffee"]["best_grade"] = "S"
	var user_ch1: Dictionary = migrated["chapter1"].duplicate()
	var user_coffee: Dictionary = migrated["coffee"].duplicate()
	var re_migrated: Dictionary = save_inst.migrate_save(migrated, 9)
	var idem_ok: bool = true
	for key in ["coffee_buff", "coffee_brew_grade"]:
		if re_migrated["chapter1"][key] != user_ch1[key]:
			_fail("T5: chapter1.%s clobbered on re-migration" % key)
			idem_ok = false
	for key in user_coffee:
		if re_migrated["coffee"][key] != user_coffee[key]:
			_fail("T5: coffee.%s clobbered on re-migration" % key)
			idem_ok = false
	if idem_ok:
		_pass("T5: re-migration from v9 is idempotent (existing values not clobbered)")
	else:
		_fail("T5: re-migration clobbered existing keys")

	## -------------------------------------------------------------------
	## Test 6: full chain v1 → v9 produces all expected keys.
	## -------------------------------------------------------------------
	var v1_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var from_v1: Dictionary = save_inst.migrate_save(v1_save, 1)
	var expected_ch1_keys: Array = [
		"met_pig",                         ## v3 step
		"pig_revealed_crisis",             ## v3 step
		"met_murrow",                      ## v3 step
		"has_law_binder",                  ## v3 step
		"recruited_crab",                  ## v3 step
		"recruited_whimsy",                ## v3 step
		"coffee_tutorial_seen",            ## v3 step
		"court_ready",                     ## v3 step
		"entered_court",                   ## v3 step
		"court_outcome",                   ## v3 step
		"met_crab",                        ## v4 step
		"met_whimsy",                      ## v4 step
		"has_rights_memo",                 ## v5 step
		"met_asia",                        ## v6 step
		"viewed_family_photo",             ## v6 step
		"met_asia_via_behind",             ## v7 step
		"halina_met",                      ## v8 step
		"halina_arrived",                  ## v8 step
		"client_meeting_stance",           ## v8 step
		"client_meeting_evidence",          ## v8 step (renamed from bonus_evidence_collected in v22)
		"cardiologist_plant_landed",       ## v8 step
		"client_fee_agreed",               ## v8 step
		"archive_research_complete",       ## v8 step
		"casebook_judge_state",            ## v8 step
		"court_won_procedural_reset",      ## v8 step
		"beat13_complete",                 ## v8 step
		"received_swine_postcard",         ## v8 step
		"postcard_asia_announced",         ## v8 step
		"postcard_readaloud_cue_shown",    ## v8 step
		"postcard_body_read",              ## v8 step
		"pig_postcard_reaction_shown",     ## v8 step
		"whimsy_postcard_deflection_shown",## v8 step
		"complete",                        ## v8 step
		"coffee_buff",                     ## v9 step
		"coffee_brew_grade",               ## v9 step
	]
	var expected_coffee_keys: Array = [
		"tutorial_seen",
		"last_result",
		"last_grade",
		"last_buff",
		"assist_used",
		"times_brewed",
		"best_grade",
	]
	var chain_ok: bool = true
	if not from_v1.has("chapter1") or not from_v1["chapter1"] is Dictionary:
		_fail("T6: chapter1 missing or wrong type")
		chain_ok = false
	else:
		for key in expected_ch1_keys:
			if not from_v1["chapter1"].has(key):
				_fail("T6: chapter1 missing key from migration chain: " + key)
				chain_ok = false
	if not from_v1.has("badges") or not from_v1["badges"] is Dictionary:
		_fail("T6: badges missing or wrong type")
		chain_ok = false
	elif not from_v1["badges"].has("day_one_survivor"):
		_fail("T6: badges missing key day_one_survivor")
		chain_ok = false
	if not from_v1.has("routes_unlocked") or not from_v1["routes_unlocked"] is Dictionary:
		_fail("T6: routes_unlocked missing or wrong type")
		chain_ok = false
	else:
		for route_id in ["residential", "business_district", "court_plaza"]:
			if not from_v1["routes_unlocked"].has(route_id):
				_fail("T6: routes_unlocked missing key " + route_id)
				chain_ok = false
	if not from_v1.has("coffee") or not from_v1["coffee"] is Dictionary:
		_fail("T6: coffee missing or wrong type")
		chain_ok = false
	else:
		for key in expected_coffee_keys:
			if not from_v1["coffee"].has(key):
				_fail("T6: coffee missing key from migration chain: " + key)
				chain_ok = false
	if chain_ok:
		_pass("T6: v1 -> v9 migration chain produces all expected keys")
	else:
		_fail("T6: v1 -> v9 chain broken; keys: " + str(from_v1.keys()))

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestSaveMigrationV8V9] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestSaveMigrationV8V9] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestSaveMigrationV8V9] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestSaveMigrationV8V9] PASS")
		quit(0)
