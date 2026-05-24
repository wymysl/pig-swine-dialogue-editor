class_name Facing
extends RefCounted
## Shared 8-direction facing math.
##
## Replaces three copy-paste implementations that previously lived in
## scripts/actors/player.gd, scripts/actors/npc.gd, and scripts/actors/asia.gd
## (2026-05-22 tech critique F6). Bucket centres:
##   right       =   0°
##   front_right =  45°
##   front       =  90°
##   front_left  = 135°
##   left        = 180°
##   back_left   = 225°
##   back        = 270°
##   back_right  = 315°
## Each bucket spans ±22.5° around its centre. The "front" half of the camera
## corresponds to positive Y in Godot's screen-space coordinate frame, which
## is why "front" maps to a downward direction (sin(angle) > 0).

const DEFAULT: String = "front"

## from_vector — return the 8-direction facing name for `dir`. A zero vector
## returns DEFAULT so callers can blindly call this on an idle frame without
## having to guard themselves.
static func from_vector(dir: Vector2) -> String:
	if dir == Vector2.ZERO:
		return DEFAULT
	var angle: float = rad_to_deg(dir.angle())
	if angle < 0.0:
		angle += 360.0
	return from_angle_degrees(angle)


## from_angle_degrees — return the facing name for an angle already converted
## to [0, 360). Exposed for callers that already have an angle (saves the
## duplicated atan + normalise dance).
static func from_angle_degrees(angle: float) -> String:
	if angle >= 337.5 or angle < 22.5:
		return "right"
	elif angle < 67.5:
		return "front_right"
	elif angle < 112.5:
		return "front"
	elif angle < 157.5:
		return "front_left"
	elif angle < 202.5:
		return "left"
	elif angle < 247.5:
		return "back_left"
	elif angle < 292.5:
		return "back"
	else:
		return "back_right"
