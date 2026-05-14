extends SceneTree
## Verifies the Pig & Swine office stays fully visible under the current
## TileMapLayer wall topology.

const OFFICE_SCENE := "res://scenes/interiors/pig_swine_office.tscn"


func _init() -> void:
	var packed := load(OFFICE_SCENE) as PackedScene
	if packed == null:
		printerr("[OfficeWallVisibility] FAIL: could not load office scene")
		quit(1)
		return

	var office := packed.instantiate()
	get_root().add_child(office)
	await process_frame
	await process_frame

	if office.get_node_or_null("RoomFog") != null:
		printerr("[OfficeWallVisibility] FAIL: RoomFog black-overlay node should not exist")
		quit(1)
		return

	if office.get_node_or_null("WallOccluder") != null:
		printerr("[OfficeWallVisibility] FAIL: legacy WallOccluder should not exist in TileMap office")
		quit(1)
		return

	var floor_layer := office.get_node_or_null("Floor") as TileMapLayer
	var wall_layer := office.get_node_or_null("Walls") as TileMapLayer
	if floor_layer == null or wall_layer == null:
		printerr("[OfficeWallVisibility] FAIL: Floor and Walls TileMapLayer nodes are required")
		quit(1)
		return

	var floor_rect: Rect2i = floor_layer.get_used_rect()
	var wall_rect: Rect2i = wall_layer.get_used_rect()
	if floor_rect.size.x <= 0 or floor_rect.size.y <= 0:
		printerr("[OfficeWallVisibility] FAIL: Floor TileMapLayer has no used cells")
		quit(1)
		return
	if not _walls_enclose_floor(wall_rect, floor_rect):
		printerr("[OfficeWallVisibility] FAIL: Walls TileMapLayer does not enclose floor; walls=%s floor=%s" % [str(wall_rect), str(floor_rect)])
		quit(1)
		return

	var camera := office.get_node_or_null("Player/Camera2D") as Camera2D
	if camera == null:
		printerr("[OfficeWallVisibility] FAIL: Player/Camera2D missing")
		quit(1)
		return
	if not _camera_matches_floor(camera, floor_layer, floor_rect):
		printerr("[OfficeWallVisibility] FAIL: camera limits should match floor bounds; limits=(%d,%d,%d,%d) floor=%s tile_size=%s" % [
			camera.limit_left, camera.limit_top, camera.limit_right, camera.limit_bottom,
			str(floor_rect), str(floor_layer.tile_set.tile_size)
		])
		quit(1)
		return

	for path in ["Asia", "MrPig", "Murrow", "Props/DeskKula", "Props/DeskWymysl"]:
		var item := office.get_node_or_null(path) as CanvasItem
		if item == null or not item.visible:
			printerr("[OfficeWallVisibility] FAIL: visible office node missing or hidden: ", path)
			quit(1)
			return

	print("[OfficeWallVisibility] PASS - office remains visible with TileMap walls and locked camera bounds.")
	quit(0)


func _camera_matches_floor(camera: Camera2D, floor_layer: TileMapLayer, floor_rect: Rect2i) -> bool:
	var tile_size: Vector2i = floor_layer.tile_set.tile_size
	var expected_left: int = floor_rect.position.x * tile_size.x
	var expected_top: int = floor_rect.position.y * tile_size.y
	var expected_right: int = (floor_rect.position.x + floor_rect.size.x) * tile_size.x
	var expected_bottom: int = (floor_rect.position.y + floor_rect.size.y) * tile_size.y
	return (
		camera.limit_left == expected_left
		and camera.limit_top == expected_top
		and camera.limit_right == expected_right
		and camera.limit_bottom == expected_bottom
	)


func _walls_enclose_floor(wall_rect: Rect2i, floor_rect: Rect2i) -> bool:
	return (
		wall_rect.position.x <= floor_rect.position.x - 1
		and wall_rect.position.y <= floor_rect.position.y - 1
		and wall_rect.position.x + wall_rect.size.x >= floor_rect.position.x + floor_rect.size.x + 1
		and wall_rect.position.y + wall_rect.size.y >= floor_rect.position.y + floor_rect.size.y + 1
	)
