extends CanvasLayer
## CaseFolder — Dr. A. Cula's persistent Blue Folder UI.
## Text is loaded from data/case_folder_strings.json; packet logic stays in BlueBinder.

const STRINGS_PATH: String = "res://data/case_folder_strings.json"
const BLUE_BINDER_PATH: String = "res://scenes/ui/blue_binder.tscn"
const CHAPTER1_CASE_ID: String = "chapter1_sikorska"
const CaseFolderModel = preload("res://scripts/ui/case_folder_model.gd")

const TAB_NOTES: int = 0
const TAB_EVIDENCE: int = 1
const TAB_CASEBOOK: int = 2
const TAB_MOTION_PACKET: int = 3
const TAB_KEYS: Array[String] = ["notes", "evidence", "casebook", "motion_packet"]

var _strings: Dictionary = {}
var _items: Dictionary = {}
var _active_tab: int = TAB_NOTES
var _selected_index: int = 0
var _entries: Array[Dictionary] = []
var _is_open: bool = false
var _motion_packet: CanvasLayer = null

@onready var _title_label: Label = $FolderRoot/TitleStrip
@onready var _tab_bar: HBoxContainer = $FolderRoot/TabBar
@onready var _content: HBoxContainer = $FolderRoot/PageArea/Content
@onready var _list_vbox: VBoxContainer = $FolderRoot/PageArea/Content/ListPanel/ListScroll/ListVBox
@onready var _detail_title: Label = $FolderRoot/PageArea/Content/DetailPanel/DetailVBox/DetailTitle
@onready var _detail_meta: Label = $FolderRoot/PageArea/Content/DetailPanel/DetailVBox/DetailMeta
@onready var _detail_body: Label = $FolderRoot/PageArea/Content/DetailPanel/DetailVBox/DetailBody
@onready var _empty_label: Label = $FolderRoot/PageArea/EmptyState
@onready var _save_button: Button = $FolderRoot/FooterBar/SaveNowButton
@onready var _save_status_label: Label = $FolderRoot/FooterBar/SaveStatusLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_strings = CaseFolderModel.load_json_dictionary(STRINGS_PATH)
	_items = CaseFolderModel.load_items()
	_save_button.text = _status_string("save_button", "Save Now")
	_save_button.pressed.connect(_on_save_now_pressed)
	_connect_status_signals()
	_build_tabs()
	_set_tab(TAB_NOTES)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("case_folder_toggle"):
		if _is_open:
			close()
		elif _can_open():
			open()
		get_viewport().set_input_as_handled()
		return
	if not _is_open:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
		return
	if _is_left(event):
		_set_tab((_active_tab - 1 + TAB_KEYS.size()) % TAB_KEYS.size())
		get_viewport().set_input_as_handled()
		return
	if _is_right(event):
		_set_tab((_active_tab + 1) % TAB_KEYS.size())
		get_viewport().set_input_as_handled()
		return
	if _is_up(event):
		_move_selection(-1)
		get_viewport().set_input_as_handled()
		return
	if _is_down(event):
		_move_selection(1)
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_accept") or event.is_action_pressed("interact"):
		_open_selected_entry()
		get_viewport().set_input_as_handled()


func open() -> void:
	if _is_open or not _can_open():
		return
	visible = true
	_is_open = true
	_refresh_current_tab()
	get_tree().paused = true
	_emit_toggled(true)


func close() -> void:
	if not _is_open:
		return
	_hide_motion_packet()
	visible = false
	_is_open = false
	get_tree().paused = false
	_emit_toggled(false)


func is_open() -> bool:
	return _is_open


func _can_open() -> bool:
	if get_tree().paused:
		return false
	var ch1: Dictionary = CaseFolderModel.chapter1(_state_data())
	return bool(ch1.get("has_case_folder", false))


func _build_tabs() -> void:
	_title_label.text = CaseFolderModel.string_value(_strings, "folder_title")
	for child in _tab_bar.get_children():
		_tab_bar.remove_child(child)
		child.queue_free()
	for i in range(TAB_KEYS.size()):
		var button := Button.new()
		button.text = CaseFolderModel.tab_label(_strings, TAB_KEYS[i])
		button.toggle_mode = true
		button.focus_mode = Control.FOCUS_ALL
		button.custom_minimum_size = Vector2(152.0, 40.0)
		button.pressed.connect(_set_tab.bind(i))
		_tab_bar.add_child(button)


func _set_tab(tab_index: int) -> void:
	_active_tab = clamp(tab_index, 0, TAB_KEYS.size() - 1)
	_selected_index = 0
	_refresh_tab_buttons()
	_refresh_current_tab()


func _refresh_current_tab() -> void:
	_hide_motion_packet()
	_entries = []
	if _active_tab == TAB_NOTES:
		_entries = _note_entries()
	elif _active_tab == TAB_EVIDENCE:
		_entries = _evidence_entries()
	elif _active_tab == TAB_CASEBOOK:
		_entries = _casebook_entries()
	elif _active_tab == TAB_MOTION_PACKET:
		_refresh_motion_packet_tab()
		return
	_render_entry_list()
	_render_selected_detail(false)


