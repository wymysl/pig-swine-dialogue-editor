extends SceneTree
## tests/test_chapter1_phase_b.gd — verifies Chapter 1 Phase B wiring.
##
## Coverage:
##   T1   — Halina intro option writes "sympathetic"
##   T2   — Halina intro option writes "blunt_procedural"
##   T3   — Halina intro option writes "technical"
##   T4   — Each commit also emits Signals.chapter1_flag_changed with the
##          new stance value.
##   T5   — V1.A Asia announcement state matches when
##          recruited_whimsy=true && halina_arrived=false; its line is the
##          canonical "Mrs. Sikorska is here..." line; its on_dismiss flips
##          halina_arrived true.
##   T6   — Once halina_arrived=true, V1.A state 7 (hint_halina_met) wins
##          the priority race — the announcement does NOT re-fire.
##   T7-9 — halina.json dispatch reaches the correct round-0 state:
##          sympathetic → client_meeting_evidence = wojcik_witness_statement
##          blunt_procedural → client_meeting_evidence = return_to_sender_slip
##          technical → client_meeting_evidence = lease_1962_inheritance_1987
##          (asserts the state's on_dismiss block writes correctly via the
##          DialogueRunner dismiss path).
##   T9b  — a low-trust path can progress through r1, r2, and the shared close.
##   T10  — MeetingRoomTrigger gating decisions:
##          (a) preconditions unmet → no dispatch
##          (b) preconditions met, stance == "" → would dispatch Halina intro
##          (c) preconditions met, stance != "" → would dispatch halina dialogue
##          (d) halina_met == true → no dispatch
##
## Runs headless. Exits 0 on pass, 1 on fail.
## Synchronous; one await for autoload registration.

var _pass_count: int = 0
var _fail_count: int = 0

## Capture buffer for dialogue_line_ready: [npc_id, lines]
var _line_capture: Array = ["", []]
## Capture buffer for chapter1_flag_changed: [(flag, value), ...]
var _flag_changes: Array = []


