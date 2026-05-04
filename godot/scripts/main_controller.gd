extends Node2D
## MainController — root of scenes/Main.tscn.
## Sole writer: Code role (see AGENTS.md §File ownership).
## Responsibilities: scene router, autoload glue, top-level UI overlays.
## CurrentScene child slot holds the active room scene.
##
## Sprint 2: boots the scene recorded in State, wires the RoomTransition child.

const VERSION: String = "0.1.0"

## Public handle so Door nodes can reach the transition system.
var transition: Node  ## typed as Node; runtime type is RoomTransition

func _ready() -> void:
	print("Pig & Swine RPG v", VERSION, " — engine ready.")
	transition = $RoomTransition
	transition.set_scene_slot($CurrentScene)
	_boot_initial_scene()
	_check_headless_tests()


func _check_headless_tests() -> void:
	if not DisplayServer.get_name() == "headless":
		return
	
	for arg in OS.get_cmdline_args():
		if arg == "--smoke-test":
			print("[SmokeTest] PASS")
			get_tree().quit(0)
		elif arg == "--inspect":
			_run_inspect()
		elif arg == "--test-room-transition":
			_run_room_transition_test()


func _run_room_transition_test() -> void:
	print("[TestRoomTransition] Starting...")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var room: Node = $CurrentScene.get_child(0)
	if room.name != "OfficeStreet":
		printerr("[TestRoomTransition] FAIL: Expected OfficeStreet, got ", room.name)
		get_tree().quit(1)
		return
		
	var door: Area2D = room.get_node("FrontDoor")
	var player: CharacterBody2D = room.get_node("Player")
	if not player.is_in_group("player"): player.add_to_group("player")
	
	print("[TestRoomTransition] Triggering office_front_door...")
	door.emit_signal("body_entered", player)
	var event := InputEventKey.new()
	event.pressed = true
	event.keycode = KEY_E
	door._unhandled_input(event)
	
	while transition.is_busy():
		await get_tree().process_frame
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	room = $CurrentScene.get_child(0)
	print("[TestRoomTransition] Loaded room: ", room.name)
	if room.name != "PigSwineOffice":
		printerr("[TestRoomTransition] FAIL: Expected PigSwineOffice")
		get_tree().quit(1)
		return
		
	var spawn: Node2D = room.get_node("StreetSpawn")
	player = room.get_node("Player")
	if player.position.distance_to(spawn.position) > 1.0:
		printerr("[TestRoomTransition] FAIL: Player not at spawn")
		get_tree().quit(1)
		return
		
	print("[TestRoomTransition] Triggering return trip...")
	door = room.get_node("BackDoor")
	if not player.is_in_group("player"): player.add_to_group("player")
	door.emit_signal("body_entered", player)
	door._unhandled_input(event)
	
	while transition.is_busy():
		await get_tree().process_frame
		
	await get_tree().process_frame
	await get_tree().process_frame
	
	room = $CurrentScene.get_child(0)
	print("[TestRoomTransition] Back to: ", room.name)
	if room.name != "OfficeStreet":
		printerr("[TestRoomTransition] FAIL: Return failed")
		get_tree().quit(1)
		return
		
	print("[TestRoomTransition] PASS")
	get_tree().quit(0)


func _boot_initial_scene() -> void:
	var scene_path: String = State.data.get(
		"current_scene_path",
		"res://scenes/world/routes/office_street.tscn"
	)
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		push_error("MainController: failed to load boot scene: " + scene_path)
		return
	$CurrentScene.add_child(packed.instantiate())

func _run_inspect() -> void:
	print("[Inspect] Starting...")
	await get_tree().process_frame
	await get_tree().process_frame
	
	var current_scene: Node = $CurrentScene
	if current_scene.get_child_count() == 0:
		printerr("[Inspect] FAIL: CurrentScene has no children")
		get_tree().quit(1)
		return

	var room: Node = current_scene.get_child(0)
	print("[Inspect] CurrentScene child: ", room.name)

	var floor_node := room.get_node_or_null("Floor") as ColorRect
	if floor_node != null:
		print("[Inspect] Floor.color = ", floor_node.color)
		print("[Inspect] Floor.size  = ", floor_node.size)

	var player: Node = room.get_node_or_null("Player")
	if player != null:
		print("[Inspect] Player.position = ", player.position)

	var front_door: Area2D = room.get_node_or_null("FrontDoor")
	if front_door != null:
		print("[Inspect] FrontDoor found, target: ", front_door.target_scene)

	print("[Inspect] PASS")
	get_tree().quit(0)
