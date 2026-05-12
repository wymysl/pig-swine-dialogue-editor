extends SceneTree
## tests/test_scene_inspect.gd — structural inspection of the loaded scene tree.
## Verifies that office_street.tscn is loaded under MainController/CurrentScene,
## and that the Player has a VISIBLE visual node with non-zero draw data.
## A Sprite2D with null texture and a ColorRect with zero size both FAIL this check.

func _init() -> void:
	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	if main_scene == null:
		printerr("[Inspect] FAIL: could not load Main.tscn")
		quit(1)
		return

	var main: Node = main_scene.instantiate()
	get_root().add_child(main)
	await process_frame
	await process_frame

	# --- CurrentScene wiring ---
	var current_scene: Node = main.get_node_or_null("CurrentScene")
	if current_scene == null:
		printerr("[Inspect] FAIL: CurrentScene node not found")
		quit(1)
		return

	if current_scene.get_child_count() == 0:
		printerr("[Inspect] FAIL: CurrentScene has no children — office_street.tscn NOT loaded!")
		quit(1)
		return

	var office: Node = current_scene.get_child(0)
	print("[Inspect] CurrentScene child: ", office.name, " (", office.get_class(), ")")

	# --- Floor ---
	var floor_node := office.get_node_or_null("Floor") as ColorRect
	if floor_node == null:
		printerr("[Inspect] FAIL: Floor ColorRect not found")
		quit(1)
		return
	print("[Inspect] Floor.color = ", floor_node.color)
	print("[Inspect] Floor.size  = ", floor_node.size)
	if floor_node.size.x < 1.0 or floor_node.size.y < 1.0:
		printerr("[Inspect] FAIL: Floor has zero size — won't render!")
		quit(1)
		return

	# --- Player ---
	var player: Node = office.get_node_or_null("Player")
	if player == null:
		printerr("[Inspect] FAIL: Player node not found")
		quit(1)
		return
	print("[Inspect] Player.position = ", player.position)

	# --- Visual: must be a ColorRect with non-zero size, OR a Sprite2D with non-null texture ---
	var visual_ok: bool = false
	var visual_desc: String = ""

	# Check for ColorRect named "Visual"
	var color_rect := player.get_node_or_null("Visual") as ColorRect
	if color_rect != null:
		var w: float = color_rect.offset_right - color_rect.offset_left
		var h: float = color_rect.offset_bottom - color_rect.offset_top
		if w > 0.0 and h > 0.0:
			visual_ok = true
			visual_desc = "ColorRect 'Visual' %dx%d color=%s" % [int(w), int(h), color_rect.color]
		else:
			visual_desc = "ColorRect 'Visual' has zero size (%.0fx%.0f) — won't render!" % [w, h]

	# Fallback: check Sprite2D with a non-null texture
	if not visual_ok:
		var spr := player.get_node_or_null("Sprite2D") as Sprite2D
		if spr != null and spr.texture != null:
			visual_ok = true
			visual_desc = "Sprite2D with texture: " + spr.texture.resource_path
		elif spr != null:
			visual_desc = "Sprite2D found but texture is null — invisible!"

	# Fallback: check AnimatedSprite2D
	if not visual_ok:
		var anim_spr := player.get_node_or_null("Visual") as AnimatedSprite2D
		if anim_spr != null and anim_spr.sprite_frames != null:
			visual_ok = true
			visual_desc = "AnimatedSprite2D with frames: " + anim_spr.sprite_frames.resource_path

	if not visual_ok:
		printerr("[Inspect] FAIL: Player has no visible primitive. ", visual_desc)
		quit(1)
		return

	print("[Inspect] Player visual: ", visual_desc)

	# --- Doors and Spawns ---
	var front_door: Area2D = office.get_node_or_null("FrontDoor")
	if front_door == null:
		printerr("[Inspect] FAIL: FrontDoor not found")
		quit(1)
		return
	print("[Inspect] FrontDoor target_scene: ", front_door.target_scene)
	
	var office_spawn: Node2D = office.get_node_or_null("OfficeSpawn")
	if office_spawn == null:
		printerr("[Inspect] FAIL: OfficeSpawn not found")
		quit(1)
		return
	print("[Inspect] OfficeSpawn position: ", office_spawn.position)

	# --- InputMap: each movement action must have ≥1 event bound ---
	var input_ok: bool = true
	for action: String in ["move_up", "move_down", "move_left", "move_right", "interact"]:
		if not InputMap.has_action(action):
			printerr("[Inspect] FAIL: InputMap missing action '", action, "'")
			input_ok = false
			continue
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if events.is_empty():
			printerr("[Inspect] FAIL: InputMap action '", action, "' has 0 events — keys won't work!")
			input_ok = false
		else:
			print("[Inspect] InputMap '", action, "': ", events.size(), " event(s)")
	if not input_ok:
		quit(1)
		return

	print("")

	# --- NPCs in pig_swine_office.tscn ---
	# Load the office scene directly and check for NPC nodes.
	var office_packed: PackedScene = load("res://scenes/interiors/pig_swine_office.tscn")
	if office_packed == null:
		printerr("[Inspect] FAIL: could not load pig_swine_office.tscn")
		quit(1)
		return
	var office_scene: Node = office_packed.instantiate()
	get_root().add_child(office_scene)
	await process_frame

	var expected_npcs: Array[String] = ["Asia", "MrPig", "Murrow"]
	for npc_name in expected_npcs:
		var npc: Node = office_scene.get_node_or_null(npc_name)
		if npc == null:
			printerr("[Inspect] FAIL: NPC '%s' not found in pig_swine_office.tscn" % npc_name)
			office_scene.queue_free()
			quit(1)
			return
		var npc_id: String = npc.get("npc_id") if npc.get("npc_id") != null else ""
		var display_name: String = npc.get("display_name") if npc.get("display_name") != null else ""
		print("[Inspect] NPC '%s': npc_id='%s' display_name='%s'" % [npc_name, npc_id, display_name])
		if npc_id == "":
			printerr("[Inspect] FAIL: NPC '%s' has empty npc_id" % npc_name)
			office_scene.queue_free()
			quit(1)
			return
		if display_name == "":
			printerr("[Inspect] FAIL: NPC '%s' has empty display_name" % npc_name)
			office_scene.queue_free()
			quit(1)
			return
		if npc_name == "MrPig":
			var visual_spr := npc.get_node_or_null("Visual") as Sprite2D
			if visual_spr == null or visual_spr.texture == null:
				printerr("[Inspect] FAIL: MrPig does not have a valid Sprite2D Visual")
				office_scene.queue_free()
				quit(1)
				return

	office_scene.queue_free()

	print("")
	# --- Archive Room ---
	var archive_packed: PackedScene = load("res://scenes/interiors/archive_room.tscn")
	if archive_packed == null:
		printerr("[Inspect] FAIL: could not load archive_room.tscn")
		quit(1)
		return
	var archive_scene: Node = archive_packed.instantiate()
	get_root().add_child(archive_scene)
	await process_frame
	
	var crab: Node = archive_scene.get_node_or_null("Crab")
	if crab == null:
		printerr("[Inspect] FAIL: NPC 'Crab' not found in archive_room.tscn")
		quit(1)
		return
	print("[Inspect] NPC 'Crab' found in archive_room.tscn")
	archive_scene.queue_free()

	# --- Cafe Paragraf ---
	var cafe_packed: PackedScene = load("res://scenes/interiors/cafe_paragraf.tscn")
	if cafe_packed == null:
		printerr("[Inspect] FAIL: could not load cafe_paragraf.tscn")
		quit(1)
		return
	var cafe_scene: Node = cafe_packed.instantiate()
	get_root().add_child(cafe_scene)
	await process_frame
	
	var whimsy: Node = cafe_scene.get_node_or_null("Whimsy")
	if whimsy == null:
		printerr("[Inspect] FAIL: NPC 'Whimsy' not found in cafe_paragraf.tscn")
		quit(1)
		return
	print("[Inspect] NPC 'Whimsy' found in cafe_paragraf.tscn")
	cafe_scene.queue_free()

	print("[Inspect] PASS — scene tree is correctly wired, visually renderable, and NPCs are present.")
	quit(0)
