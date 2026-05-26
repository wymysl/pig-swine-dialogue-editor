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
	_test_complete_packet_available_citation_stays_strong()
	_test_complete_packet_weak_citations_not_strong()
	_test_unavailable_phase2_citation_downgrades_packet()
	_test_phase2_backfire_downgrades_packet()
	_test_phase2_round_results_accumulated()
	_test_start_round_loads_chapter1_round_file()
	_test_end_round_intermediate_returns_next_index_no_recursion()
	_test_state_accumulates_across_rounds()
	_test_mid_round_2_save_roundtrip()

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
	## Updated 2026-05-26 per design plan Step 3.2: end_round no longer
	## recurses into start_round(N+1); the caller now drives the next round
	## explicitly. Test asserts the round_2/round_3 cuts wire up correctly
	## without the old auto-advance.
	print("[T8] full three-round smoke (explicit round advance, no recursion)")
	_reset_state()
	_seed_good_frame()
	var move = _motion_to_set_aside()

	_controller.start_round("landlord_counsel_ch1", 1)
	_controller.opponent_advance()
	var r1: Dictionary = _controller.player_present(move, "envelope_address_number_seven")
	var end1: Dictionary = _controller.end_round()
	_assert(int(end1.get("next_round_index", 0)) == 2, "end_round R1 returns next_round_index 2")

	_controller.start_round("landlord_counsel_ch1", 2)
	_controller.opponent_advance()
	var r2: Dictionary = _controller.player_present(move, "rights_memo_article_6")
	var end2: Dictionary = _controller.end_round()
	_assert(int(end2.get("next_round_index", 0)) == 3, "end_round R2 returns next_round_index 3")

	_controller.start_round("landlord_counsel_ch1", 3)
	_controller.opponent_advance()
	var r3: Dictionary = _controller.player_present(move, "renewal_2019_number_twelve")
	var final_result: Dictionary = _controller.end_round()

	var all_non_backfire: bool = r1.get("bucket", "") != "backfires" \
		and r2.get("bucket", "") != "backfires" \
		and r3.get("bucket", "") != "backfires"
	_assert(all_non_backfire, "all three rounds resolved without backfire")
	_assert(final_result.get("court_won_procedural_reset", false) == true, "court_won_procedural_reset set true")
	_assert(_chapter1()["court_won_procedural_reset"] == true, "State carries court_won_procedural_reset true")
	_assert(not final_result.has("next_round_index"), "end_round R3 does NOT return next_round_index (terminal)")


func _test_complete_packet_available_citation_stays_strong() -> void:
	## Step 1.1 corrective contract: moving court_outcome out of
	## consume_assembled_packet() must not erase the old best outcome. A complete
	## packet plus the current available Phase 2 citation still reaches STRONG.
	print("[T9] complete packet + available Phase 2 citation stays OUTCOME_STRONG")
	_reset_state()
	_seed_complete_packet()
	var move = _motion_to_set_aside()
	_controller.start_round("landlord_counsel_ch1", 3)
	_controller.opponent_advance()
	var present_result: Dictionary = _controller.player_present(move, "renewal_2019_number_twelve")
	var final_result: Dictionary = _controller.end_round()
	var results: Array = _chapter1().get("phase2_round_results", [])

	_assert(present_result.get("evidence_available", false) == true, "Phase 2 citation evidence is available")
	_assert(results.size() == 1, "one Phase 2 citation recorded")
	if results.size() > 0:
		_assert(results[0].get("evidence_available", false) == true,
			"recorded citation preserves evidence availability")
	_assert(final_result.get("court_outcome", "") == "strong",
		"available current citation preserves OUTCOME_STRONG")


