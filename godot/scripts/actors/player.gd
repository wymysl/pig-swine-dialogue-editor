extends CharacterBody2D
## Player — canonical movement implementation.
## Walk 120 px/s (1.875 tiles/s on the 64-px logical grid).
## Sprint 2.8× walk = 336 px/s, toggled by the existing `sprint` action.
## Diagonal input is normalised so W+D == W in speed.
## Animation direction is derived from velocity.angle() discretised into 8×45° buckets.
## Idle retains the last non-zero direction.
## Single writer: Code role (scripts/actors/player.gd).

## Canonical walk speed: 1.875 tiles/s × 64 px/tile = 120 px/s.
const WALK_SPEED: float = 120.0
## Sprint multiplier: exactly 2.8× walk.
const SPRINT_SPEED_MULTIPLIER: float = 2.8

var _last_facing: String = "front"
@onready var anim: AnimatedSprite2D = get_node_or_null("Visual")
@onready var _state := get_node_or_null("/root/State")

func _ready() -> void:
	add_to_group("player")

func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("sprint") and _state:
		_state.session_sprint_toggled = not _state.session_sprint_toggled

	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		var is_sprinting: bool = _state.session_sprint_toggled if _state else false
		var speed: float = WALK_SPEED * (SPRINT_SPEED_MULTIPLIER if is_sprinting else 1.0)
		## dir is already normalised by Input.get_vector for diagonal input.
		velocity = dir * speed
		_update_facing(velocity)
		if anim:
			if is_sprinting and anim.sprite_frames.has_animation("run_" + _last_facing):
				anim.play("run_" + _last_facing)
				anim.speed_scale = 1.0
			else:
				anim.play("walk_" + _last_facing)
				anim.speed_scale = 1.0
	else:
		velocity = Vector2.ZERO
		if anim:
			anim.play("idle_" + _last_facing)
			anim.speed_scale = 1.0
	move_and_slide()

## Discretise a movement vector into one of 8 named directions (45° buckets).
## Bucket centers: right=0°, front_right=45°, front=90°, front_left=135°,
## left=180°, back_left=225°, back=270°, back_right=315°.
## Each bucket spans ±22.5° around its center.
func _update_facing(dir: Vector2) -> void:
	var angle := rad_to_deg(dir.angle())
	if angle < 0.0:
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
