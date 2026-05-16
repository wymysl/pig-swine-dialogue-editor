extends Node
## BinderUI — autoload for the blue procedural binder UI.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Owns one BlueBinder scene instance, instantiated at boot and parented
## under the autoload. Activated by the `binder` input action when the player
## holds the procedural binder (chapter1.has_law_binder == true) and no
## other paused-modal UI is on screen (dialogue box not open).
##
## v0 prototype — pure visualisation. Does NOT flip chapter1.binder_read_*
## flags on open or page-turn. v1 will add the state-write hooks per
## PROPOSAL_player_driven_argument.md §2 v2 deliverable.
##
## Lifecycle:
##   _ready()  — instantiate BlueBinder scene as a hidden child.
##   _unhandled_input(binder) — toggle open/close when the gate evaluates true.
##   open()/close() — show/hide the scene, pause/unpause the tree.
##
## Process mode is PROCESS_MODE_ALWAYS so the autoload still receives input
## after open() flips get_tree().paused = true (so the player can close the
## binder while it's open).

const BinderScenePath: String = "res://scenes/ui/blue_binder.tscn"

var _binder: CanvasLayer = null
var _is_open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var packed: PackedScene = load(BinderScenePath) as PackedScene
	if packed == null:
		push_error("BinderUI: could not load %s" % BinderScenePath)
		return
	_binder = packed.instantiate() as CanvasLayer
	if _binder == null:
		push_error("BinderUI: BlueBinder scene root is not a CanvasLayer")
		return
	_binder.visible = false
	add_child(_binder)


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("binder"):
		return
	if _is_open:
		close()
		return
	if not _can_open():
		return
	open()


## _can_open — gate predicate for the B key.
## Requires chapter1.has_law_binder == true AND no other paused-modal UI active.
## The "no other modal" check is conservative: if the tree is already paused
## (e.g. dialogue box up), we do not open over the top.
func _can_open() -> bool:
	var tree: SceneTree = get_tree()
	if tree == null:
		return false
	if tree.paused:
		return false
	var state: Node = get_node_or_null("/root/State")
	if state == null:
		return false
	var data: Dictionary = state.data if "data" in state else {}
	var ch1: Dictionary = data.get("chapter1", {})
	return bool(ch1.get("has_law_binder", false))


func open() -> void:
	if _is_open:
		return
	if _binder == null:
		return
	if _binder.has_method("refresh_from_state"):
		_binder.refresh_from_state()
	_binder.visible = true
	_is_open = true
	get_tree().paused = true


func close() -> void:
	if not _is_open:
		return
	if _binder != null:
		_binder.visible = false
	_is_open = false
	get_tree().paused = false


## is_open — read-only accessor for systems that need to know whether the
## binder is currently up (e.g. to avoid emitting dialogue while it is).
func is_open() -> bool:
	return _is_open
