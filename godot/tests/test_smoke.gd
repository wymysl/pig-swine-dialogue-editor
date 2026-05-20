extends SceneTree
## tests/test_smoke.gd — smoke test: load Main.tscn, wait one frame, quit 0.
## Verifies the scene tree initialises and boot-time catalogue validation is clean.
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
	for autoload_name in ["State", "Signals", "Casebook", "DialogueRunner"]:
		if get_root().get_node_or_null(autoload_name) == null:
			printerr("[SmokeTest] FAIL: missing autoload /root/%s" % autoload_name)
			quit(1)
			return
	if instance.get_node_or_null("Save") == null:
		printerr("[SmokeTest] FAIL: Main.tscn missing Save node")
		quit(1)
		return
	var runner = get_root().get_node_or_null("DialogueRunner")
	if runner != null and runner.has_method("get_validation_errors"):
		var validation_errors: Array = runner.get_validation_errors()
		if not validation_errors.is_empty():
			printerr("[SmokeTest] FAIL: DialogueRunner validation emitted %d error(s)." % validation_errors.size())
			for message in validation_errors:
				printerr("  - %s" % str(message))
			quit(1)
			return
	print("[SmokeTest] PASS: Main.tscn loaded and _ready() fired without errors.")
	quit(0)
