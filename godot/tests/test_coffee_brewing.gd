extends SceneTree
## tests/test_coffee_brewing.gd — exercises judgment, grading, and
## result emission against the live coffee_brewing scene.
## Runs headless. Exits 0 on pass, 1 on fail.

const COFFEE_SCENE_PATH: String = "res://scenes/minigames/coffee_brewing.tscn"

## Phase.GRIND ordinal. Phase enum is { INTRO=0, READY=1, GRIND=2, POUR=3,
## SERVE=4, RESULT=5, EXIT=6 } per coffee_brewing.gd. Adjust if the enum changes.
const PHASE_GRIND: int = 2

var _pass_count: int = 0
var _fail_count: int = 0
var _skip_count: int = 0


func _init() -> void:
	print("[TestCoffeeBrewing] Starting...")
	await process_frame

	_test_scene_loads_cleanly()
	_test_pattern_loads_and_splits_into_phases()
	_test_perfect_run_grade_and_buff()
	_test_all_miss_run_grade_buff_and_progression()
	_test_result_dictionary_shape()
	_test_state_writes_after_perfect_run()
	_test_minigame_finished_signal_payload()
	_test_normal_mode_four_lanes_and_lane_inputs()
	_test_single_button_assist_collapses_lane_matching()
	_test_wider_timing_assist_widens_windows()

	paused = false
	await process_frame
	await process_frame
	_finish()


func _test_scene_loads_cleanly() -> void:
	var engine: Node = _instantiate_engine("chapter1_court_coffee")
	if engine == null:
		_fail("T1: scene did not instantiate")
		return

	var expected_paths: Array[String] = [
		"BackgroundPanel",
		"BackgroundPanel/PromptSpawner",
		"AnimationPlayer",
		"PauseLayer",
	]
	var ok: bool = true
	for node_path in expected_paths:
		if not engine.has_node(node_path):
			_fail("T1: missing expected child " + node_path)
			ok = false
	if ok:
		_pass("T1: coffee scene instantiates and exposes expected child nodes")
	_cleanup_engine(engine)


func _test_pattern_loads_and_splits_into_phases() -> void:
	var engine: Node = _instantiate_engine("chapter1_court_coffee")
	if engine == null:
		_fail("T2: scene did not instantiate")
		return

	var phases: Dictionary = _phases(engine)
	var phase_ok: bool = (
		phases.has("grind") and phases["grind"] is Array and phases["grind"].size() > 0
		and phases.has("pour") and phases["pour"] is Array and phases["pour"].size() > 0
		and phases.has("serve") and phases["serve"] is Array and phases["serve"].size() > 0
	)
	var ok: bool = (
		str(engine.get("pattern_id")) == "chapter1_court_coffee"
		and int(engine.get("_lane_count")) == 2
		and phase_ok
	)
	if ok:
		_pass("T2: chapter1_court_coffee loads as 2 lanes and splits into grind/pour/serve arrays")
	else:
		_fail("T2: pattern split wrong; pattern_id=%s lanes=%s phases=%s" % [
			str(engine.get("pattern_id")), str(engine.get("_lane_count")), str(phases)
		])
	_cleanup_engine(engine)


func _test_perfect_run_grade_and_buff() -> void:
	_reset_state()
	var engine: Node = _instantiate_engine("chapter1_court_coffee")
	if engine == null:
		_fail("T3: scene did not instantiate")
		return

	_drive_perfect_run(engine)
	var result: Dictionary = _computed_result(engine)
	if result.is_empty():
		_cleanup_engine(engine)
		return

	var ok: bool = (
		result.get("grade") == "S"
		and result.get("buff") == "procedurally_alert_plus"
		and int(result.get("brew_quality", 0)) > int(result.get("bitterness", 0)) + 600
	)
	if ok:
		_pass("T3: perfect run computes S grade, Procedurally Alert+, and high quality margin")
	else:
		_fail("T3: perfect run result wrong: " + str(result))
	_cleanup_engine(engine)


