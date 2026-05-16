extends SceneTree
## test_chapter1_motion_packet_full_path.gd — full Chapter 1 motion-packet path.
##
## Covers the packet assembly UI, save/load continuity, court packet scoring,
## court outcome flags, and the first post-court dialogue beats.

var _pass_count: int = 0
var _fail_count: int = 0

var _state: Node = null
var _sigs: Node = null
var _runner: Node = null
var _binder: CanvasLayer = null
var _controller: Node = null
var _save_node: Node = null
var _capture: Dictionary = {"speaker": "", "npc_id": "", "lines": []}
const TEMP_SAVE_PATH: String = "/tmp/pig_swine_motion_packet_full_path_save.json"


func _init() -> void:
	print("[TestCh1MotionPacketFullPath] Starting...")
	await process_frame

	if not _setup():
		_finish()
		return

	_test_strong_packet_survives_save_load_and_reaches_strong_dialogue()
	_test_standard_packet_scores_standard()
	_test_decoy_merits()
	_test_decoy_notice_period()
	_test_decoy_standing_wrong_party()
	_test_overbroad_remedy()
	_test_incapacity_blunder()
	_test_missing_evidence_under_investigated_path()

	if _binder != null:
		_binder.queue_free()
	if _controller != null:
		_controller.queue_free()
	if _save_node != null:
		_save_node.queue_free()
	_finish()


func _setup() -> bool:
	_state = get_root().get_node_or_null("/root/State")
	_sigs = get_root().get_node_or_null("/root/Signals")
	_runner = get_root().get_node_or_null("/root/DialogueRunner")
	if _state == null or _sigs == null or _runner == null:
		_fail("State, Signals, and DialogueRunner autoloads are registered")
		return false

	_sigs.dialogue_line_ready.connect(_on_dialogue_line_ready)

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

	var save_script := load("res://scripts/systems/save.gd") as GDScript
	if save_script == null:
		_fail("save.gd loads")
		return false
	_save_node = Node.new()
	_save_node.set_script(save_script)
	get_root().add_child(_save_node)
	return true


func _test_strong_packet_survives_save_load_and_reaches_strong_dialogue() -> void:
	print("[T1] strong packet + save/load + post-court dialogue")
	_reset_state()
	_surface_required_evidence()
	_refresh_binder()
	_assign_strong_packet()
	var apply_score: Dictionary = _binder.apply_packet_assessment()
	_assert(bool(apply_score.get("applied", false)), "strong packet applies through BlueBinder")

	var loaded: bool = _round_trip_packet_save()
	_assert(loaded, "temp save/load succeeds after packet assembly")
	var ch1: Dictionary = _ch1()
	_assert(ch1["packet_slot_address_non_current"] == "envelope_address_number_seven",
		"loaded save preserves address slot")
	_assert(ch1["packet_slot_landlord_knowledge"] == "renewal_2019_number_twelve",
		"loaded save preserves landlord-knowledge slot")
	_assert(ch1["packet_slot_actual_notice_window"] == "notice_timeline_april",
		"loaded save preserves actual-notice slot")
	_assert(ch1["packet_slot_no_third_party_authority"] == "resident_no_7_no_authority",
		"loaded save preserves third-party-authority slot")

	_controller.load_data()
	var score: Dictionary = _controller.evaluate_packet_submission()
	_assert(score.get("outcome", "") == "strong", "loaded 4/4 packet scores strong")

	var final_result: Dictionary = _play_court_to_remedy()
	_assert(final_result.get("court_outcome", "") == "strong", "court final result preserves strong packet outcome")
	_assert(ch1["court_won_procedural_reset"] == true and ch1["won_court"] == true,
		"court outcome flags are set on strong path")

	var judge: Dictionary = _request_dialogue("judge_district_ch1", "Judge")
	_assert(_first_line(judge).contains("all four elements"),
		"judge strong remedy dialogue acknowledges all four elements")
	_sigs.dialogue_dismissed.emit()

	ch1["beat13_complete"] = true
	var postcard: Dictionary = _request_dialogue("postcard_swine_ch1", "Postcard")
	_assert(_first_line(postcard) == "Mr. Pig. Postcard. The address says Sapporo.",
		"post-court postcard dialogue becomes reachable after court flags")
	_sigs.dialogue_dismissed.emit()
	_assert(ch1["received_swine_postcard"] == true, "postcard opener marks postcard received")


func _test_standard_packet_scores_standard() -> void:
	print("[T2] standard correct packet")
	_reset_state()
	_surface_required_evidence()
	_refresh_binder()
	_assign_standard_packet()
	var score: Dictionary = _controller.evaluate_packet_submission()
	_assert(score.get("outcome", "") == "standard", "3/4 correct packet scores standard")
	_assert(int(score.get("supported_count", 0)) == 3, "standard packet counts three supported elements")
	_assert(str(score.get("reaction_template", "")) == "approving_set_aside",
		"standard correct packet keeps the ordinary set-aside reaction")

	_ch1()["casebook_judge_state"] = "round_3_remedy"
	_ch1()["court_outcome"] = "standard"
	var judge: Dictionary = _request_dialogue("judge_district_ch1", "Judge")
	_assert(_first_line(judge).contains("imperfect but sufficient"),
		"judge standard remedy dialogue is selected")
	_sigs.dialogue_dismissed.emit()


