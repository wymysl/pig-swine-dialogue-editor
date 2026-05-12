extends SceneTree
## Verifies the Pig & Swine office stays fully visible and only walls fade.

const OFFICE_SCENE := "res://scenes/interiors/pig_swine_office.tscn"
const GLOBAL_CAMERA_LIMITS := [0, 0, 960, 640]


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

	var camera := office.get_node_or_null("Player/Camera2D") as Camera2D
	if camera == null or not _camera_matches(camera, GLOBAL_CAMERA_LIMITS):
		printerr("[OfficeWallVisibility] FAIL: camera should keep full-office limits")
		quit(1)
		return

	for path in ["Asia", "MrPig", "Murrow", "Props/DeskKula", "Props/DeskWymysl"]:
		var item := office.get_node_or_null(path) as CanvasItem
		if item == null or not item.visible:
			printerr("[OfficeWallVisibility] FAIL: visible office node missing or hidden: ", path)
			quit(1)
			return

	var wall_occluder := office.get_node_or_null("WallOccluder")
	if wall_occluder == null:
		printerr("[OfficeWallVisibility] FAIL: WallOccluder not found")
		quit(1)
		return

	var player := office.get_node_or_null("Player") as Node2D
	var visual := office.get_node_or_null("WallOccluder/WingWallLow/Visual") as CanvasItem
	if player == null or visual == null:
		printerr("[OfficeWallVisibility] FAIL: player or wall visual not found")
		quit(1)
		return

	wall_occluder.call("_on_zone_entered", player, "WingWallLow")
	await create_timer(0.25).timeout
	if visual.modulate.a > 0.2:
		printerr("[OfficeWallVisibility] FAIL: wall did not fade when occluded")
		quit(1)
		return

	wall_occluder.call("_on_zone_exited", player, "WingWallLow")
	await create_timer(0.25).timeout
	if visual.modulate.a < 0.95:
		printerr("[OfficeWallVisibility] FAIL: wall did not restore after occlusion")
		quit(1)
		return

	print("[OfficeWallVisibility] PASS - office remains visible and walls fade.")
	quit(0)


func _camera_matches(camera: Camera2D, limits: Array) -> bool:
	return (
		camera.limit_left == limits[0]
		and camera.limit_top == limits[1]
		and camera.limit_right == limits[2]
		and camera.limit_bottom == limits[3]
	)
