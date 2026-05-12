extends SceneTree

func _init() -> void:
	var player_script = load("res://scripts/actors/player.gd")
	var player = player_script.new()
	var anim = AnimatedSprite2D.new()
	anim.name = "Visual"
	anim.sprite_frames = load("res://art/sprites/cula/cula_sprite_frames.tres")
	player.add_child(anim)
	
	# Manually push actions
	if not InputMap.has_action("move_right"):
		InputMap.add_action("move_right")
	if not InputMap.has_action("sprint"):
		InputMap.add_action("sprint")
		
	get_root().add_child(player)
	await process_frame
		
	# Test walking
	Input.action_press("move_right")
	player._physics_process(0.1)
	var walk_vel = player.velocity.length()
	if anim.animation != "walk_right":
		printerr("[SprintTest] FAIL: Expected walk_right, got ", anim.animation)
		quit(1)
		return
		
	# Test sprinting
	Input.action_press("sprint")
	player._physics_process(0.1)
	var sprint_vel = player.velocity.length()
	if anim.animation != "run_right":
		printerr("[SprintTest] FAIL: Expected run_right, got ", anim.animation)
		quit(1)
		return
		
	if sprint_vel <= walk_vel:
		printerr("[SprintTest] FAIL: Sprint velocity (", sprint_vel, ") not greater than walk velocity (", walk_vel, ")")
		quit(1)
		return
		
	if not is_equal_approx(sprint_vel, walk_vel * player.SPRINT_SPEED_MULTIPLIER):
		printerr("[SprintTest] FAIL: Sprint velocity is not exactly SPRINT_SPEED_MULTIPLIER * walk_vel")
		quit(1)
		return
		
	Input.action_release("move_right")
	Input.action_release("sprint")
	player.free()
	
	print("[SprintTest] PASS")
	quit(0)
