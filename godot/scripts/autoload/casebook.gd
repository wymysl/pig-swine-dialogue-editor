extends Node
## Casebook autoload — sole writer for the player's collected judgment cards.
## Loads entries from data/judgments.json (draft:false only).
## Single writer: Code role only (see AGENTS.md §File ownership).

const JUDGMENTS_PATH: String = "res://data/judgments.json"

var _judgments: Dictionary = {}


func _ready() -> void:
	reload()


func reload() -> void:
	_judgments.clear()
	var parsed: Dictionary = _load_json_dictionary(JUDGMENTS_PATH)
	var raw_judgments: Array = parsed.get("judgments", [])
	for raw in raw_judgments:
		if not raw is Dictionary:
			continue
		var judgment: Dictionary = raw
		if bool(judgment.get("draft", false)):
			continue
		var judgment_id: String = str(judgment.get("id", ""))
		if judgment_id == "":
			continue
		_judgments[judgment_id] = judgment


func get_collected_judgments() -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for judgment_id in _judgments.keys():
		var judgment: Dictionary = _judgments[judgment_id]
		if _conditions_met(judgment):
			out.append(judgment)
	return out


func get_judgment(judgment_id: String) -> Dictionary:
	return _judgments.get(judgment_id, {})


func _conditions_met(judgment: Dictionary) -> bool:
	var conditions: Dictionary = judgment.get("conditions", {})
	var required_flags: Array = conditions.get("required_flags", [])
	if required_flags.is_empty():
		return true
	for raw_condition in required_flags:
		if not raw_condition is Dictionary:
			return false
		var condition: Dictionary = raw_condition
		if not _condition_met(condition):
			return false
	return true


func _condition_met(condition: Dictionary) -> bool:
	var path: String = str(condition.get("path", ""))
	if path == "":
		return false
	var actual: Variant = _resolve_state_path(path)
	var op: String = str(condition.get("op", "eq"))
	if op == "eq":
		return actual == condition.get("value", null)
	if op == "any_of":
		var values: Array = condition.get("values", [])
		return values.has(actual)
	return false


func _resolve_state_path(path: String) -> Variant:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return null
	var current: Variant = state_node.get("data")
	for segment in path.split("."):
		if current is Dictionary and current.has(segment):
			current = current[segment]
		else:
			return null
	return current


func _load_json_dictionary(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("Casebook: could not open %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("Casebook: %s is not a JSON object" % path)
		return {}
	return parsed