func _test_complete_packet_weak_citations_not_strong() -> void:
	## Step 1.1 load-bearing test: a player who completes the packet perfectly
	## but deliberately mis-cites in Phase 2 must NOT get OUTCOME_STRONG.
	print("[T10] complete packet + weak Phase 2 citations downgrades to OUTCOME_NARROW")
	_reset_state()
	_seed_complete_packet()

	## Manually inject weak Phase 2 results to simulate
	## mis-citation without needing to run the full 3-round flow.
	_chapter1()["phase2_round_results"] = [
		{"round": 3, "citation_id": "bad_cite_1", "evidence_id": "", "evidence_available": true, "effectiveness_bucket": "no_effect", "opponent_move": "move_a"},
		{"round": 3, "citation_id": "bad_cite_2", "evidence_id": "", "evidence_available": true, "effectiveness_bucket": "not_very_effective", "opponent_move": "move_b"},
	]

	var move = _motion_to_set_aside()
	_controller.start_round("landlord_counsel_ch1", 3)
	_controller.opponent_advance()
	_controller.player_present(move, "renewal_2019_number_twelve")
	var final_result: Dictionary = _controller.end_round()

	var outcome: String = str(final_result.get("court_outcome", ""))
	_assert(outcome == "narrow",
		"complete packet with weak citations downgrades to OUTCOME_NARROW (got '%s')" % outcome)


func _test_unavailable_phase2_citation_downgrades_packet() -> void:
	## A citation using evidence outside the current Phase 2 frame must not
	## inherit the packet's strong outcome.
	print("[T11] unavailable Phase 2 citation downgrades complete packet")
	_reset_state()
	_seed_complete_packet()

	var move = _motion_to_set_aside()
	_controller.start_round("landlord_counsel_ch1", 3)
	_controller.opponent_advance()
	var present_result: Dictionary = _controller.player_present(move, "unknown_exhibit")
	var final_result: Dictionary = _controller.end_round()

	_assert(present_result.get("evidence_available", true) == false,
		"unknown evidence is unavailable in Phase 2")
	_assert(final_result.get("court_outcome", "") == "narrow",
		"unavailable citation downgrades final outcome to OUTCOME_NARROW")


func _test_phase2_backfire_downgrades_packet() -> void:
	## Any Phase 2 backfire must downgrade the final band, even if later
	## citations are clean. This protects against per-round bucket overwrites.
	print("[T12] Phase 2 backfire downgrades complete packet")
	_reset_state()
	_seed_complete_packet()
	_chapter1()["phase2_round_results"] = [
		{"round": 3, "citation_id": "bad_cite_backfire", "evidence_id": "", "evidence_available": true, "effectiveness_bucket": "backfires", "opponent_move": "move_a"},
	]

	var move = _motion_to_set_aside()
	_controller.start_round("landlord_counsel_ch1", 3)
	_controller.opponent_advance()
	_controller.player_present(move, "renewal_2019_number_twelve")
	var final_result: Dictionary = _controller.end_round()

	_assert(final_result.get("court_outcome", "") == "narrow",
		"backfire history downgrades final outcome to OUTCOME_NARROW")


func _test_phase2_round_results_accumulated() -> void:
	## Verify that player_present in Phase 2 (round 3) appends to
	## chapter1.phase2_round_results in state.
	print("[T13] Phase 2 present appends citation and evidence ids")
	_reset_state()
	_seed_good_frame()
	_controller.start_round("landlord_counsel_ch1", 3)
	_controller.opponent_advance()
	var move = _motion_to_set_aside()
	_controller.player_present(move, "renewal_2019_number_twelve")
	var results: Array = _chapter1().get("phase2_round_results", [])
	_assert(results.size() == 1, "one Phase 2 result recorded")
	if results.size() > 0:
		var entry: Dictionary = results[0]
		_assert(entry.has("round") and entry["round"] == 3, "round is 3")
		_assert(entry.has("citation_id") and entry["citation_id"] == move.id, "citation_id is the move id")
		_assert(entry.has("evidence_id") and entry["evidence_id"] == "renewal_2019_number_twelve", "evidence_id present")
		_assert(entry.has("evidence_available") and entry["evidence_available"] == true, "evidence_available present")
		_assert(entry.has("effectiveness_bucket"), "effectiveness_bucket present")
		_assert(entry.has("opponent_move"), "opponent_move present")
		_assert(_valid_bucket(entry["effectiveness_bucket"]), "bucket is valid")


