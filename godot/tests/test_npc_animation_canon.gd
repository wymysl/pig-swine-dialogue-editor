extends SceneTree

func _init() -> void:
	print("[TestNPC Canon] Starting...")
	var npcs = ["crab", "whimsy", "asia", "mr_pig", "murrow", "halina", "mr_swine", "cula"]
	var dirs = ["front", "back", "left", "right", "front_left", "front_right", "back_left", "back_right"]
	var actions = ["idle", "walk", "run"]

	var npc_script = load("res://scripts/actors/npc.gd")

	for npc_id in npcs:
		var frames_path = "res://art/sprites/" + npc_id + "/" + npc_id + "_sprite_frames.tres"
		var frames = load(frames_path)
		if frames == null:
			printerr("[TestNPC Canon] FAIL: could not load frames for ", npc_id)
			quit(1)
			return

		var npc = Area2D.new()
		npc.set_script(npc_script)
		
		var visual = AnimatedSprite2D.new()
		visual.name = "Visual"
		visual.sprite_frames = frames
		npc.add_child(visual)

		get_root().add_child(npc)
		
		for act in actions:
			for d in dirs:
				npc.play_animation(act, d)
				var current_anim = visual.animation
				if current_anim == "" or current_anim == "default":
					printerr("[TestNPC Canon] FAIL: empty animation for ", npc_id, " ", act, "_", d)
					quit(1)
					return
					
				if frames.get_frame_count(current_anim) == 0:
					printerr("[TestNPC Canon] FAIL: resolved to empty animation ", current_anim, " for ", npc_id, " request: ", act, "_", d)
					quit(1)
					return
		
		npc.queue_free()

	print("[TestNPC Canon] PASS: All fallbacks resolved successfully.")
	quit(0)
