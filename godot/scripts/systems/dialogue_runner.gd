extends Node
## DialogueRunner — resolves NPC dialogue against State.data.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Lifecycle:
##   _ready()  — loads all JSON files from data/dialogues/ and data/asia_hints.json.
##   On Signals.dialogue_requested(npc_id) — picks the best matching line and
##               emits Signals.dialogue_line_ready(speaker, line).
##
## Trigger evaluation:
##   Each state entry may have a "trigger" string of &&-separated clauses.
##   Clause format:  "chapter1.met_pig == true"
##                   "chapter1.met_murrow != false"
##   LHS is a dotted path into State.data. RHS is compared as a string.
##   All clauses must pass for the state entry to match.
##
## Selection priority:
##   1. First state whose trigger evaluates to true (in JSON order).
##   2. If no states match: a random entry from the "idle_flavor" array.
##   3. If idle_flavor is also empty: a hard-coded fallback line.

const DIALOGUES_DIR: String = "res://data/dialogues/"
const ASIA_HINTS_PATH: String = "res://data/asia_hints.json"
const FALLBACK_LINE: String = "..."

## _catalogue — map of npc_id -> parsed dialogue Dict.
var _catalogue: Dictionary = {}
var _active_state_mutations: Array = []


func _ready() -> void:
	var sigs = get_node_or_null("/root/Signals")
	if sigs:
		sigs.dialogue_requested.connect(_on_dialogue_requested)
		sigs.dialogue_dismissed.connect(_on_dialogue_dismissed)
	_load_all_dialogues()

func _on_dialogue_dismissed() -> void:
	if _active_state_mutations.is_empty():
		return
	var state_node = get_node_or_null("/root/State")
	if state_node == null:
		return
	for mut in _active_state_mutations:
		if mut is Dictionary and mut.has("set") and mut.has("value"):
			_set_state_value(state_node.data, mut["set"], mut["value"])
	_active_state_mutations.clear()

func _set_state_value(data: Dictionary, path: String, value: Variant) -> void:
	var segments = path.split(".")
	var current = data
	for i in range(segments.size() - 1):
		var seg = segments[i]
		if current is Dictionary and current.has(seg) and current[seg] is Dictionary:
			current = current[seg]
		else:
			return
	var last_seg = segments[segments.size() - 1]
	if current is Dictionary and current.has(last_seg):
		current[last_seg] = value


## _signals — safe accessor; returns null in headless --script mode.
func _signals() -> Node:
	return get_node_or_null("/root/Signals")


## _state_data — safe accessor for State.data dict.
func _state_data() -> Dictionary:
	var st = get_node_or_null("/root/State")
	if st:
		return st.data
	return {}


func _load_all_dialogues() -> void:
	## Load asia_hints.json under the key "asia".
	_load_file("asia", ASIA_HINTS_PATH)

	## Load every *.json inside DIALOGUES_DIR.
	var dir := DirAccess.open(DIALOGUES_DIR)
	if dir == null:
		push_warning("DialogueRunner: dialogues dir not found: " + DIALOGUES_DIR)
		return
	dir.list_dir_begin()
	var fname: String = dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.ends_with(".json"):
			var npc_id: String = fname.get_basename()
			_load_file(npc_id, DIALOGUES_DIR + fname)
		fname = dir.get_next()
	dir.list_dir_end()


