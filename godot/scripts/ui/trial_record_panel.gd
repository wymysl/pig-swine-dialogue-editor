extends PanelContainer
## TrialRecordPanel — live-updating trial record displayed during court round encounters.
##
## Subscribes to trial_record_* signals from BattleController (via Signals autoload).
## Never holds a direct reference to BattleController — all updates are signal-driven.
## Player-facing strings are loaded at _ready() from data/court_rounds/_trial_record_labels.json;
## no strings are hardcoded here per AGENTS.md §Stack invariants.
##
## Visual contract (AGENTS.md §Accessibility):
##   Effectiveness is conveyed by BOTH color and text label — never color alone.

const LABELS_PATH: String = "res://data/court_rounds/_trial_record_labels.json"
const POPUP_DWELL_SEC: float = 1.5

@onready var _panel_title: Label = $MarginContainer/VBox/PanelTitle
@onready var _facts_header: Label = $MarginContainer/VBox/FactsHeader
@onready var _facts_list: VBoxContainer = $MarginContainer/VBox/FactsList
@onready var _authorities_header: Label = $MarginContainer/VBox/AuthoritiesHeader
@onready var _authorities_list: VBoxContainer = $MarginContainer/VBox/AuthoritiesList
@onready var _opposing_position: Label = $MarginContainer/VBox/OpposingPosition
@onready var _effectiveness_popup: PanelContainer = $MarginContainer/VBox/EffectivenessPopup
@onready var _effectiveness_label: Label = $MarginContainer/VBox/EffectivenessPopup/EffectivenessLabel

## Loaded from _trial_record_labels.json. Empty dict if file fails to load.
var _labels: Dictionary = {}

## Popup token — incremented on each new citation popup so that the collapse
## callback from a superseded popup is a harmless no-op.
var _popup_token: int = 0


func _ready() -> void:
	_load_labels()
	_apply_ui_labels()
	_effectiveness_popup.hide()
	_connect_signals()


func _load_labels() -> void:
	if not FileAccess.file_exists(LABELS_PATH):
		push_error("TrialRecordPanel: labels file not found: %s" % LABELS_PATH)
		return
	var file: FileAccess = FileAccess.open(LABELS_PATH, FileAccess.READ)
	if file == null:
		push_error("TrialRecordPanel: cannot open labels file: %s" % LABELS_PATH)
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("TrialRecordPanel: JSON parse failed for labels file")
		return
	_labels = parsed


func _apply_ui_labels() -> void:
	var ui: Dictionary = {}
	if _labels.get("ui_labels", {}) is Dictionary:
		ui = _labels["ui_labels"]
	_panel_title.text = str(ui.get("panel_title", "Trial Record"))
	_facts_header.text = str(ui.get("facts_section", "Facts on Record"))
	_authorities_header.text = str(ui.get("authorities_section", "Authorities Cited"))
	_opposing_position.text = str(ui.get("opposing_position_label", ""))


func _connect_signals() -> void:
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs == null:
		push_error("TrialRecordPanel: Signals autoload not found; panel will not update")
		return
	if sigs.has_signal("trial_record_round_started"):
		sigs.trial_record_round_started.connect(_on_round_started)
	if sigs.has_signal("trial_record_fact_established"):
		sigs.trial_record_fact_established.connect(_on_fact_established)
	if sigs.has_signal("trial_record_citation_resolved"):
		sigs.trial_record_citation_resolved.connect(_on_citation_resolved)
	if sigs.has_signal("trial_record_opponent_stated"):
		sigs.trial_record_opponent_stated.connect(_on_opponent_stated)


## Called when a new court round begins. Clears both lists and resets the
## opposing-position line to the label-only placeholder.
func _on_round_started(_round_index: int) -> void:
	for child in _facts_list.get_children():
		child.queue_free()
	for child in _authorities_list.get_children():
		child.queue_free()
	_effectiveness_popup.hide()
	_popup_token += 1  ## invalidate any in-flight popup timer
	var ui: Dictionary = {}
	if _labels.get("ui_labels", {}) is Dictionary:
		ui = _labels["ui_labels"]
	_opposing_position.text = str(ui.get("opposing_position_label", ""))


## Called when Phase 1 fact-finding establishes a fact flag.
## Appends a "✓ <evidence_id>" row to the Facts on Record list.
func _on_fact_established(evidence_id: String, _flag_name: String) -> void:
	var row: Label = Label.new()
	row.text = "✓ %s" % evidence_id
	row.add_theme_font_size_override("font_size", 13)
	row.add_theme_color_override("font_color", Color(0.78, 0.93, 0.70, 1.0))
	row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_facts_list.add_child(row)


## Called when a Phase 2 citation resolves. Shows the effectiveness popup for
## POPUP_DWELL_SEC seconds, then collapses it to a row in the Authorities list.
## Both color and text label are set (WCAG requirement: no color-alone encoding).
func _on_citation_resolved(citation_id: String, bucket: String, _opponent_move: String) -> void:
	var bucket_labels: Dictionary = {}
	if _labels.get("bucket_labels", {}) is Dictionary:
		bucket_labels = _labels["bucket_labels"]
	var bucket_data: Dictionary = {}
	if bucket_labels.get(bucket, {}) is Dictionary:
		bucket_data = bucket_labels[bucket]

	var label_text: String = str(bucket_data.get("text", bucket))
	var label_color: Color = _color_from_array(bucket_data.get("color", []))

	_effectiveness_label.text = label_text
	_effectiveness_label.add_theme_color_override("font_color", label_color)
	_effectiveness_popup.show()

	_popup_token += 1
	var token: int = _popup_token
	get_tree().create_timer(POPUP_DWELL_SEC).timeout.connect(
		func() -> void: _collapse_popup_if_token(token, citation_id, label_text, label_color)
	)


## Called when the opponent advances a move, updating the Opposing Position line.
func _on_opponent_stated(move_display_name: String) -> void:
	if move_display_name.is_empty():
		return
	var ui: Dictionary = {}
	if _labels.get("ui_labels", {}) is Dictionary:
		ui = _labels["ui_labels"]
	var prefix: String = str(ui.get("opposing_position_label", "Opposing position"))
	_opposing_position.text = "%s: %s" % [prefix, move_display_name]


## Collapses the effectiveness popup to a row in the Authorities Cited list.
## The token check ensures only the most recent popup triggers a row addition.
func _collapse_popup_if_token(
	token: int,
	citation_id: String,
	label_text: String,
	label_color: Color
) -> void:
	if token != _popup_token:
		return  ## superseded by a newer citation popup
	_effectiveness_popup.hide()
	var row: Label = Label.new()
	row.text = "%s — %s" % [citation_id, label_text]
	row.add_theme_font_size_override("font_size", 13)
	row.add_theme_color_override("font_color", label_color)
	row.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_authorities_list.add_child(row)


## Parses a JSON color array [r, g, b] or [r, g, b, a] into a Color.
## Falls back to a neutral off-white if the array is malformed.
func _color_from_array(arr: Variant) -> Color:
	if not arr is Array:
		return Color(0.85, 0.83, 0.78, 1.0)
	var a: Array = arr
	if a.size() < 3:
		return Color(0.85, 0.83, 0.78, 1.0)
	var alpha: float = 1.0 if a.size() < 4 else float(a[3])
	return Color(float(a[0]), float(a[1]), float(a[2]), alpha)