func _test_all_miss_run_grade_buff_and_progression() -> void:
	_reset_state()
	var engine: Node = _instantiate_engine("chapter1_court_coffee")
	if engine == null:
		_fail("T4: scene did not instantiate")
		return

	_drive_all_miss_run(engine)
	var result: Dictionary = _computed_result(engine)
	engine.call("_exit_minigame")

	var state_node = get_root().get_node_or_null("/root/State")
	var ch1: Dictionary = state_node.get("data").get("chapter1", {}) if state_node else {}
	var ok: bool = (
		str(result.get("grade", "")) in ["D", "F"]
		and result.get("buff") == "over_caffeinated"
		and int(result.get("bitterness", 0)) > int(result.get("brew_quality", 0))
		and ch1.get("coffee_tutorial_seen", false) == true
	)
	if ok:
		_pass("T4: all-miss run soft-fails with over_caffeinated and still advances tutorial flag")
	else:
		_fail("T4: all-miss result/state wrong; result=%s chapter1=%s" % [str(result), str(ch1)])
	_cleanup_engine(engine)


func _test_result_dictionary_shape() -> void:
	_reset_state()
	var engine: Node = _instantiate_engine("chapter1_court_coffee")
	if engine == null:
		_fail("T5: scene did not instantiate")
		return

	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		_fail("T5: Signals autoload not available")
		_cleanup_engine(engine)
		return

	var captured_result: Array = [{}]
	sigs.coffee_brewing_completed.connect(func(result: Dictionary) -> void:
		captured_result[0] = result
	, CONNECT_ONE_SHOT)

	_drive_perfect_run(engine)
	engine.call("_exit_minigame")

	var result: Dictionary = captured_result[0]
	var expected_types: Dictionary = {
		"minigame": TYPE_STRING,
		"context": TYPE_STRING,
		"grade": TYPE_STRING,
		"result": TYPE_STRING,
		"buff": TYPE_STRING,
		"brew_quality": TYPE_INT,
		"bitterness": TYPE_INT,
		"perfect_hits": TYPE_INT,
		"good_hits": TYPE_INT,
		"okay_hits": TYPE_INT,
		"misses": TYPE_INT,
		"assist_used": TYPE_BOOL,
	}
	var ok: bool = true
	for key in expected_types:
		if not result.has(key):
			_fail("T5: emitted result missing key " + key)
			ok = false
		elif typeof(result[key]) != expected_types[key]:
			_fail("T5: result.%s expected type %s, got %s" % [
				key, str(expected_types[key]), str(typeof(result[key]))
			])
			ok = false
	if result.get("minigame", "") != "coffee_brewing":
		_fail("T5: result.minigame should be coffee_brewing, got " + str(result.get("minigame", "")))
		ok = false
	if ok:
		_pass("T5: coffee_brewing_completed emits the full spec-shaped result dictionary")
	_cleanup_engine(engine)


func _test_state_writes_after_perfect_run() -> void:
	_reset_state()
	var engine: Node = _instantiate_engine("chapter1_court_coffee")
	if engine == null:
		_fail("T6: scene did not instantiate")
		return

	_drive_perfect_run(engine)
	engine.call("_exit_minigame")

	var state_node = get_root().get_node_or_null("/root/State")
	var data: Dictionary = state_node.get("data") if state_node else {}
	var ch1: Dictionary = data.get("chapter1", {})
	var coffee: Dictionary = data.get("coffee", {})
	var ok: bool = (
		ch1.get("coffee_tutorial_seen", false) == true
		and ch1.get("coffee_buff", "") == "procedurally_alert_plus"
		and ch1.get("coffee_brew_grade", "") == "S"
		and coffee.get("tutorial_seen", false) == true
		and int(coffee.get("times_brewed", 0)) > 0
		and coffee.get("last_buff", "") == "procedurally_alert_plus"
	)
	if ok:
		_pass("T6: perfect run writes chapter1 and top-level coffee state")
	else:
		_fail("T6: state writes wrong; chapter1=%s coffee=%s" % [str(ch1), str(coffee)])
	_cleanup_engine(engine)


func _test_minigame_finished_signal_payload() -> void:
	_reset_state()
	var engine: Node = _instantiate_engine("chapter1_court_coffee")
	if engine == null:
		_fail("T7: scene did not instantiate")
		return

	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		_fail("T7: Signals autoload not available")
		_cleanup_engine(engine)
		return

	var captured: Array = ["", ""]
	sigs.minigame_finished.connect(func(minigame_id: String, outcome: String) -> void:
		captured[0] = minigame_id
		captured[1] = outcome
	, CONNECT_ONE_SHOT)

	_drive_perfect_run(engine)
	engine.call("_exit_minigame")

	if captured[0] == "coffee_brewing" and captured[1] == "procedurally_alert_plus":
		_pass("T7: minigame_finished emits coffee_brewing with the grade-derived buff")
	else:
		_fail("T7: minigame_finished payload wrong: " + str(captured))
	_cleanup_engine(engine)