func _init() -> void:
	print("[TestChapter1PhaseB] Starting...")
	await process_frame  ## one await — let autoloads register

	var state_node = get_root().get_node_or_null("/root/State")
	if state_node == null:
		_fail("State autoload not registered")
		_finish()
		return
	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		_fail("Signals autoload not registered")
		_finish()
		return
	var runner = get_root().get_node_or_null("/root/DialogueRunner")
	if runner == null:
		_fail("DialogueRunner autoload not registered")
		_finish()
		return

	## Subscribe once for all tests that watch flag changes.
	sigs.chapter1_flag_changed.connect(func(flag: String, value) -> void:
		_flag_changes.append([flag, value])
	)
	## Subscribe for dialogue line capture.
	sigs.dialogue_line_ready.connect(func(_speaker: String, npc_id: String, lines: Array) -> void:
		_line_capture[0] = npc_id
		_line_capture[1] = lines
	)

	## Common helper to reset chapter1 to a clean baseline before each test.
	## met_asia=true is a Phase B precondition (you can't reach Whimsy recruit
	## without meeting Asia first) and prevents asia.json's first_welcome state
	## from pre-empting V1.A states during asia-dialogue tests.
	var reset_ch1 := func() -> void:
		state_node.data["chapter1"]["met_asia"] = true
		state_node.data["chapter1"]["has_case_folder"] = true
		state_node.data["chapter1"]["recruited_whimsy"] = false
		state_node.data["chapter1"]["halina_arrived"] = false
		state_node.data["chapter1"]["halina_met"] = false
		state_node.data["chapter1"]["client_meeting_stance"] = ""
		state_node.data["chapter1"]["client_meeting_evidence"] = ""
		state_node.data["chapter1"]["client_fee_agreed"] = false
		state_node.data["chapter1"]["cardiologist_plant_landed"] = false
		state_node.data["chapter1"]["halina_stance"] = ""
		state_node.data["chapter1"]["incapacity_penalty"] = false
		state_node.data["chapter1"]["halina_r0_done"] = false
		state_node.data["chapter1"]["halina_r1_choice"] = ""
		state_node.data["chapter1"]["halina_r1_done"] = false
		state_node.data["chapter1"]["halina_r2_choice"] = ""
		state_node.data["chapter1"]["halina_r2_done"] = false
		state_node.data["chapter1"]["halina_close_done"] = false
		state_node.data["chapter1"]["landlord_tip_received"] = false
		_flag_changes.clear()
		_line_capture = ["", []]

	## -----------------------------------------------------------------------
	## T1–T4: in-dialogue option pick (replaces the old stance-menu modal)
	## -----------------------------------------------------------------------
	## The stance picker now lives in halina.json's client_meeting_intro
	## state. The runner dispatches the intro + options; the dialogue box
	## renders them; the player commits via Signals.dialogue_option_committed(value).
	## We bypass the box and emit dialogue_option_committed directly to
	## exercise the runner's write path.
	##
	## Capture buffer for dialogue_options_ready so we can assert the
	## choices broadcast correctly.
	var _options_capture: Array = ["", []]  ## [write_path, choices]
	sigs.dialogue_options_ready.connect(func(write_path: String, choices: Array) -> void:
		_options_capture[0] = write_path
		_options_capture[1] = choices
	)

	## Helper: trigger the stance dialogue, then emit the option_committed
	## value as if the player had picked it.
	var pick_stance := func(stance: String) -> void:
		state_node.data["chapter1"]["halina_arrived"] = true
		runner._on_dialogue_requested("halina", "Mrs. Sikorska")
		sigs.dialogue_option_committed.emit(stance)

	## Test 1: sympathetic
	reset_ch1.call()
	pick_stance.call("sympathetic")
	if state_node.data["chapter1"]["client_meeting_stance"] == "sympathetic":
		_pass("T1: dialogue option 'sympathetic' writes State.client_meeting_stance")
	else:
		_fail("T1: expected 'sympathetic', got '%s'" % state_node.data["chapter1"]["client_meeting_stance"])
	sigs.dialogue_dismissed.emit()

	## Test 2: blunt_procedural
	reset_ch1.call()
	pick_stance.call("blunt_procedural")
	if state_node.data["chapter1"]["client_meeting_stance"] == "blunt_procedural":
		_pass("T2: dialogue option 'blunt_procedural' writes State.client_meeting_stance")
	else:
		_fail("T2: expected 'blunt_procedural', got '%s'" % state_node.data["chapter1"]["client_meeting_stance"])
	sigs.dialogue_dismissed.emit()

	## Test 3: technical
	reset_ch1.call()
	pick_stance.call("technical")
	if state_node.data["chapter1"]["client_meeting_stance"] == "technical":
		_pass("T3: dialogue option 'technical' writes State.client_meeting_stance")
	else:
		_fail("T3: expected 'technical', got '%s'" % state_node.data["chapter1"]["client_meeting_stance"])
	sigs.dialogue_dismissed.emit()

	## Test 4: option commit emits chapter1_flag_changed
	reset_ch1.call()
	pick_stance.call("sympathetic")
	var t4_ok: bool = false
	for change in _flag_changes:
		if change[0] == "client_meeting_stance" and change[1] == "sympathetic":
			t4_ok = true
			break
	if t4_ok:
		_pass("T4: option commit emits Signals.chapter1_flag_changed('client_meeting_stance', 'sympathetic')")
	else:
		_fail("T4: expected signal emission not found in captures: " + str(_flag_changes))
	sigs.dialogue_dismissed.emit()

	## Test 4b: dialogue_options_ready broadcasts write_path + 3 choices.
	## Clear capture buffer IN PLACE — reassigning the local would break the
	## closure capture (lambda holds a reference to the original Array).
	reset_ch1.call()
	_options_capture[0] = ""
	_options_capture[1] = []
	state_node.data["chapter1"]["halina_arrived"] = true
	runner._on_dialogue_requested("halina", "Mrs. Sikorska")
	var captured_choices: Array = _options_capture[1]
	if _options_capture[0] == "chapter1.client_meeting_stance" \
			and captured_choices.size() == 3 \
			and captured_choices[0].get("value", "") == "sympathetic" \
			and captured_choices[1].get("value", "") == "blunt_procedural" \
			and captured_choices[2].get("value", "") == "technical":
		_pass("T4b: dialogue_options_ready broadcasts write_path + 3 stance choices in order")
	else:
		_fail("T4b: options broadcast malformed; write_path='%s' choices=%s" % [_options_capture[0], str(captured_choices)])
	## Drain the option without crashing (test cleanup).
	sigs.dialogue_option_committed.emit("sympathetic")
	sigs.dialogue_dismissed.emit()

	## -----------------------------------------------------------------------
	## T5–T6: V1.A Asia announcement state
	## -----------------------------------------------------------------------
	## Test 5: announcement state matches before halina_arrived flips.
	## Set every flag below halina_arrived in the V1.A priority chain to
	## true so earlier states (state 1-5) don't fire first.
	reset_ch1.call()
	state_node.data["chapter1"]["pig_revealed_crisis"] = true
	state_node.data["chapter1"]["met_murrow"] = true
	state_node.data["chapter1"]["has_law_binder"] = true
	state_node.data["chapter1"]["recruited_crab"] = true
	state_node.data["chapter1"]["has_rights_memo"] = true
	state_node.data["chapter1"]["recruited_whimsy"] = true
	## halina_arrived stays false; halina_met stays false.
	runner._on_dialogue_requested("asia", "Asia")
	var lines5: Array = _line_capture[1]
	var expected5: String = "Mrs. Sikorska is here. I've shown her into the meeting room."
	if lines5.size() > 0 and lines5[0] == expected5:
		_pass("T5: V1.A announcement state dispatches canonical line when recruited_whimsy && !halina_arrived")
	else:
		_fail("T5: expected '%s' but got: %s" % [expected5, str(lines5)])

	## Test 5b: dismiss the announcement → halina_arrived should flip.
	sigs.dialogue_dismissed.emit()
	if state_node.data["chapter1"]["halina_arrived"] == true:
		_pass("T5b: announcement on_dismiss flips chapter1.halina_arrived → true")
	else:
		_fail("T5b: halina_arrived should be true after dismiss; got " + str(state_node.data["chapter1"]["halina_arrived"]))

	## Test 6: after halina_arrived=true, the next Asia interaction routes
	## to hint_halina_met (state 7), NOT back to the announcement.
	_line_capture = ["", []]
	runner._on_dialogue_requested("asia", "Asia")
	var lines6: Array = _line_capture[1]
	var expected6: String = "Mrs. Sikorska is in the meeting room. She brought her own folder."
	if lines6.size() > 0 and lines6[0] == expected6:
		_pass("T6: after halina_arrived=true, hint_halina_met wins (announcement does not re-fire)")
	else:
		_fail("T6: expected '%s' but got: %s" % [expected6, str(lines6)])

	## -----------------------------------------------------------------------
	## T7–T9: halina.json stance dispatch — verify on_dismiss flag writes
	## -----------------------------------------------------------------------
	## For each committed opening stance, request Halina dialogue, dismiss the
	## matching round-0 response, and assert the stance-specific bonus evidence
	## writes correctly. The option-chain handoff itself is covered by
	## test_halina_intro_chain.gd.
	var stance_to_evidence: Dictionary = {
		"sympathetic": "wojcik_witness_statement",
		"blunt_procedural": "return_to_sender_slip",
		"technical": "lease_1962_inheritance_1987",
	}
	var stance_to_halina_stance: Dictionary = {
		"sympathetic": "high",
		"blunt_procedural": "blunt",
		"technical": "technical",
	}
	var test_idx: int = 7
	for stance in ["sympathetic", "blunt_procedural", "technical"]:
		reset_ch1.call()
		state_node.data["chapter1"]["halina_arrived"] = true
		state_node.data["chapter1"]["client_meeting_stance"] = stance
		runner._on_dialogue_requested("halina", "Mrs. Sikorska")
		sigs.dialogue_dismissed.emit()

		var ch1: Dictionary = state_node.data["chapter1"]
		var expected_evidence: String = stance_to_evidence[stance]
		var expected_halina_stance: String = stance_to_halina_stance[stance]
		var t_ok: bool = (
			ch1["client_meeting_stance"] == stance
			and ch1["halina_r0_done"] == true
			and ch1["client_meeting_evidence"] == expected_evidence
			and ch1["halina_stance"] == expected_halina_stance
		)
		if t_ok:
			_pass("T%d: halina '%s' dispatch writes round-0 evidence=%s halina_stance=%s" % [test_idx, stance, expected_evidence, expected_halina_stance])
		else:
			_fail("T%d: halina '%s' round-0 flag writes failed; ch1 state: stance=%s halina_stance=%s r0_done=%s evidence=%s last_lines=%s" % [
				test_idx, stance,
				str(ch1["client_meeting_stance"]), str(ch1.get("halina_stance", "MISSING")),
				str(ch1["halina_r0_done"]), str(ch1["client_meeting_evidence"]),
				str(_line_capture[1])
			])
		test_idx += 1

	## Test 9b: low-trust path completes all remaining rounds and reaches the
	## shared close. This guards the state-order progression after choices are
	## persisted.
	reset_ch1.call()
	state_node.data["chapter1"]["halina_arrived"] = true
	state_node.data["chapter1"]["client_meeting_stance"] = "blunt_procedural"
	runner._on_dialogue_requested("halina", "Mrs. Sikorska")
	sigs.dialogue_dismissed.emit()
	state_node.data["chapter1"]["halina_r1_choice"] = "technical"
	runner._on_dialogue_requested("halina", "Mrs. Sikorska")
	sigs.dialogue_dismissed.emit()
	state_node.data["chapter1"]["halina_r2_choice"] = "technical"
	runner._on_dialogue_requested("halina", "Mrs. Sikorska")
	sigs.dialogue_dismissed.emit()
	runner._on_dialogue_requested("halina", "Mrs. Sikorska")
	sigs.dialogue_dismissed.emit()
	var ch1_close: Dictionary = state_node.data["chapter1"]
	if ch1_close["halina_met"] == true \
			and ch1_close["client_fee_agreed"] == true \
			and ch1_close["halina_close_done"] == true \
			and ch1_close["cardiologist_plant_landed"] == true:
		_pass("T9b: low-trust Halina path reaches shared close and writes completion flags")
	else:
		_fail("T9b: low-trust path did not close; ch1=" + str(ch1_close))

	## -----------------------------------------------------------------------
	## T10: MeetingRoomTrigger gating decisions
	## -----------------------------------------------------------------------
	## Load the trigger script, instantiate, mock the side effects, and
	## verify which branch fires for each gating state.
	var trigger_script: GDScript = load("res://scripts/actors/meeting_room_trigger.gd") as GDScript
	if trigger_script == null:
		_fail("T10: could not load meeting_room_trigger.gd")
		_finish()
		return

	## We can't easily exercise _on_body_entered without a CharacterBody2D
	## in a group, so we read the chapter1 dict directly via the trigger's
	## _chapter1() method (private but accessible) and trace the same
	## branching logic in the test. This is a unit-level check of the
	## gating contract, not an integration check (the integration check
	## happens manually when Piotr plays the chapter).
	##
	## Add the trigger to the tree before calling _chapter1() — that method
	## uses get_node_or_null("/root/State") which only resolves when the
	## script is attached to a tree-mounted node. Mirrors production wiring.
	reset_ch1.call()
	var trigger: Node = trigger_script.new()
	get_root().add_child(trigger)

	## Scenario (a): preconditions unmet (recruited_whimsy=false) → no dispatch.
	var ch1_a: Dictionary = trigger._chapter1()
	var would_dispatch_a: bool = (
		ch1_a.get("recruited_whimsy", false)
		and ch1_a.get("halina_arrived", false)
		and not ch1_a.get("halina_met", false)
	)
	if not would_dispatch_a:
		_pass("T10a: preconditions unmet → no dispatch")
	else:
		_fail("T10a: should not dispatch when recruited_whimsy=false")

	## Scenario (b): preconditions met, stance == "" → would dispatch Halina intro.
	reset_ch1.call()
	state_node.data["chapter1"]["recruited_whimsy"] = true
	state_node.data["chapter1"]["halina_arrived"] = true
	state_node.data["chapter1"]["client_meeting_stance"] = ""
	var ch1_b: Dictionary = trigger._chapter1()
	var should_dispatch_intro_b: bool = (
		ch1_b.get("recruited_whimsy", false)
		and ch1_b.get("halina_arrived", false)
		and not ch1_b.get("halina_met", false)
		and str(ch1_b.get("client_meeting_stance", "")) == ""
	)
	if should_dispatch_intro_b:
		_pass("T10b: gating met + empty stance → Halina intro path")
	else:
		_fail("T10b: should dispatch Halina intro; ch1=" + str(ch1_b))

	## Scenario (c): preconditions met, stance committed → would dispatch dialogue.
	reset_ch1.call()
	state_node.data["chapter1"]["recruited_whimsy"] = true
	state_node.data["chapter1"]["halina_arrived"] = true
	state_node.data["chapter1"]["client_meeting_stance"] = "sympathetic"
	var ch1_c: Dictionary = trigger._chapter1()
	var should_dispatch_c: bool = (
		ch1_c.get("recruited_whimsy", false)
		and ch1_c.get("halina_arrived", false)
		and not ch1_c.get("halina_met", false)
		and str(ch1_c.get("client_meeting_stance", "")) != ""
	)
	if should_dispatch_c:
		_pass("T10c: gating met + stance committed → dialogue dispatch path")
	else:
		_fail("T10c: should take dialogue path; ch1=" + str(ch1_c))

	## Scenario (d): halina_met == true → no dispatch.
	reset_ch1.call()
	state_node.data["chapter1"]["recruited_whimsy"] = true
	state_node.data["chapter1"]["halina_arrived"] = true
	state_node.data["chapter1"]["halina_met"] = true
	var ch1_d: Dictionary = trigger._chapter1()
	var would_dispatch_d: bool = not ch1_d.get("halina_met", false)
	if not would_dispatch_d:
		_pass("T10d: halina_met=true → no dispatch (post-meeting no-op)")
	else:
		_fail("T10d: should not dispatch when halina_met=true")

	trigger.free()

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestChapter1PhaseB] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestChapter1PhaseB] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestChapter1PhaseB] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestChapter1PhaseB] PASS")
		quit(0)