func _load_file(npc_id: String, path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("DialogueRunner: cannot open " + path)
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_error("DialogueRunner: JSON parse failed for " + path)
		return
	_catalogue[npc_id] = parsed
	print("DialogueRunner: loaded dialogue for '%s'" % npc_id)


func _on_dialogue_requested(npc_id: String, display_name: String) -> void:
	if not _catalogue.has(npc_id):
		push_warning("DialogueRunner: no dialogue data for npc_id='%s'" % npc_id)
		var sigs_fb = _signals()
		if sigs_fb:
			sigs_fb.dialogue_line_ready.emit(display_name, [FALLBACK_LINE])
		return

	var data: Dictionary = _catalogue[npc_id]
	var speaker: String = display_name

	## Try each state entry in order.
	var states: Array = data.get("states", [])
	for entry in states:
		var trigger: String = entry.get("trigger", "")
		if _evaluate_trigger(trigger):
			_active_state_mutations = entry.get("on_dismiss", [])
			var lines: Array = _extract_lines(entry)
			var sigs2 = _signals()
			if sigs2:
				sigs2.dialogue_line_ready.emit(speaker, lines)
			return

	## Fall back to idle_flavor (random).
	var idle: Array = data.get("idle_flavor", [])
	if idle.size() > 0:
		var chosen = idle[randi() % idle.size()]
		var lines: Array = _extract_lines(chosen) if chosen is Dictionary else [str(chosen)]
		var sigs3 = _signals()
		if sigs3:
			sigs3.dialogue_line_ready.emit(speaker, lines)
		return

	## Hard fallback.
	var sigs_hf = _signals()
	if sigs_hf:
		sigs_hf.dialogue_line_ready.emit(speaker, [FALLBACK_LINE])


## _extract_line — handles both dialogue JSON formats:
##   Simple:   { "line": "Text here." }
##   Asia hint: { "hint": { "neutral": "Text.", "agitated": "...", "deadpan": "..." } }
func _extract_lines(entry: Dictionary) -> Array:
	if entry.has("lines"):
		var val = entry["lines"]
		if val is Array:
			return val
		elif val is String:
			return [val]
	if entry.has("line"):
		return [entry["line"]]
	if entry.has("hint") and entry["hint"] is Dictionary:
		var hint: Dictionary = entry["hint"]
		## Prefer "neutral", then first available key.
		if hint.has("neutral"):
			return [hint["neutral"]]
		for key in hint:
			return [hint[key]]
	return [FALLBACK_LINE]


## _evaluate_trigger — returns true if every clause in the trigger string passes.
## An empty trigger always passes (unconditional match).
func _evaluate_trigger(trigger: String) -> bool:
	if trigger.strip_edges() == "":
		return true
	var clauses: Array = trigger.split("&&")
	for raw_clause in clauses:
		var clause: String = raw_clause.strip_edges()
		if not _evaluate_clause(clause):
			return false
	return true


## _evaluate_clause — evaluates a single "lhs op rhs" clause.
## Supported operators: == and !=
## LHS is a dotted key path into State.data.
func _evaluate_clause(clause: String) -> bool:
	var op: String = ""
	var parts: PackedStringArray
	if clause.contains("!="):
		op = "!="
		parts = clause.split("!=", false, 1)
	elif clause.contains("=="):
		op = "=="
		parts = clause.split("==", false, 1)
	else:
		push_warning("DialogueRunner: unrecognised clause operator in: " + clause)
		return false

	if parts.size() != 2:
		push_warning("DialogueRunner: malformed clause: " + clause)
		return false

	var lhs_path: String = parts[0].strip_edges()
	var rhs_raw: String = parts[1].strip_edges()

	var actual = _resolve_path(lhs_path)
	if actual == null:
		push_warning("DialogueRunner: unresolved path '%s' in clause '%s'" % [lhs_path, clause])
		return false

	## Normalise both sides to string for comparison.
	var actual_str: String = _to_compare_str(actual)
	var expected_str: String = _to_compare_str(rhs_raw)

	if op == "==":
		return actual_str == expected_str
	else:  ## !=
		return actual_str != expected_str


## _resolve_path — traverses dotted path into State.data.
## Returns null if any segment is missing.
func _resolve_path(path: String) -> Variant:
	var segments: Array = path.split(".")
	var current: Variant = _state_data()
	for seg in segments:
		if current is Dictionary and current.has(seg):
			current = current[seg]
		else:
			return null
	return current


## _to_compare_str — normalises a Variant or string-literal for comparison.
## Strips surrounding quotes if present; lowercases "true"/"false".
func _to_compare_str(v: Variant) -> String:
	var s: String = str(v)
	## Remove surrounding single or double quotes.
	if (s.begins_with('"') and s.ends_with('"')) or \
	   (s.begins_with("'") and s.ends_with("'")):
		s = s.substr(1, s.length() - 2)
	return s.to_lower()
