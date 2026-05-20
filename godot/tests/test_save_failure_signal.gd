extends SceneTree
## test_save_failure_signal.gd — save failures surface through Signals.

var _pass_count: int = 0
var _fail_count: int = 0
var _failed_reasons: Array[String] = []


func _init() -> void:
	await process_frame
	await _test_save_failure_emits_signal()
	_finish()


func _test_save_failure_emits_signal() -> void:
	print("[T1] save failure signal")
	var sigs: Node = get_root().get_node_or_null("/root/Signals")
	_assert(sigs != null, "Signals autoload exists")
	if sigs == null:
		return
	_failed_reasons.clear()
	sigs.save_failed.connect(func(reason: String) -> void:
		_failed_reasons.append(reason)
	)

	var save_script: GDScript = load("res://scripts/systems/save.gd") as GDScript
	_assert(save_script != null, "save.gd loads")
	if save_script == null:
		return
	var save_node: Node = save_script.new()
	get_root().add_child(save_node)
	await process_frame

	var missing_dir_path: String = "user://missing_save_failure_%d/save.json" % Time.get_ticks_usec()
	save_node.call("set_save_path_for_tests", missing_dir_path)
	var ok: bool = bool(save_node.call("save_game"))
	_assert(not ok, "save_game returns false when target directory is missing")
	_assert(_failed_reasons.size() == 1, "save_failed emitted once")
	if not _failed_reasons.is_empty():
		_assert(_failed_reasons[0] != "", "save_failed includes a reason")
	save_node.queue_free()


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: ", msg)
	else:
		_fail_count += 1
		printerr("  FAIL: ", msg)


func _finish() -> void:
	print("[SaveFailureSignalTest] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)