func _refresh_motion_packet_tab() -> void:
	_clear_entry_list()
	_content.visible = false
	if CaseFolderModel.active_case_id(_state_data()) == CHAPTER1_CASE_ID:
		_empty_label.visible = false
		_show_motion_packet()
	else:
		_empty_label.text = CaseFolderModel.empty_state(_strings, "motion_packet")
		_empty_label.visible = true


func _render_entry_list() -> void:
	_content.visible = true
	_empty_label.visible = _entries.is_empty()
	_empty_label.text = CaseFolderModel.empty_state(_strings, TAB_KEYS[_active_tab])
	_clear_entry_list()
	if _entries.is_empty():
		return
	for i in range(_entries.size()):
		var button := Button.new()
		button.text = CaseFolderModel.entry_list_text(_strings, _entries[i])
		button.toggle_mode = true
		button.button_pressed = i == _selected_index
		button.focus_mode = Control.FOCUS_ALL
		button.clip_text = true
		button.custom_minimum_size = Vector2(320.0, 36.0)
		button.pressed.connect(_on_entry_pressed.bind(i))
		_list_vbox.add_child(button)


func _clear_entry_list() -> void:
	for child in _list_vbox.get_children():
		_list_vbox.remove_child(child)
		child.queue_free()


func _move_selection(delta: int) -> void:
	if _entries.is_empty() or _active_tab == TAB_MOTION_PACKET:
		return
	_selected_index = (_selected_index + delta + _entries.size()) % _entries.size()
	_render_entry_list()
	_render_selected_detail(false)


func _on_entry_pressed(index: int) -> void:
	_selected_index = clamp(index, 0, max(0, _entries.size() - 1))
	_open_selected_entry()


func _open_selected_entry() -> void:
	if _entries.is_empty() or _active_tab == TAB_MOTION_PACKET:
		return
	_render_selected_detail(true)
	_render_entry_list()


func _render_selected_detail(mark_seen: bool) -> void:
	if _entries.is_empty():
		_detail_title.text = CaseFolderModel.detail_empty_key(_strings, _active_tab)
		_detail_meta.text = ""
		_detail_body.text = ""
		return
	var entry: Dictionary = _entries[clamp(_selected_index, 0, _entries.size() - 1)]
	if mark_seen and _active_tab == TAB_NOTES:
		CaseFolderModel.mark_note_seen(_state_data(), str(entry.get("id", "")))
		entry["is_new"] = false
	_detail_title.text = str(entry.get("title", ""))
	_detail_meta.text = str(entry.get("meta", ""))
	_detail_body.text = str(entry.get("body", ""))


func _note_entries() -> Array[Dictionary]:
	return CaseFolderModel.note_entries(_state_data(), _strings)


func _evidence_entries() -> Array[Dictionary]:
	return CaseFolderModel.evidence_entries(_state_data(), _items, _strings)


func _casebook_entries() -> Array[Dictionary]:
	var casebook: Node = get_node_or_null("/root/Casebook")
	return CaseFolderModel.casebook_entries(casebook, _strings)


func _show_motion_packet() -> void:
	if _motion_packet == null:
		var packed: PackedScene = load(BLUE_BINDER_PATH) as PackedScene
		if packed == null:
			return
		_motion_packet = packed.instantiate() as CanvasLayer
		if _motion_packet == null:
			return
		_motion_packet.layer = layer + 1
		add_child(_motion_packet)
	if _motion_packet.has_method("refresh_from_state"):
		_motion_packet.refresh_from_state()
	_motion_packet.visible = true


func _hide_motion_packet() -> void:
	if _motion_packet != null:
		_motion_packet.visible = false


func _state_data() -> Dictionary:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return {}
	var data: Variant = state_node.get("data")
	return data if data is Dictionary else {}


func _refresh_tab_buttons() -> void:
	var buttons: Array = _tab_bar.get_children()
	for i in range(buttons.size()):
		var button: Button = buttons[i] as Button
		if button == null:
			continue
		button.button_pressed = i == _active_tab
		button.self_modulate = Color(1.0, 1.0, 1.0, 1.0) if i == _active_tab else Color(0.72, 0.78, 0.9, 1.0)


func _emit_toggled(is_open_value: bool) -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("case_folder_toggled"):
		sigs.case_folder_toggled.emit(is_open_value)


func _connect_status_signals() -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs == null:
		return
	if sigs.has_signal("save_completed"):
		sigs.save_completed.connect(_on_save_completed)
	if sigs.has_signal("save_failed"):
		sigs.save_failed.connect(_on_save_failed)


func _on_save_now_pressed() -> void:
	_save_status_label.text = _status_string("saving", "Saving...")
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("manual_save_requested"):
		sigs.manual_save_requested.emit()


func _on_save_completed() -> void:
	_save_status_label.text = _status_string("save_completed", "Saved.")


func _on_save_failed(reason: String) -> void:
	_save_status_label.text = _status_string("save_failed_prefix", "Save failed:") + " " + reason


func _status_string(key: String, fallback: String) -> String:
	var status: Variant = _strings.get("status", {})
	if status is Dictionary:
		return str(status.get(key, fallback))
	return fallback


func _is_left(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_left") or event.is_action_pressed("move_left")


func _is_right(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_right") or event.is_action_pressed("move_right")


func _is_up(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_up") or event.is_action_pressed("move_up")


func _is_down(event: InputEvent) -> bool:
	return event.is_action_pressed("ui_down") or event.is_action_pressed("move_down")
