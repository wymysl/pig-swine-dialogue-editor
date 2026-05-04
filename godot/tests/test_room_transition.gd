extends SceneTree
## tests/test_room_transition.gd — functional test for scene transitions.
## Loads the game, triggers the office door, verifies scene swap and player placement.

func _init() -> void:
	print("[TestRoomTransition] Starting...")
	
	# 1. Setup Main
	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	if main_scene == null:
		printerr("[TestRoomTransition] FAIL: could not load Main.tscn")
		quit(1)
		return
		
	var main: Node = main_scene.instantiate()
	get_root().add_child(main)
	
	# Wait for Main and its initial scene to boot
	await process_frame
	await process_frame
	
	var current_scene: Node = main.get_node("CurrentScene")
	if current_scene.get_child_count() == 0:
		printerr("[TestRoomTransition] FAIL: Initial scene not loaded")
		quit(1)
		return
		
	var room: Node = current_scene.get_child(0)
	print("[TestRoomTransition] Initial room: ", room.name)
	if room.name != "OfficeStreet":
		printerr("[TestRoomTransition] FAIL: Expected OfficeStreet, got ", room.name)
		quit(1)
		return
		
	# 2. Trigger Door to Office
	var door: Area2D = room.get_node_or_null("FrontDoor")
	var player: CharacterBody2D = room.get_node_or_null("Player")
	
	if door == null or player == null:
		printerr("[TestRoomTransition] FAIL: FrontDoor or Player not found in OfficeStreet")
		quit(1)
		return
		
	print("[TestRoomTransition] Triggering office_front_door...")
	# Add player to "player" group if not already there (door.gd checks group)
	if not player.is_in_group("player"):
		player.add_to_group("player")
		
	# Simulate player entering door area
	door.emit_signal("body_entered", player)
	
	# Simulate pressing interact (E)
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_E
	door._unhandled_input(event)
	
	# 3. Wait for transition to complete
	var transition: Node = main.get_node("RoomTransition")
	var timeout := 2.0
	while transition.is_busy() and timeout > 0:
		await process_frame
		timeout -= 1.0/60.0
		
	if timeout <= 0:
		printerr("[TestRoomTransition] FAIL: Transition timed out")
		quit(1)
		return
		
	# Wait a few more frames for cleanup and instantiation
	await process_frame
	await process_frame
	
	# 4. Verify new room
	room = current_scene.get_child(0)
	print("[TestRoomTransition] Loaded room: ", room.name)
	if room.name != "PigSwineOffice":
		printerr("[TestRoomTransition] FAIL: Expected PigSwineOffice, got ", room.name)
		quit(1)
		return
		
	# Verify player was moved to spawn
	var spawn: Node2D = room.get_node_or_null("StreetSpawn")
	if spawn == null:
		printerr("[TestRoomTransition] FAIL: StreetSpawn not found in PigSwineOffice")
		quit(1)
		return
		
	# Note: player is re-instantiated in the new scene, so we find the new one
	player = room.get_node_or_null("Player")
	print("[TestRoomTransition] Player pos: ", player.position, " Spawn pos: ", spawn.position)
	if player.position.distance_to(spawn.position) > 1.0:
		printerr("[TestRoomTransition] FAIL: Player not placed at StreetSpawn")
		quit(1)
		return
		
	# 5. Return trip
	door = room.get_node_or_null("BackDoor")
	if door == null:
		printerr("[TestRoomTransition] FAIL: BackDoor not found in PigSwineOffice")
		quit(1)
		return
		
	print("[TestRoomTransition] Triggering office_back_to_street...")
	if not player.is_in_group("player"):
		player.add_to_group("player")
	door.emit_signal("body_entered", player)
	door._unhandled_input(event)
	
	timeout = 2.0
	while transition.is_busy() and timeout > 0:
		await process_frame
		timeout -= 1.0/60.0
		
	await process_frame
	await process_frame
	
	room = current_scene.get_child(0)
	print("[TestRoomTransition] Back to room: ", room.name)
	if room.name != "OfficeStreet":
		printerr("[TestRoomTransition] FAIL: Expected return to OfficeStreet, got ", room.name)
		quit(1)
		return
		
	spawn = room.get_node_or_null("OfficeSpawn")
	player = room.get_node_or_null("Player")
	print("[TestRoomTransition] Player pos: ", player.position, " Spawn pos: ", spawn.position)
	if player.position.distance_to(spawn.position) > 1.0:
		printerr("[TestRoomTransition] FAIL: Player not placed at OfficeSpawn")
		quit(1)
		return
		
	print("[TestRoomTransition] PASS")
	quit(0)
