extends SceneTree
## tests/test_save_migration_v9_v10.gd — verifies coffee accessibility save
## migration (v9 -> v10). save.gd is loaded standalone; migrate_save is
## called on a freshly-instantiated node. State.SAVE_VERSION is read
## off the loaded state.gd script.
##
## Runs headless. Exits 0 on pass, 1 on fail.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestSaveMigrationV9V10] Starting...")

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
	## Test 1: SAVE_VERSION constant on state.gd is 10.
	## -------------------------------------------------------------------
	var save_version_val: int = state_script.SAVE_VERSION
	if save_version_val == 10:
		_pass("T1: state.gd SAVE_VERSION == 10")
	else:
		_fail("T1: expected SAVE_VERSION == 10, got " + str(save_version_val))

	## -------------------------------------------------------------------
	## Test 2: v9 save — pre-existing coffee state preserved.
	## -------------------------------------------------------------------
	var v9_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"coffee_tutorial_seen": true,
			"coffee_buff": "procedurally_alert",
			"coffee_brew_grade": "A",
		},
		"coffee": {
			"tutorial_seen": true,
			"last_result": "good_brew",
			"last_grade": "A",
			"last_buff": "procedurally_alert",
			"assist_used": false,
			"times_brewed": 2,
			"best_grade": "A",
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
	var pre_ch1: Dictionary = v9_save["chapter1"].duplicate()
	var pre_coffee: Dictionary = v9_save["coffee"].duplicate()
	var migrated: Dictionary = save_inst.migrate_save(v9_save, 9)

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
	for key in pre_coffee:
		if not migrated["coffee"].has(key):
			_fail("T2: pre-existing coffee key dropped: " + key)
			preserved_ok = false
		elif migrated["coffee"][key] != pre_coffee[key]:
			_fail("T2: pre-existing coffee key mutated: %s (was %s, now %s)" % [
				key, str(pre_coffee[key]), str(migrated["coffee"][key])
			])
			preserved_ok = false
	if preserved_ok:
		_pass("T2: every pre-existing v9 coffee key preserved with original value")

	## -------------------------------------------------------------------
	## Test 3: settings.coffee_accessibility defaults all false.
	## -------------------------------------------------------------------
	var access_ok: bool = true
	if not migrated.has("settings") or not migrated["settings"] is Dictionary:
		_fail("T3: settings dict missing or wrong type")
		access_ok = false
	elif not migrated["settings"].has("coffee_accessibility") or not migrated["settings"]["coffee_accessibility"] is Dictionary:
		_fail("T3: settings.coffee_accessibility missing or wrong type")
		access_ok = false
	else:
		var accessibility: Dictionary = migrated["settings"]["coffee_accessibility"]
		var expected: Dictionary = {
			"slower_notes": false,
			"wider_timing": false,
			"single_button": false,
		}
		for key in expected:
			if not accessibility.has(key):
				_fail("T3: coffee_accessibility missing key " + key)
				access_ok = false
			elif typeof(accessibility[key]) != TYPE_BOOL:
				_fail("T3: coffee_accessibility.%s expected bool, got type %s" % [
					key, str(typeof(accessibility[key]))
				])
				access_ok = false
			elif accessibility[key] != expected[key]:
				_fail("T3: coffee_accessibility.%s expected false, got %s" % [
					key, str(accessibility[key])
				])
				access_ok = false
	if access_ok:
		_pass("T3: settings.coffee_accessibility has all v10 defaults")

	## -------------------------------------------------------------------
	## Test 4: idempotency — re-running from v10 doesn't clobber.
	## -------------------------------------------------------------------
	migrated["settings"]["camera_shake"] = false
	migrated["settings"]["coffee_accessibility"]["slower_notes"] = true
	migrated["settings"]["coffee_accessibility"]["wider_timing"] = true
	migrated["settings"]["coffee_accessibility"]["single_button"] = false
	var user_settings: Dictionary = migrated["settings"].duplicate(true)
	var re_migrated: Dictionary = save_inst.migrate_save(migrated, 10)
	var idem_ok: bool = true
	for key in user_settings:
		if not re_migrated["settings"].has(key):
			_fail("T4: settings.%s dropped on re-migration" % key)
			idem_ok = false
		elif re_migrated["settings"][key] != user_settings[key]:
			_fail("T4: settings.%s clobbered on re-migration" % key)
			idem_ok = false
	if idem_ok:
		_pass("T4: re-migration from v10 is idempotent")

	## -------------------------------------------------------------------
	## Test 5: reset_state declares the v10 defaults.
	## -------------------------------------------------------------------
	var state_inst: Node = state_script.new()
	var default_state: Dictionary = state_inst.reset_state()
	var reset_ok: bool = true
	if not default_state.has("settings") or not default_state["settings"] is Dictionary:
		_fail("T5: reset_state missing settings dict")
		reset_ok = false
	elif not default_state["settings"].has("coffee_accessibility") or not default_state["settings"]["coffee_accessibility"] is Dictionary:
		_fail("T5: reset_state missing settings.coffee_accessibility")
		reset_ok = false
	else:
		var reset_access: Dictionary = default_state["settings"]["coffee_accessibility"]
		for key in ["slower_notes", "wider_timing", "single_button"]:
			if not reset_access.has(key):
				_fail("T5: reset_state coffee_accessibility missing key " + key)
				reset_ok = false
			elif reset_access[key] != false:
				_fail("T5: reset_state coffee_accessibility.%s expected false, got %s" % [
					key, str(reset_access[key])
				])
				reset_ok = false
	if reset_ok:
		_pass("T5: reset_state declares all coffee accessibility defaults")

	## -------------------------------------------------------------------
	## Test 6: full chain v1 -> v10 produces settings.coffee_accessibility.
	## -------------------------------------------------------------------
	var v1_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var from_v1: Dictionary = save_inst.migrate_save(v1_save, 1)
	var chain_ok: bool = true
	if not from_v1.has("settings") or not from_v1["settings"] is Dictionary:
		_fail("T6: settings missing or wrong type")
		chain_ok = false
	elif not from_v1["settings"].has("coffee_accessibility") or not from_v1["settings"]["coffee_accessibility"] is Dictionary:
		_fail("T6: settings.coffee_accessibility missing or wrong type")
		chain_ok = false
	else:
		for key in ["slower_notes", "wider_timing", "single_button"]:
			if not from_v1["settings"]["coffee_accessibility"].has(key):
				_fail("T6: coffee_accessibility missing key from migration chain: " + key)
				chain_ok = false
			elif from_v1["settings"]["coffee_accessibility"][key] != false:
				_fail("T6: coffee_accessibility.%s expected false after chain" % key)
				chain_ok = false
	if chain_ok:
		_pass("T6: v1 -> v10 migration chain produces coffee accessibility settings")

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestSaveMigrationV9V10] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestSaveMigrationV9V10] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestSaveMigrationV9V10] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestSaveMigrationV9V10] PASS")
		quit(0)
