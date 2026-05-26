extends SceneTree
## tests/test_battle_controller.gd — restores coverage for the Casebook battle
## controller and the three data resources under scripts/systems/battle/.

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

var _controller = null
var _principle_move_script: GDScript = null
var _state_node: Node = null
var _signals_node: Node = null
var _skepticism_events: Array = []


func _init() -> void:
	print("[TestBattleController] Starting...")
	await process_frame

	_state_node = get_root().get_node_or_null("/root/State")
	_signals_node = get_root().get_node_or_null("/root/Signals")
	if _state_node == null:
		_assert(false, "State autoload registered")
		_finish()
		return
	if _signals_node == null:
		_assert(false, "Signals autoload registered")
		_finish()
		return

	if _signals_node.has_signal("judge_skepticism_raised"):
		_signals_node.judge_skepticism_raised.connect(func(round_index: int, proposed_frame: String) -> void:
			_skepticism_events.append([round_index, proposed_frame])
		)

	var controller_script := load("res://scripts/systems/battle/battle_controller.gd") as GDScript
	_principle_move_script = load("res://scripts/systems/battle/principle_move.gd") as GDScript
	if controller_script == null or _principle_move_script == null:
		_assert(false, "battle scripts load by path")
		_finish()
		return
	_controller = Node.new()
	_controller.set_script(controller_script)
	get_root().add_child(_controller)
	await process_frame

	_test_boot_loads_judgment_and_opponent()
	_test_start_round_sets_round_1_open()
	_test_present_returns_live_bucket()
	_test_backfire_decrements_judicial_patience()
	_test_substantive_defense_starts_phase_2_at_three_patience()
	_test_legacy_merits_defence_alias_still_resolves()
	_test_press_decrements_witness_cooperation()
	_test_unknown_tag_rejected_by_taxonomy()
	_test_end_to_end_three_round_smoke()

	_finish()


func _test_boot_loads_judgment_and_opponent() -> void:
	print("[T1] boot loads judgment and opponent data")
	_reset_state()
	var loaded: bool = _controller.load_data()
	var judgment = _controller.get_judgment("procedural_reset_ch1")
	var opponent = _controller.get_opponent("landlord_counsel_ch1")
	_assert(loaded, "controller load_data returns true")
	_assert(judgment != null, "procedural_reset_ch1 judgment loaded")
	_assert(judgment != null and judgment.principle_moves.size() == 5, "judgment hydrates five principle moves")
	_assert(opponent != null, "landlord_counsel_ch1 opponent loaded")
	_assert(opponent != null and opponent.court_rounds.size() == 3, "opponent hydrates three court rounds")


func _test_start_round_sets_round_1_open() -> void:
	print("[T2] start_round writes round_1_open")
	_reset_state()
	_controller.start_round("landlord_counsel_ch1", 1)
	_assert(_chapter1()["casebook_judge_state"] == "round_1_open", "casebook_judge_state becomes round_1_open")


func _test_present_returns_live_bucket() -> void:
	print("[T3] player_present resolves a live bucket")
	_reset_state()
	_seed_good_frame()
	_controller.start_round("landlord_counsel_ch1", 1)
	_controller.opponent_advance()
	var move = _motion_to_set_aside()
	var result: Dictionary = _controller.player_present(move, "envelope_address_number_seven")
	_assert(_valid_bucket(result.get("bucket", "")), "bucket is one of the five declared values")
	_assert(typeof(result.get("score", null)) == TYPE_FLOAT, "score is a float")


func _test_backfire_decrements_judicial_patience() -> void:
	print("[T4] Phase 2 backfire decrements judicial_patience by 1")
	_reset_state()
	_seed_good_frame()
	_controller.start_round("landlord_counsel_ch1", 3)
	_controller.opponent_advance()
	var active_round = _controller.get_opponent("landlord_counsel_ch1").get_round(3)
	var phase_two_strengths: Array[String] = ["proportionality"]
	active_round.moves[0].resists = phase_two_strengths
	var backfire_move = _principle_move_script.new()
	backfire_move.id = "backfire_probe"
	backfire_move.name = "Backfire Probe"
	backfire_move.effectiveness_modifiers = {
		_principle_move_script.ARTICLE_WEIGHT_KEY: 0.0,
		_principle_move_script.PRINCIPLE_WEIGHT_KEY: 1.0,
		_principle_move_script.CONTEXT_WEIGHT_KEY: 0.0,
	}
	backfire_move.set_judgment_tags({
		"article": [],
		"principle": ["proportionality"],
		"context": [],
	})
	var before: int = int(_chapter1()["judicial_patience"])
	var result: Dictionary = _controller.player_present(backfire_move, "")
	var after: int = int(_chapter1()["judicial_patience"])
	_assert(result.get("bucket", "") == "backfires", "primary strength collision returns backfires")
	_assert(before - after == 1, "judicial_patience decremented by 1")


