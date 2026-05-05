extends Node2D
## MainController — root of scenes/Main.tscn.
## Sole writer: Code role (see AGENTS.md §File ownership).
## Responsibilities: scene router, autoload glue, top-level UI overlays.
## CurrentScene child slot holds the active room scene.
##
## Sprint 3: boots the scene recorded in State, wires the RoomTransition child.
## Test/CLI logic lives entirely in tests/test_*.gd — never here.

const VERSION: String = "0.1.0"

## Public handle so Door and other nodes can reach the transition system.
var transition: Node  ## typed as Node; runtime type is RoomTransition


func _ready() -> void:
	print("Pig & Swine RPG v", VERSION, " — engine ready.")
	transition = $RoomTransition
	transition.set_scene_slot($CurrentScene)
	_boot_initial_scene()


func _boot_initial_scene() -> void:
	## Use get_node_or_null so this script compiles in --script test mode where
	## autoloads are not yet registered. Falls back to the default scene path.
	var state_node = get_node_or_null("/root/State")
	var scene_path: String
	if state_node != null:
		scene_path = state_node.data.get(
			"current_scene_path",
			"res://scenes/world/routes/office_street.tscn"
		)
	else:
		scene_path = "res://scenes/world/routes/office_street.tscn"
	var packed: PackedScene = load(scene_path) as PackedScene
	if packed == null:
		push_error("MainController: failed to load boot scene: " + scene_path)
		return
	$CurrentScene.add_child(packed.instantiate())
