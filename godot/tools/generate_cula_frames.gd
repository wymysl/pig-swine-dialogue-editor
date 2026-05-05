@tool
extends SceneTree

func _init() -> void:
	var frames = SpriteFrames.new()
	var dirs = ["front", "back", "left", "right", "front_left", "front_right", "back_left", "back_right"]
	
	for d in dirs:
		# Idle
		frames.add_animation("idle_" + d)
		frames.set_animation_loop("idle_" + d, false)
		frames.set_animation_speed("idle_" + d, 5.0)
		var idle_path = "res://art/sprites/cula/cula_idle_" + d + ".png"
		var tex_idle = ResourceLoader.load(idle_path)
		if tex_idle:
			frames.add_frame("idle_" + d, tex_idle)
		else:
			print("Missing idle: ", idle_path)
			
		# Walk
		frames.add_animation("walk_" + d)
		frames.set_animation_loop("walk_" + d, true)
		frames.set_animation_speed("walk_" + d, 8.0)
		for i in range(6):
			var num = str(i).pad_zeros(2)
			var walk_path = "res://art/sprites/cula/walk/" + d + "/cula_walk_" + d + "_" + num + ".png"
			var tex_walk = ResourceLoader.load(walk_path)
			if tex_walk:
				frames.add_frame("walk_" + d, tex_walk)
			else:
				print("Missing walk: ", walk_path)
				
	var err = ResourceSaver.save(frames, "res://art/sprites/cula/cula_sprite_frames.tres")
	if err != OK:
		print("Error saving resource: ", err)
	else:
		print("Success saving cula_sprite_frames.tres")
	
	quit()
