extends SceneTree

const CHAPTER1_PATH: String = "res://data/chapters/chapter1.json"
const DIALOGUES_DIR: String = "res://data/dialogues/"
const MUTATION_HOOK_KEYS: Array = ["on_dismiss", "on_enter", "on_select"]
const NON_DIALOGUE_SET_MARKERS: Array = [
	"engine",
	"casebook engine",
	"trigger",
	"not yet authored",
	"office payoff close",
	"when wired",
]

var _had_error: bool = false


func _init() -> void:
	var chapter_data: Dictionary = _load_json_dictionary(CHAPTER1_PATH)
	if _had_error:
		quit(1)
		return

	var chapter_flags: Dictionary = {}
	var set_by_by_flag: Dictionary = {}
	var flag_order: Array = []
	_collect_chapter_flags(chapter_data, chapter_flags, set_by_by_flag, flag_order)
	if _had_error:
		quit(1)
		return

	var dialogue_flags: Dictionary = {}
	_collect_dialogue_flags(dialogue_flags)
	if _had_error:
		quit(1)
		return

	var dialogue_set_count: int = 0
	var engine_set_count: int = 0
	var unreferenced_count: int = 0

	for flag_key in flag_order:
		if dialogue_flags.has(flag_key):
			dialogue_set_count += 1
			continue

		var set_by: String = str(set_by_by_flag.get(flag_key, ""))
		print("[Chapter1FlagCoverage] UNREFERENCED: ", flag_key, " | set_by: ", set_by)
		if _is_non_dialogue_set(set_by):
			engine_set_count += 1
		else:
			unreferenced_count += 1

	print("%d flags total, %d dialogue-set, %d engine-set, %d unreferenced" % [
		flag_order.size(),
		dialogue_set_count,
		engine_set_count,
		unreferenced_count,
	])

	if unreferenced_count > 0:
		printerr("[Chapter1FlagCoverage] FAIL: ", unreferenced_count, " flags are not set by dialogue and are not annotated as engine-set.")
		quit(1)
		return

	print("[Chapter1FlagCoverage] PASS: All dialogue-owned Chapter 1 flags are referenced.")
	quit(0)


func _load_json_dictionary(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		_fail("could not open " + path)
		return {}

	var text: String = file.get_as_text()
	file.close()

	var parsed: Variant = JSON.parse_string(text)
	if parsed == null:
		_fail("JSON parse failed for " + path)
		return {}
	if not parsed is Dictionary:
		_fail("expected a JSON object in " + path)
		return {}

	return parsed as Dictionary


func _collect_chapter_flags(
	chapter_data: Dictionary,
	chapter_flags: Dictionary,
	set_by_by_flag: Dictionary,
	flag_order: Array
) -> void:
	if not chapter_data.has("new_state_flags") or not chapter_data["new_state_flags"] is Array:
		_fail(CHAPTER1_PATH + " is missing a new_state_flags array")
		return

	var entries: Array = chapter_data["new_state_flags"]
	for entry in entries:
		if not entry is Dictionary:
			_fail(CHAPTER1_PATH + " has a non-object new_state_flags entry")
			return

		var flag_key: String = str(entry.get("key", ""))
		if flag_key == "":
			_fail(CHAPTER1_PATH + " has a new_state_flags entry without key")
			return

		chapter_flags[flag_key] = true
		set_by_by_flag[flag_key] = str(entry.get("set_by", ""))
		flag_order.append(flag_key)


func _collect_dialogue_flags(dialogue_flags: Dictionary) -> void:
	var dir: DirAccess = DirAccess.open(DIALOGUES_DIR)
	if dir == null:
		_fail("could not open " + DIALOGUES_DIR)
		return

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and _should_scan_dialogue_file(file_name):
			var path: String = DIALOGUES_DIR + file_name
			var dialogue_data: Dictionary = _load_json_dictionary(path)
			if _had_error:
				dir.list_dir_end()
				return
			_scan_dialogue_value(dialogue_data, dialogue_flags)
		file_name = dir.get_next()
	dir.list_dir_end()


func _should_scan_dialogue_file(file_name: String) -> bool:
	if not file_name.ends_with(".json"):
		return false
	if file_name.contains(".bak"):
		return false
	return true


func _scan_dialogue_value(value: Variant, dialogue_flags: Dictionary) -> void:
	if value is Dictionary:
		var dict: Dictionary = value as Dictionary

		for hook_key in MUTATION_HOOK_KEYS:
			if dict.has(hook_key):
				_scan_mutations(dict[hook_key], dialogue_flags)

		if dict.has("options") and dict["options"] is Dictionary:
			_scan_options(dict["options"] as Dictionary, dialogue_flags)

		for child_key in dict.keys():
			var child: Variant = dict[child_key]
			if child is Dictionary or child is Array:
				_scan_dialogue_value(child, dialogue_flags)
	elif value is Array:
		var values: Array = value as Array
		for item in values:
			_scan_dialogue_value(item, dialogue_flags)


func _scan_options(options: Dictionary, dialogue_flags: Dictionary) -> void:
	var write_path: String = str(options.get("write_path", ""))
	if write_path != "":
		dialogue_flags[write_path] = true

	if options.has("choices") and options["choices"] is Array:
		var choices: Array = options["choices"] as Array
		for choice in choices:
			if choice is Dictionary:
				_scan_assignment_object(choice as Dictionary, dialogue_flags)


func _scan_mutations(mutations: Variant, dialogue_flags: Dictionary) -> void:
	if mutations is Array:
		var mutation_list: Array = mutations as Array
		for mutation in mutation_list:
			if mutation is Dictionary:
				_scan_assignment_object(mutation as Dictionary, dialogue_flags)
	elif mutations is Dictionary:
		_scan_assignment_object(mutations as Dictionary, dialogue_flags)


func _scan_assignment_object(mutation: Dictionary, dialogue_flags: Dictionary) -> void:
	if mutation.has("set"):
		var set_path: String = str(mutation["set"])
		if set_path != "":
			dialogue_flags[set_path] = true

	if mutation.has("write_path"):
		var write_path: String = str(mutation["write_path"])
		if write_path != "":
			dialogue_flags[write_path] = true

	if mutation.has("award_badge"):
		var badge_id: String = str(mutation["award_badge"])
		if badge_id != "":
			dialogue_flags["badges." + badge_id] = true

	if mutation.has("unlock_route"):
		var route_id: String = str(mutation["unlock_route"])
		if route_id != "":
			dialogue_flags["routes_unlocked." + route_id] = true


func _is_non_dialogue_set(set_by: String) -> bool:
	var lower_set_by: String = set_by.to_lower()
	for marker in NON_DIALOGUE_SET_MARKERS:
		if lower_set_by.contains(str(marker)):
			return true
	return false


func _fail(message: String) -> void:
	_had_error = true
	printerr("[Chapter1FlagCoverage] FAIL: ", message)
