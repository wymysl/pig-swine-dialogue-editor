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

	if not visual_ok:
		printerr("[Inspect] FAIL: Player has no visible primitive. ", visual_desc)
		quit(1)
		return

	print("[Inspect] Player visual: ", visual_desc)

	# --- Camera ---
	var camera: Camera2D = player.get_node_or_null("Camera2D")
	print("[Inspect] Camera2D present: ", camera != null)

	# --- InputMap: each movement action must have ≥1 event bound ---
	var input_ok: bool = true
	for action: String in ["move_up", "move_down", "move_left", "move_right"]:
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
	print("[Inspect] PASS — scene tree is correctly wired and visually renderable.")
	print("[Inspect] Expected on screen: dark floor ", floor_node.color, " | amber square at Player.position ", player.position)
	quit(0)