func _test_decoy_merits() -> void:
	print("[T3] merits decoy")
	_reset_state()
	_surface_required_evidence()
	_ch1()["surfaced_payment_receipts"] = true
	_refresh_binder()
	_assign_strong_packet()
	_binder.set_decoy_selected("decoy_merits", true)
	_binder.apply_packet_assessment()
	var score: Dictionary = _controller.consume_assembled_packet()
	_assert(score.get("dominant_frame", "") == "substantive_defense",
		"merits decoy becomes the dominant frame")
	_assert(score.get("reaction_template", "") == "tolerant_try_again",
		"merits decoy uses the tolerant correction reaction")
	_assert(score.get("outcome", "") == "blunder-recovered",
		"merits decoy burns a round attempt and is recovered")
	_assert(_ch1()["judicial_patience"] == 3, "merits decoy applies -2 judicial patience")


func _test_decoy_notice_period() -> void:
	print("[T4] notice-period decoy")
	_reset_state()
	_surface_required_evidence()
	_ch1()["surfaced_tenancy_act_window"] = true
	_ch1()["halina_trust"] = 2
	_refresh_binder()
	_assign_strong_packet()
	_binder.set_decoy_selected("decoy_notice_period", true)
	_binder.apply_packet_assessment()
	var score: Dictionary = _controller.consume_assembled_packet()
	_assert(score.get("dominant_frame", "") == "notice_period_failure",
		"notice-period decoy becomes the dominant frame")
	_assert(score.get("reaction_template", "") == "cool_dismissal",
		"notice-period decoy uses cool dismissal")
	_assert(score.get("outcome", "") == "blunder-recovered",
		"notice-period decoy is recovered rather than blocking the chapter")
	_assert(_ch1()["halina_trust"] == 1, "notice-period decoy applies Halina trust penalty")


func _test_decoy_standing_wrong_party() -> void:
	print("[T5] standing / wrong-party decoy")
	_reset_state()
	_surface_required_evidence()
	_ch1()["surfaced_property_transfer"] = true
	_ch1()["halina_trust"] = 2
	_refresh_binder()
	_assign_strong_packet()
	_binder.set_decoy_selected("decoy_standing_wrong_party", true)
	_binder.apply_packet_assessment()
	var score: Dictionary = _controller.consume_assembled_packet()
	_assert(score.get("dominant_frame", "") == "standing_wrong_party",
		"standing decoy becomes the dominant frame")
	_assert(score.get("reaction_template", "") == "sharper_really_your_theory",
		"standing decoy gets the sharper bench reaction")
	_assert(score.get("outcome", "") == "blunder-recovered",
		"standing decoy is recovered rather than hard-failing")
	_assert(_ch1()["judicial_patience"] == 2, "standing decoy applies -3 judicial patience")
	_assert(_ch1()["halina_trust"] == 1, "standing decoy applies Halina trust penalty")


func _test_overbroad_remedy() -> void:
	print("[T6] overbroad remedy")
	_reset_state()
	_surface_required_evidence()
	_refresh_binder()
	_assign_strong_packet()
	_binder.set_requested_remedy("dismissal_with_prejudice")
	_binder.apply_packet_assessment()
	var score: Dictionary = _controller.consume_assembled_packet()
	_assert(score.get("dominant_frame", "") == "overbroad_remedy",
		"overbroad remedy becomes the dominant frame")
	_assert(score.get("outcome", "") == "narrow", "overbroad remedy narrows a strong packet")
	_assert(score.get("reaction_template", "") == "sharper_really_your_theory",
		"overbroad remedy gets the sharper bench reaction")

	_ch1()["casebook_judge_state"] = "round_3_remedy"
	var judge: Dictionary = _request_dialogue("judge_district_ch1", "Judge")
	_assert(_first_line(judge).contains("asked for the world"),
		"judge overbroad-remedy dialogue is selected")
	_sigs.dialogue_dismissed.emit()


func _test_incapacity_blunder() -> void:
	print("[T7] incapacity blunder")
	_reset_state()
	_surface_required_evidence()
	_ch1()["halina_met"] = true
	_ch1()["surfaced_sikorska_age"] = true
	_ch1()["halina_trust"] = 4
	_ch1()["recruited_crab"] = true
	_refresh_binder()
	_assign_strong_packet()
	_binder.set_decoy_selected("decoy_incapacity", true)
	_binder.apply_packet_assessment()
	var score: Dictionary = _controller.consume_assembled_packet()
	_assert(score.get("dominant_frame", "") == "incapacity_defense",
		"incapacity becomes the dominant frame")
	_assert(score.get("reaction_template", "") == "icy_silence",
		"incapacity gets the icy bench reaction")
	_assert(score.get("outcome", "") == "blunder-recovered",
		"incapacity is recovered as the chapter floor")
	_assert(_ch1()["halina_trust"] == 0, "incapacity applies -4 Halina trust")
	_assert(_ch1()["recruited_crab"] == false, "incapacity withdraws Crab support")
	_assert(_ch1()["judicial_patience"] == 0, "incapacity drains judicial patience")

	_ch1()["casebook_judge_state"] = "round_3_remedy"
	var judge: Dictionary = _request_dialogue("judge_district_ch1", "Judge")
	_assert(_first_line(judge).contains("cognitive, not chronological"),
		"judge incapacity dialogue names the capacity error")
	_sigs.dialogue_dismissed.emit()


