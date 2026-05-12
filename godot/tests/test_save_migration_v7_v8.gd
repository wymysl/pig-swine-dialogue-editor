extends SceneTree
## tests/test_save_migration_v7_v8.gd — verifies the Chapter 1 Phase A.1
## save migration (v7 → v8). save.gd is loaded as a standalone GDScript
## (no autoload required); migrate_save is called on a freshly-instantiated
## node. State.SAVE_VERSION is read off the loaded state.gd script.
##
## Runs headless. Exits 0 on pass, 1 on fail.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestSaveMigrationV7V8] Starting...")

	## Load both scripts standalone. Neither references autoload globals
	## at compile time (save.gd's State access was switched to runtime
	## lookup as of Phase A.1), so load() succeeds without the SceneTree
	## context.
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

	## -----------------------------------------------------------------------
	## Test 1: SAVE_VERSION constant on the state.gd script is >= 8.
	## (Bumped to 9 in coffee-brewing sprint; this test verifies v7->v8
	## migration still works, not that v8 is the current tip.)
	## -----------------------------------------------------------------------
	var save_version_val: int = state_script.SAVE_VERSION
	if save_version_val >= 8:
		_pass("T1: state.gd SAVE_VERSION >= 8 (current: %d)" % save_version_val)
	else:
		_fail("T1: expected SAVE_VERSION >= 8, got " + str(save_version_val))

	## -----------------------------------------------------------------------
	## Test 2: v7 save dict — pre-existing keys preserved through migration.
	## -----------------------------------------------------------------------
	var v7_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "from_corridor",
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
		},
	}
	var pre_ch1: Dictionary = v7_save["chapter1"].duplicate()

	var migrated: Dictionary = save_inst.migrate_save(v7_save, 7)

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
	if preserved_ok:
		_pass("T2: every pre-existing chapter1 key preserved with original value")

	## -----------------------------------------------------------------------
	## Test 3: new Phase A boolean flags exist with default false.
	## -----------------------------------------------------------------------
	var new_bool_flags: Array = [
		"halina_met",
		"halina_arrived",
		"cardiologist_plant_landed",
		"client_fee_agreed",
		"archive_research_complete",
		"court_won_procedural_reset",
		"beat13_complete",
		"received_swine_postcard",
		"postcard_asia_announced",
		"postcard_readaloud_cue_shown",
		"postcard_body_read",
		"pig_postcard_reaction_shown",
		"whimsy_postcard_deflection_shown",
		"complete",
	]
	var bool_ok: bool = true
	for flag in new_bool_flags:
		if not migrated["chapter1"].has(flag):
			_fail("T3: missing new bool flag chapter1." + flag)
			bool_ok = false
		elif migrated["chapter1"][flag] != false:
			_fail("T3: chapter1.%s default should be false, got %s" % [flag, str(migrated["chapter1"][flag])])
			bool_ok = false
	if bool_ok:
		_pass("T3: all %d new Phase A bool flags present with default false" % new_bool_flags.size())

	## -----------------------------------------------------------------------
	## Test 4: new Phase A string-enum flags exist with default "".
	## -----------------------------------------------------------------------
	var new_str_flags: Array = [
		"client_meeting_stance",
		"bonus_evidence_collected",
		"casebook_judge_state",
	]
	var str_ok: bool = true
	for flag in new_str_flags:
		if not migrated["chapter1"].has(flag):
			_fail("T4: missing new string flag chapter1." + flag)
			str_ok = false
		elif migrated["chapter1"][flag] != "":
			_fail("T4: chapter1.%s default should be empty string, got %s" % [flag, str(migrated["chapter1"][flag])])
			str_ok = false
	if str_ok:
		_pass("T4: all %d new Phase A string-enum flags present with default ''" % new_str_flags.size())

	## -----------------------------------------------------------------------
	## Test 5: top-level badges dict exists with day_one_survivor: false.
	## -----------------------------------------------------------------------
	if migrated.has("badges") and migrated["badges"] is Dictionary \
			and migrated["badges"].has("day_one_survivor") \
			and migrated["badges"]["day_one_survivor"] == false:
		_pass("T5: badges.day_one_survivor present with default false")
	else:
		_fail("T5: badges dict malformed: " + str(migrated.get("badges", "<missing>")))

	## -----------------------------------------------------------------------
	## Test 6: top-level routes_unlocked dict exists with all three routes.
	## -----------------------------------------------------------------------
	var routes_ok: bool = true
	if not (migrated.has("routes_unlocked") and migrated["routes_unlocked"] is Dictionary):
		_fail("T6: routes_unlocked dict missing or wrong type")
		routes_ok = false
	else:
		for route_id in ["residential", "business_district", "court_plaza"]:
			if not migrated["routes_unlocked"].has(route_id):
				_fail("T6: routes_unlocked missing key " + route_id)
				routes_ok = false
			elif migrated["routes_unlocked"][route_id] != false:
				_fail("T6: routes_unlocked.%s default should be false" % route_id)
				routes_ok = false
	if routes_ok:
		_pass("T6: routes_unlocked has all 3 declared routes with default false")

	## -----------------------------------------------------------------------
	## Test 7: idempotency — re-running migration from v8 must not corrupt.
	## -----------------------------------------------------------------------
	migrated["chapter1"]["halina_met"] = true
	migrated["badges"]["day_one_survivor"] = true
	var re_migrated: Dictionary = save_inst.migrate_save(migrated, 8)
	if re_migrated["chapter1"]["halina_met"] == true and re_migrated["badges"]["day_one_survivor"] == true:
		_pass("T7: re-running migration from v8 is idempotent (existing keys not clobbered)")
	else:
		_fail("T7: re-migration clobbered existing keys")

	## -----------------------------------------------------------------------
	## Test 8: migration from v1 walks the whole chain and lands on v8.
	## -----------------------------------------------------------------------
	var v1_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated_from_v1: Dictionary = save_inst.migrate_save(v1_save, 1)
	var v1_chain_ok: bool = (
		migrated_from_v1.has("chapter1")
		and migrated_from_v1["chapter1"].has("met_pig")              ## v3 step
		and migrated_from_v1["chapter1"].has("met_crab")             ## v4 step
		and migrated_from_v1["chapter1"].has("has_rights_memo")      ## v5 step
		and migrated_from_v1["chapter1"].has("met_asia")             ## v6 step
		and migrated_from_v1["chapter1"].has("met_asia_via_behind")  ## v7 step
		and migrated_from_v1["chapter1"].has("halina_met")           ## v8 step
		and migrated_from_v1.has("badges")
		and migrated_from_v1.has("routes_unlocked")
	)
	if v1_chain_ok:
		_pass("T8: v1 -> v8 migration chain produces all expected keys")
	else:
		_fail("T8: v1 -> v8 migration chain broken; final shape: " + str(migrated_from_v1.keys()))

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestSaveMigrationV7V8] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestSaveMigrationV7V8] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestSaveMigrationV7V8] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestSaveMigrationV7V8] PASS")
		quit(0)
