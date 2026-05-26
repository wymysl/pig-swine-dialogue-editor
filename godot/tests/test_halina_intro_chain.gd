extends SceneTree
## Verifies Halina's opening option chain reaches the correct first response
## state and writes each stance's first-round evidence on dismiss.

var _pass_count: int = 0
var _fail_count: int = 0
var _line_capture: Array = ["", []]


func _init() -> void:
	print("[HalinaIntroChainTest] Starting...")
	await process_frame

	var state_node = get_root().get_node_or_null("/root/State")
	var sigs = get_root().get_node_or_null("/root/Signals")
	var runner = get_root().get_node_or_null("/root/DialogueRunner")
	if state_node == null or sigs == null or runner == null:
		_fail("Required autoload missing; State=%s Signals=%s DialogueRunner=%s" % [
			str(state_node != null), str(sigs != null), str(runner != null)
		])
		_finish()
		return

	sigs.dialogue_line_ready.connect(func(_speaker: String, npc_id: String, lines: Array) -> void:
		_line_capture[0] = npc_id
		_line_capture[1] = lines
	)

	_check_stance(state_node, sigs, runner, "sympathetic", "high", "wojcik_witness_statement")
	_check_stance(state_node, sigs, runner, "blunt_procedural", "blunt", "return_to_sender_slip")
	_check_stance(state_node, sigs, runner, "technical", "technical", "lease_1962_inheritance_1987")

	_finish()


func _check_stance(state_node: Node, sigs: Node, runner: Node, stance: String, expected_halina_stance: String, expected_evidence: String) -> void:
	var ch1: Dictionary = state_node.data["chapter1"]
	ch1["halina_met"] = false
	ch1["halina_stance"] = ""
	ch1["incapacity_penalty"] = false
	ch1["halina_r0_done"] = false
	ch1["client_meeting_stance"] = ""
	ch1["client_meeting_evidence"] = ""
	if state_node.data.has("dialogue_states_seen"):
		state_node.data["dialogue_states_seen"] = []
	_line_capture = ["", []]

	runner._on_dialogue_requested("halina", "Mrs. Sikorska")
	sigs.dialogue_option_committed.emit(stance)

	var lines: Array = _line_capture[1]
	var reached_response: bool = (
		_line_capture[0] == "halina"
		and lines.size() > 0
		and lines[0] is Dictionary
		and str(lines[0].get("speaker", "")) == "cula"
	)
	if reached_response:
		_pass("chain '%s' reaches a Cula-led r0 response state" % stance)
	else:
		_fail("chain '%s' did not reach expected r0 response; npc=%s lines=%s" % [
			stance, str(_line_capture[0]), str(lines)
		])

	if ch1["client_meeting_stance"] == stance:
		_pass("chain '%s' writes client_meeting_stance" % stance)
	else:
		_fail("chain '%s' wrong client_meeting_stance; got=%s" % [
			stance, str(ch1["client_meeting_stance"])
		])

	sigs.dialogue_dismissed.emit()
	if ch1["halina_r0_done"] == true and ch1["client_meeting_evidence"] == expected_evidence \
			and ch1.get("halina_stance", "") == expected_halina_stance:
		_pass("dismiss '%s' writes r0_done, evidence=%s, halina_stance=%s" % [stance, expected_evidence, expected_halina_stance])
	else:
		_fail("dismiss '%s' wrong r0 state; r0_done=%s evidence=%s halina_stance=%s (expected %s)" % [
			stance, str(ch1["halina_r0_done"]), str(ch1["client_meeting_evidence"]),
			str(ch1.get("halina_stance", "MISSING")), expected_halina_stance
		])


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[HalinaIntroChainTest] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[HalinaIntroChainTest] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[HalinaIntroChainTest] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[HalinaIntroChainTest] PASS")
		quit(0)
