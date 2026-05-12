extends Area2D
## MinigameTrigger — launches a minigame scene on interact.
## Collision layer 4 (npc/interactables), mask 2 (player).
## Note: This is separate from pickup.gd because minigames launch scenes rather
## than directly pushing dialogue or modifying state flags. The minigame itself
## manages state outcomes (e.g. tutorial seen) and signals completion.

@export var minigame_scene_path: String = ""
@export var pattern_id: String = ""
@export var repeatable: bool = false
@export var availability_flag: String = ""

var _player_inside: bool = false
var _prompt: Node
var _consumed: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	var sigs = get_node_or_null("/root/Signals")
	if sigs and sigs.has_signal("minigame_finished"):
		sigs.minigame_finished.connect(_on_minigame_finished)
	if sigs and sigs.has_signal("chapter1_flag_changed"):
		sigs.chapter1_flag_changed.connect(_on_chapter1_flag_changed)
	
	if not has_node("Visual"):
		var visual := ColorRect.new()
		visual.name = "Visual"
		visual.color = Color(0.2, 0.8, 0.8, 1.0)
		visual.offset_left = -16.0
		visual.offset_top = -16.0
		visual.offset_right = 16.0
		visual.offset_bottom = 16.0
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
	if not _can_interact():
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		
		if not minigame_scene_path.is_empty():
			var packed = load(minigame_scene_path)
			if packed:
				var minigame = packed.instantiate()
				## Forward pattern_id if the trigger has one and the scene accepts it.
				if not pattern_id.is_empty() and "pattern_id" in minigame:
					minigame.pattern_id = pattern_id
				get_tree().root.add_child(minigame)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_refresh_prompt()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if _prompt:
			_prompt.hide_prompt()

func _on_minigame_finished(minigame_id: String, _outcome: String) -> void:
	if repeatable:
		return
	if _matches_minigame(minigame_id):
		_consumed = true
		_refresh_prompt()

func _on_chapter1_flag_changed(flag_name: String, _new_value: Variant) -> void:
	if availability_flag.is_empty() or flag_name == availability_flag:
		_refresh_prompt()

func _can_interact() -> bool:
	if not repeatable and _consumed:
		return false
	return _is_availability_flag_met()

func _is_availability_flag_met() -> bool:
	if availability_flag.is_empty():
		return true
	var state_node = get_node_or_null("/root/State")
	if state_node == null:
		return false
	var ch1: Dictionary = state_node.data.get("chapter1", {})
	return _is_truthy(ch1.get(availability_flag, false))

func _is_truthy(value: Variant) -> bool:
	if value is bool:
		return value
	if value is String:
		return not (value as String).is_empty()
	if value is int:
		return (value as int) != 0
	if value is float:
		return not is_zero_approx(value)
	return false

func _matches_minigame(minigame_id: String) -> bool:
	if minigame_scene_path.is_empty():
		return false
	if minigame_id == minigame_scene_path:
		return true
	return minigame_id == minigame_scene_path.get_file().get_basename()

func _refresh_prompt() -> void:
	if not _prompt:
		return
	if _player_inside and _can_interact():
		_prompt.show_prompt()
	else:
		_prompt.hide_prompt()
