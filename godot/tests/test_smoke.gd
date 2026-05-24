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

	## Dev-addon autoload presence (2026-05-24): the Godot AI addon registers
	## `_mcp_game_helper` per godot/AGENTS.md §"Approved development addons".
	## It is a debugger-channel listener used during editor sessions only — no
	## game system reads from it. Pinning its presence here keeps an
	## accidental removal of `addons/godot_ai/` from boot-passing silently.
	## When the open F2 web-export-exclusion decision lands, this assertion
	## will need a feature-tag guard (e.g. `if not OS.has_feature("web")`).
	if get_root().get_node_or_null("_mcp_game_helper") == null:
		printerr("[SmokeTest] FAIL: missing dev autoload /root/_mcp_game_helper (addons/godot_ai/).")
		quit(1)
		return

	## Boot-error inspection across autoloads with a validation-errors surface.
	## 2026-05-22 tech critique F5: previously only DialogueRunner was gated;
	## Casebook's JSON-load failures silently passed smoke.
	for autoload_name in ["DialogueRunner", "Casebook"]:
		var auto: Node = get_root().get_node_or_null(autoload_name)
		if auto != null and auto.has_method("get_validation_errors"):
			var errs: Array = auto.get_validation_errors()
			if not errs.is_empty():
				printerr("[SmokeTest] FAIL: %s reported %d boot error(s)." % [autoload_name, errs.size()])
				for message in errs:
					printerr("  - %s" % str(message))
				quit(1)
				return

	## MainController.instance contract (2026-05-22 tech critique F8): the
	## static accessor must be live after Main.tscn boot so actors like door.gd
	## can route through MainController.instance.transition.
	if instance is MainController:
		if MainController.instance != instance:
			printerr("[SmokeTest] FAIL: MainController.instance not wired to the booted Main node.")
			quit(1)
			return
		if (instance as MainController).transition == null:
			printerr("[SmokeTest] FAIL: MainController.transition is null after boot.")
			quit(1)
			return

	print("[SmokeTest] PASS: Main.tscn loaded and _ready() fired without errors.")
	quit(0)
