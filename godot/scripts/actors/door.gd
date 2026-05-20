extends Area2D
## scripts/actors/door.gd
## Area2D-based interactable door. Player presses [interact] (E) while overlapping
## to trigger a room transition to target_scene / target_spawn_id.
##
## Properties are set per-instance in the scene inspector or via the scene file.
## Reads target data from data/doors.json via door_id; inspector overrides take
## precedence over JSON data so scenes can hard-code the values for robustness.
##
## AGENTS.md: Code role owns id, target_scene, target_spawn_id, required_flag.
## Design role populates locked_text (left empty by Code; door is always unlocked
## when required_flag is "" or the flag is set in State).
##
## Single writer: Code role (scripts/actors/door.gd).

## door_id matches an entry in data/doors.json.
@export var door_id: String = ""
## Direct inspector override — takes precedence over doors.json if non-empty.
@export var target_scene: String = ""
## Spawn-point node name in the target scene.
@export var target_spawn_id: String = "default"
## Dotted State.data path that must be truthy for this door to open
## ("" = always open). Example: "chapter1.has_law_binder".
@export var required_flag: String = ""

## Visual indicator: thin dark rect shown in the room floor.
@export var show_indicator: bool = true

const DOOR_SOUND_PATH: String = "res://audio/sfx/door_open.ogg"

var _player_inside: bool = false
var _prompt: Node
var _sfx: AudioStreamPlayer


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_sfx = AudioStreamPlayer.new()
	var stream = load(DOOR_SOUND_PATH) as AudioStream
	if stream:
		_sfx.stream = stream
	add_child(_sfx)
	# Resolve target_scene from doors.json if not set directly.
	if target_scene.is_empty() and not door_id.is_empty():
		_resolve_from_json()

	var prompt_scene = load("res://scenes/ui/interaction_prompt.tscn")
	if prompt_scene:
		_prompt = prompt_scene.instantiate()
		add_child(_prompt)


func _resolve_from_json() -> void:
	var path: String = "res://data/doors.json"
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Door: cannot open " + path)
		return
	var data: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if data == null or not data.has("doors"):
		return
	for entry: Dictionary in data["doors"]:
		if entry.get("id", "") == door_id:
			if target_scene.is_empty():
				target_scene = entry.get("target_scene", "")
			if target_spawn_id == "default":
				target_spawn_id = entry.get("target_spawn_id", "default")
			required_flag = entry.get("required_flag", "")
			return


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside:
		return
	if not event.is_action_pressed("interact"):
		return
	_try_open()


func _try_open() -> void:
	if target_scene.is_empty():
		push_error("Door '%s': target_scene is empty — check doors.json or inspector." % door_id)
		return
	# Check required flag.
	if not required_flag.is_empty():
		var state_node = get_tree().get_root().get_node_or_null("State")
		var st: Dictionary = {}
		if state_node and state_node.get("data") is Dictionary:
			st = state_node.data
		if not _is_required_flag_met(st):
			return  # locked — Design will add locked_text feedback later
	# Delegate to RoomTransition via MainController.
	var mc: Node = get_tree().get_root().get_node_or_null("Main")
	if mc == null:
		push_error("Door: could not find /root/Main node.")
		return
	var rt: Node = mc.get_node_or_null("RoomTransition")
	if rt == null:
		push_error("Door: /root/Main/RoomTransition not found.")
		return
	if _sfx and _sfx.stream:
		_sfx.play()
	rt.go_to(target_scene, target_spawn_id)


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if _prompt:
			_prompt.show_prompt()


func _on_body_exited(body: Node) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if _prompt:
			_prompt.hide_prompt()


func _is_required_flag_met(state_data: Dictionary) -> bool:
	if required_flag.is_empty():
		return true
	var value: Variant = _resolve_state_path(state_data, required_flag)
	return _truthy(value)


func _resolve_state_path(state_data: Dictionary, path: String) -> Variant:
	var current: Variant = state_data
	for segment in path.split("."):
		if not current is Dictionary:
			return null
		var dict: Dictionary = current
		if not dict.has(segment):
			return null
		current = dict[segment]
	return current


func _truthy(value: Variant) -> bool:
	if value == null:
		return false
	if value is bool:
		return bool(value)
	if value is int:
		return int(value) != 0
	if value is float:
		return not is_zero_approx(float(value))
	if value is String:
		return not str(value).is_empty()
	if value is Array:
		return not (value as Array).is_empty()
	if value is Dictionary:
		return not (value as Dictionary).is_empty()
	return true
