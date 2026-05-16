extends SceneTree
## test_court_packet_scoring.gd — court consumes the assembled Chapter 1 packet.

var _pass_count: int = 0
var _fail_count: int = 0

var _controller = null
var _state_node: Node = null


func _init() -> void:
	print("[TestCourtPacketScoring] Starting...")
	await process_frame

	_state_node = get_root().get_node_or_null("/root/State")
	if _state_node == null:
		_fail("State autoload registered")
		_finish()
		return

	var controller_script := load("res://scripts/systems/battle/battle_controller.gd") as GDScript
	if controller_script == null:
		_fail("battle_controller.gd loads")
		_finish()
		return
	_controller = Node.new()
	_controller.set_script(controller_script)
	get_root().add_child(_controller)
	await process_frame

	_test_strong_packet_scores_strong()
	_test_standard_packet_requires_address_plus_one()
	_test_narrow_packet_for_wrong_or_thin_shape()
	_test_blunder_packet_uses_ally_recovery()
	_test_incapacity_applies_trust_and_crab_consequences()
	_test_final_court_flags_use_packet_outcome()

	_finish()


func _test_strong_packet_scores_strong() -> void:
	print("[T1] strong packet")
	_reset_state()
	_seed_strong_packet()
	var score: Dictionary = _controller.evaluate_packet_submission()
	_assert(score.get("outcome", "") == "strong", "4/4 supported packet scores strong")
	_assert(score.get("supported_count", 0) == 4, "strong packet counts all four elements")
	_assert(score.get("selected_blunders", []).is_empty(), "strong packet has no blunders")
	_assert(score.get("starting_judicial_patience", 0) == 5, "strong packet keeps full judicial patience")


func _test_standard_packet_requires_address_plus_one() -> void:
	print("[T2] standard packet")
	_reset_state()
	var ch1: Dictionary = _chapter1()
	ch1["binder_read_envelope"] = true
	ch1["binder_read_renewal"] = true
	ch1["packet_slot_address_non_current"] = "envelope_address_number_seven"
	ch1["element_non_current_address"] = true
	ch1["packet_slot_landlord_knowledge"] = "renewal_2019_number_twelve"
	ch1["element_landlord_knowledge"] = true
	var score: Dictionary = _controller.evaluate_packet_submission()
	_assert(score.get("outcome", "") == "standard", "address defect plus one supporting element scores standard")
	_assert(score.get("has_address_defect", false) == true, "standard packet includes address defect")
	_assert(score.get("supporting_detail_count", 0) == 1, "standard packet has one extra element")


func _test_narrow_packet_for_wrong_or_thin_shape() -> void:
	print("[T3] narrow packet")
	_reset_state()
	_seed_strong_packet()
	var ch1: Dictionary = _chapter1()
	ch1["packet_requested_remedy"] = "dismissal_with_prejudice"
	var score: Dictionary = _controller.evaluate_packet_submission()
	_assert(score.get("outcome", "") == "narrow", "overbroad remedy narrows an otherwise supported packet")
	_assert(score.get("reaction_template", "") == "sharper_really_your_theory", "narrow wrong-remedy packet gets sharp judge reaction")
	_assert(score.get("judicial_patience_delta", 0) == -2, "wrong-remedy packet takes a patience hit")

	_reset_state()
	ch1 = _chapter1()
	ch1["surfaced_notice_timeline"] = true
	ch1["surfaced_resident_no_authority"] = true
	ch1["packet_slot_actual_notice_window"] = "notice_timeline_april"
	ch1["element_timely_actual_notice_motion"] = true
	ch1["packet_slot_no_third_party_authority"] = "resident_no_7_no_authority"
	ch1["element_no_third_party_cure"] = true
	score = _controller.evaluate_packet_submission()
	_assert(score.get("outcome", "") == "narrow", "two supported elements without the address defect scores narrow")


