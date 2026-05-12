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
		var dir = (patrol_target - global_position).normalized()
		global_position += dir * patrol_speed * delta
		
		# To get the right facing suffix
		var angle = rad_to_deg(dir.angle())
		if angle < 0:
			angle += 360.0
		
		var facing = "front"
		if angle >= 337.5 or angle < 22.5:
			facing = "right"
		elif angle >= 22.5 and angle < 67.5:
			facing = "front_right"
		elif angle >= 67.5 and angle < 112.5:
			facing = "front"
		elif angle >= 112.5 and angle < 157.5:
			facing = "front_left"
		elif angle >= 157.5 and angle < 202.5:
			facing = "left"
		elif angle >= 202.5 and angle < 247.5:
			facing = "back_left"
		elif angle >= 247.5 and angle < 292.5:
			facing = "back"
		elif angle >= 292.5 and angle < 337.5:
			facing = "back_right"
			
		play_animation("walk", facing)