func _test_start_round_loads_chapter1_round_file() -> void:
	## Step 3.2: start_round(opp, N) must load chapter1_round_N.json into a
	## controller-side cache exposed via get_active_round_data(). This is the
	## load-bearing assertion for "Controller can run rounds 1 → 2 → 3 with
	## each pulling its own data file" (2026-05-26 design plan Step 3.2).
	print("[T14] start_round loads per-round chapter1_round_N.json file")
	_reset_state()
	_seed_good_frame()
	for round_index in [1, 2, 3]:
		_controller.start_round("landlord_counsel_ch1", round_index)
		var data: Dictionary = _controller.get_active_round_data()
		var expected_id: String = "chapter1_round_%d" % round_index
		_assert(not data.is_empty(), "round %d data dict is non-empty" % round_index)
		_assert(str(data.get("id", "")) == expected_id, "round %d data file id == '%s'" % [round_index, expected_id])
		_assert(int(data.get("chapter", 0)) == 1, "round %d data file declares chapter 1" % round_index)
		_assert(data.has("phase_1_fact_finding"), "round %d data exposes phase_1_fact_finding" % round_index)
		_assert(data.has("phase_2_closing"), "round %d data exposes phase_2_closing" % round_index)


func _test_end_round_intermediate_returns_next_index_no_recursion() -> void:
	## Step 3.2 acceptance: end_round on rounds 1-2 must NOT auto-advance into
	## start_round(N+1) (the old recursive behavior). It writes the round's
	## react_tag and returns next_round_index for the caller to drive.
	print("[T15] end_round R1/R2 returns next_round_index without recursing")
	_reset_state()
	_seed_good_frame()
	var move = _motion_to_set_aside()

	_controller.start_round("landlord_counsel_ch1", 1)
	_controller.opponent_advance()
	_controller.player_present(move, "envelope_address_number_seven")
	var pre_state: String = str(_chapter1().get("casebook_judge_state", ""))
	var end_r1: Dictionary = _controller.end_round()
	var post_state: String = str(_chapter1().get("casebook_judge_state", ""))
	_assert(int(end_r1.get("next_round_index", -1)) == 2, "R1 end_round returns next_round_index == 2")
	_assert(post_state == "round_1_react", "R1 end_round writes casebook_judge_state == round_1_react (got '%s'; pre-state '%s')" % [post_state, pre_state])

	## Without the caller explicitly calling start_round(2), the controller
	## remains anchored on round 1's active_round_data — no silent advance.
	_assert(str(_controller.get_active_round_data().get("id", "")) == "chapter1_round_1",
		"controller does NOT auto-advance: active round data still chapter1_round_1")

	_controller.start_round("landlord_counsel_ch1", 2)
	_controller.opponent_advance()
	_controller.player_present(move, "rights_memo_article_6")
	var end_r2: Dictionary = _controller.end_round()
	_assert(int(end_r2.get("next_round_index", -1)) == 3, "R2 end_round returns next_round_index == 3")
	_assert(str(_chapter1().get("casebook_judge_state", "")) == "round_2_react",
		"R2 end_round writes casebook_judge_state == round_2_react")


func _test_state_accumulates_across_rounds() -> void:
	## Step 3.2 acceptance: "State accumulates across rounds (Round 2's Phase 2
	## sees Round 1's fact-flags; Round 3 sees both)." Flags written by
	## player_press in R1 must persist into R3's Phase 2 view of State.data.
	print("[T16] chapter1.* flags from earlier rounds persist into later rounds")
	_reset_state()
	_seed_good_frame()

	## R1: press a witness statement that establishes a chapter1.* flag.
	## 'file_says_served' triggers _establish_evidence; if the evidence entry
	## carries a sets_flag pointing under chapter1.*, the flag flips.
	_controller.start_round("landlord_counsel_ch1", 1)
	_controller.opponent_advance()
	_controller.player_press("file_says_served")
	var r1_cooperation: int = int(_chapter1().get("witness_cooperation", 0))
	_assert(r1_cooperation == 2, "R1 press decremented witness_cooperation to 2 (got %d)" % r1_cooperation)
	_controller.end_round()

	## R2: cooperation budget resets at start of R2's Phase 1, but chapter1.*
	## state (proposed_frame, packet slots, has_law_binder, etc.) does NOT.
	_controller.start_round("landlord_counsel_ch1", 2)
	_assert(_chapter1().get("proposed_frame", "") == "defective_service_135bis",
		"R2 sees R1's proposed_frame (set via _seed_good_frame)")
	_assert(_chapter1().get("binder_read_envelope", false) == true,
		"R2 sees R1's binder_read_envelope flag")
	_controller.end_round()

	## R3: same accumulated context still present.
	_controller.start_round("landlord_counsel_ch1", 3)
	_assert(_chapter1().get("binder_read_envelope", false) == true,
		"R3 still sees binder_read_envelope flag")
	_assert(_chapter1().get("binder_read_renewal", false) == true,
		"R3 still sees binder_read_renewal flag")


