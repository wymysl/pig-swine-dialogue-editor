extends SceneTree
## test_facing.gd — Facing.from_vector / from_angle_degrees bucket boundaries.
##
## Extracted utility replacing three copy-paste implementations in player.gd,
## npc.gd, asia.gd (2026-05-22 tech critique F6). This test pins the bucket
## boundaries so a future tweak (e.g. swapping which side of 22.5° goes
## "right" vs "front_right") fails loudly instead of producing wrong-direction
## walk animations across three actors.
##
## Owner: QA role.
## Run:   godot --headless --path godot --script tests/test_facing.gd

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	_run_all()
	_finish()


func _run_all() -> void:
	_test_zero_vector_returns_default()
	_test_cardinal_centres()
	_test_diagonal_centres()
	_test_bucket_boundaries()
	_test_normalised_vs_raw_input()


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


## T1 — Vector2.ZERO returns the default facing rather than crashing on the
## angle of a zero vector (which is defined as 0 in Godot but would map to
## "right", an arbitrary direction).
func _test_zero_vector_returns_default() -> void:
	print("[T1] zero vector returns DEFAULT")
	_assert(Facing.from_vector(Vector2.ZERO) == "front",
		"Vector2.ZERO returns 'front' (the documented DEFAULT)")
	_assert(Facing.DEFAULT == "front", "DEFAULT constant equals 'front'")


## T2 — Each cardinal bucket centre maps to its canonical name.
func _test_cardinal_centres() -> void:
	print("[T2] cardinal bucket centres")
	_assert(Facing.from_vector(Vector2(1, 0)) == "right", "(1,0) → right (0°)")
	_assert(Facing.from_vector(Vector2(0, 1)) == "front", "(0,1) → front (90°)")
	_assert(Facing.from_vector(Vector2(-1, 0)) == "left", "(-1,0) → left (180°)")
	_assert(Facing.from_vector(Vector2(0, -1)) == "back", "(0,-1) → back (270°)")


## T3 — Each diagonal bucket centre maps to its canonical name. Note that
## front_right / back_right etc. use Godot's screen-space frame, where +Y is
## "down" (i.e. front).
func _test_diagonal_centres() -> void:
	print("[T3] diagonal bucket centres")
	_assert(Facing.from_vector(Vector2(1, 1)) == "front_right", "(1,1) → front_right (45°)")
	_assert(Facing.from_vector(Vector2(-1, 1)) == "front_left", "(-1,1) → front_left (135°)")
	_assert(Facing.from_vector(Vector2(-1, -1)) == "back_left", "(-1,-1) → back_left (225°)")
	_assert(Facing.from_vector(Vector2(1, -1)) == "back_right", "(1,-1) → back_right (315°)")


## T4 — Bucket boundaries: the value AT the boundary (22.5°, 67.5°, ...)
## belongs to the next bucket per the original implementation's `>=` checks.
## Pin this so a refactor that swaps `>=` for `>` fails immediately.
func _test_bucket_boundaries() -> void:
	print("[T4] bucket boundaries are inclusive on the upper side")
	## 22.5° is the boundary between right (0°) and front_right (45°).
	## from_angle_degrees uses `>= 22.5` → front_right.
	_assert(Facing.from_angle_degrees(22.5) == "front_right",
		"22.5° belongs to front_right (right/front_right boundary)")
	_assert(Facing.from_angle_degrees(22.49) == "right",
		"22.49° belongs to right")
	## 337.5° is the boundary back from back_right into right.
	_assert(Facing.from_angle_degrees(337.5) == "right",
		"337.5° belongs to right (back_right/right boundary)")
	_assert(Facing.from_angle_degrees(337.49) == "back_right",
		"337.49° belongs to back_right")
	## 67.5°: front_right → front.
	_assert(Facing.from_angle_degrees(67.5) == "front",
		"67.5° belongs to front")
	## 247.5°: back_left → back.
	_assert(Facing.from_angle_degrees(247.5) == "back",
		"247.5° belongs to back")


## T5 — Normalised and raw vectors of the same direction produce the same
## facing. Asserts the function does not subtly depend on magnitude.
func _test_normalised_vs_raw_input() -> void:
	print("[T5] normalised vs raw input")
	var raw: Vector2 = Vector2(3, 3)
	var norm: Vector2 = raw.normalized()
	_assert(Facing.from_vector(raw) == Facing.from_vector(norm),
		"raw (3,3) and normalised (1/√2,1/√2) produce the same facing")
	_assert(Facing.from_vector(Vector2(0.001, 0)) == "right",
		"tiny positive-x vector still resolves to 'right'")


func _finish() -> void:
	print("[Facing] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)
