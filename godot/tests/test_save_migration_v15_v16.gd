extends SceneTree
## test_save_migration_v15_v16.gd — headless migration tests for v15 -> v16.
## v16 adds chapter1.murrow_choice (string, default "").
##
## Run: godot --headless --path godot --script tests/test_save_migration_v15_v16.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0


func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v15->v16] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v15->v16] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)


func _run_all() -> void:
	_test_save_version_constant()
	_test_v15_to_v16_adds_murrow_choice()
	_test_v15_to_v16_preserves_existing()
	_test_idempotency()
	_test_reset_state_declares_murrow_choice()
	_test_missing_chapter1_handled()
	_test_full_v1_to_v16_chain()


func _assert(condition: bool, msg: String) -> void:
	_test_count += 1
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _save() -> Node:
	var script := load("res://scripts/systems/save.gd") as GDScript
	var node := Node.new()
	node.set_script(script)
	return node


func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 16, "SAVE_VERSION >= 16")
	state_node.free()


func _test_v15_to_v16_adds_murrow_choice() -> void:
	print("[T2] v15->v16 adds murrow_choice")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_murrow": true,
			"state_choice": "precise",
		},
		"dialogue_states_seen": [],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 15)
	_assert(migrated["chapter1"].has("murrow_choice"), "murrow_choice key exists")
	_assert(migrated["chapter1"]["murrow_choice"] == "", "murrow_choice defaults empty string")
	_assert(typeof(migrated["chapter1"]["murrow_choice"]) == TYPE_STRING, "murrow_choice is String")
	save_node.free()


func _test_v15_to_v16_preserves_existing() -> void:
	print("[T3] preserves existing keys")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"met_murrow": true,
			"state_choice": "formal",
			"murrow_choice": "friendly",
			"halina_trust": 7,
		},
		"dialogue_states_seen": ["murrow_case_summary"],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 15)
	_assert(migrated["chapter1"]["met_pig"] == true, "met_pig preserved")
	_assert(migrated["chapter1"]["state_choice"] == "formal", "state_choice preserved")
	_assert(migrated["chapter1"]["murrow_choice"] == "friendly", "existing murrow_choice preserved")
	## halina_trust 7 (≥ 5) → migrated to halina_stance = "high" at v27.
	_assert(not migrated["chapter1"].has("halina_trust"), "halina_trust erased by v27 migration")
	_assert(migrated["chapter1"].get("halina_stance", "") == "high", "halina_trust 7 → halina_stance 'high'")
	_assert(migrated["dialogue_states_seen"].has("murrow_case_summary"), "dialogue_states_seen preserved")
	save_node.free()


func _test_idempotency() -> void:
	print("[T4] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {"met_murrow": false},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 15)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 15)
	_assert(first["chapter1"]["murrow_choice"] == second["chapter1"]["murrow_choice"],
		"murrow_choice same after double migration")
	_assert(second["chapter1"]["murrow_choice"] == "", "murrow_choice still empty on re-run")
	save_node.free()


func _test_reset_state_declares_murrow_choice() -> void:
	print("[T5] reset_state declares murrow_choice")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(fresh.has("chapter1"), "chapter1 dict exists")
	_assert(fresh["chapter1"].has("murrow_choice"), "murrow_choice in reset_state")
	_assert(fresh["chapter1"]["murrow_choice"] == "", "murrow_choice defaults empty string")
	_assert(fresh["chapter1"].has("state_choice"), "state_choice still in reset_state")
	state_node.free()


func _test_missing_chapter1_handled() -> void:
	print("[T6] missing chapter1 dict is not crashed on")
	var save_node := _save()
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 15)
	_assert(not migrated.has("chapter1") or migrated["chapter1"].has("murrow_choice"),
		"no crash and either chapter1 absent or murrow_choice present")
	save_node.free()


func _test_full_v1_to_v16_chain() -> void:
	print("[T7] full v1->v16 chain")
	var save_node := _save()
	var v1: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save_node.migrate_save(v1, 1)
	_assert(migrated.has("chapter1"), "chapter1 exists after full chain")
	_assert(migrated["chapter1"].has("state_choice"), "state_choice exists after full chain")
	_assert(migrated["chapter1"].has("murrow_choice"), "murrow_choice exists after full chain")
	_assert(migrated["chapter1"]["murrow_choice"] == "", "murrow_choice empty after full chain")
	_assert(migrated["chapter1"].has("won_court"), "won_court exists (v13 step regression)")
	_assert(migrated.has("dialogue_states_seen"), "dialogue_states_seen exists (v12 regression)")
	_assert(migrated.has("badges"), "badges exists (v8 regression)")
	save_node.free()
