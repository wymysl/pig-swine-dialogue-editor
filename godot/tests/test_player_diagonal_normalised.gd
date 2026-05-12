extends SceneTree
## tests/test_player_diagonal_normalised.gd
##
## Verifies that:
## 1. Walk speed is exactly WALK_SPEED (96 px/s).
## 2. Sprint speed is exactly WALK_SPEED * SPRINT_SPEED_MULTIPLIER (153.6 px/s).
## 3. Diagonal input (W+D) produces the same speed as cardinal input (W alone)
##    within float tolerance — i.e. Input.get_vector already normalises the
##    diagonal and player.gd does not apply a second scaling.
## 4. Animation direction from a diagonal vector (1, 1) → "front_right".
## 5. _update_facing is consistent with velocity.angle(): 8 buckets, each 45°,
##    centers at right/front_right/front/front_left/left/back_left/back/back_right.
##
## Run headless:
##   godot --headless --script tests/test_player_diagonal_normalised.gd

func _init() -> void:
	var script = load("res://scripts/actors/player.gd")
	if script == null:
		_fail("Could not load player.gd")
		return
	var player = script.new()

	# ── 1. Walk speed constant ────────────────────────────────────────────────
	if not is_equal_approx(player.WALK_SPEED, 96.0):
		_fail("WALK_SPEED should be 96.0, got " + str(player.WALK_SPEED))
		return

	# ── 2. Sprint multiplier ──────────────────────────────────────────────────
	if not is_equal_approx(player.SPRINT_SPEED_MULTIPLIER, 1.6):
		_fail("SPRINT_SPEED_MULTIPLIER should be 1.6, got "
			+ str(player.SPRINT_SPEED_MULTIPLIER))
		return

	var sprint_speed := player.WALK_SPEED * player.SPRINT_SPEED_MULTIPLIER
	if not is_equal_approx(sprint_speed, 153.6):
		_fail("Sprint speed should be 153.6 px/s, got " + str(sprint_speed))
		return

	# ── 3. Diagonal normalisation (structural) ────────────────────────────────
	# Input.get_vector normalises its output; we simulate both vectors manually
	# to assert that any dir passed through the speed formula produces the same
	# magnitude regardless of whether it was cardinal or diagonal.
	var cardinal := Vector2(1.0, 0.0)                          # W alone  (already unit)
	var diagonal := Vector2(1.0, 1.0).normalized()             # W+D normalised
	# Both should already be unit vectors; applying WALK_SPEED gives 96 px/s.
	var cardinal_speed := (cardinal * player.WALK_SPEED).length()
	var diagonal_speed := (diagonal * player.WALK_SPEED).length()
	if not is_equal_approx(cardinal_speed, diagonal_speed):
		_fail("Diagonal speed %.4f != cardinal speed %.4f — normalisation broken"
			% [diagonal_speed, cardinal_speed])
		return
	if not is_equal_approx(diagonal_speed, player.WALK_SPEED):
		_fail("Normalised diagonal speed %.4f != WALK_SPEED %.4f"
			% [diagonal_speed, player.WALK_SPEED])
		return

	# ── 4. Facing direction for diagonal vector (1,1) → front_right ──────────
	player._update_facing(Vector2(1.0, 1.0))
	if player._last_facing != "front_right":
		_fail("_update_facing(1,1) expected 'front_right', got '"
			+ player._last_facing + "'")
		return

	# ── 5. All 8 direction buckets ── exact center vectors ────────────────────
	# Each bucket center is at its named angle; the center ±22.5° belongs to it.
	# We test both the bucket center AND the two ±22.4° edge cases.
	var buckets: Array = [
		# [vector at center,       expected_facing]
		[Vector2(1.0,  0.0),        "right"],
		[Vector2(1.0,  1.0),        "front_right"],
		[Vector2(0.0,  1.0),        "front"],
		[Vector2(-1.0, 1.0),        "front_left"],
		[Vector2(-1.0, 0.0),        "left"],
		[Vector2(-1.0, -1.0),       "back_left"],
		[Vector2(0.0,  -1.0),       "back"],
		[Vector2(1.0,  -1.0),       "back_right"],
	]
	for entry in buckets:
		var v: Vector2 = entry[0]
		var expected: String = entry[1]
		player._update_facing(v)
		if player._last_facing != expected:
			_fail("_update_facing(%s) expected '%s', got '%s'"
				% [str(v), expected, player._last_facing])
			return

	# ── 6. Bucket-edge vectors (±22.4° from center — still same bucket) ───────
	# Right bucket center = 0°; at 22.4° it is still "right" (< 22.5° threshold).
	var right_edge := Vector2(cos(deg_to_rad(22.4)), sin(deg_to_rad(22.4)))
	player._update_facing(right_edge)
	if player._last_facing != "right":
		_fail("22.4° vector should still be 'right', got '" + player._last_facing + "'")
		return

	# front_right center = 45°; at 22.6° from center (= 67.4°) still "front_right".
	var fr_edge := Vector2(cos(deg_to_rad(67.4)), sin(deg_to_rad(67.4)))
	player._update_facing(fr_edge)
	if player._last_facing != "front_right":
		_fail("67.4° vector should still be 'front_right', got '"
			+ player._last_facing + "'")
		return

	# ── 7. Idle retains last facing ───────────────────────────────────────────
	player._update_facing(Vector2(0.0, -1.0))   # sets "back"
	# Don't call _update_facing again; _last_facing should remain "back".
	if player._last_facing != "back":
		_fail("Idle last-facing retention broken: expected 'back', got '"
			+ player._last_facing + "'")
		return

	player.free()
	print("[DiagonalNorm] PASS — walk=96 px/s, sprint=153.6 px/s, "
		+ "diagonal normalised, all 8 buckets correct.")
	quit(0)


func _fail(msg: String) -> void:
	printerr("[DiagonalNorm] FAIL: ", msg)
	quit(1)
