extends SceneTree
## test_packet_scorer.gd — BlueBinder and BattleController share packet scoring.

var _pass_count: int = 0
var _fail_count: int = 0

var _state: Node = null
var _binder: CanvasLayer = null
var _controller: Node = null


func _init() -> void:
	print("[TestPacketScorer] Starting...")
	await process_frame

	if not _setup():
		_finish()
		return
	await process_frame

	_test_strong_packet_matches()
	_test_decoy_priority_matches()
	_test_under_supported_packet_matches()

	if _binder != null:
		_binder.queue_free()
	if _controller != null:
		_controller.queue_free()
	_finish()


func _setup() -> bool:
	_state = get_root().get_node_or_null("/root/State")
	if _state == null:
		_fail("State autoload registered")
		return false

	var packed: PackedScene = load("res://scenes/ui/blue_binder.tscn") as PackedScene
	if packed == null:
		_fail("blue_binder.tscn loads")
		return false
	_binder = packed.instantiate() as CanvasLayer
	if _binder == null:
		_fail("blue_binder root is CanvasLayer")
		return false
	get_root().add_child(_binder)

	var controller_script := load("res://scripts/systems/battle/battle_controller.gd") as GDScript
	if controller_script == null:
		_fail("battle_controller.gd loads")
		return false
	_controller = Node.new()
	_controller.set_script(controller_script)
	get_root().add_child(_controller)
	return true


func _test_strong_packet_matches() -> void:
	print("[T1] strong packet")
	_reset_state()
	_surface_required_evidence()
	_refresh_binder()
	_assign_strong_packet()
	_assert_shared_score("strong", "defective_service_135bis")


func _test_decoy_priority_matches() -> void:
	print("[T2] decoy priority")
	_reset_state()
	_surface_required_evidence()
	var ch1: Dictionary = _ch1()
	ch1["surfaced_property_transfer"] = true
	_refresh_binder()
	_assign_strong_packet()
	_binder.set_requested_remedy("dismissal_with_prejudice")
	_binder.set_decoy_selected("decoy_standing_wrong_party", true)
	_assert_shared_score("blunder-recovered", "standing_wrong_party")


func _test_under_supported_packet_matches() -> void:
	print("[T3] under-supported packet")
	_reset_state()
	var ch1: Dictionary = _ch1()
	ch1["binder_read_renewal"] = true
	_refresh_binder()
	_binder.assign_evidence_to_slot("element_landlord_knowledge", "renewal_2019_number_twelve")
	_assert_shared_score("blunder-recovered", "defective_service_135bis")


func _assert_shared_score(expected_outcome: String, expected_frame: String) -> void:
	var binder_score: Dictionary = _binder.evaluate_packet()
	var court_score: Dictionary = _controller.evaluate_packet_submission()
	_assert(str(binder_score.get("outcome", "")) == str(court_score.get("outcome", "")),
		"outcome matches")
	_assert(str(court_score.get("outcome", "")) == expected_outcome,
		"outcome is %s" % expected_outcome)
	_assert(str(binder_score.get("proposed_frame", "")) == str(court_score.get("dominant_frame", "")),
		"proposed/dominant frame matches")
	_assert(str(court_score.get("dominant_frame", "")) == expected_frame,
		"dominant frame is %s" % expected_frame)
	_assert(int(binder_score.get("starting_judicial_patience", -1)) == int(court_score.get("starting_judicial_patience", -2)),
		"starting judicial patience matches")
	_assert(binder_score.get("selected_frames", []) == court_score.get("selected_blunders", []),
		"selected frame list matches")


func _reset_state() -> void:
	_state.data = _state.reset_state()


func _ch1() -> Dictionary:
	return _state.data["chapter1"]


func _refresh_binder() -> void:
	if _binder != null and _binder.has_method("refresh_from_state"):
		_binder.refresh_from_state()


func _surface_required_evidence() -> void:
	var ch1: Dictionary = _ch1()
	ch1["binder_read_envelope"] = true
	ch1["binder_read_renewal"] = true
	ch1["surfaced_notice_timeline"] = true
	ch1["surfaced_resident_no_authority"] = true


func _assign_strong_packet() -> void:
	_binder.assign_evidence_to_slot("element_non_current_address", "envelope_address_number_seven")
	_binder.assign_evidence_to_slot("element_landlord_knowledge", "renewal_2019_number_twelve")
	_binder.assign_evidence_to_slot("element_timely_actual_notice_motion", "notice_timeline_april")
	_binder.assign_evidence_to_slot("element_no_third_party_cure", "resident_no_7_no_authority")


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestPacketScorer] FAIL: %s" % msg)


func _finish() -> void:
	print("")
	print("[TestPacketScorer] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestPacketScorer] PASS")
		quit(0)
