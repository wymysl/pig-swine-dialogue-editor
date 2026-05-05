extends SceneTree
## tests/test_asia_progression.gd — unit test for Asia's hint progression
## based on State.data flags mutating.

var _pass_count: int = 0
var _fail_count: int = 0
var _signal_capture: Array = ["", []]

func _init() -> void:
	print("[TestAsiaProgression] Starting...")
	await process_frame

	var runner_scene := load("res://scripts/systems/dialogue_runner.gd") as GDScript
	if runner_scene == null:
		_fail("Could not load dialogue_runner.gd")
		_finish()
		return

	var runner := Node.new()
	runner.set_script(runner_scene)
	get_root().add_child(runner)
	await process_frame

	var state_node = get_root().get_node_or_null("/root/State")
	if state_node == null:
		_fail("State autoload not available")
		_finish()
		return

	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		_fail("Signals autoload not available")
		_finish()
		return

	var capture := _signal_capture
	sigs.dialogue_line_ready.connect(func(s: String, l: Array) -> void:
		capture[0] = s
		capture[1] = l
	)

	## Test 1: Initial state (met_pig == false, pig_revealed_crisis == false)
	state_node.data["chapter1"]["met_pig"] = false
	state_node.data["chapter1"]["pig_revealed_crisis"] = false
	state_node.data["chapter1"]["met_murrow"] = false
	
	runner._on_dialogue_requested("asia", "Asia")
	await process_frame
	if _signal_capture[1].size() > 0 and "Welcome, Dr. A. Cula" in _signal_capture[1][0]:
		_pass("T1: Asia hint correct before meeting pig")
	else:
		_fail("T1: expected initial hint, got " + str(_signal_capture[1]))

	## Test 2: After meeting pig (pig_revealed_crisis == true, met_murrow == false)
	state_node.data["chapter1"]["pig_revealed_crisis"] = true
	_signal_capture[1] = []
	runner._on_dialogue_requested("asia", "Asia")
	await process_frame
	if _signal_capture[1].size() > 0 and "Mr. Murrow knows what the case is about" in _signal_capture[1][0]:
		_pass("T2: Asia hint correct after meeting pig")
	else:
		_fail("T2: expected post-pig hint, got " + str(_signal_capture[1]))

	## Test 3: After meeting murrow (met_murrow == true, has_law_binder == false)
	state_node.data["chapter1"]["met_murrow"] = true
	_signal_capture[1] = []
	runner._on_dialogue_requested("asia", "Asia")
	await process_frame
	if _signal_capture[1].size() > 0 and "You're after the procedural binder" in _signal_capture[1][0]:
		_pass("T3: Asia hint correct after meeting murrow")
	else:
		_fail("T3: expected post-murrow hint, got " + str(_signal_capture[1]))

	_finish()

func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestAsiaProgression] PASS: ", msg)

func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestAsiaProgression] FAIL: ", msg)

func _finish() -> void:
	print("[TestAsiaProgression] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestAsiaProgression] PASS")
		quit(0)
