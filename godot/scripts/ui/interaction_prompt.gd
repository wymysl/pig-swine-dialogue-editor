extends Node2D
## InteractionPrompt — small "[E]" indicator that floats above the higher of
## (parent interactable, player). Top-level so its position is computed in
## global space rather than relative to its parent's transform.
##
## Why "above the higher of the two"? Sprites at 92×92 native put the
## character's head ~30px above center, so a fixed offset above the parent
## interactable risks overlapping the player's head when the player approaches
## from above. Computing position from the higher of the two clears both heads
## regardless of approach direction.

const PROMPT_HEIGHT_OFFSET: float = 60.0  ## pixels above whichever is higher

var _tween: Tween
var _parent_node: Node2D = null
var _player_node: Node2D = null


func _ready() -> void:
	modulate.a = 0.0
	visible = false
	top_level = true  # ignore parent transform; we set global_position ourselves
	_parent_node = get_parent() as Node2D


func _process(_delta: float) -> void:
	if not visible:
		return
	if _parent_node == null:
		return
	if _player_node == null:
		var players: Array = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			_player_node = players[0] as Node2D
		else:
			return
	var x_anchor: float = _parent_node.global_position.x
	var top_y: float = min(_parent_node.global_position.y, _player_node.global_position.y) - PROMPT_HEIGHT_OFFSET
	global_position = Vector2(x_anchor, top_y)


func show_prompt() -> void:
	if _tween:
		_tween.kill()
	visible = true
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15)


func hide_prompt() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.15)
	_tween.tween_callback(func(): visible = false)
