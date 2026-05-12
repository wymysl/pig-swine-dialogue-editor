extends Area2D
## Pickup — an interactable item in the world.
## Collision layer 4 (npc/interactables), mask 2 (player).

@export var item_id: String = ""
@export var display_name: String = ""
@export var state_flag_path: String = ""
@export var pickup_line: String = ""

var _player_inside: bool = false
var _prompt: Node

func _ready() -> void:
	if not state_flag_path.is_empty():
		var state_node = get_node_or_null("/root/State")
		var parts = state_flag_path.split(".")
		if parts.size() == 2 and state_node:
			var chapter = state_node.data.get(parts[0], {})
			if chapter.get(parts[1], false):
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
		
		if not state_flag_path.is_empty():
			var state_node = get_node_or_null("/root/State")
			var parts = state_flag_path.split(".")
			if parts.size() == 2 and state_node:
				if state_node.data.has(parts[0]):
					state_node.data[parts[0]][parts[1]] = true
					
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