func _test_normal_mode_four_lanes_and_lane_inputs() -> void:
	_reset_state()
	var engine: Node = _instantiate_engine("office_standard_coffee")
	if engine == null:
		_fail("T8: scene did not instantiate")
		return

	var lanes_ok: bool = int(engine.get("_lane_count")) == 4
	var before_hits: int = int(engine.get("_perfect_hits"))
	## Force out of INTRO; input is ignored during INTRO phase.
	engine.set("_phase", PHASE_GRIND)
	_set_single_active_note(engine, 2, 4.0)
	engine.set("_beat_time", 4.0)
	_send_action(engine, "move_up")
	_set_single_active_note(engine, 3, 6.0)
	engine.set("_beat_time", 6.0)
	_send_action(engine, "move_down")
	var input_ok: bool = int(engine.get("_perfect_hits")) == before_hits + 2

	if lanes_ok and input_ok:
		_pass("T8: office_standard_coffee loads 4 lanes and lane-2/lane-3 inputs judge cleanly")
	else:
		_fail("T8: normal-mode lane check failed; lanes=%s perfect_hits=%s before=%s" % [
			str(engine.get("_lane_count")), str(engine.get("_perfect_hits")), str(before_hits)
		])
	_cleanup_engine(engine)


func _test_single_button_assist_collapses_lane_matching() -> void:
	_reset_state()
	var engine: Node = _instantiate_engine("office_standard_coffee")
	if engine == null:
		_fail("T9: scene did not instantiate")
		return

	engine.set("_single_button_enabled", true)
	engine.set("_single_button_used_this_run", true)
	## Force out of INTRO; input is ignored during INTRO phase.
	engine.set("_phase", PHASE_GRIND)
	_set_single_active_note(engine, 3, 8.0)
	engine.set("_beat_time", 8.0)
	_send_action(engine, "interact")

	if int(engine.get("_perfect_hits")) == 1 and int(engine.get("_wrong_hits")) == 0:
		_pass("T9: single-button assist accepts the nearest note without lane mismatch penalty")
	else:
		_fail("T9: single-button assist failed; perfect=%s wrong=%s" % [
			str(engine.get("_perfect_hits")), str(engine.get("_wrong_hits"))
		])
	_cleanup_engine(engine)


func _test_wider_timing_assist_widens_windows() -> void:
	_reset_state()
	var normal_engine: Node = _instantiate_engine("office_standard_coffee")
	if normal_engine == null:
		_fail("T10: normal scene did not instantiate")
		return
	var assisted_engine: Node = _instantiate_engine("office_standard_coffee")
	if assisted_engine == null:
		_fail("T10: assisted scene did not instantiate")
		_cleanup_engine(normal_engine)
		return

	var offset: float = float(normal_engine.get("_okay_window")) * 1.25

	normal_engine.set("_wider_timing_enabled", false)
	_set_single_active_note(normal_engine, 0, 10.0)
	normal_engine.set("_beat_time", 10.0 + offset)
	normal_engine.call("_try_judge_lane", 0)

	assisted_engine.set("_wider_timing_enabled", true)
	assisted_engine.set("_wider_timing_used_this_run", true)
	_set_single_active_note(assisted_engine, 0, 10.0)
	assisted_engine.set("_beat_time", 10.0 + offset)
	assisted_engine.call("_try_judge_lane", 0)

	var normal_missed: bool = int(normal_engine.get("_misses")) == 1 and int(normal_engine.get("_okay_hits")) == 0
	var assisted_accepted: bool = int(assisted_engine.get("_okay_hits")) == 1 and int(assisted_engine.get("_misses")) == 0
	if normal_missed and assisted_accepted:
		_pass("T10: wider timing turns a beyond-normal OKAY offset from miss into okay")
	else:
		_fail("T10: wider timing comparison failed; normal misses/okay=%s/%s assisted misses/okay=%s/%s offset=%s" % [
			str(normal_engine.get("_misses")), str(normal_engine.get("_okay_hits")),
			str(assisted_engine.get("_misses")), str(assisted_engine.get("_okay_hits")),
			str(offset)
		])
	_cleanup_engine(normal_engine)
	_cleanup_engine(assisted_engine)


