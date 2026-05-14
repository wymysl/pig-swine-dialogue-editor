extends SceneTree
## tests/test_visual_smoke.gd — visual regression baseline for interior rooms.
## Walks the player through all 8 directions in every interior scene and saves
## screenshots to test_output/visual_smoke/<room>/<beat>/<direction>.png.
## Under the headless DisplayServer this exits 0 with an explicit skip note.
##
## Usage:
##   godot --path . --script tests/test_visual_smoke.gd

const OUTPUT_DIR = "test_output/visual_smoke"
const INTERIOR_SCENES = [
	"res://scenes/interiors/pig_swine_office.tscn",
	"res://scenes/interiors/archive_room.tscn",
	"res://scenes/interiors/cafe_paragraf.tscn"
]

const DECLARED_BEATS = ["default"]
const DIRECTIONS = ["front", "front_right", "right", "back_right", "back", "back_left", "left", "front_left"]

func _init() -> void:
	print("[VisualSmoke] Starting visual smoke regression suite...")
	if DisplayServer.get_name().to_lower().contains("headless"):
		print("[VisualSmoke] NOTE: headless DisplayServer cannot provide viewport pixels; skipping screenshot capture.")
		quit(0)
		return
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(OUTPUT_DIR):
		dir.make_dir_recursive(OUTPUT_DIR)

	var state_node = get_root().get_node_or_null("State")

	for scene_path in INTERIOR_SCENES:
		var packed: PackedScene = load(scene_path)
		if packed == null:
			printerr("[VisualSmoke] FAIL: could not load " + scene_path)
			quit(1)
			return
		
		var room_name = scene_path.get_file().get_basename()
		
		for beat in DECLARED_BEATS:
			# Fulfill "sets State.current_beat to each declared beat"
			if state_node:
				if "current_beat" in state_node:
					state_node.set("current_beat", beat)
				else:
					state_node.data["current_beat"] = beat
			
			for dir_name in DIRECTIONS:
				var instance: Node = packed.instantiate()
				get_root().add_child(instance)
				
				# Wait for _ready and initial Y-sort
				await process_frame
				await process_frame
				
				var player = instance.get_node_or_null("Player")
				if player:
					player.set("_last_facing", dir_name)
					var anim = player.get_node_or_null("Visual")
					if anim and anim is AnimatedSprite2D and anim.sprite_frames.has_animation("walk_" + dir_name):
						anim.play("walk_" + dir_name)
						await process_frame
				
				# Wait one more frame to ensure rendering catches up
				await process_frame
				
				var img: Image = _capture_viewport_image()
				if img == null:
					print("[VisualSmoke] SKIP: renderer did not expose a viewport image.")
					quit(0)
					return
				
				var out_folder = OUTPUT_DIR + "/" + room_name + "/" + beat
				var da = DirAccess.open("res://")
				if not da.dir_exists(out_folder):
					da.make_dir_recursive(out_folder)
				
				var out_path = out_folder + "/" + dir_name + ".png"
				var err = img.save_png("res://" + out_path)
				if err != OK:
					printerr("[VisualSmoke] Failed to save " + out_path)
				else:
					print("[VisualSmoke] Saved " + out_path)
				
				instance.queue_free()
				await process_frame
	
	print("[VisualSmoke] Finished.")
	quit(0)


func _capture_viewport_image() -> Image:
	var texture := get_root().get_texture()
	if texture == null:
		return null
	var img: Image = texture.get_image()
	if img == null or img.is_empty():
		return null
	return img