func _test_missing_evidence_under_investigated_path() -> void:
	print("[T8] missing evidence / under-investigated path")
	_reset_state()
	_refresh_binder()
	var blocked: Dictionary = _binder.apply_packet_assessment()
	_assert(bool(blocked.get("applied", true)) == false,
		"BlueBinder refuses to apply an empty packet assessment")
	var score: Dictionary = _controller.consume_assembled_packet()
	_assert(score.get("outcome", "") == "blunder-recovered",
		"empty packet is recovered by the court floor")
	_assert(score.get("recovery_source", "") == "court_redirect",
		"under-investigated packet uses court redirect when no ally can rescue it")
	_assert(_ch1()["court_outcome"] == "blunder-recovered",
		"court_outcome records under-investigated recovery")


func _reset_state() -> void:
	_state.data = _state.reset_state()
	_controller.load_data()
	_capture = {"speaker": "", "npc_id": "", "lines": []}


func _surface_required_evidence() -> void:
	var ch1: Dictionary = _ch1()
	ch1["has_law_binder"] = true
	ch1["has_rights_memo"] = true
	ch1["binder_read_envelope"] = true
	ch1["binder_read_renewal"] = true
	ch1["binder_read_renumbering"] = true
	ch1["surfaced_notice_timeline"] = true
	ch1["surfaced_resident_no_authority"] = true


func _refresh_binder() -> void:
	if _binder != null and _binder.has_method("refresh_from_state"):
		_binder.refresh_from_state()


func _assign_strong_packet() -> void:
	_binder.assign_evidence_to_slot("element_non_current_address", "envelope_address_number_seven")
	_binder.assign_evidence_to_slot("element_landlord_knowledge", "renewal_2019_number_twelve")
	_binder.assign_evidence_to_slot("element_timely_actual_notice_motion", "notice_timeline_april")
	_binder.assign_evidence_to_slot("element_no_third_party_cure", "resident_no_7_no_authority")
	_binder.set_requested_remedy("procedural_reset")


func _assign_standard_packet() -> void:
	_binder.assign_evidence_to_slot("element_non_current_address", "envelope_address_number_seven")
	_binder.assign_evidence_to_slot("element_landlord_knowledge", "renewal_2019_number_twelve")
	_binder.assign_evidence_to_slot("element_timely_actual_notice_motion", "notice_timeline_april")
	_binder.set_requested_remedy("procedural_reset")


func _play_court_to_remedy() -> Dictionary:
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
	return _controller.end_round()


func _motion_to_set_aside():
	var judgment = _controller.get_judgment("procedural_reset_ch1")
	return judgment.get_principle_move("motion_to_set_aside")


func _request_dialogue(npc_id: String, display_name: String) -> Dictionary:
	_capture = {"speaker": "", "npc_id": "", "lines": []}
	_runner._on_dialogue_requested(npc_id, display_name)
	return _capture.duplicate(true)


func _first_line(dialogue: Dictionary) -> String:
	var lines: Array = dialogue.get("lines", [])
	if lines.is_empty():
		return ""
	return str(lines[0])


func _ch1() -> Dictionary:
	return _state.data["chapter1"]


func _on_dialogue_line_ready(speaker: String, npc_id: String, lines: Array) -> void:
	_capture["speaker"] = speaker
	_capture["npc_id"] = npc_id
	_capture["lines"] = lines


func _round_trip_packet_save() -> bool:
	## The production Save node writes user://save.json. Headless macOS runs
	## can be denied that path before the engine's GUI entitlements are in
	## place, so this focused regression uses the same versioned payload shape
	## and migration function against a /tmp file.
	var payload: Dictionary = {
		"version": int(_state.SAVE_VERSION),
		"data": _state.data,
	}
	var file := FileAccess.open(TEMP_SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(payload, "\t"))
	file.close()

	_state.data = _state.reset_state()

	var read_file := FileAccess.open(TEMP_SAVE_PATH, FileAccess.READ)
	if read_file == null:
		return false
	var parsed: Variant = JSON.parse_string(read_file.get_as_text())
	read_file.close()
	DirAccess.remove_absolute(TEMP_SAVE_PATH)
	if parsed == null or not parsed is Dictionary:
		return false

	var version: int = int(parsed.get("version", 1))
	var saved_data: Dictionary = parsed.get("data", {})
	_state.data = _save_node.migrate_save(saved_data, version)
	return true


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestCh1MotionPacketFullPath] FAIL: %s" % msg)


func _finish() -> void:
	print("")
	print("[TestCh1MotionPacketFullPath] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestCh1MotionPacketFullPath] PASS")
		quit(0)
