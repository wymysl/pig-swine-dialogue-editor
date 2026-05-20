extends SceneTree
## test_case_folder.gd — smoke coverage for the Blue Folder UI and data files.

var _pass_count: int = 0
var _fail_count: int = 0
var _fragment_signals: Array[String] = []


func _init() -> void:
	await process_frame
	_test_json_files_parse()
	_test_strings_do_not_ship_draft_markers()
	await _test_scene_has_four_tabs()
	_test_input_action_exists()
	_test_dialogue_action_adds_fragment_idempotently()
	_finish()


func _test_json_files_parse() -> void:
	print("[T1] JSON files parse")
	_assert(_load_json("res://data/case_folder_strings.json").has("tab_labels"), "case_folder_strings.json parses")
	_assert(_load_json("res://data/argument_fragments.json").has("fragments"), "argument_fragments.json parses")


func _test_strings_do_not_ship_draft_markers() -> void:
	print("[T1b] no draft markers in case folder strings")
	var strings: Dictionary = _load_json("res://data/case_folder_strings.json")
	var values: Array[String] = []
	_collect_string_values(strings, values)
	for value in values:
		_assert(not value.contains("_doc:"), "string does not expose _doc marker: " + value)
		_assert(not value.contains("DRAFT"), "string does not expose DRAFT marker: " + value)


func _test_scene_has_four_tabs() -> void:
	print("[T2] scene tab structure")
	var packed: PackedScene = load("res://scenes/ui/case_folder.tscn") as PackedScene
	_assert(packed != null, "case_folder.tscn loads")
	if packed == null:
		return
	var instance: Node = packed.instantiate()
	get_root().add_child(instance)
	await process_frame
	var tabs: HBoxContainer = instance.get_node_or_null("FolderRoot/TabBar") as HBoxContainer
	_assert(tabs != null, "TabBar exists")
	_assert(tabs != null and tabs.get_child_count() == 4, "four tab Buttons are built")
	instance.queue_free()


func _test_input_action_exists() -> void:
	print("[T3] input action")
	_assert(InputMap.has_action("case_folder_toggle"), "case_folder_toggle action exists")
	_assert(not InputMap.action_get_events("case_folder_toggle").is_empty(), "case_folder_toggle has an event")


func _test_dialogue_action_adds_fragment_idempotently() -> void:
	print("[T4] add_argument_fragment action")
	var state_node: Node = get_root().get_node_or_null("/root/State")
	var runner: Node = get_root().get_node_or_null("/root/DialogueRunner")
	var sigs: Node = get_root().get_node_or_null("/root/Signals")
	_assert(state_node != null, "State autoload exists")
	_assert(runner != null, "DialogueRunner autoload exists")
	_assert(sigs != null, "Signals autoload exists")
	if state_node == null or runner == null or sigs == null:
		return
	state_node.set("data", state_node.call("reset_state"))
	_fragment_signals.clear()
	sigs.case_folder_fragment_added.connect(func(fragment_id: String) -> void:
		_fragment_signals.append(fragment_id)
	)
	runner._catalogue["case_folder_test_npc"] = {
		"version": 1,
		"npc_id": "case_folder_test_npc",
		"states": [
			{
				"id": "case_folder_test_add_fragment",
				"trigger": "",
				"lines": ["test"],
				"on_dismiss": [
					{"add_argument_fragment": "fragment_ch1_actual_notice"}
				]
			}
		],
		"idle_flavor": [],
	}
	runner._on_dialogue_requested("case_folder_test_npc", "Test")
	runner._on_dialogue_dismissed()
	runner._on_dialogue_requested("case_folder_test_npc", "Test")
	runner._on_dialogue_dismissed()
	var folder: Dictionary = state_node.get("data").get("case_folder", {})
	var fragments: Array = folder.get("argument_fragments", [])
	_assert(fragments.size() == 1, "duplicate add_argument_fragment is a no-op")
	if fragments.size() > 0 and fragments[0] is Dictionary:
		_assert(str(fragments[0].get("id", "")) == "fragment_ch1_actual_notice", "fragment id stored")
	else:
		_assert(false, "fragment id stored")
	_assert(_fragment_signals.size() == 1, "fragment signal emitted once")


func _load_json(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return {}
	return parsed as Dictionary


func _collect_string_values(value: Variant, out: Array[String]) -> void:
	if value is Dictionary:
		for key in value:
			_collect_string_values(value[key], out)
	elif value is Array:
		for item in value:
			_collect_string_values(item, out)
	elif value is String:
		out.append(str(value))


func _assert(condition: bool, message: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: ", message)
	else:
		_fail_count += 1
		printerr("  FAIL: ", message)


func _finish() -> void:
	print("[CaseFolderTest] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)
