extends SceneTree
## test_save_migration_v19_v20.gd — migration tests for the Blue Folder foundation.

const FIXTURE_PATH: String = "res://tests/fixtures/save_v20_from_v19.json"

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0


func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v19->v20] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v19->v20] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)


func _run_all() -> void:
	_test_save_version_constant()
	_test_reset_state_declares_v20_keys()
	_test_fixture_migrates_from_v19()
	_test_preserves_existing_blue_folder_values()
	_test_idempotency()
	_test_full_v1_to_v20_chain()


func _assert(condition: bool, msg: String) -> void:
	_test_count += 1
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _save_node() -> Node:
	var script := load("res://scripts/systems/save.gd") as GDScript
	var node := Node.new()
	node.set_script(script)
	return node


func _state_node() -> Node:
	var script := load("res://scripts/autoload/state.gd") as GDScript
	var node := Node.new()
	node.set_script(script)
	return node


func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state := _state_node()
	_assert(state.SAVE_VERSION >= 20, "SAVE_VERSION >= 20")
	state.free()


func _test_reset_state_declares_v20_keys() -> void:
	print("[T2] reset_state declares v20 keys")
	var state := _state_node()
	var fresh: Dictionary = state.reset_state()
	_assert(fresh.has("case_folder"), "case_folder exists")
	_assert(fresh["case_folder"].get("argument_fragments", null) is Array, "argument_fragments is Array")
	_assert(fresh["case_folder"].get("notes_seen", null) is Dictionary, "notes_seen is Dictionary")
	_assert(fresh["chapter1"].get("has_case_folder", null) == false, "has_case_folder defaults false")
	_assert(fresh.get("inventory", null) is Dictionary, "inventory is Dictionary")
	_assert(fresh.get("active_case_id", null) == "", "active_case_id defaults empty")
	state.free()


func _test_fixture_migrates_from_v19() -> void:
	print("[T3] fixture migrates from v19")
	var fixture: Dictionary = _load_fixture()
	_assert(int(fixture.get("version", 0)) == 19, "fixture is a v19 baseline")
	var save := _save_node()
	var migrated: Dictionary = save.migrate_save((fixture["data"] as Dictionary).duplicate(true), int(fixture["version"]))
	_assert(migrated["chapter1"]["has_case_folder"] == false, "fixture gains has_case_folder false")
	_assert(migrated["case_folder"]["argument_fragments"].is_empty(), "fixture gains empty fragments")
	_assert(migrated["case_folder"]["notes_seen"].is_empty(), "fixture gains empty notes_seen")
	_assert(migrated["inventory"].has("procedural_binder"), "fixture infers procedural_binder inventory")
	_assert(migrated["active_case_id"] == "chapter1_sikorska", "fixture infers active case from law binder")
	save.free()


func _test_preserves_existing_blue_folder_values() -> void:
	print("[T4] preserves existing v20-shaped values")
	var save := _save_node()
	var old: Dictionary = {
		"active_case_id": "custom_case",
		"inventory": {"rights_memo": true},
		"case_folder": {
			"argument_fragments": [{"id": "fragment_ch1_actual_notice"}],
			"notes_seen": {"fragment_ch1_actual_notice": true},
		},
		"chapter1": {"has_case_folder": true},
	}
	var migrated: Dictionary = save.migrate_save(old.duplicate(true), 19)
	_assert(migrated["chapter1"]["has_case_folder"] == true, "existing has_case_folder preserved")
	_assert(migrated["case_folder"]["argument_fragments"].size() == 1, "existing fragment preserved")
	_assert(migrated["case_folder"]["notes_seen"].has("fragment_ch1_actual_notice"), "existing notes_seen preserved")
	_assert(migrated["inventory"].has("rights_memo"), "existing inventory preserved")
	_assert(migrated["active_case_id"] == "custom_case", "existing active case preserved")
	save.free()


func _test_idempotency() -> void:
	print("[T5] idempotency")
	var save := _save_node()
	var old: Dictionary = {
		"chapter1": {"has_case_folder": false},
	}
	var first: Dictionary = save.migrate_save(old.duplicate(true), 19)
	var second: Dictionary = save.migrate_save(first.duplicate(true), 19)
	_assert(first["case_folder"] == second["case_folder"], "case_folder stable across double migration")
	_assert(first["inventory"] == second["inventory"], "inventory stable across double migration")
	save.free()


func _test_full_v1_to_v20_chain() -> void:
	print("[T6] full v1->v20 chain")
	var save := _save_node()
	var v1: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save.migrate_save(v1, 1)
	_assert(migrated.has("chapter1"), "chapter1 exists after full chain")
	_assert(migrated["chapter1"].has("has_case_folder"), "has_case_folder exists after full chain")
	_assert(migrated.has("case_folder"), "case_folder exists after full chain")
	_assert(migrated.has("inventory"), "inventory exists after full chain")
	_assert(migrated.has("active_case_id"), "active_case_id exists after full chain")
	save.free()


func _load_fixture() -> Dictionary:
	var file := FileAccess.open(FIXTURE_PATH, FileAccess.READ)
	if file == null:
		_assert(false, "could open fixture")
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		_assert(false, "fixture parses as Dictionary")
		return {}
	return parsed as Dictionary
