extends RefCounted
## CaseFolderModel — data loading and entry shaping for the Blue Folder UI.

const ITEMS_PATH: String = "res://data/items.json"


static func load_json_dictionary(path: String) -> Dictionary:
	var file: FileAccess = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("CaseFolder: could not open %s" % path)
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		push_error("CaseFolder: %s is not a JSON object" % path)
		return {}
	return parsed


static func load_items() -> Dictionary:
	var parsed: Dictionary = load_json_dictionary(ITEMS_PATH)
	var items: Variant = parsed.get("items", {})
	return items if items is Dictionary else {}


static func tab_label(strings: Dictionary, key: String) -> String:
	var labels: Dictionary = strings.get("tab_labels", {})
	return str(labels.get(key, ""))


static func empty_state(strings: Dictionary, key: String) -> String:
	var empty_states: Dictionary = strings.get("empty_states", {})
	return str(empty_states.get(key, ""))


static func string_value(strings: Dictionary, key: String) -> String:
	return str(strings.get(key, ""))


static func detail_empty_key(strings: Dictionary, active_tab: int) -> String:
	if active_tab == 0:
		return detail_label(strings, "note_detail_empty")
	if active_tab == 1:
		return detail_label(strings, "evidence_detail_empty")
	return detail_label(strings, "casebook_detail_empty")


static func entry_list_text(strings: Dictionary, entry: Dictionary) -> String:
	var title: String = str(entry.get("title", ""))
	if bool(entry.get("is_new", false)):
		var badge: String = string_value(strings, "new_badge_label")
		if badge != "":
			return title + " " + badge
	return title


static func mark_note_seen(data: Dictionary, fragment_id: String) -> void:
	if fragment_id == "":
		return
	var folder: Dictionary = data.get("case_folder", {})
	var notes_seen: Dictionary = folder.get("notes_seen", {})
	notes_seen[fragment_id] = true


static func note_entries(data: Dictionary, strings: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	var folder: Dictionary = data.get("case_folder", {})
	var notes_seen: Dictionary = folder.get("notes_seen", {})
	var fragments: Array = folder.get("argument_fragments", [])
	for raw in fragments:
		if not raw is Dictionary:
			continue
		var fragment: Dictionary = raw
		var tags: Array[String] = string_array(fragment.get("tags", []))
		var fragment_id: String = str(fragment.get("id", ""))
		out.append({
			"id": fragment_id,
			"title": str(fragment.get("title", fragment_id)),
			"meta": format_labeled(strings, "tags", ", ".join(tags)),
			"body": str(fragment.get("body", "")),
			"is_new": not notes_seen.has(fragment_id),
		})
	return out


static func evidence_entries(data: Dictionary, items: Dictionary, strings: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	for item_id in held_item_ids(data, items):
		var item: Dictionary = items.get(item_id, {})
		out.append({
			"id": item_id,
			"title": str(item.get("display_name", item_id)),
			"meta": format_labeled(strings, "id", item_id),
			"body": str(item.get("description", "")),
			"is_new": false,
		})
	return out


static func casebook_entries(casebook: Node, strings: Dictionary) -> Array[Dictionary]:
	var out: Array[Dictionary] = []
	if casebook == null or not casebook.has_method("get_collected_judgments"):
		return out
	var judgments: Array = casebook.get_collected_judgments()
	for raw in judgments:
		if not raw is Dictionary or bool(raw.get("draft", false)):
			continue
		var judgment: Dictionary = raw
		out.append({
			"id": str(judgment.get("id", "")),
			"title": str(judgment.get("judgment_name", judgment.get("id", ""))),
			"meta": format_labeled(strings, "principles", principle_names(judgment)),
			"body": str(judgment.get("case_summary", "")),
			"is_new": false,
		})
	return out


static func active_case_id(data: Dictionary) -> String:
	return str(data.get("active_case_id", ""))


static func chapter1(data: Dictionary) -> Dictionary:
	var ch1: Variant = data.get("chapter1", {})
	return ch1 if ch1 is Dictionary else {}


static func held_item_ids(data: Dictionary, items: Dictionary) -> Array[String]:
	var held: Dictionary = {}
	var inventory: Dictionary = data.get("inventory", {})
	for item_id in inventory.keys():
		if bool(inventory[item_id]):
			held[str(item_id)] = true
	for item_id in items.keys():
		var item: Dictionary = items[item_id]
		var flag_path: String = str(item.get("state_flag", ""))
		if flag_path != "" and state_path_matches_item(data, flag_path, str(item_id)):
			held[str(item_id)] = true
	var ids: Array[String] = []
	for key in held.keys():
		ids.append(str(key))
	ids.sort()
	return ids


static func state_path_matches_item(data: Dictionary, path: String, item_id: String) -> bool:
	var value: Variant = resolve_path(data, path)
	if value is bool:
		return bool(value)
	if value is String:
		return str(value) == item_id
	return false


static func principle_names(judgment: Dictionary) -> String:
	var names: Array[String] = []
	var moves: Array = judgment.get("principle_moves", [])
	for raw_move in moves:
		if raw_move is Dictionary:
			names.append(str(raw_move.get("name", raw_move.get("id", ""))))
	return ", ".join(names)


static func format_labeled(strings: Dictionary, label_key: String, value: String) -> String:
	if value == "":
		return ""
	var label: String = detail_label(strings, label_key)
	return value if label == "" else label + " " + value


static func detail_label(strings: Dictionary, key: String) -> String:
	var labels: Dictionary = strings.get("detail_labels", {})
	return str(labels.get(key, ""))


static func string_array(raw: Variant) -> Array[String]:
	var out: Array[String] = []
	if raw is Array:
		for value in raw:
			out.append(str(value))
	return out


static func resolve_path(data: Dictionary, path: String) -> Variant:
	var current: Variant = data
	for segment in path.split("."):
		if current is Dictionary and current.has(segment):
			current = current[segment]
		else:
			return null
	return current
