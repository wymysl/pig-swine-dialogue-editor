extends SceneTree
## tests/test_dialogue_runner.gd — unit tests for DialogueRunner predicate evaluation
## and line selection logic.
##
## Runs entirely headless: no window, no rendered frames.
## Tests load the fixture JSON and drive _evaluate_trigger / _on_dialogue_requested
## directly.

const FIXTURE_PATH: String = "res://tests/fixtures/dialogue_fixture.json"

var _pass_count: int = 0
var _fail_count: int = 0

## Capture buffers for signal results (Array avoids closure-capture issues).
var _signal_capture: Array = ["", ""]  ## [speaker, line]

## Minimal State stub so DialogueRunner can call State.data
## The real State autoload should be available via the project settings.


func _init() -> void:
	print("[TestDialogueRunner] Starting...")
	await process_frame

	## Instantiate a bare DialogueRunner node.
	var runner_scene := load("res://scripts/systems/dialogue_runner.gd") as GDScript
	if runner_scene == null:
		_fail("Could not load dialogue_runner.gd")
		_finish()
		return

	var runner := Node.new()
	runner.set_script(runner_scene)
	get_root().add_child(runner)
	await process_frame

	## Manually inject fixture data into runner's catalogue (bypass file I/O).
	var fixture_text: String = ""
	var f := FileAccess.open(FIXTURE_PATH, FileAccess.READ)
	if f == null:
		_fail("Could not open fixture: " + FIXTURE_PATH)
		_finish()
		return
	fixture_text = f.get_as_text()
	f.close()

	var fixture = JSON.parse_string(fixture_text)
	if fixture == null:
		_fail("Fixture JSON parse failed")
		_finish()
		return
	runner._catalogue["test_npc"] = fixture

	## -----------------------------------------------------------------------
	## Test 1: trigger "chapter1.met_pig == false" passes when met_pig is false
	## -----------------------------------------------------------------------
	var state_node = get_root().get_node_or_null("/root/State")
	if state_node == null:
		_fail("State autoload not available — cannot run trigger tests")
		_finish()
		return
	state_node.data["chapter1"]["met_pig"] = false
	var result: bool = runner._evaluate_trigger("chapter1.met_pig == false")
	if result:
		_pass("T1: trigger 'met_pig == false' returns true when State is false")
	else:
		_fail("T1: trigger 'met_pig == false' should return true but returned false")

	## -----------------------------------------------------------------------
	## Test 2: trigger "chapter1.met_pig == true" fails when met_pig is false
	## -----------------------------------------------------------------------
	result = runner._evaluate_trigger("chapter1.met_pig == true")
	if not result:
		_pass("T2: trigger 'met_pig == true' returns false when State is false")
	else:
		_fail("T2: trigger 'met_pig == true' should return false but returned true")

	## -----------------------------------------------------------------------
	## Test 3: compound trigger passes when both sides are correct
	## -----------------------------------------------------------------------
	state_node.data["chapter1"]["met_pig"] = true
	state_node.data["chapter1"]["met_murrow"] = false
	result = runner._evaluate_trigger("chapter1.met_pig == true && chapter1.met_murrow == false")
	if result:
		_pass("T3: compound trigger (met_pig==true && met_murrow==false) passes correctly")
	else:
		_fail("T3: compound trigger should pass but returned false")

	## -----------------------------------------------------------------------
	## Test 4: line selection picks first passing state
	## -----------------------------------------------------------------------
	state_node.data["chapter1"]["met_pig"] = false
	state_node.data["chapter1"]["met_murrow"] = false
	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		_fail("T4: Signals autoload not available")
		_finish()
		return
	_signal_capture[0] = ""
	_signal_capture[1] = ""
	var capture := _signal_capture  ## named ref so lambda captures correctly
	sigs.dialogue_line_ready.connect(func(s: String, l: String) -> void:
		capture[0] = s
		capture[1] = l
	, CONNECT_ONE_SHOT)
	runner._on_dialogue_requested("test_npc", "Test NPC")
	await process_frame
	if _signal_capture[1] == "Pig has not been met.":
		_pass("T4: first matching state line selected (met_pig==false -> 'Pig has not been met.')")
	else:
		_fail("T4: expected 'Pig has not been met.' but got: " + _signal_capture[1])

	## -----------------------------------------------------------------------
	## Test 5: empty trigger always passes (first unconditional state matched)
	## -----------------------------------------------------------------------
	result = runner._evaluate_trigger("")
	if result:
		_pass("T5: empty trigger always passes")
	else:
		_fail("T5: empty trigger should always pass")

	## -----------------------------------------------------------------------
	## Test 6: idle_flavor returned when no state trigger passes
	## -----------------------------------------------------------------------
	## Fixture states:
	##   1. has_law_binder==true  (fails when binder=false)
	##   2. met_pig==false        (fails when pig=true)
	##   3. met_pig==true && met_murrow==false  (fails when murrow=true)
	## Set: pig=true, murrow=true, binder=false → all fail → idle_flavor.
	state_node.data["chapter1"]["met_pig"] = true
	state_node.data["chapter1"]["met_murrow"] = true
	state_node.data["chapter1"]["has_law_binder"] = false
	_signal_capture[1] = ""
	var capture2 := _signal_capture
	sigs.dialogue_line_ready.connect(func(s: String, l: String) -> void:
		capture2[1] = l
	, CONNECT_ONE_SHOT)
	runner._on_dialogue_requested("test_npc", "Test NPC")
	await process_frame
	if _signal_capture[1] in ["Idle line A.", "Idle line B."]:
		_pass("T6: idle_flavor returned when no state trigger matches")
	else:
		_fail("T6: expected idle_flavor line but got: " + _signal_capture[1])

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestDialogueRunner] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestDialogueRunner] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestDialogueRunner] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestDialogueRunner] PASS")
		quit(0)
