extends SceneTree
## tests/test_npc.gd — structural and interaction tests for the NPC actor.
##
## Tests:
##   1. NPC node instantiates from npc.gd without errors.
##   2. Exported vars (npc_id, display_name, npc_color) apply correctly.
##   3. _on_body_entered correctly sets _player_inside.
##   4. ui_accept press while inside emits Signals.dialogue_requested(npc_id, display_name).
##   5. No signal emitted when player is NOT inside.

var _pass_count: int = 0
var _fail_count: int = 0

## Capture buffer for signal results.
var _signal_capture: Array = ["", ""]  ## [npc_id, display_name]


func _init() -> void:
	print("[TestNPC] Starting...")
	await process_frame

	var npc_script := load("res://scripts/actors/npc.gd") as GDScript
	if npc_script == null:
		_fail("Could not load npc.gd")
		_finish()
		return

	## -----------------------------------------------------------------------
	## Test 1: NPC instantiates
	## -----------------------------------------------------------------------
	var npc := Area2D.new()
	npc.set_script(npc_script)
	npc.npc_id = "pig"
	npc.display_name = "Mr. Pig"
	npc.npc_color = Color(0.83, 0.54, 0.54, 1)
	get_root().add_child(npc)
	await process_frame
	_pass("T1: NPC Area2D instantiated without error")

	## -----------------------------------------------------------------------
	## Test 2: Exported vars applied
	## -----------------------------------------------------------------------
	if npc.npc_id == "pig" and npc.display_name == "Mr. Pig":
		_pass("T2: Exported vars npc_id and display_name correct")
	else:
		_fail("T2: Exported vars wrong — npc_id='%s' display_name='%s'" % [npc.npc_id, npc.display_name])

	## -----------------------------------------------------------------------
	## Test 3: _on_body_entered sets _player_inside = true
	## -----------------------------------------------------------------------
	var fake_player := CharacterBody2D.new()
	fake_player.add_to_group("player")
	get_root().add_child(fake_player)
	await process_frame

	npc._on_body_entered(fake_player)
	if npc._player_inside:
		_pass("T3: _on_body_entered sets _player_inside = true for player group")
	else:
		_fail("T3: _player_inside should be true after body_entered but is false")

	## -----------------------------------------------------------------------
	## Test 4: ui_accept press emits dialogue_requested(npc_id, display_name)
	## -----------------------------------------------------------------------
	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		_fail("T4: Signals autoload not available")
		_finish()
		return
	_signal_capture[0] = ""
	_signal_capture[1] = ""
	var capture := _signal_capture
	sigs.dialogue_requested.connect(func(id: String, dname: String) -> void:
		capture[0] = id
		capture[1] = dname
	, CONNECT_ONE_SHOT)

	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_E
	npc._unhandled_input(event)
	await process_frame

	if _signal_capture[0] == "pig" and _signal_capture[1] == "Mr. Pig":
		_pass("T4: dialogue_requested emitted with correct npc_id and display_name")
	else:
		_fail("T4: expected npc_id='pig' display_name='Mr. Pig' but got id='%s' name='%s'" % [_signal_capture[0], _signal_capture[1]])

	## -----------------------------------------------------------------------
	## Test 5: No signal emitted when player is NOT inside
	## -----------------------------------------------------------------------
	npc._on_body_exited(fake_player)
	_signal_capture[0] = ""
	_signal_capture[1] = ""
	var capture5 := _signal_capture
	sigs.dialogue_requested.connect(func(id: String, dname: String) -> void:
		capture5[0] = id
		capture5[1] = dname
	, CONNECT_ONE_SHOT)
	npc._unhandled_input(event)
	await process_frame

	if _signal_capture[0] == "" and _signal_capture[1] == "":
		_pass("T5: No dialogue_requested emitted when _player_inside is false")
	else:
		_fail("T5: dialogue_requested should NOT fire outside NPC range but did")

	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestNPC] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestNPC] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestNPC] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestNPC] PASS")
		quit(0)
