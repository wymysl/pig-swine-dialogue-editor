extends SceneTree
## test_state_writer.gd — DialogueRunner._set_state_value strictness contract.
##
## Per the 2026-05-22 tech critique F3: the silent-no-op writer is the same
## class of bug that drove the v13 migration (chapter1.coffee_retry_decision
## landed nowhere because the slot was never declared). The function now
## returns bool and push_errors on unresolved paths in strict mode (default).
##
## Coverage:
##   T1: writing a declared path returns true and persists the value.
##   T2: writing an unknown leaf key returns false in strict mode.
##   T3: writing into a missing parent segment returns false in strict mode.
##   T4: strict=false preserves the legacy silent no-op behaviour for callers
##       that intentionally probe optional paths.
##   T5: a deep-nested declared path writes correctly.
##
## Owner: QA role.
## Run:   godot --headless --path godot --script tests/test_state_writer.gd

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	await process_frame
	_run_all()
	_finish()


func _run_all() -> void:
	_test_declared_path_writes()
	_test_unknown_leaf_strict_fails()
	_test_missing_parent_strict_fails()
	_test_permissive_mode_no_ops_quietly()
	_test_deep_nested_path()


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _runner() -> Node:
	return get_root().get_node_or_null("/root/DialogueRunner")


## T1 — A path declared in State.reset_state() writes successfully.
func _test_declared_path_writes() -> void:
	print("[T1] declared path writes and returns true")
	var runner: Node = _runner()
	_assert(runner != null, "DialogueRunner autoload available")
	if runner == null:
		return
	var data: Dictionary = {"chapter1": {"met_pig": false}}
	var ok: bool = runner._set_state_value(data, "chapter1.met_pig", true)
	_assert(ok, "_set_state_value returns true for declared key")
	_assert(data["chapter1"]["met_pig"] == true, "value persisted at declared path")


## T2 — Writing to an unknown leaf in strict mode returns false.
func _test_unknown_leaf_strict_fails() -> void:
	print("[T2] unknown leaf key in strict mode returns false")
	var runner: Node = _runner()
	if runner == null:
		return
	var data: Dictionary = {"chapter1": {"met_pig": false}}
	var ok: bool = runner._set_state_value(data, "chapter1.nonexistent_flag", true)
	_assert(not ok, "strict write to undeclared leaf returns false")
	_assert(not data["chapter1"].has("nonexistent_flag"), "undeclared key not silently added")


## T3 — Writing into a missing parent segment returns false in strict mode.
func _test_missing_parent_strict_fails() -> void:
	print("[T3] missing parent segment in strict mode returns false")
	var runner: Node = _runner()
	if runner == null:
		return
	var data: Dictionary = {"chapter1": {"met_pig": false}}
	var ok: bool = runner._set_state_value(data, "nonexistent_section.some_key", true)
	_assert(not ok, "strict write through missing parent returns false")
	_assert(not data.has("nonexistent_section"), "missing parent not silently added")


## T4 — strict=false preserves the legacy silent no-op for callers that
## intentionally probe optional paths.
func _test_permissive_mode_no_ops_quietly() -> void:
	print("[T4] strict=false silently no-ops without error")
	var runner: Node = _runner()
	if runner == null:
		return
	var data: Dictionary = {"chapter1": {"met_pig": false}}
	var ok: bool = runner._set_state_value(data, "chapter1.nonexistent_flag", true, false)
	_assert(not ok, "permissive write still returns false on undeclared leaf")
	_assert(not data["chapter1"].has("nonexistent_flag"), "permissive write does not silently create the key")


## T5 — A path two levels deep into a declared structure writes correctly.
func _test_deep_nested_path() -> void:
	print("[T5] deep nested declared path writes correctly")
	var runner: Node = _runner()
	if runner == null:
		return
	var data: Dictionary = {
		"settings": {
			"coffee_accessibility": {
				"wider_timing": false,
			},
		},
	}
	var ok: bool = runner._set_state_value(data, "settings.coffee_accessibility.wider_timing", true)
	_assert(ok, "deep nested write returns true")
	_assert(data["settings"]["coffee_accessibility"]["wider_timing"] == true,
		"value persisted at deep nested path")


func _finish() -> void:
	print("[StateWriter] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)
