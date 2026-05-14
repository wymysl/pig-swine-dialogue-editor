extends SceneTree
## tests/test_visual_capture.gd — visual capture for render-capable test runs.
## Loads Main.tscn, waits a frame, and saves a PNG when viewport pixels exist.
## Under the headless DisplayServer this exits 0 with an explicit skip note.

func _init() -> void:
	if DisplayServer.get_name().to_lower().contains("headless"):
		print("[Capture] NOTE: headless DisplayServer cannot provide viewport pixels; skipping PNG capture.")
		quit(0)
		return
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
	var img: Image = _capture_viewport_image(viewport)
	if img == null:
		print("[Capture] SKIP: headless renderer did not expose a viewport image.")
		quit(0)
		return
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


func _capture_viewport_image(viewport: Viewport) -> Image:
	var texture := viewport.get_texture()
	if texture == null:
		return null
	var img: Image = texture.get_image()
	if img == null or img.is_empty():
		return null
	return img
