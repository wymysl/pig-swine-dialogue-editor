extends Area2D
## Sign — a readable signage prop in the overworld.
##
## Wraps a non-NPC interactable (street sign, notice board, plate) and
## dispatches its lines through the existing dialogue box on E. Schema:
## data/signage_ch1.json (and per-chapter siblings if/when later chapters
## add signage). Signs are NOT NPCs and do NOT go through dialogue_runner;
## they are stateless reads.
##
## Per AGENTS.md §Stack invariants, no player-facing text lives in .gd or
## .tscn — the line text is loaded at boot from the JSON signage catalogue.
##
## Optional gate flag: if the entry declares `_gate_flag` and the State
## value at that path evaluates truthy, the sign uses `lines_unlocked`
## instead of `lines`. This lets the Court Signpost shift from a bare
## directional to a helpful note once the court route is unlocked.
##
## Collision layer 4 (npc/interactables), mask 2 (player) — matches
## pickup.gd convention. The script is meant to be attached to an Area2D
## child of a Sprite2D sign prop in the scene tree.

@export var sign_id: String = ""
@export var catalogue_path: String = "res://data/signage_ch1.json"

var _player_inside: bool = false
var _prompt: Node
var _lines: Array = []
var _lines_unlocked: Array = []
var _gate_flag: String = ""


func _ready() -> void:
	_apply_catalogue_data()

	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if not has_node("Visual"):
		## Sign decoration is rendered by the parent Sprite2D in the scene
		## tree. Sign.gd does not add a visual of its own. (pickup.gd
		## adds a yellow ColorRect because pickups are spawned without
		## sprites; signs are always children of an existing Sprite2D.)
		pass

	var has_shape: bool = false
	for child in get_children():
		if child is CollisionShape2D:
			has_shape = true
			break
	if not has_shape:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(48.0, 48.0)
		shape.shape = rect
		add_child(shape)

	var prompt_scene = load("res://scenes/ui/interaction_prompt.tscn")
	if prompt_scene:
		_prompt = prompt_scene.instantiate()
		add_child(_prompt)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		var lines_to_show: Array = _resolve_lines()
		if lines_to_show.is_empty():
			return
		var sigs = get_node_or_null("/root/Signals")
		if sigs:
			## Empty speaker + empty npc_id matches the pickup.gd convention
			## for stage-direction-style lines. The dialogue box renders
			## them as descriptive prose without a speaker tag.
			sigs.dialogue_line_ready.emit("", "", lines_to_show)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		if _prompt:
			_prompt.show_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		if _prompt:
			_prompt.hide_prompt()


func _apply_catalogue_data() -> void:
	if sign_id.is_empty():
		push_warning("Sign: sign_id is empty; nothing will be dispatched")
		return
	var entry: Dictionary = _load_sign_entry(sign_id)
	if entry.is_empty():
		push_warning("Sign: sign_id '%s' missing from %s" % [sign_id, catalogue_path])
		return
	var raw_lines = entry.get("lines", [])
	if raw_lines is Array:
		_lines = raw_lines
	var raw_unlocked = entry.get("lines_unlocked", [])
	if raw_unlocked is Array:
		_lines_unlocked = raw_unlocked
	_gate_flag = str(entry.get("_gate_flag", ""))


func _load_sign_entry(id: String) -> Dictionary:
	if not FileAccess.file_exists(catalogue_path):
		push_warning("Sign: catalogue missing: " + catalogue_path)
		return {}
	var file := FileAccess.open(catalogue_path, FileAccess.READ)
	if file == null:
		push_warning("Sign: cannot open catalogue: " + catalogue_path)
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed == null or not parsed is Dictionary:
		push_warning("Sign: catalogue JSON parse failed: " + catalogue_path)
		return {}
	var raw_signs = parsed.get("signs", [])
	if not raw_signs is Array:
		push_warning("Sign: catalogue missing 'signs' array")
		return {}
	for entry in raw_signs:
		if entry is Dictionary and str(entry.get("id", "")) == id:
			return entry
	return {}


func _resolve_lines() -> Array:
	if _gate_flag.is_empty() or _lines_unlocked.is_empty():
		return _lines
	if _read_state_value(_gate_flag):
		return _lines_unlocked
	return _lines


func _read_state_value(path: String) -> Variant:
	var state_node = get_node_or_null("/root/State")
	var parts = path.split(".")
	if parts.size() != 2 or state_node == null:
		return null
	var top: String = parts[0]
	var key: String = parts[1]
	if not state_node.data.has(top) or not state_node.data[top] is Dictionary:
		return null
	var target: Dictionary = state_node.data[top]
	if not target.has(key):
		return null
	return target[key]