func _test_blunder_packet_uses_ally_recovery() -> void:
	print("[T4] blunder packet recovery")
	_reset_state()
	_seed_standard_packet()
	var ch1: Dictionary = _chapter1()
	ch1["recruited_crab"] = true
	ch1["decoy_notice_period"] = true
	var score: Dictionary = _controller.evaluate_packet_submission()
	_assert(score.get("outcome", "") == "blunder-recovered", "burning notice-period decoy scores blunder-recovered")
	_assert(score.get("judicial_patience_delta", 0) == -2, "blunder applies judicial patience hit")
	_assert(score.get("recovery_source", "") == "crab_rescue", "recruited Crab rescues a bad packet")

	_reset_state()
	_seed_standard_packet()
	score = _controller.evaluate_packet_submission()
	_assert(score.get("outcome", "") == "standard", "same packet without blunder returns to standard")


func _test_incapacity_applies_trust_and_crab_consequences() -> void:
	print("[T5] incapacity branch consequences")
	_reset_state()
	_seed_standard_packet()
	var ch1: Dictionary = _chapter1()
	ch1["halina_met"] = true
	ch1["halina_trust"] = 3
	ch1["recruited_crab"] = true
	ch1["surfaced_sikorska_age"] = true
	ch1["decoy_incapacity"] = true
	var score: Dictionary = _controller.consume_assembled_packet()
	_assert(score.get("outcome", "") == "blunder-recovered", "incapacity is recovered, not a hard loss")
	_assert(score.get("reaction_template", "") == "icy_silence", "incapacity gets icy judge response")
	_assert(score.get("recovery_source", "") == "crab_withdrawal", "incapacity withdraws recruited Crab support")
	_assert(_chapter1()["halina_trust"] == -1, "incapacity applies Halina trust penalty")
	_assert(_chapter1()["recruited_crab"] == false, "Crab support is sharply withdrawn")
	_assert(_chapter1()["judicial_patience"] == 0, "incapacity consumes judicial patience")
	_assert(_chapter1()["court_outcome"] == "blunder-recovered", "court_outcome records recovered blunder")


func _test_final_court_flags_use_packet_outcome() -> void:
	print("[T6] final flags use packet outcome")
	_reset_state()
	_seed_strong_packet()
	var move = _motion_to_set_aside()

	_controller.start_round("landlord_counsel_ch1", 1)
	_controller.opponent_advance()
	_controller.player_present(move, "envelope_address_number_seven")
	_controller.end_round()

	_controller.opponent_advance()
	_controller.player_present(move, "rights_memo_article_6")
	_controller.end_round()

	_controller.opponent_advance()
	_controller.player_present(move, "renewal_2019_number_twelve")
	var final_result: Dictionary = _controller.end_round()

	_assert(final_result.get("court_outcome", "") == "strong", "final result preserves strong packet outcome")
	_assert(_chapter1()["court_won_procedural_reset"] == true, "procedural reset floor is set")
	_assert(_chapter1()["won_court"] == true, "won_court is set despite quality grading")


func _seed_standard_packet() -> void:
	var ch1: Dictionary = _chapter1()
	ch1["binder_read_envelope"] = true
	ch1["binder_read_renewal"] = true
	ch1["packet_slot_address_non_current"] = "envelope_address_number_seven"
	ch1["element_non_current_address"] = true
	ch1["packet_slot_landlord_knowledge"] = "renewal_2019_number_twelve"
	ch1["element_landlord_knowledge"] = true


func _seed_strong_packet() -> void:
	_seed_standard_packet()
	var ch1: Dictionary = _chapter1()
	ch1["surfaced_notice_timeline"] = true
	ch1["surfaced_resident_no_authority"] = true
	ch1["packet_slot_actual_notice_window"] = "notice_timeline_april"
	ch1["element_timely_actual_notice_motion"] = true
	ch1["packet_slot_no_third_party_authority"] = "resident_no_7_no_authority"
	ch1["element_no_third_party_cure"] = true


func _motion_to_set_aside():
	var judgment = _controller.get_judgment("procedural_reset_ch1")
	return judgment.get_principle_move("motion_to_set_aside")


func _reset_state() -> void:
	_state_node.data = _state_node.reset_state()
	_controller.load_data()


func _chapter1() -> Dictionary:
	return _state_node.data["chapter1"]


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestCourtPacketScoring] FAIL: %s" % msg)


func _finish() -> void:
	if _controller != null:
		_controller.queue_free()
	print("")
	print("[TestCourtPacketScoring] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestCourtPacketScoring] PASS")
		quit(0)
