extends SceneTree
## test_door_required_flag.gd — dotted State.data path gates for doors.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestDoorRequiredFlag] Starting...")
	await process_frame

	_test_empty_flag_unlocks()
	_test_top_level_flag_still_works()
	_test_chapter1_dotted_flag_works()
	_test_missing_dotted_flag_locks()

	_finish()


func _door():
	var script := load("res://scripts/actors/door.gd") as GDScript
	var door := Area2D.new()
	door.set_script(script)
	return door


func _test_empty_flag_unlocks() -> void:
	print("[T1] empty flag")
	var door = _door()
	door.required_flag = ""
	_assert(door._is_required_flag_met({}), "empty required_flag unlocks")
	door.free()


func _test_top_level_flag_still_works() -> void:
	print("[T2] top-level flag")
	var door = _door()
	door.required_flag = "court_open"
	_assert(door._is_required_flag_met({"court_open": true}), "top-level true flag unlocks")
	_assert(not door._is_required_flag_met({"court_open": false}), "top-level false flag locks")
	door.free()


func _test_chapter1_dotted_flag_works() -> void:
	print("[T3] chapter1 dotted flag")
	var door = _door()
	door.required_flag = "chapter1.has_law_binder"
	var state_data: Dictionary = {
		"chapter1": {
			"has_law_binder": true,
		},
	}
	_assert(door._is_required_flag_met(state_data), "chapter1.has_law_binder unlocks when true")
	state_data["chapter1"]["has_law_binder"] = false
	_assert(not door._is_required_flag_met(state_data), "chapter1.has_law_binder locks when false")
	door.free()


func _test_missing_dotted_flag_locks() -> void:
	print("[T4] missing dotted flag")
	var door = _door()
	door.required_flag = "chapter1.has_law_binder"
	_assert(not door._is_required_flag_met({"chapter1": {}}), "missing nested flag locks")
	_assert(not door._is_required_flag_met({}), "missing chapter dict locks")
	door.free()


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _finish() -> void:
	print("")
	print("[TestDoorRequiredFlag] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestDoorRequiredFlag] PASS")
		quit(0)
