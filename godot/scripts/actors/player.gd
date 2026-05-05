extends CharacterBody2D
## Player — sprint 4 implementation.
## Walks on a 32×32 grid with WASD and arrow keys.
## Movement is raw position update for now; tile-snap refinement is a later sprint.
## Single writer: Code role (scripts/actors/player.gd).

const TILE_SIZE: int = 32
const MOVE_SPEED: float = 4.0  ## tiles per second (used for visual smoothing later)

var _last_facing: String = "front"
@onready var anim: AnimatedSprite2D = get_node_or_null("Visual")

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		velocity = dir.normalized() * TILE_SIZE * MOVE_SPEED
		_update_facing(dir)
		if anim:
			anim.play("walk_" + _last_facing)
	else:
		velocity = Vector2.ZERO
		if anim:
			anim.play("idle_" + _last_facing)
	move_and_slide()

func _update_facing(dir: Vector2) -> void:
	# Using angle to determine 8-way direction
	var angle = rad_to_deg(dir.angle())
	if angle < 0:
		angle += 360.0
	
	if angle >= 337.5 or angle < 22.5:
		_last_facing = "right"
	elif angle >= 22.5 and angle < 67.5:
		_last_facing = "front_right"
	elif angle >= 67.5 and angle < 112.5:
		_last_facing = "front"
	elif angle >= 112.5 and angle < 157.5:
		_last_facing = "front_left"
	elif angle >= 157.5 and angle < 202.5:
		_last_facing = "left"
	elif angle >= 202.5 and angle < 247.5:
		_last_facing = "back_left"
	elif angle >= 247.5 and angle < 292.5:
		_last_facing = "back"
	elif angle >= 292.5 and angle < 337.5:
		_last_facing = "back_right"
