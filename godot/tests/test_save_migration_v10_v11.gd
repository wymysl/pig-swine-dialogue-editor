extends SceneTree
## tests/test_save_migration_v10_v11.gd — verifies Halina trust meter save
## migration (v10 -> v11). save.gd is loaded standalone; migrate_save is
## called on a freshly-instantiated node. State.SAVE_VERSION is read
## off the loaded state.gd script.
##
## Runs headless. Exits 0 on pass, 1 on fail.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestSaveMigrationV10V11] Starting...")

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
	## Test 1: SAVE_VERSION constant on state.gd is 11.
	## -------------------------------------------------------------------
	## SAVE_VERSION may have moved past 11 by later sprints; this test only
	## requires that v11 has actually shipped (i.e. SAVE_VERSION >= 11).
	var save_version_val: int = state_script.SAVE_VERSION
	if save_version_val >= 11:
		_pass("T1: state.gd SAVE_VERSION >= 11 (current: %d)" % save_version_val)
	else:
		_fail("T1: expected SAVE_VERSION >= 11, got " + str(save_version_val))

	## -------------------------------------------------------------------
	## Test 2: v10 save — pre-existing keys preserved after migration.
	## -------------------------------------------------------------------
	var v10_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"halina_met": true,
			"client_meeting_stance": "sympathetic",
			"client_meeting_evidence": "wojcik_witness_statement",  ## key renamed v22
			"cardiologist_plant_landed": true,
			"client_fee_agreed": true,
			"coffee_buff": "procedurally_alert",
		},
		"settings": {
			"coffee_accessibility": {
				"slower_notes": true,
				"wider_timing": false,
				"single_button": false,
			}
		},
	}
	var pre_ch1: Dictionary = v10_save["chapter1"].duplicate()
	var migrated: Dictionary = save_inst.migrate_save(v10_save, 10)

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
		_pass("T2: every pre-existing v10 chapter1 key preserved with original value")

	## -------------------------------------------------------------------
	## Test 3: v11 defaults all present with correct types and values.
	## -------------------------------------------------------------------
	var trust_ok: bool = true
	var v11_expected: Dictionary = {
		"halina_r0_done": false,
		"halina_r1_choice": "",
		"halina_r1_done": false,
		"halina_r2_choice": "",
		"halina_r2_done": false,
		"halina_close_done": false,
		"landlord_tip_received": false,
	}
	for key in v11_expected:
		if not migrated["chapter1"].has(key):
			_fail("T3: missing v11 key: " + key)
			trust_ok = false
		else:
			var got = migrated["chapter1"][key]
			var expected = v11_expected[key]
			if typeof(got) != typeof(expected):
				_fail("T3: %s wrong type — expected %s, got %s" % [
					key, str(typeof(expected)), str(typeof(got))
				])
				trust_ok = false
			elif got != expected:
				_fail("T3: %s wrong value — expected %s, got %s" % [
					key, str(expected), str(got)
				])
				trust_ok = false
	if trust_ok:
		_pass("T3: all v11 halina trust meter keys present with correct defaults")

	if migrated["chapter1"].get("halina_stance") != "blunt":
		_fail("T3: expected migrated halina_stance to be 'blunt', got " + str(migrated["chapter1"].get("halina_stance")))
	if migrated["chapter1"].get("incapacity_penalty") != false:
		_fail("T3: expected migrated incapacity_penalty to be false")

	## -------------------------------------------------------------------
	## Test 4: idempotency — re-running from v11 doesn't clobber set values.
	## -------------------------------------------------------------------
	migrated["chapter1"]["halina_stance"] = "high"
	migrated["chapter1"]["incapacity_penalty"] = true
	migrated["chapter1"]["halina_r0_done"] = true
	migrated["chapter1"]["halina_r1_choice"] = "warm"
	migrated["chapter1"]["halina_r1_done"] = true
	var user_ch1: Dictionary = migrated["chapter1"].duplicate()
	var re_migrated: Dictionary = save_inst.migrate_save(migrated, 11)
	var idem_ok: bool = true
	for key in user_ch1:
		if not re_migrated["chapter1"].has(key):
			_fail("T4: chapter1.%s dropped on re-migration" % key)
			idem_ok = false
		elif re_migrated["chapter1"][key] != user_ch1[key]:
			_fail("T4: chapter1.%s clobbered on re-migration (was %s, now %s)" % [
				key, str(user_ch1[key]), str(re_migrated["chapter1"][key])
			])
			idem_ok = false
	if idem_ok:
		_pass("T4: re-migration from v11 is idempotent")

	## -------------------------------------------------------------------
	## Test 5: reset_state declares all v11 defaults.
	## -------------------------------------------------------------------
	var state_inst: Node = state_script.new()
	var default_state: Dictionary = state_inst.reset_state()
	var reset_ok: bool = true
	if not default_state.has("chapter1") or not default_state["chapter1"] is Dictionary:
		_fail("T5: reset_state missing chapter1 dict")
		reset_ok = false
	else:
		var reset_ch1: Dictionary = default_state["chapter1"]
		for key in v11_expected:
			if not reset_ch1.has(key):
				_fail("T5: reset_state missing v11 key " + key)
				reset_ok = false
			elif typeof(reset_ch1[key]) != typeof(v11_expected[key]):
				_fail("T5: reset_state %s wrong type" % key)
				reset_ok = false
			elif reset_ch1[key] != v11_expected[key]:
				_fail("T5: reset_state %s wrong default — expected %s, got %s" % [
					key, str(v11_expected[key]), str(reset_ch1[key])
				])
				reset_ok = false
	if reset_ok:
		_pass("T5: reset_state declares all v11 halina trust meter defaults")
	
	if reset_ch1.get("halina_stance") != "":
		_fail("T5: expected reset_state halina_stance to be '', got " + str(reset_ch1.get("halina_stance")))
	if reset_ch1.get("incapacity_penalty") != false:
		_fail("T5: expected reset_state incapacity_penalty to be false")

	## -------------------------------------------------------------------
	## Test 6: full chain v1 -> v11 produces all halina trust keys.
	## -------------------------------------------------------------------
	var v1_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var from_v1: Dictionary = save_inst.migrate_save(v1_save, 1)
	var chain_ok: bool = true
	if not from_v1.has("chapter1") or not from_v1["chapter1"] is Dictionary:
		_fail("T6: chapter1 missing after full chain migration")
		chain_ok = false
	else:
		for key in v11_expected:
			if not from_v1["chapter1"].has(key):
				_fail("T6: v1->v11 chain missing key: " + key)
				chain_ok = false
			elif from_v1["chapter1"][key] != v11_expected[key]:
				_fail("T6: v1->v11 chain wrong default for %s: got %s" % [
					key, str(from_v1["chapter1"][key])
				])
				chain_ok = false
	if chain_ok:
		_pass("T6: v1 -> v11 migration chain produces all halina trust meter keys")
	
	if from_v1["chapter1"].get("halina_stance") != "blunt":
		_fail("T6: expected chain halina_stance to be 'blunt', got " + str(from_v1["chapter1"].get("halina_stance")))
	if from_v1["chapter1"].get("incapacity_penalty") != false:
		_fail("T6: expected chain incapacity_penalty to be false")

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestSaveMigrationV10V11] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestSaveMigrationV10V11] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestSaveMigrationV10V11] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestSaveMigrationV10V11] PASS")
		quit(0)
