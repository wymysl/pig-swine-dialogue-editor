extends SceneTree

func _init() -> void:
	var packed: PackedScene = load("res://scenes/world/routes/office_street.tscn")
	if packed == null:
		printerr("[WallTest] FAIL: could not load office_street.tscn")
		quit(1)
		return
		
	var scene = packed.instantiate()
	get_root().add_child(scene)
	await process_frame
	
	var player = scene.get_node_or_null("Player")
	if player == null:
		printerr("[WallTest] FAIL: Player not found")
		quit(1)
		return
		
	# Move player to the top wall (y = -8 is the wall, player is 32x32)
	# Floor top is y=0, so moving player to y=0 and trying to move UP.
	player.position = Vector2(480, 0)
	var initial_pos = player.position
	
	if not InputMap.has_action("move_up"):
		InputMap.add_action("move_up")
		
	Input.action_press("move_up")
	player._physics_process(0.1)
	
	var final_pos = player.position
	
	if final_pos.y < initial_pos.y:
		printerr("[WallTest] FAIL: Player moved through the top wall! initial=", initial_pos, " final=", final_pos)
		quit(1)
		return
		
	Input.action_release("move_up")
	print("[WallTest] PASS: Player blocked by wall.")
	quit(0)
