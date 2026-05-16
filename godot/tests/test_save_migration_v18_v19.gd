extends SceneTree
## test_save_migration_v18_v19.gd — migration tests for packet selection state.
## v19 adds:
##   chapter1.packet_slot_address_non_current
##   chapter1.packet_slot_landlord_knowledge
##   chapter1.packet_slot_actual_notice_window
##   chapter1.packet_slot_no_third_party_authority
##   chapter1.packet_requested_remedy

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0


func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v18->v19] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v18->v19] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)


func _run_all() -> void:
	_test_save_version_constant()
	_test_v18_to_v19_adds_packet_selection_keys()
	_test_v18_to_v19_preserves_existing_values()
	_test_idempotency()
	_test_reset_state_declares_v19_keys()
	_test_full_v1_to_v19_chain()


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


func _v19_defaults() -> Dictionary:
	return {
		"packet_slot_address_non_current": "",
		"packet_slot_landlord_knowledge": "",
		"packet_slot_actual_notice_window": "",
		"packet_slot_no_third_party_authority": "",
		"packet_requested_remedy": "procedural_reset",
	}


func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 19, "SAVE_VERSION >= 19")
	state_node.free()


func _test_v18_to_v19_adds_packet_selection_keys() -> void:
	print("[T2] v18->v19 adds selection keys")
	var save_node := _save_node()
	var old: Dictionary = {
		"chapter1": {
			"proposed_frame": "defective_service_135bis",
			"judicial_patience": 5,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 18)
	var ch1: Dictionary = migrated["chapter1"]
	for key in _v19_defaults().keys():
		_assert(ch1.has(key), "%s key exists" % key)
		_assert(ch1[key] == _v19_defaults()[key], "%s default set" % key)
	_assert(ch1["proposed_frame"] == "defective_service_135bis", "existing v18 fields preserved")
	save_node.free()


func _test_v18_to_v19_preserves_existing_values() -> void:
	print("[T3] preserves existing selection values")
	var save_node := _save_node()
	var old: Dictionary = {
		"chapter1": {
			"packet_slot_address_non_current": "renewal_2019_number_twelve",
			"packet_requested_remedy": "tenancy_ruling",
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 18)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1["packet_slot_address_non_current"] == "renewal_2019_number_twelve", "pre-existing slot value preserved")
	_assert(ch1["packet_requested_remedy"] == "tenancy_ruling", "pre-existing remedy preserved")
	_assert(ch1.has("packet_slot_landlord_knowledge"), "other v19 keys still backfilled")
	save_node.free()


func _test_idempotency() -> void:
	print("[T4] idempotency")
	var save_node := _save_node()
	var old: Dictionary = {
		"chapter1": {
			"packet_slot_no_third_party_authority": "resident_no_7_no_authority",
			"packet_requested_remedy": "merits_dismissal",
		},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 18)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 18)
	_assert(first["chapter1"]["packet_slot_no_third_party_authority"] == second["chapter1"]["packet_slot_no_third_party_authority"], "slot value stable across double migration")
	_assert(second["chapter1"]["packet_requested_remedy"] == "merits_dismissal", "remedy stable across double migration")
	save_node.free()


func _test_reset_state_declares_v19_keys() -> void:
	print("[T5] reset_state declares v19 keys")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	var ch1: Dictionary = fresh["chapter1"]
	for key in _v19_defaults().keys():
		_assert(ch1.has(key), "%s declared in reset_state" % key)
		_assert(ch1[key] == _v19_defaults()[key], "%s default matches reset_state" % key)
	state_node.free()


func _test_full_v1_to_v19_chain() -> void:
	print("[T6] full v1->v19 chain")
	var save_node := _save_node()
	var v1: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save_node.migrate_save(v1, 1)
	_assert(migrated.has("chapter1"), "chapter1 exists after full chain")
	var ch1: Dictionary = migrated["chapter1"]
	for key in _v19_defaults().keys():
		_assert(ch1.has(key), "%s exists after full chain" % key)
	_assert(ch1.has("decoy_incapacity"), "v18 packet booleans still present")
	_assert(ch1.has("proposed_frame"), "v17 field still present")
	save_node.free()
