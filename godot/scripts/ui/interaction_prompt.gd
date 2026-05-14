extends Node2D
## InteractionPrompt — small "[E]" indicator that floats above the higher of
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

const PROMPT_HEIGHT_OFFSET: float = 60.0  ## pixels above whichever is higher

var _tween: Tween
var _anchor_node: Node2D = null
var _player_node: Node2D = null


func _ready() -> void:
	modulate.a = 0.0
	visible = false
	top_level = true  # ignore parent transform; we set global_position ourselves
	## Default anchor: the parent node (typical NPC case).
	_anchor_node = get_parent() as Node2D


## set_anchor_node — override the default parent anchor.
## Called by NPC.gd when prompt_anchor_path is set; the prompt then renders
## above the supplied node instead of above the trigger zone parent.
## Useful for desk/counter trigger zones where the NPC sprite is offset.
func set_anchor_node(node: Node2D) -> void:
	if node != null:
		_anchor_node = node


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
	visible = true
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, 0.15)


func hide_prompt() -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, 0.15)
	_tween.tween_callback(func(): visible = false)
