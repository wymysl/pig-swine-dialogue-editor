extends "res://scripts/actors/npc.gd"

@export var cabinet_node_path: NodePath
var cabinet_pos: Vector2
var default_pos: Vector2
var is_patrolling: bool = false
var patrol_target: Vector2 = Vector2.ZERO
var patrol_speed: float = 50.0
var rng = RandomNumberGenerator.new()

func _ready() -> void:
	default_facing = "front_left"
	super._ready()
	default_pos = global_position
	
	if not cabinet_node_path.is_empty():
		var cab = get_node_or_null(cabinet_node_path)
		if cab and cab is CanvasItem:
			cabinet_pos = cab.global_position
			_start_patrol_timer()

func _start_patrol_timer() -> void:
	var timer = get_tree().create_timer(rng.randf_range(3.0, 6.0))
	timer.timeout.connect(_on_patrol_timer)

func _on_patrol_timer() -> void:
	if _is_interacting:
		_start_patrol_timer() # wait until done
		return
	is_patrolling = true
	patrol_target = cabinet_pos

func _process(delta: float) -> void:
	if _is_interacting or not is_patrolling:
		return
		
	var dist = global_position.distance_to(patrol_target)
	if dist < 2.0:
		global_position = patrol_target
		if patrol_target == cabinet_pos:
			# Reached cabinet, face it (back)
			_set_facing("back")
			var t = get_tree().create_timer(rng.randf_range(2.0, 5.0))
			t.timeout.connect(func(): patrol_target = default_pos)
		else:
			# Reached home
			is_patrolling = false
			_set_facing(default_facing)
			_start_patrol_timer()
	else:
		var dir: Vector2 = (patrol_target - global_position).normalized()
		global_position += dir * patrol_speed * delta

		## Delegated to Facing.from_vector — see scripts/systems/facing.gd
		## (2026-05-22 tech critique F6 deduplication).
		play_animation("walk", Facing.from_vector(dir))
