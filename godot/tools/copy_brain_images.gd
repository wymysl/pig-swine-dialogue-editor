## Godot tool script: Copy images from brain directory to project art directory.
## Run: godot --headless --path godot --script tools/copy_brain_images.gd --log-file /tmp/copy_brain.log
extends SceneTree

const BRAIN_DIR = "/Users/piotr/.gemini/antigravity/brain/d501b945-6b7d-4f24-bd29-09c778495aed/"

var _copy_map: Dictionary = {}

func _init() -> void:
	# Machine sprites
	_copy_map["machine_idle_1778624705306.png"] = "res://art/minigames/coffee/coffee_machine_idle.png"
	_copy_map["machine_gurgle_1778624725072.png"] = "res://art/minigames/coffee/coffee_machine_gurgle.png"
	_copy_map["machine_happy_1778624740234.png"] = "res://art/minigames/coffee/coffee_machine_happy.png"
	_copy_map["machine_angry_1778624753883.png"] = "res://art/minigames/coffee/coffee_machine_angry.png"

	var ok_count := 0
	var fail_count := 0

	for src_name in _copy_map:
		var src_path: String = BRAIN_DIR + str(src_name)
		var dst_path: String = str(_copy_map[src_name])
		var img := Image.new()
		var err := img.load(src_path)
		if err != OK:
			print("FAIL load: ", src_path, " error=", err)
			fail_count += 1
			continue

		# Resize to 128x128 for machine sprites
		if img.get_width() != 128 or img.get_height() != 128:
			img.resize(128, 128, Image.INTERPOLATE_NEAREST)

		err = img.save_png(dst_path)
		if err != OK:
			print("FAIL save: ", dst_path, " error=", err)
			fail_count += 1
		else:
			print("OK: ", dst_path, " (", img.get_width(), "x", img.get_height(), ")")
			ok_count += 1

	print("Done: ", ok_count, " OK, ", fail_count, " FAILED")
	quit()
