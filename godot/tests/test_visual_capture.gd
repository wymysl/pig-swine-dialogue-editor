extends SceneTree
## tests/test_visual_capture.gd — headless visual capture for CI verification.
## Loads Main.tscn (which loads office_street.tscn), waits a frame, saves a PNG.

func _init() -> void:
	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	if main_scene == null:
		printerr("[Capture] FAIL: could not load Main.tscn")
		quit(1)
		return
	var instance: Node = main_scene.instantiate()
	get_root().add_child(instance)
	# Wait two frames for _ready() to run and children to be added
	await process_frame
	await process_frame
	# Capture the viewport
	var viewport: Viewport = get_root()
	var img: Image = viewport.get_texture().get_image()
	var out_path: String = "exports/web/screenshot_headless.png"
	var err: int = img.save_png(out_path)
	if err == OK:
		print("[Capture] Screenshot saved to: ", out_path, " (", img.get_width(), "x", img.get_height(), ")")
		# Sample pixel at centre (480,320) — should be the player amber color
		var centre: Color = img.get_pixel(480, 320)
		print("[Capture] Centre pixel: R=", snapped(centre.r, 0.01), " G=", snapped(centre.g, 0.01), " B=", snapped(centre.b, 0.01))
		# Sample pixel at (10,10) — should be the floor dark color
		var floor_px: Color = img.get_pixel(10, 10)
		print("[Capture] Floor pixel: R=", snapped(floor_px.r, 0.01), " G=", snapped(floor_px.g, 0.01), " B=", snapped(floor_px.b, 0.01))
	else:
		printerr("[Capture] Failed to save PNG, error: ", err)
	quit(0)
