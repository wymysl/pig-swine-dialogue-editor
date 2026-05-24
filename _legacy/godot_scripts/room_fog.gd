extends Node2D
## room_fog.gd — Darkens rooms the player is not currently in.
##
## Attach to a Node2D whose children are room nodes. Each room child must have:
##   - An "Overlay" ColorRect child (solid black, covers the room area)
##   - A "Zone" Area2D child with a CollisionShape2D matching the room bounds
##
## When the player enters a room's Zone, that room's overlay fades to transparent
## while all other rooms' overlays fade to FOG_ALPHA. At doorways (player in two
## zones simultaneously), both rooms stay clear.

const FOG_ALPHA: float = 0.45
const FOG_DURATION: float = 0.3

var _player_rooms: Dictionary = {}   # room_name -> true
var _overlays: Dictionary = {}       # room_name -> Overlay node
var _initialized: bool = false


func _ready() -> void:
	for child in get_children():
		if not child is Node2D:
			continue
		var overlay = child.get_node_or_null("Overlay")
		var zone = child.get_node_or_null("Zone")
		if overlay == null or zone == null:
			continue
		_overlays[child.name] = overlay
		zone.body_entered.connect(_on_room_entered.bind(child.name))
		zone.body_exited.connect(_on_room_exited.bind(child.name))

	# Wait two frames for physics to register pre-existing overlaps,
	# then scan for the player's starting room.
	await get_tree().process_frame
	await get_tree().process_frame
	_detect_initial_room()


func _detect_initial_room() -> void:
	for child in get_children():
		var zone: Area2D = child.get_node_or_null("Zone") as Area2D
		if zone == null:
			continue
		for body in zone.get_overlapping_bodies():
			if body.is_in_group("player"):
				_player_rooms[child.name] = true

	# Set initial fog state instantly (no tween).
	for room_name: String in _overlays:
		var overlay: ColorRect = _overlays[room_name]
		overlay.modulate.a = 0.0 if _player_rooms.has(room_name) else FOG_ALPHA
	_initialized = true


func _on_room_entered(body: Node2D, room_name: String) -> void:
	if not body.is_in_group("player"):
		return
	_player_rooms[room_name] = true
	if _initialized:
		_update_fog()


func _on_room_exited(body: Node2D, room_name: String) -> void:
	if not body.is_in_group("player"):
		return
	_player_rooms.erase(room_name)
	if _initialized:
		_update_fog()


func _update_fog() -> void:
	for room_name: String in _overlays:
		var overlay: ColorRect = _overlays[room_name]
		var target: float = 0.0 if _player_rooms.has(room_name) else FOG_ALPHA
		_tween_overlay(overlay, target)


func _tween_overlay(overlay: ColorRect, target: float) -> void:
	if overlay.has_meta("_fog_tw"):
		var old_tw: Tween = overlay.get_meta("_fog_tw")
		if old_tw != null and old_tw.is_valid():
			old_tw.kill()
	var tw: Tween = create_tween()
	tw.tween_property(overlay, "modulate:a", target, FOG_DURATION)
	overlay.set_meta("_fog_tw", tw)
