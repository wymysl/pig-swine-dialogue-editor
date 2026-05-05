extends Area2D
## NPC — placeholder interactive character node.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Pattern: mirrors door.gd. Player walks into CollisionShape2D, presses the
## interact action (ui_accept / E), DialogueRunner receives the signal and
## resolves the correct dialogue line.
##
## Spawning: add as Area2D node in a scene; set exported vars in the inspector
## or via the .tscn file. Collision layer 3 (npc), mask 2 (player).

## npc_id must match the key in data/dialogues/<npc_id>.json.
@export var npc_id: String = ""

## display_name is the canonical form used by DialogueRunner as the speaker.
## Rule A compliance: "Asia", "Mr. Pig", "Murrow" (see AGENTS.md §Naming).
@export var display_name: String = ""

## npc_color: visual identifier rendered as a small ColorRect.
@export var npc_color: Color = Color(0.5, 0.5, 0.5, 1.0)

## Width and height of the visual body rectangle.
const BODY_W: float = 24.0
const BODY_H: float = 32.0

var _player_inside: bool = false
var _prompt: Node

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	## Build the visual body at runtime so the .tscn file stays lean.
	if not has_node("Visual"):
		var visual := ColorRect.new()
		visual.name = "Visual"
		visual.color = npc_color
		visual.offset_left = -BODY_W * 0.5
		visual.offset_top = -BODY_H * 0.5
		visual.offset_right = BODY_W * 0.5
		visual.offset_bottom = BODY_H * 0.5
		add_child(visual)

	## Build the interaction collision shape if none exists in the scene.
	var has_shape = false
	for child in get_children():
		if child is CollisionShape2D:
			has_shape = true
			break
	if not has_shape:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(BODY_W + 8.0, BODY_H + 8.0)
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
		var sigs = get_node_or_null("/root/Signals")
		if sigs:
			sigs.dialogue_requested.emit(npc_id, display_name)
		get_viewport().set_input_as_handled()


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