func _test_substantive_defense_starts_phase_2_at_three_patience() -> void:
	## Renamed from _test_merits_defence_starts_phase_2_at_three_patience per the
	## decoy-revision rename (merits_defence → substantive_defense). The battle
	## controller has a legacy-name compatibility helper (battle_controller.gd
	## _normalise_frame_id) that still accepts "merits_defence" — covered by
	## _test_legacy_merits_defence_alias_still_resolves below.
	print("[T5] substantive_defense starts Phase 2 with judicial_patience 3")
	_reset_state()
	_chapter1()["proposed_frame"] = "substantive_defense"
	_chapter1()["client_meeting_evidence"] = "lease_1962_inheritance_1987"
	_skepticism_events.clear()
	_controller.start_round("landlord_counsel_ch1", 3)
	_assert(_chapter1()["judicial_patience"] == 3, "judicial_patience starts at 3")
	_assert(_skepticism_events.size() == 1 and _skepticism_events[0][0] == 3, "judge_skepticism_raised emitted at round 3 open")


func _test_legacy_merits_defence_alias_still_resolves() -> void:
	## Regression: the battle controller's _normalise_frame_id helper maps the
	## retired 'merits_defence' enum value forward to 'substantive_defense' for
	## old save files still carrying the legacy value. This test exists so a
	## future cleanup pass cannot silently drop the alias.
	print("[T5b] legacy merits_defence alias normalises to substantive_defense")
	_reset_state()
	_chapter1()["proposed_frame"] = "merits_defence"
	_chapter1()["client_meeting_evidence"] = "lease_1962_inheritance_1987"
	_skepticism_events.clear()
	_controller.start_round("landlord_counsel_ch1", 3)
	_assert(_chapter1()["judicial_patience"] == 3, "legacy alias also starts at patience 3")
	_assert(_skepticism_events.size() == 1, "legacy alias still emits judge_skepticism_raised")


func _test_press_decrements_witness_cooperation() -> void:
	print("[T6] Press spends witness cooperation in Phase 1")
	_reset_state()
	_controller.start_round("landlord_counsel_ch1", 1)
	var before: int = int(_chapter1()["witness_cooperation"])
	_controller.opponent_advance()
	_controller.player_press("file_says_served")
	var after: int = int(_chapter1()["witness_cooperation"])
	_assert(before == 3, "Phase 1 starts with cooperation budget 3")
	_assert(after == before - 1, "Press decrements witness_cooperation")


func _test_unknown_tag_rejected_by_taxonomy() -> void:
	print("[T7] taxonomy validation rejects constructed unknown tag")
	var taxonomy: Dictionary = _load_taxonomy()
	var bad_tags: Dictionary[String, float] = {"not_a_real_tag": 1.0}
	var ok: bool = Effectiveness.validate_against_taxonomy(bad_tags, taxonomy)
	_assert(not ok, "unknown tag returns false from validate_against_taxonomy")


func _test_end_to_end_three_round_smoke() -> void:
	print("[T8] full three-round smoke")
	_reset_state()
	_seed_good_frame()
	var move = _motion_to_set_aside()

	_controller.start_round("landlord_counsel_ch1", 1)
	_controller.opponent_advance()
	var r1: Dictionary = _controller.player_present(move, "envelope_address_number_seven")
	_controller.end_round()

	_controller.opponent_advance()
	var r2: Dictionary = _controller.player_present(move, "rights_memo_article_6")
	_controller.end_round()

	_controller.opponent_advance()
	var r3: Dictionary = _controller.player_present(move, "renewal_2019_number_twelve")
	var final_result: Dictionary = _controller.end_round()

	var all_non_backfire: bool = r1.get("bucket", "") != "backfires" \
		and r2.get("bucket", "") != "backfires" \
		and r3.get("bucket", "") != "backfires"
	_assert(all_non_backfire, "all three rounds resolved without backfire")
	_assert(final_result.get("court_won_procedural_reset", false) == true, "court_won_procedural_reset set true")
	_assert(_chapter1()["court_won_procedural_reset"] == true, "State carries court_won_procedural_reset true")


func _motion_to_set_aside():
	var judgment = _controller.get_judgment("procedural_reset_ch1")
	return judgment.get_principle_move("motion_to_set_aside")


func _seed_good_frame() -> void:
	_chapter1()["proposed_frame"] = "defective_service_135bis"
	_chapter1()["binder_read_envelope"] = true
	_chapter1()["binder_read_renewal"] = true
	_chapter1()["binder_read_renumbering"] = true
	_chapter1()["has_rights_memo"] = true


func _reset_state() -> void:
	_state_node.data = _state_node.reset_state()
	_skepticism_events.clear()
	_controller.load_data()


func _chapter1() -> Dictionary:
	return _state_node.data["chapter1"]


func _valid_bucket(bucket: Variant) -> bool:
	return [
		"super_effective",
		"effective",
		"not_very_effective",
		"no_effect",
		"backfires",
	].has(str(bucket))


func _load_taxonomy() -> Dictionary:
	var file := FileAccess.open("res://data/tag_taxonomy.json", FileAccess.READ)
	if file == null:
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		return {}
	return parsed


func _assert(condition: bool, msg: String) -> void:
	_test_count += 1
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


func _finish() -> void:
	print("")
	print("[TestBattleController] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestBattleController] PASS")
		quit(0)
