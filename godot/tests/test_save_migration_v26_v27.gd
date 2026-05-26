extends SceneTree
## tests/test_save_migration_v26_v27.gd — verifies the halina_trust → halina_stance +
## incapacity_penalty rename migration (v26 -> v27). save.gd is loaded standalone;
## migrate_save is called on a freshly-instantiated node. State.SAVE_VERSION is
## read off the loaded state.gd script.
##
## Runs headless. Exits 0 on pass, 1 on fail.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestSaveMigrationV26V27] Starting...")

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
	## Test 1: SAVE_VERSION constant on state.gd is >= 27.
	## -------------------------------------------------------------------
	var save_version_val: int = state_script.SAVE_VERSION
	if save_version_val >= 27:
		_pass("T1: state.gd SAVE_VERSION >= 27 (current: %d)" % save_version_val)
	else:
		_fail("T1: expected SAVE_VERSION >= 27, got " + str(save_version_val))

	## -------------------------------------------------------------------
	## Test 2: v26 save with halina_trust >= 5 migrates to halina_stance "high".
	## -------------------------------------------------------------------
	var v26_high: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"halina_met": true,
			"halina_r0_done": true,
			"halina_r1_done": true,
			"client_meeting_stance": "sympathetic",
			"halina_trust": 7,
		},
	}
	var migrated_high: Dictionary = save_inst.migrate_save(v26_high, 26)
	if migrated_high["chapter1"].has("halina_trust"):
		_fail("T2: halina_trust key not erased after migration")
	elif migrated_high["chapter1"].get("halina_stance") != "high":
		_fail("T2: halina_trust 7 did not produce halina_stance 'high' (got %s)" % str(migrated_high["chapter1"].get("halina_stance")))
	elif migrated_high["chapter1"].get("incapacity_penalty") != false:
		_fail("T2: halina_trust 7 unexpectedly set incapacity_penalty true")
	else:
		_pass("T2: halina_trust 7 → halina_stance 'high', incapacity_penalty false, key erased")

	## -------------------------------------------------------------------
	## Test 3: v26 save with 0 <= halina_trust < 5 migrates to halina_stance "blunt".
	## -------------------------------------------------------------------
	var v26_blunt: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"halina_met": true,
			"halina_trust": 3,
		},
	}
	var migrated_blunt: Dictionary = save_inst.migrate_save(v26_blunt, 26)
	if migrated_blunt["chapter1"].has("halina_trust"):
		_fail("T3: halina_trust key not erased after migration")
	elif migrated_blunt["chapter1"].get("halina_stance") != "blunt":
		_fail("T3: halina_trust 3 did not produce halina_stance 'blunt' (got %s)" % str(migrated_blunt["chapter1"].get("halina_stance")))
	elif migrated_blunt["chapter1"].get("incapacity_penalty") != false:
		_fail("T3: halina_trust 3 unexpectedly set incapacity_penalty true")
	else:
		_pass("T3: halina_trust 3 → halina_stance 'blunt', incapacity_penalty false, key erased")

	## -------------------------------------------------------------------
	## Test 4: v26 save with negative halina_trust → halina_stance "blunt" +
	## incapacity_penalty true.
	## -------------------------------------------------------------------
	var v26_incap: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"halina_met": true,
			"halina_trust": -1,
		},
	}
	var migrated_incap: Dictionary = save_inst.migrate_save(v26_incap, 26)
	if migrated_incap["chapter1"].has("halina_trust"):
		_fail("T4: halina_trust key not erased after migration")
	elif migrated_incap["chapter1"].get("halina_stance") != "blunt":
		_fail("T4: negative halina_trust did not produce halina_stance 'blunt' (got %s)" % str(migrated_incap["chapter1"].get("halina_stance")))
	elif migrated_incap["chapter1"].get("incapacity_penalty") != true:
		_fail("T4: negative halina_trust did not set incapacity_penalty true")
	else:
		_pass("T4: halina_trust -1 → halina_stance 'blunt', incapacity_penalty true, key erased")

	## -------------------------------------------------------------------
	## Test 5: v26 save without halina_trust at all → blank defaults.
	## -------------------------------------------------------------------
	var v26_no_trust: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"halina_met": false,
		},
	}
	var migrated_no_trust: Dictionary = save_inst.migrate_save(v26_no_trust, 26)
	if migrated_no_trust["chapter1"].get("halina_stance") != "":
		_fail("T5: missing halina_trust did not produce halina_stance '' (got %s)" % str(migrated_no_trust["chapter1"].get("halina_stance")))
	elif migrated_no_trust["chapter1"].get("incapacity_penalty") != false:
		_fail("T5: missing halina_trust unexpectedly set incapacity_penalty true")
	else:
		_pass("T5: no halina_trust in save → halina_stance '', incapacity_penalty false")

	## -------------------------------------------------------------------
	## Test 6: idempotency — re-running from v27 does not clobber set values.
	## -------------------------------------------------------------------
	var v27_existing: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"halina_met": true,
			"halina_stance": "technical",
			"incapacity_penalty": false,
		},
	}
	var re_migrated: Dictionary = save_inst.migrate_save(v27_existing, 27)
	if re_migrated["chapter1"].get("halina_stance") != "technical":
		_fail("T6: re-migration clobbered halina_stance (got %s)" % str(re_migrated["chapter1"].get("halina_stance")))
	elif re_migrated["chapter1"].get("incapacity_penalty") != false:
		_fail("T6: re-migration mutated incapacity_penalty")
	else:
		_pass("T6: re-migration from v27 is idempotent — halina_stance and incapacity_penalty preserved")

	## -------------------------------------------------------------------
	## Test 7: reset_state declares halina_stance "" and incapacity_penalty false.
	## -------------------------------------------------------------------
	var state_inst: Node = state_script.new()
	var default_state: Dictionary = state_inst.reset_state()
	var reset_ok: bool = true
	if not default_state.has("chapter1") or not default_state["chapter1"] is Dictionary:
		_fail("T7: reset_state missing chapter1 dict")
		reset_ok = false
	else:
		var reset_ch1: Dictionary = default_state["chapter1"]
		if reset_ch1.has("halina_trust"):
			_fail("T7: reset_state still declares halina_trust (should be gone)")
			reset_ok = false
		if not reset_ch1.has("halina_stance"):
			_fail("T7: reset_state missing halina_stance")
			reset_ok = false
		elif reset_ch1["halina_stance"] != "":
			_fail("T7: reset_state halina_stance not '' (got %s)" % str(reset_ch1["halina_stance"]))
			reset_ok = false
		if not reset_ch1.has("incapacity_penalty"):
			_fail("T7: reset_state missing incapacity_penalty")
			reset_ok = false
		elif reset_ch1["incapacity_penalty"] != false:
			_fail("T7: reset_state incapacity_penalty not false")
			reset_ok = false
	if reset_ok:
		_pass("T7: reset_state declares halina_stance '' and incapacity_penalty false; halina_trust absent")

	## -------------------------------------------------------------------
	## Test 8: v1 → v27 full chain regression — both fields present, halina_trust absent.
	## -------------------------------------------------------------------
	var v1_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var from_v1: Dictionary = save_inst.migrate_save(v1_save, 1)
	var chain_ok: bool = true
	if not from_v1.has("chapter1") or not from_v1["chapter1"] is Dictionary:
		_fail("T8: chapter1 missing after full chain migration")
		chain_ok = false
	else:
		if from_v1["chapter1"].has("halina_trust"):
			_fail("T8: v1->v27 chain produced halina_trust (should be absent)")
			chain_ok = false
		if not from_v1["chapter1"].has("halina_stance"):
			_fail("T8: v1->v27 chain missing halina_stance")
			chain_ok = false
		elif from_v1["chapter1"]["halina_stance"] != "":
			_fail("T8: v1->v27 chain halina_stance not '' (got %s)" % str(from_v1["chapter1"]["halina_stance"]))
			chain_ok = false
		if not from_v1["chapter1"].has("incapacity_penalty"):
			_fail("T8: v1->v27 chain missing incapacity_penalty")
			chain_ok = false
		elif from_v1["chapter1"]["incapacity_penalty"] != false:
			_fail("T8: v1->v27 chain incapacity_penalty not false")
			chain_ok = false
	if chain_ok:
		_pass("T8: v1 -> v27 migration chain produces halina_stance '' and incapacity_penalty false; halina_trust absent")

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestSaveMigrationV26V27] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestSaveMigrationV26V27] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestSaveMigrationV26V27] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestSaveMigrationV26V27] PASS")
		quit(0)
