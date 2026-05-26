extends SceneTree
## tests/test_pickup_items_data.gd — verifies Pickup uses items.json as source of truth.
##
## Covers:
##   1. item_id hydrates display_name/state_flag_path/pickup_line from items.json.
##   2. Bool state flags are written true and emit chapter1_flag_changed.
##   3. Hydrated pickup_line is emitted as a dialogue line.
##   4. String state flags write the item_id, supporting bonus-evidence pickups.

var _pass_count: int = 0
var _fail_count: int = 0

var _picked_up: Array = []
var _flag_changes: Array = []
var _dialogue_lines: Array = []


func _init() -> void:
	print("[TestPickupItemsData] Starting...")
	await process_frame

	var state_node = get_root().get_node_or_null("/root/State")
	var sigs = get_root().get_node_or_null("/root/Signals")
	if state_node == null:
		_fail("State autoload not registered")
		_finish()
		return
	if sigs == null:
		_fail("Signals autoload not registered")
		_finish()
		return

	sigs.item_picked_up.connect(func(item_id: String, display_name: String) -> void:
		_picked_up.append([item_id, display_name])
	)
	sigs.chapter1_flag_changed.connect(func(flag_name: String, value) -> void:
		_flag_changes.append([flag_name, value])
	)
	sigs.dialogue_line_ready.connect(func(_speaker: String, _npc_id: String, lines: Array) -> void:
		_dialogue_lines.append(lines)
	)

	## -----------------------------------------------------------------------
	## T1-4: procedural_binder scene fallback values are replaced by items.json.
	## -----------------------------------------------------------------------
	state_node.data = state_node.reset_state()
	_clear_captures()
	var binder := _spawn_pickup("procedural_binder")
	binder.display_name = "Scene Binder"
	binder.state_flag_path = "chapter1.unused_scene_flag"
	binder.pickup_line = "Scene fallback line."
	get_root().add_child(binder)
	await process_frame

	if binder.display_name == "Unreasonably Heavy Procedural Binder" \
		and binder.state_flag_path == "chapter1.has_law_binder" \
		and binder.pickup_line.begins_with("The binder is heavier"):
		_pass("T1: Pickup hydrates binder fields from items.json")
	else:
		_fail("T1: binder hydration mismatch: name='%s' path='%s' line='%s'" % [
			binder.display_name, binder.state_flag_path, binder.pickup_line
		])

	_interact_with(binder)
	await process_frame

	if state_node.data["chapter1"]["has_law_binder"] == true:
		_pass("T2: bool state flag is written true on pickup")
	else:
		_fail("T2: has_law_binder should be true after pickup")

	if _picked_up.size() == 1 \
		and _picked_up[0][0] == "procedural_binder" \
		and _picked_up[0][1] == "Unreasonably Heavy Procedural Binder":
		_pass("T3: item_picked_up emits hydrated display name")
	else:
		_fail("T3: item_picked_up capture mismatch: %s" % str(_picked_up))

	if _has_flag_change("has_law_binder", true):
		_pass("T4: bool pickup emits chapter1_flag_changed")
	else:
		_fail("T4: missing chapter1_flag_changed('has_law_binder', true)")

	if _dialogue_lines.size() == 1 \
		and _dialogue_lines[0].size() == 1 \
		and str(_dialogue_lines[0][0]).begins_with("The binder is heavier"):
		_pass("T4b: hydrated pickup_line is emitted")
	else:
		_fail("T4b: hydrated pickup_line missing from dialogue_line_ready: %s" % str(_dialogue_lines))

	## -----------------------------------------------------------------------
	## T5-6: string-valued state flags write the item id, not boolean true.
	## -----------------------------------------------------------------------
	state_node.data = state_node.reset_state()
	_clear_captures()
	var bonus := _spawn_pickup("return_to_sender_slip")
	get_root().add_child(bonus)
	await process_frame
	_interact_with(bonus)
	await process_frame

	if state_node.data["chapter1"]["client_meeting_evidence"] == "return_to_sender_slip":
		_pass("T5: string state flag writes item_id for bonus evidence")
	else:
		_fail("T5: expected return_to_sender_slip, got '%s'" % state_node.data["chapter1"]["client_meeting_evidence"])

	if _has_flag_change("client_meeting_evidence", "return_to_sender_slip"):
		_pass("T6: string pickup emits chapter1_flag_changed with item_id")
	else:
		_fail("T6: missing chapter1_flag_changed for bonus evidence")

	_finish()


func _spawn_pickup(id: String) -> Area2D:
	var pickup_script := load("res://scripts/actors/pickup.gd") as GDScript
	var pickup := Area2D.new()
	pickup.set_script(pickup_script)
	pickup.item_id = id
	return pickup


func _interact_with(pickup: Area2D) -> void:
	var player := CharacterBody2D.new()
	player.add_to_group("player")
	get_root().add_child(player)
	pickup._on_body_entered(player)
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_E
	pickup._unhandled_input(event)
	player.queue_free()


func _clear_captures() -> void:
	_picked_up.clear()
	_flag_changes.clear()
	_dialogue_lines.clear()


func _has_flag_change(flag_name: String, expected_value) -> bool:
	for change in _flag_changes:
		if change[0] == flag_name and change[1] == expected_value:
			return true
	return false


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestPickupItemsData] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestPickupItemsData] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestPickupItemsData] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestPickupItemsData] PASS")
		quit(0)