func _instantiate_engine(pattern_id: String) -> Node:
	var packed_scene: PackedScene = load(COFFEE_SCENE_PATH) as PackedScene
	if packed_scene == null:
		_fail("Could not load " + COFFEE_SCENE_PATH)
		return null
	var engine: Node = packed_scene.instantiate()
	if engine == null:
		_fail("Could not instantiate " + COFFEE_SCENE_PATH)
		return null
	engine.set("pattern_id", pattern_id)
	get_root().add_child(engine)
	return engine


func _cleanup_engine(engine: Node) -> void:
	if engine != null and is_instance_valid(engine) and not engine.is_queued_for_deletion():
		if engine.get_parent() != null:
			engine.get_parent().remove_child(engine)
		engine.free()
	paused = false


func _reset_state() -> void:
	var state_node = get_root().get_node_or_null("/root/State")
	if state_node == null:
		_fail("State autoload not available")
		return
	state_node.set("data", state_node.call("reset_state"))


func _phases(engine: Node) -> Dictionary:
	var phases = engine.get("_phases_data")
	if phases is Dictionary:
		return phases
	return {}


func _drive_perfect_run(engine: Node) -> void:
	engine.set("_phase", PHASE_GRIND)
	engine.set("_beat_time", 0.0)
	var phases: Dictionary = _phases(engine)
	_register_notes(engine, phases.get("grind", []), "perfect", true)
	_judge_pour_center(engine)
	_register_notes(engine, phases.get("serve", []), "perfect", true)


func _drive_all_miss_run(engine: Node) -> void:
	engine.set("_phase", PHASE_GRIND)
	engine.set("_beat_time", 0.0)
	var phases: Dictionary = _phases(engine)
	_register_notes(engine, phases.get("grind", []), "miss", false)
	_register_notes(engine, phases.get("serve", []), "miss", false)


func _register_notes(engine: Node, notes: Array, judgment: String, include_stamp: bool) -> void:
	for raw_note in notes:
		if not raw_note is Dictionary:
			continue
		var note: Dictionary = raw_note
		var kind: String = str(note.get("kind", "tap"))
		if kind == "pour":
			continue
		if kind == "stamp" and not include_stamp:
			continue
		engine.call("_register_judgment", judgment, note)


func _judge_pour_center(engine: Node) -> void:
	var phases: Dictionary = _phases(engine)
	var pour_notes: Array = phases.get("pour", [])
	if pour_notes.is_empty() or not pour_notes[0] is Dictionary:
		_fail("No pour note available for centered pour judgment")
		return
	var pour_note: Dictionary = pour_notes[0]
	var target_start: float = float(pour_note.get("target_start", 0.0))
	var target_end: float = float(pour_note.get("target_end", target_start))
	engine.set("_pour_active", true)
	engine.set("_pour_handled", false)
	engine.set("_pour_target_start", target_start)
	engine.set("_pour_target_end", target_end)
	engine.set("_beat_time", (target_start + target_end) / 2.0)
	engine.call("_judge_pour_release")


func _computed_result(engine: Node) -> Dictionary:
	var result = engine.call("_compute_grade")
	if result is Dictionary:
		return result
	_fail("_compute_grade did not return a Dictionary: " + str(result))
	return {}


func _set_single_active_note(engine: Node, lane: int, note_time: float) -> void:
	engine.set("_active_notes", [{
		"node": null,
		"time": note_time,
		"lane": lane,
		"kind": "tap",
		"icon": "bean",
		"judged": false,
	}])


func _send_action(engine: Node, action: String) -> void:
	var event := InputEventAction.new()
	event.action = action
	event.pressed = true
	engine.call("_unhandled_input", event)


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestCoffeeBrewing] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestCoffeeBrewing] FAIL: ", msg)


func _skip(msg: String) -> void:
	_skip_count += 1
	print("[TestCoffeeBrewing] SKIP: ", msg)


func _finish() -> void:
	print("")
	print("[TestCoffeeBrewing] Results: %d passed, %d failed, %d skipped" % [
		_pass_count, _fail_count, _skip_count
	])
	quit(0 if _fail_count == 0 else 1)