func _test_mid_round_2_save_roundtrip() -> void:
	## Step 3.2 verification: "Save round-trip mid-Round-2." The Step 3.2
	## controller refactor does NOT change State.data shape (the round-file
	## cache is in-memory only), so SAVE_VERSION is unchanged. This test
	## proves that mid-Round-2 chapter1 state survives a disk round-trip
	## through save.gd::save_game / load_game.
	print("[T17] mid-Round-2 save/load disk round-trip preserves chapter1 state")
	_reset_state()
	_seed_good_frame()
	var move = _motion_to_set_aside()

	## Drive to mid-Round-2: open R1, do one Phase 1 action, close R1 (which
	## writes casebook_judge_state := round_1_react and returns next index),
	## then open R2 (which writes casebook_judge_state := round_2_open).
	_controller.start_round("landlord_counsel_ch1", 1)
	_controller.opponent_advance()
	_controller.player_present(move, "envelope_address_number_seven")
	_controller.end_round()
	_controller.start_round("landlord_counsel_ch1", 2)
	_controller.opponent_advance()
	_controller.player_present(move, "rights_memo_article_6")

	var mid_state: String = str(_chapter1().get("casebook_judge_state", ""))
	var mid_frame: String = str(_chapter1().get("proposed_frame", ""))
	_assert(mid_state == "round_2_react", "mid-R2 casebook_judge_state == round_2_react (got '%s')" % mid_state)

	## Disk round-trip via a standalone Save node instance, pattern lifted
	## from tests/test_save_roundtrip.gd::_make_save.
	var save_script: GDScript = load("res://scripts/systems/save.gd") as GDScript
	var save_node: Node = save_script.new()
	get_root().add_child(save_node)
	var tmp_path: String = "user://test_battle_round_save_%d.json" % Time.get_ticks_usec()
	save_node.set_save_path_for_tests(tmp_path)

	var save_ok: bool = save_node.save_game()
	_assert(save_ok, "save_game returns true on mid-R2 state")

	## Mutate State.data away from the saved snapshot so load has work to do.
	_state_node.data = _state_node.reset_state()
	_assert(str(_chapter1().get("casebook_judge_state", "")) != "round_2_react",
		"State reset cleared mid-R2 casebook_judge_state")

	var load_ok: bool = save_node.load_game()
	_assert(load_ok, "load_game returns true reading the mid-R2 save")
	_assert(str(_chapter1().get("casebook_judge_state", "")) == "round_2_react",
		"casebook_judge_state == round_2_react survives the disk round-trip")
	_assert(str(_chapter1().get("proposed_frame", "")) == mid_frame,
		"proposed_frame survives the disk round-trip")

	save_node.queue_free()


func _motion_to_set_aside():
	var judgment = _controller.get_judgment("procedural_reset_ch1")
	return judgment.get_principle_move("motion_to_set_aside")


func _seed_good_frame() -> void:
	_chapter1()["proposed_frame"] = "defective_service_135bis"
	_chapter1()["binder_read_envelope"] = true
	_chapter1()["binder_read_renewal"] = true
	_chapter1()["binder_read_renumbering"] = true
	_chapter1()["has_rights_memo"] = true


func _seed_complete_packet() -> void:
	_seed_good_frame()
	_chapter1()["element_non_current_address"] = true
	_chapter1()["element_landlord_knowledge"] = true
	_chapter1()["element_timely_actual_notice_motion"] = true
	_chapter1()["element_no_third_party_cure"] = true
	_chapter1()["surfaced_notice_timeline"] = true
	_chapter1()["surfaced_resident_no_authority"] = true
	_chapter1()["packet_slot_address_non_current"] = "envelope_address_number_seven"
	_chapter1()["packet_slot_landlord_knowledge"] = "renewal_2019_number_twelve"
	_chapter1()["packet_slot_actual_notice_window"] = "notice_timeline_april"
	_chapter1()["packet_slot_no_third_party_authority"] = "resident_no_7_no_authority"


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
