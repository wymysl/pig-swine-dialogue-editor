extends Node2D
## wall_occluder.gd — Fades interior wall segments when the player walks behind them.
##
## Attach this script to a Node2D that is a parent of individual wall segment nodes.
## Each wall segment should be a Node2D with:
##   - A ColorRect child named "Visual" (the visible wall)
##   - An Area2D child named "OcclusionZone" with a CollisionShape2D
##
## When the player enters an OcclusionZone, the corresponding Visual (plus one
## adjacent segment on each side) fades to FADE_ALPHA. When the player leaves,
## it fades back to opaque.
##
## The "adjacent segment" logic uses the `neighbors` array exported on each
## wall segment's Area2D metadata — set via the scene tree.

const FADE_ALPHA: float = 0.12
const FADE_DURATION: float = 0.2

## Maps segment_name -> list of segment_names that should also fade.
@export var neighbor_map: Dictionary = {}

var _active_segments: Dictionary = {}  # segment_name -> true (player is inside)
var _segments: Dictionary = {}  # segment_name -> Visual node


func _ready() -> void:
	# Collect all wall segment children and wire their occlusion zones.
	for child in get_children():
		if not child is Node2D:
			continue
		var visual = child.get_node_or_null("Visual")
		var zone = child.get_node_or_null("OcclusionZone")
		if visual == null or zone == null:
			continue
		_segments[child.name] = visual
		zone.body_entered.connect(_on_zone_entered.bind(child.name))
		zone.body_exited.connect(_on_zone_exited.bind(child.name))


func _on_zone_entered(body: Node2D, segment_name: String) -> void:
	if not body.is_in_group("player"):
		return
	_active_segments[segment_name] = true
	_update_fade(segment_name)


func _on_zone_exited(body: Node2D, segment_name: String) -> void:
	if not body.is_in_group("player"):
		return
	_active_segments.erase(segment_name)
	_update_fade(segment_name)


func _update_fade(_changed_segment: String) -> void:
	# Collect all segments that should be faded: any active segment + its neighbors.
	var should_fade: Dictionary = {}
	for seg_name: String in _active_segments:
		should_fade[seg_name] = true
		if neighbor_map.has(seg_name):
			for neighbor: String in neighbor_map[seg_name]:
				should_fade[neighbor] = true

	# Apply fade/unfade to all known segments.
	for seg_name: String in _segments:
		var visual: Node = _segments[seg_name]
		var target_alpha: float = FADE_ALPHA if should_fade.has(seg_name) else 1.0
		_tween_alpha(visual, target_alpha)


func _tween_alpha(node: Node, target: float) -> void:
	# Kill any existing tween on this node to avoid conflicts.
	if node.has_meta("_wall_tween"):
		var old_tw: Tween = node.get_meta("_wall_tween")
		if old_tw != null and old_tw.is_valid():
			old_tw.kill()
	var tw: Tween = create_tween()
	tw.tween_property(node, "modulate:a", target, FADE_DURATION)
	node.set_meta("_wall_tween", tw)
