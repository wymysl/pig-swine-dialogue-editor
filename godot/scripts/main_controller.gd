extends Node2D
## MainController — root of scenes/Main.tscn.
## Sole writer: Code role (see AGENTS.md §File ownership).
## Responsibilities: scene router, autoload glue, top-level UI overlays.
## CurrentScene child slot holds the active room scene.
##
## Sprint 1: hard-codes office_street as the boot scene.
## Sprint 2: replace the preload+instantiate below with room_transition.gd.

const VERSION: String = "0.1.0"

const _BOOT_SCENE: PackedScene = preload("res://scenes/world/routes/office_street.tscn")

func _ready() -> void:
	print("Pig & Swine RPG v", VERSION, " — engine ready.")
	var boot: Node = _BOOT_SCENE.instantiate()
	$CurrentScene.add_child(boot)
