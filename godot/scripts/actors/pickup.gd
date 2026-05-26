extends Area2D
## Pickup — an interactable item in the world.
## Collision layer 4 (npc/interactables), mask 2 (player).

@export var item_id: String = ""
@export var display_name: String = ""
@export var state_flag_path: String = ""
@export var pickup_line: String = ""

const ITEMS_PATH: String = "res://data/items.json"
const CHAPTER1_CASE_ID: String = "chapter1_sikorska"

var _player_inside: bool = false
var _prompt: Node

func _ready() -> void:
	_apply_item_catalogue_data()
	if _is_already_collected():
		queue_free()
		return

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if not has_node("Visual"):
		var visual := ColorRect.new()
		visual.name = "Visual"
		visual.color = Color(0.8, 0.8, 0.2, 1.0)
		visual.offset_left = -8.0
		visual.offset_top = -8.0
		visual.offset_right = 8.0
		visual.offset_bottom = 8.0
		add_child(visual)

	var has_shape = false
	for child in get_children():
		if child is CollisionShape2D:
			has_shape = true
			break
	if not has_shape:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(40.0, 40.0)
		shape.shape = rect
		add_child(shape)

	var prompt_scene = load("res://scenes/ui/interaction_prompt.tscn")
	if prompt_scene:
		_prompt = prompt_scene.instantiate()
		add_child(_prompt)

func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_write_state_flag()
		_add_to_inventory()
		_update_active_case()

		var sigs = get_node_or_null("/root/Signals")
		if sigs:
			sigs.item_picked_up.emit(item_id, display_name)
			if not pickup_line.is_empty():
				sigs.dialogue_line_ready.emit("", "", [pickup_line])

		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if _prompt:
			_prompt.show_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if _prompt:
			_prompt.hide_prompt()


func _apply_item_catalogue_data() -> void:
	if item_id.is_empty():
		return
	var item_data: Dictionary = _load_item_data(item_id)
	if item_data.is_empty():
		return
	display_name = str(item_data.get("display_name", display_name))
	state_flag_path = str(item_data.get("state_flag", state_flag_path))
	pickup_line = str(item_data.get("pickup_line", pickup_line))


func _load_item_data(id: String) -> Dictionary:
	if not FileAccess.file_exists(ITEMS_PATH):
		push_warning("Pickup: items catalogue missing: " + ITEMS_PATH)
		return {}
	var file := FileAccess.open(ITEMS_PATH, FileAccess.READ)
	if file == null:
		push_warning("Pickup: cannot open items catalogue: " + ITEMS_PATH)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Dictionary:
		push_warning("Pickup: items catalogue JSON parse failed: " + ITEMS_PATH)
		return {}
	var raw_items = parsed.get("items", {})
	if not raw_items is Dictionary:
		push_warning("Pickup: items catalogue missing 'items' dictionary")
		return {}
	var items: Dictionary = raw_items
	if not items.has(id) or not items[id] is Dictionary:
		push_warning("Pickup: item_id '%s' missing from items catalogue" % id)
		return {}
	return items[id]


func _is_already_collected() -> bool:
	if state_flag_path.is_empty():
		return false
	var current_value = _read_state_value(state_flag_path)
	if current_value is bool:
		return current_value
	if current_value is String:
		return current_value != "" and (current_value == item_id or state_flag_path == "chapter1.client_meeting_evidence")
	return false


func _write_state_flag() -> void:
	if state_flag_path.is_empty():
		return
	var state_node = get_node_or_null("/root/State")
	var parts = state_flag_path.split(".")
	if parts.size() != 2 or state_node == null:
		return
	var top: String = parts[0]
	var key: String = parts[1]
	if not state_node.data.has(top) or not state_node.data[top] is Dictionary:
		return
	var target: Dictionary = state_node.data[top]
	if not target.has(key):
		return
	var value = _pickup_state_value(target[key])
	target[key] = value
	if top == "chapter1":
		var sigs = get_node_or_null("/root/Signals")
		if sigs and sigs.has_signal("chapter1_flag_changed"):
			sigs.chapter1_flag_changed.emit(key, value)


func _read_state_value(path: String):
	var state_node = get_node_or_null("/root/State")
	var parts = path.split(".")
	if parts.size() != 2 or state_node == null:
		return null
	var top: String = parts[0]
	var key: String = parts[1]
	if not state_node.data.has(top) or not state_node.data[top] is Dictionary:
		return null
	var target: Dictionary = state_node.data[top]
	if not target.has(key):
		return null
	return target[key]


func _pickup_state_value(current_value):
	if current_value is String:
		return item_id
	return true


func _add_to_inventory() -> void:
	if item_id.is_empty():
		return
	var state_node = get_node_or_null("/root/State")
	if state_node == null:
		return
	if not state_node.data.has("inventory") or not state_node.data["inventory"] is Dictionary:
		state_node.data["inventory"] = {}
	state_node.data["inventory"][item_id] = true


func _update_active_case() -> void:
	if item_id != "procedural_binder":
		return
	var state_node = get_node_or_null("/root/State")
	if state_node == null:
		return
	if state_node.data.has("active_case_id"):
		state_node.data["active_case_id"] = CHAPTER1_CASE_ID
