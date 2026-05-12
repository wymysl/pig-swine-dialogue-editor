extends SceneTree

func _init() -> void:
	var frames: SpriteFrames = load("res://art/sprites/cula/cula_sprite_frames.tres")
	if frames == null:
		printerr("[FramesTest] FAIL: could not load cula_sprite_frames.tres")
		quit(1)
		return
		
	var expected_dirs = ["front", "back", "left", "right", "front_left", "front_right", "back_left", "back_right"]
	
	for d in expected_dirs:
		if not frames.has_animation("idle_" + d):
			printerr("[FramesTest] FAIL: Missing animation idle_", d)
			quit(1)
			return
		if not frames.has_animation("walk_" + d):
			printerr("[FramesTest] FAIL: Missing animation walk_", d)
			quit(1)
			return
		if not frames.has_animation("run_" + d):
			printerr("[FramesTest] FAIL: Missing animation run_", d)
			quit(1)
			return
			
	var run_front_count = frames.get_frame_count("run_front")
	if run_front_count != 6:
		printerr("[FramesTest] FAIL: Expected 6 frames for run_front, got ", run_front_count)
		quit(1)
		return
		
	var run_front_speed = frames.get_animation_speed("run_front")
	if not is_equal_approx(run_front_speed, 12.0):
		printerr("[FramesTest] FAIL: Expected 12.0 FPS for run_front, got ", run_front_speed)
		quit(1)
		return
		
	print("[FramesTest] PASS: All 24 animations verified.")
	quit(0)
