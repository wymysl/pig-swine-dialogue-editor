extends CanvasLayer
## SaveStatusToast — small global feedback surface for save and folder status.

const STRINGS_PATH: String = "res://data/case_folder_strings.json"
const DISPLAY_SECONDS: float = 3.0

var _strings: Dictionary = {}
var _tween: Tween = null

@onready var _panel: PanelContainer = $ToastPanel
@onready var _label: Label = $ToastPanel/ToastLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	_strings = _load_status_strings()
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs == null:
		return
	if sigs.has_signal("save_completed"):
		sigs.save_completed.connect(_on_save_completed)
	if sigs.has_signal("save_failed"):
		sigs.save_failed.connect(_on_save_failed)
	if sigs.has_signal("case_folder_acquired"):
		sigs.case_folder_acquired.connect(_on_case_folder_acquired)


func _on_save_completed() -> void:
	_show(status_string("save_completed", "Saved."))


func _on_save_failed(reason: String) -> void:
	var prefix: String = status_string("save_failed_prefix", "Save failed:")
	_show(prefix + " " + reason)


func _on_case_folder_acquired() -> void:
	var template: String = status_string("case_folder_acquired", "Press [%s] to open your case folder.")
	_show(template % [_action_label("case_folder_toggle")])


func status_string(key: String, fallback: String) -> String:
	return str(_strings.get(key, fallback))


func _show(text: String) -> void:
	if _tween != null:
		_tween.kill()
	_label.text = text
	visible = true
	_panel.modulate.a = 0.0
	_tween = create_tween()
	_tween.tween_property(_panel, "modulate:a", 1.0, 0.12)
	_tween.tween_interval(DISPLAY_SECONDS)
	_tween.tween_property(_panel, "modulate:a", 0.0, 0.24)
	_tween.tween_callback(func() -> void: visible = false)


func _load_status_strings() -> Dictionary:
	var file: FileAccess = FileAccess.open(STRINGS_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return {}
	var status: Variant = parsed.get("status", {})
	return status if status is Dictionary else {}


func _action_label(action_name: String) -> String:
	if not InputMap.has_action(action_name):
		return action_name
	for event in InputMap.action_get_events(action_name):
		var label: String = _event_label(event)
		if label != "":
			return label
	return action_name


func _event_label(event: InputEvent) -> String:
	if event is InputEventKey:
		var key_event: InputEventKey = event
		var code: Key = key_event.key_label
		if code == KEY_NONE:
			code = key_event.keycode
		if code == KEY_NONE:
			code = key_event.physical_keycode
		var key_name: String = OS.get_keycode_string(code)
		if key_name != "":
			return key_name
	return event.as_text().strip_edges()
