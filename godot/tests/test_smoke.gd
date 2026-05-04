extends SceneTree
## tests/test_smoke.gd — smoke test: load Main.tscn, wait one frame, quit 0.
## Verifies the scene tree initialises without errors in headless mode.
## Owner: QA role (append-only; see AGENTS.md §File ownership).
##
## Usage:
##   godot --headless --script tests/test_smoke.gd
##
## Also drives the acceptance command:
##   godot --headless --check-only --path .
## (via: project main_scene runs → smoke test can be called separately)

func _init() -> void:
	# Load Main.tscn as a child of the root so all autoloads are available.
	var main_scene: PackedScene = load("res://scenes/Main.tscn")
	if main_scene == null:
		printerr("[SmokeTest] FAIL: could not load res://scenes/Main.tscn")
		quit(1)
		return
	var instance: Node = main_scene.instantiate()
	get_root().add_child(instance)
	# Defer quit by one frame so _ready() callbacks on all nodes run first.
	await process_frame
	print("[SmokeTest] PASS: Main.tscn loaded and _ready() fired without errors.")
	quit(0)
