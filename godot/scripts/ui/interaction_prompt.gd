extends Node2D
## InteractionPrompt — small action indicator that floats above the higher of
## (anchor node, player). Top-level so its position is computed in
## global space rather than relative to its parent's transform.
##
## Why "above the higher of the two"? Character visuals extend above their
## node origin, so a fixed offset above the anchor risks overlapping the
## player's head when the player approaches from above. Computing position
## from the higher of the two clears both heads regardless of approach
## direction.
##
## Anchor node:
##   By default the anchor is the parent (the NPC node owning this prompt).
##   For zone-style interactables that are visually separate from the actual
##   NPC sprite (e.g., DeskFront — an Area2D in front of the reception
##   counter that opens Asia's dialogue), the owner can call set_anchor_node()
##   with an explicit reference (e.g., the Asia node behind the counter) so
##   the prompt renders above the NPC's head, not above the trigger zone.
##   Phase-8 polish: this prevents [E] from rendering on the desk surface.

const PROMPT_HEIGHT_OFFSET: float = 82.0  ## pixels above whichever is higher

var _tween: Tween
var _anchor_node: Node2D = null
var _player_node: Node2D = null
var _action_name: String = "interact"

@onready var _label: Label = $ColorRect/Label


func _ready() -> void:
	modulate.a = 0.0
	visible = false
	top_level = true  # ignore parent transform; we set global_position ourselves
	## Default anchor: the parent node (typical NPC case).
	_anchor_node = get_parent() as Node2D
	_refresh_action_label()


## set_anchor_node — override the default parent anchor.
## Called by NPC.gd when prompt_anchor_path is set; the prompt then renders
## above the supplied node instead of above the trigger zone parent.
## Useful for desk/counter trigger zones where the NPC sprite is offset.
func set_anchor_node(node: Node2D) -> void:
	if node != null:
		_anchor_node = node


func set_action_name(action_name: String) -> void:
	if action_name == "":
		return
	_action_name = action_name
	if is_node_ready():
		_refresh_action_label()


func _process(_delta: float) -> void:
	if not visible:
		return
	if _anchor_node == null:
		return
	if _player_node == null:
		var players: Array = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			_player_node = players[0] as Node2D
		else:
			return
	var x_anchor: float = _anchor_node.global_position.x
	var top_y: float = min(_anchor_node.global_position.y, _player_node.global_position.y) - PROMPT_HEIGHT_OFFSET
	global_position = Vector2(x_anchor, top_y)


func show_prompt() -> void:
	if _tween:
		_tween.kill()
	_refresh_action_label()
	visible = true
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15)


func hide_prompt() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.15)
	_tween.tween_callback(func(): visible = false)


func _refresh_action_label() -> void:
	_label.text = "[" + _action_label(_action_name) + "]"


func _action_label(action_name: String) -> String:
	if not InputMap.has_action(action_name):
		return action_name
	for event in InputMap.action_get_events(action_name):
		var label_text: String = _event_label(event)
		if label_text != "":
			return label_text
	return action_name


func _event_label(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		var code: Key = key_event.key_label
		if code == KEY_NONE:
			code = key_event.keycode
		if code == KEY_NONE:
			code = key_event.physical_keycode
		var key_name: String = OS.get_keycode_string(code)
		if key_name != "":
			return key_name
	return event.as_text().strip_edges()
