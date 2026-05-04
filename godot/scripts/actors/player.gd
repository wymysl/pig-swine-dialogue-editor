extends CharacterBody2D
## Player — sprint-1 stub.
## Walks on a 32×32 grid with WASD and arrow keys.
## Movement is raw position update for now; tile-snap refinement is a later sprint.
## Single writer: Code role (scripts/actors/player.gd — canonical location for sprint 2+).
## This file lives here temporarily as the room scene is self-contained for sprint 1.

const TILE_SIZE: int = 32
const MOVE_SPEED: float = 4.0  ## tiles per second (used for visual smoothing later)

func _physics_process(_delta: float) -> void:
	var dir: Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if dir != Vector2.ZERO:
		# Raw position update: one tile per frame while held, capped at MOVE_SPEED tiles/s.
		# Tile-snapping and smooth interpolation are deferred to sprint 2.
		velocity = dir * TILE_SIZE * MOVE_SPEED
	else:
		velocity = Vector2.ZERO
	move_and_slide()
