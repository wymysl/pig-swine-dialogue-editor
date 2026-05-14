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

	var collision_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or not collision_shape.shape is RectangleShape2D:
		printerr("[WallTest] FAIL: Player CollisionShape2D rectangle not found")
		quit(1)
		return

	## The player origin is above the physical body. Test the collision shape's
	## top edge, not the origin, so sprite-offset changes don't look like wall
	## penetration.
	var player_rect := collision_shape.shape as RectangleShape2D
	var floor_top: float = 0.0
	var start_y: float = floor_top + (player_rect.size.y * 0.5) - collision_shape.position.y + 1.0
	player.position = Vector2(480, start_y)
		
	if not InputMap.has_action("move_up"):
		InputMap.add_action("move_up")
		
	Input.action_press("move_up")
	player._physics_process(0.1)
	Input.action_release("move_up")
	
	var final_top_edge: float = player.position.y + collision_shape.position.y - (player_rect.size.y * 0.5)
	
	if final_top_edge < floor_top - 0.01:
		printerr("[WallTest] FAIL: Player collision shape moved through the top wall! top_edge=", final_top_edge)
		quit(1)
		return

	print("[WallTest] PASS: Player blocked by wall.")
	quit(0)
