extends Area2D
## BlueFolderPickup — grants Dr. A. Cula's persistent Blue Folder.
## Sole writer: Code role. Player-facing text belongs in dialogue JSON.

const FLAG_NAME: String = "has_case_folder"

var _player_inside: bool = false
var _prompt: Node = null


func _ready() -> void:
	if _is_acquired():
		queue_free()
		return
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_ensure_collision_shape()
	_ensure_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside:
		return
	if not event.is_action_pressed("interact"):
		return
	get_viewport().set_input_as_handled()
	_acquire()
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	if _prompt != null and _prompt.has_method("show_prompt"):
		_prompt.show_prompt()


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = false
	if _prompt != null and _prompt.has_method("hide_prompt"):
		_prompt.hide_prompt()


func _is_acquired() -> bool:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return false
	var data: Dictionary = state_node.get("data")
	var ch1: Dictionary = data.get("chapter1", {})
	return bool(ch1.get(FLAG_NAME, false))


func _acquire() -> void:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return
	var data: Dictionary = state_node.get("data")
	if not data.has("chapter1") or not data["chapter1"] is Dictionary:
		return
	var ch1: Dictionary = data["chapter1"]
	if not ch1.has(FLAG_NAME):
		return
	ch1[FLAG_NAME] = true
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null:
		if sigs.has_signal("chapter1_flag_changed"):
			sigs.chapter1_flag_changed.emit(FLAG_NAME, true)
		if sigs.has_signal("case_folder_acquired"):
			sigs.case_folder_acquired.emit()


func _ensure_collision_shape() -> void:
	for child in get_children():
		if child is CollisionShape2D:
			return
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(40.0, 30.0)
	shape.shape = rect
	add_child(shape)


func _ensure_prompt() -> void:
	var prompt_scene: PackedScene = load("res://scenes/ui/interaction_prompt.tscn") as PackedScene
	if prompt_scene == null:
		return
	_prompt = prompt_scene.instantiate()
	add_child(_prompt)
