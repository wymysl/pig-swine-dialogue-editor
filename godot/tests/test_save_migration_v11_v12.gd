extends SceneTree
## tests/test_save_migration_v11_v12.gd — verifies the dialogue once-state save
## migration (v11 -> v12). save.gd is loaded standalone; migrate_save is
## called on a freshly-instantiated node. State.SAVE_VERSION is read off the
## loaded state.gd script.
##
## Runs headless. Exits 0 on pass, 1 on fail.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestSaveMigrationV11V12] Starting...")

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
	## Test 1: SAVE_VERSION constant on state.gd is 12.
	## -------------------------------------------------------------------
	## SAVE_VERSION may have moved past 12 by later sprints; this test only
	## requires that v12 has actually shipped (i.e. SAVE_VERSION >= 12).
	## See test_save_migration_v7_v8.gd for the established `>=` convention.
	var save_version_val: int = state_script.SAVE_VERSION
	if save_version_val >= 12:
		_pass("T1: state.gd SAVE_VERSION >= 12 (current: %d)" % save_version_val)
	else:
		_fail("T1: expected SAVE_VERSION >= 12, got " + str(save_version_val))

	## -------------------------------------------------------------------
	## Test 2: v11 save — pre-existing keys preserved after migration.
	## -------------------------------------------------------------------
	var v11_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"halina_met": true,
			"halina_trust": 4,
			"halina_r0_done": true,
			"halina_r1_choice": "warm",
			"halina_r1_done": true,
			"client_meeting_stance": "sympathetic",
		},
		"badges": {"day_one_survivor": true},
		"routes_unlocked": {"residential": true, "business_district": false, "court_plaza": false},
	}
	var pre_ch1: Dictionary = v11_save["chapter1"].duplicate()
	var migrated: Dictionary = save_inst.migrate_save(v11_save, 11)

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
		_pass("T2: every pre-existing v11 chapter1 key preserved with original value")

	## -------------------------------------------------------------------
	## Test 3: v12 adds top-level dialogue_states_seen as an empty Array.
	## -------------------------------------------------------------------
	if not migrated.has("dialogue_states_seen"):
		_fail("T3: dialogue_states_seen missing after migration")
	elif not migrated["dialogue_states_seen"] is Array:
		_fail("T3: dialogue_states_seen is not Array (got %s)" % typeof(migrated["dialogue_states_seen"]))
	elif migrated["dialogue_states_seen"].size() != 0:
		_fail("T3: dialogue_states_seen expected empty, got %s" % str(migrated["dialogue_states_seen"]))
	else:
		_pass("T3: dialogue_states_seen present and empty after v11 -> v12 migration")

	## -------------------------------------------------------------------
	## Test 4: idempotency — re-running from v12 preserves seen entries.
	## -------------------------------------------------------------------
	migrated["dialogue_states_seen"] = ["client_meeting_intro", "asia_first_meeting"]
	var re_migrated: Dictionary = save_inst.migrate_save(migrated, 12)
	if not re_migrated.has("dialogue_states_seen") \
			or not re_migrated["dialogue_states_seen"] is Array \
			or re_migrated["dialogue_states_seen"].size() != 2 \
			or not re_migrated["dialogue_states_seen"].has("client_meeting_intro") \
			or not re_migrated["dialogue_states_seen"].has("asia_first_meeting"):
		_fail("T4: re-migration clobbered dialogue_states_seen entries (got %s)" % str(re_migrated.get("dialogue_states_seen", "<missing>")))
	else:
		_pass("T4: re-migration from v12 preserves dialogue_states_seen entries")

	## -------------------------------------------------------------------
	## Test 5: reset_state declares dialogue_states_seen as empty Array.
	## -------------------------------------------------------------------
	var state_inst: Node = state_script.new()
	var default_state: Dictionary = state_inst.reset_state()
	if not default_state.has("dialogue_states_seen"):
		_fail("T5: reset_state missing dialogue_states_seen")
	elif not default_state["dialogue_states_seen"] is Array:
		_fail("T5: reset_state dialogue_states_seen wrong type")
	elif default_state["dialogue_states_seen"].size() != 0:
		_fail("T5: reset_state dialogue_states_seen not empty")
	else:
		_pass("T5: reset_state declares dialogue_states_seen as empty Array")

	## -------------------------------------------------------------------
	## Test 6: full chain v1 -> v12 produces the new field.
	## -------------------------------------------------------------------
	var v1_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var from_v1: Dictionary = save_inst.migrate_save(v1_save, 1)
	if not from_v1.has("dialogue_states_seen") or not from_v1["dialogue_states_seen"] is Array:
		_fail("T6: v1 -> v12 chain missing dialogue_states_seen Array")
	else:
		_pass("T6: v1 -> v12 migration chain produces dialogue_states_seen")

	## -------------------------------------------------------------------
	## Test 7: a saved Array with a non-Array dialogue_states_seen value gets
	## normalised to []. Defensive against hand-edited or corrupted saves.
	## -------------------------------------------------------------------
	var bad_save: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"dialogue_states_seen": "not-an-array",
	}
	var fixed: Dictionary = save_inst.migrate_save(bad_save, 11)
	if not fixed["dialogue_states_seen"] is Array \
			or fixed["dialogue_states_seen"].size() != 0:
		_fail("T7: non-Array dialogue_states_seen not normalised (got %s)" % str(fixed["dialogue_states_seen"]))
	else:
		_pass("T7: corrupt dialogue_states_seen normalised to []")

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestSaveMigrationV11V12] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestSaveMigrationV11V12] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestSaveMigrationV11V12] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestSaveMigrationV11V12] PASS")
		quit(0)
