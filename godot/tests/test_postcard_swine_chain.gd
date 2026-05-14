extends SceneTree
## tests/test_postcard_swine_chain.gd — verifies the Beat 14 postcard dialogue
## advances through its existing state flags instead of re-firing the opener.

const POSTCARD_PATH: String = "res://data/dialogues/postcard_swine_ch1.json"
const NPC_ID: String = "postcard_swine_ch1_isolated"

var _pass_count: int = 0
var _fail_count: int = 0
var _runner: Node
var _state: Node
var _sigs: Node
var _capture: Dictionary = {"speaker": "", "npc_id": "", "lines": []}


func _init() -> void:
	print("[TestPostcardSwineChain] Starting...")
	await process_frame

	if not _setup_runner():
		_finish()
		return

	_reset_postcard_state()

	_assert_step(
		"Asia",
		"asia",
		"Mr. Pig. Postcard. The address says Sapporo.",
		"postcard_asia_announced"
	)
	_assert(_state.data["chapter1"]["received_swine_postcard"] == true,
		"T1b: first postcard beat marks the postcard as received")

	_assert_step(
		"Narration",
		"stage_direction",
		"Pig turns the postcard over. The front shows a snowy building and a sign too small to read at this distance. Pig reads the body aloud.",
		"postcard_readaloud_cue_shown"
	)
	_assert_step(
		"Mr. Pig",
		"pig",
		"Greetings from Sapporo. A very serious gentleman in the lobby has proposed a venture involving conference centers and a fisheries contact, and I have given him my card on principle. Keep Pig & Swine afloat in my absence.",
		"postcard_body_read"
	)
	_assert_step(
		"Mr. Pig",
		"pig",
		"The Sea of Japan, then.",
		"pig_postcard_reaction_shown"
	)
	_assert_step(
		"Whimsy",
		"whimsy",
		"Behold. The postcard.",
		"whimsy_postcard_deflection_shown"
	)
	_assert_step(
		"Narration",
		"stage_direction",
		"The postcard remains on Pig's desk. The ledger drawer is closed. Asia's mail stack is thinner. The case board still carries the third-clause note until someone erases it for the next matter.",
		"complete"
	)

	_assert(_state.data["badges"]["day_one_survivor"] == true,
		"T6b: chapter close awards day_one_survivor")
	_assert(_state.data["routes_unlocked"]["residential"] == true
			and _state.data["routes_unlocked"]["business_district"] == true
			and _state.data["routes_unlocked"]["court_plaza"] == true,
		"T6c: chapter close unlocks all Chapter 1 routes")

	_finish()


func _setup_runner() -> bool:
	_state = get_root().get_node_or_null("/root/State")
	_sigs = get_root().get_node_or_null("/root/Signals")
	if _state == null or _sigs == null:
		_fail("State or Signals autoload missing")
		return false

	var runner_script := load("res://scripts/autoload/dialogue_runner.gd") as GDScript
	if runner_script == null:
		_fail("Could not load dialogue_runner.gd")
		return false
	_runner = Node.new()
	_runner.set_script(runner_script)
	get_root().add_child(_runner)

	var file := FileAccess.open(POSTCARD_PATH, FileAccess.READ)
	if file == null:
		_fail("Could not open " + POSTCARD_PATH)
		return false
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Dictionary:
		_fail("postcard_swine_ch1.json parse failed")
		return false
	_runner._catalogue[NPC_ID] = parsed

	_sigs.dialogue_line_ready.connect(_on_dialogue_line_ready)
	return true


func _reset_postcard_state() -> void:
	var ch1: Dictionary = _state.data["chapter1"]
	ch1["court_won_procedural_reset"] = true
	ch1["beat13_complete"] = true
	ch1["received_swine_postcard"] = false
	ch1["postcard_asia_announced"] = false
	ch1["postcard_readaloud_cue_shown"] = false
	ch1["postcard_body_read"] = false
	ch1["pig_postcard_reaction_shown"] = false
	ch1["whimsy_postcard_deflection_shown"] = false
	ch1["complete"] = false
	_state.data["badges"]["day_one_survivor"] = false
	_state.data["routes_unlocked"]["residential"] = false
	_state.data["routes_unlocked"]["business_district"] = false
	_state.data["routes_unlocked"]["court_plaza"] = false


func _assert_step(expected_speaker: String, expected_npc_id: String, expected_line: String, flag: String) -> void:
	_capture = {"speaker": "", "npc_id": "", "lines": []}
	_runner._on_dialogue_requested(NPC_ID, "Postcard")
	var lines: Array = _capture["lines"]
	var line_ok: bool = lines.size() == 1 and lines[0] == expected_line
	_assert(_capture["speaker"] == expected_speaker and _capture["npc_id"] == expected_npc_id and line_ok,
		"%s dispatches with expected speaker and line" % flag)
	_sigs.dialogue_dismissed.emit()
	_assert(_state.data["chapter1"][flag] == true,
		"%s set on dismiss" % flag)


func _on_dialogue_line_ready(speaker: String, npc_id: String, lines: Array) -> void:
	_capture["speaker"] = speaker
	_capture["npc_id"] = npc_id
	_capture["lines"] = lines


func _assert(ok: bool, msg: String) -> void:
	if ok:
		_pass(msg)
	else:
		_fail(msg)


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestPostcardSwineChain] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestPostcardSwineChain] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestPostcardSwineChain] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestPostcardSwineChain] PASS")
		quit(0)
