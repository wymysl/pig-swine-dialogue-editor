extends CanvasLayer
class_name UnifyPost

# Toggleable screen-space post-process layer that applies the unify_post shader
# to the full viewport. Attach as a child of Main (or the active world scene)
# above all world content but below UI / dialogue layers.
#
# Default toggle key: F9. Holding Shift while pressing F9 cycles strength.

@export_range(0.0, 1.0, 0.05) var strength: float = 1.0:
	set(v):
		strength = clamp(v, 0.0, 1.0)
		_apply_strength()

@export_range(0.0, 0.15, 0.005) var dither_strength: float = 0.04:
	set(v):
		dither_strength = clamp(v, 0.0, 0.15)
		_apply_dither()

@export var toggle_action_name: String = "unify_post_toggle"

@onready var _rect: ColorRect = $Rect

func _ready() -> void:
	# Render above world (default 0) but below UI / dialogue (layer 10+).
	# Dialogue, stance menu, binder, case folder, and pause layers all sit
	# above this, so UI typography stays unaffected by the palette pass.
	layer = 5
	_apply_strength()
	_apply_dither()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F9:
			if event.shift_pressed:
				# Cycle strength: 0.0 -> 0.5 -> 1.0 -> 0.0
				var next: float = fposmod(strength + 0.5, 1.5)
				strength = next
			else:
				visible = not visible

func _apply_strength() -> void:
	if _rect and _rect.material is ShaderMaterial:
		(_rect.material as ShaderMaterial).set_shader_parameter("strength", strength)

func _apply_dither() -> void:
	if _rect and _rect.material is ShaderMaterial:
		(_rect.material as ShaderMaterial).set_shader_parameter("dither_strength", dither_strength)
