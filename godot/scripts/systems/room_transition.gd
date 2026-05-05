extends Node
## scripts/systems/room_transition.gd
## Handles all scene-to-scene transitions: fade-out, swap CurrentScene child, place
## player at named spawn, fade-in. Communicates exclusively via the Signals autoload.
##
## Architectural choice: NOT an autoload. MainController instantiates this as a child
## so it has access to $CurrentScene without reaching up through get_tree(). It is still
## accessible project-wide via MainController.transition (set by main_controller.gd).
##
## Usage:
##   MainController.transition.go_to("res://scenes/world/routes/office_street.tscn", "street_spawn")
##
## Emits:
##   Signals.room_transition_started(target_scene_path)
##   Signals.room_transition_finished(target_scene_path)
##
## Single writer: Code role only (see AGENTS.md §File ownership).

const FADE_DURATION: float = 0.25  ## seconds for each half (out + in) = 500ms total

var _current_scene_slot: Node  ## set by MainController after instantiation
var _is_transitioning: bool = false

## Overlay ColorRect that covers the viewport during fade.
var _overlay: ColorRect


func _ready() -> void:
	_overlay = ColorRect.new()
	_overlay.color = Color(0.0, 0.0, 0.0, 0.0)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_overlay.z_index = 100
	add_child(_overlay)


## _signals — safe accessor; returns null in headless --script mode.
func _signals() -> Node:
	return get_node_or_null("/root/Signals")


## _state — safe accessor; returns null in headless --script mode.
func _state() -> Node:
	return get_node_or_null("/root/State")


## go_to — begin a transition to target_scene_path, placing the player at spawn_id.
## No-ops if a transition is already in progress.
func go_to(target_scene_path: String, spawn_id: String) -> void:
	if _is_transitioning:
		return
	_is_transitioning = true
	var sigs = _signals()
	if sigs:
		sigs.room_transition_started.emit(target_scene_path)
	await _fade_to(1.0)
	_swap_scene(target_scene_path, spawn_id)
	await _fade_to(0.0)
	_is_transitioning = false
	if sigs:
		sigs.room_transition_finished.emit(target_scene_path)


## _fade_to — tween the overlay alpha to target_alpha over FADE_DURATION seconds.
func _fade_to(target_alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(_overlay, "color:a", target_alpha, FADE_DURATION)
	await tween.finished


## _swap_scene — free current scene child, load and add the new scene, place player.
func _swap_scene(target_scene_path: String, spawn_id: String) -> void:
	if _current_scene_slot == null:
		push_error("RoomTransition: _current_scene_slot is null — call set_scene_slot() first.")
		return

	# Free current children.
	for child: Node in _current_scene_slot.get_children():
		child.queue_free()
	# Yield one frame so queue_free propagates before we add the new scene.
	await get_tree().process_frame

	var packed: PackedScene = load(target_scene_path) as PackedScene
	if packed == null:
		push_error("RoomTransition: failed to load scene: " + target_scene_path)
		return

	var new_scene: Node = packed.instantiate()
	_current_scene_slot.add_child(new_scene)

	# Update persistent state.
	var st = _state()
	if st:
		st.data["current_scene_path"] = target_scene_path
		st.data["current_spawn_id"] = spawn_id

	# Place player at the named spawn point.
	var player: Node = new_scene.get_node_or_null("Player")
	var spawn: Node = new_scene.get_node_or_null(spawn_id)
	if player != null and spawn != null:
		player.position = spawn.position
	elif player != null:
		pass  # spawn_id not found — player stays at scene-default position


## set_scene_slot — called by MainController to hand us the CurrentScene node.
func set_scene_slot(slot: Node) -> void:
	_current_scene_slot = slot


## is_busy — true while a transition is in progress.
func is_busy() -> bool:
	return _is_transitioning
