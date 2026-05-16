extends CanvasLayer
## BlueBinder — Chapter 1 motion-packet assembly surface.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## v1 scope:
## - Show surfaced evidence cards only (no hidden-card hunting).
## - Let the player assign surfaced evidence to four required packet slots.
## - Keep requested remedy as a separate choice.
## - Expose optional decoy/blunder toggles, with incapacity gated behind halina_met.
## - Persist selections into State.data.chapter1.
## - Apply packet scoring with one hard gate only: minimum required elements.

const EVIDENCE_FILE: String = "res://data/evidence_ch1.json"
const FRAMES_FILE: String = "res://data/argument_frames_ch1.json"

const SLOT_NON_CURRENT_ADDRESS: String = "element_non_current_address"
const SLOT_LANDLORD_KNOWLEDGE: String = "element_landlord_knowledge"
const SLOT_ACTUAL_NOTICE_WINDOW: String = "element_timely_actual_notice_motion"
const SLOT_NO_THIRD_PARTY_AUTHORITY: String = "element_no_third_party_cure"

const SLOT_ORDER: Array[String] = [
	SLOT_NON_CURRENT_ADDRESS,
	SLOT_LANDLORD_KNOWLEDGE,
	SLOT_ACTUAL_NOTICE_WINDOW,
	SLOT_NO_THIRD_PARTY_AUTHORITY,
]

const SLOT_LABELS: Dictionary = {
	SLOT_NON_CURRENT_ADDRESS: "Address non-current",
	SLOT_LANDLORD_KNOWLEDGE: "Landlord knowledge",
	SLOT_ACTUAL_NOTICE_WINDOW: "Actual-notice window",
	SLOT_NO_THIRD_PARTY_AUTHORITY: "No third-party authority",
}

const SLOT_STATE_KEYS: Dictionary = {
	SLOT_NON_CURRENT_ADDRESS: "packet_slot_address_non_current",
	SLOT_LANDLORD_KNOWLEDGE: "packet_slot_landlord_knowledge",
	SLOT_ACTUAL_NOTICE_WINDOW: "packet_slot_actual_notice_window",
	SLOT_NO_THIRD_PARTY_AUTHORITY: "packet_slot_no_third_party_authority",
}

const REMEDY_STATE_KEY: String = "packet_requested_remedy"
const REMEDY_OPTIONS: Array[Dictionary] = [
	{"id": "procedural_reset", "label": "Procedural reset"},
	{"id": "merits_dismissal", "label": "Merits dismissal"},
	{"id": "tenancy_ruling", "label": "Tenancy ruling"},
	{"id": "dismissal_with_prejudice", "label": "Dismissal with prejudice"},
]

const DECOY_DEFINITIONS: Array[Dictionary] = [
	{
		"flag": "decoy_merits",
		"frame_id": "substantive_defense",
		"fallback_label": "Merits fallback",
		"requires_halina": false,
	},
	{
		"flag": "decoy_notice_period",
		"frame_id": "notice_period_failure",
		"fallback_label": "Notice-period fallback",
		"requires_halina": false,
	},
	{
		"flag": "decoy_standing_wrong_party",
		"frame_id": "standing_wrong_party",
		"fallback_label": "Standing / wrong party",
		"requires_halina": false,
	},
	{
		"flag": "decoy_overbroad_remedy",
		"frame_id": "overbroad_remedy",
		"fallback_label": "Overbroad remedy",
		"requires_halina": false,
	},
	{
		"flag": "decoy_incapacity",
		"frame_id": "incapacity_defense",
		"fallback_label": "Incapacity by age (blunder)",
		"requires_halina": true,
	},
]

const FRAME_PRIORITY: Array[String] = [
	"incapacity_defense",
	"overbroad_remedy",
	"standing_wrong_party",
	"notice_period_failure",
	"substantive_defense",
]

const FRAME_DEFAULT: String = "defective_service_135bis"
const DEFAULT_REMEDY: String = "procedural_reset"

## Order is determined by JSON key insertion order, which Godot 4 Dictionary
## iteration preserves.
var _evidence: Dictionary = {}
var _frames: Dictionary = {}
var _ordered_ids: Array[String] = []
var _active_index: int = 0

## OptionButton index maps.
var _slot_option_values: Dictionary = {}
var _remedy_option_values: Array[String] = []
var _decoy_checkboxes: Dictionary = {}

@onready var _page_tabs: HBoxContainer = $BinderRoot/PageTabs
@onready var _page_body_title: Label = $BinderRoot/PageBody/PageBodyTitle
@onready var _page_body_summary: Label = $BinderRoot/PageBody/PageBodySummary
@onready var _press_lines_container: VBoxContainer = $BinderRoot/PageBody/PressLines
@onready var _tags_footer: Label = $BinderRoot/PageBody/TagsFooter

@onready var _slot_address_option: OptionButton = $BinderRoot/PageBody/PacketPanel/PacketVBox/AddressSlotOption
@onready var _slot_landlord_option: OptionButton = $BinderRoot/PageBody/PacketPanel/PacketVBox/LandlordSlotOption
@onready var _slot_notice_option: OptionButton = $BinderRoot/PageBody/PacketPanel/PacketVBox/NoticeSlotOption
@onready var _slot_authority_option: OptionButton = $BinderRoot/PageBody/PacketPanel/PacketVBox/AuthoritySlotOption
@onready var _remedy_option: OptionButton = $BinderRoot/PageBody/PacketPanel/PacketVBox/RemedyOption
@onready var _decoy_container: VBoxContainer = $BinderRoot/PageBody/PacketPanel/PacketVBox/DecoyOptions
@onready var _apply_packet_button: Button = $BinderRoot/PageBody/PacketPanel/PacketVBox/ApplyPacketButton
@onready var _packet_status_label: Label = $BinderRoot/PageBody/PacketPanel/PacketVBox/PacketStatusLabel


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_evidence()
	_load_frames()
	_connect_packet_controls()
	refresh_from_state()


## refresh_from_state — called by BinderUI autoload before each open() so the
## surface reflects current chapter state.
func refresh_from_state() -> void:
	_ensure_state_defaults()
	_refresh_ordered_ids_from_surface()
	_build_tabs()
	_build_slot_options()
	_build_remedy_options()
	_build_decoy_options()
	_show_page(_active_index)
	_render_packet_status_preview()


## Public helper for tests.
func get_surfaced_evidence_ids() -> Array[String]:
	return _ordered_ids.duplicate()


## Public helper for tests.
func get_available_evidence_for_slot(slot_key: String) -> Array[String]:
	var out: Array[String] = []
	if not SLOT_ORDER.has(slot_key):
		return out
	for evidence_id in _ordered_ids:
		var card: Dictionary = _evidence.get(evidence_id, {})
		if _card_supports_slot(card, slot_key):
			out.append(evidence_id)
	return out


## Public helper for tests and scripting. Returns true when assignment is valid.
func assign_evidence_to_slot(slot_key: String, evidence_id: String) -> bool:
	if not SLOT_ORDER.has(slot_key):
		return false
	if evidence_id != "":
		if not _ordered_ids.has(evidence_id):
			return false
		var card: Dictionary = _evidence.get(evidence_id, {})
		if not _card_supports_slot(card, slot_key):
			return false
	var slot_state_key: String = SLOT_STATE_KEYS.get(slot_key, "")
	if slot_state_key == "":
		return false
	_write_chapter1(slot_state_key, evidence_id)
	_write_chapter1(slot_key, evidence_id != "")
	_build_slot_options()
	_render_packet_status_preview()
	return true


## Public helper for tests and scripting.
func set_requested_remedy(remedy_id: String) -> bool:
	if not _is_known_remedy(remedy_id):
		return false
	_write_chapter1(REMEDY_STATE_KEY, remedy_id)
	_build_remedy_options()
	_render_packet_status_preview()
	return true


## Public helper for tests and scripting.
func set_decoy_selected(decoy_flag: String, selected: bool) -> bool:
	if not _is_known_decoy_flag(decoy_flag):
		return false
	if decoy_flag == "decoy_incapacity" and not bool(_chapter1().get("halina_met", false)):
		return false
	_write_chapter1(decoy_flag, selected)
	_build_decoy_options()
	_render_packet_status_preview()
	return true


## evaluate_packet — computes packet completeness + scoring, without writing.
func evaluate_packet() -> Dictionary:
	var ch1: Dictionary = _chapter1()
	var required_count: int = 0
	for slot_key in SLOT_ORDER:
		var state_key: String = SLOT_STATE_KEYS.get(slot_key, "")
		if state_key != "" and String(ch1.get(state_key, "")) != "":
			required_count += 1

	var minimum_required: int = _minimum_required_elements()
	var remedy_id: String = String(ch1.get(REMEDY_STATE_KEY, DEFAULT_REMEDY))
	if not _is_known_remedy(remedy_id):
		remedy_id = DEFAULT_REMEDY

	var selected_frames: Array[String] = []
	for decoy in DECOY_DEFINITIONS:
		var flag_name: String = str(decoy.get("flag", ""))
		var frame_id: String = str(decoy.get("frame_id", ""))
		if flag_name == "decoy_incapacity" and not bool(ch1.get("halina_met", false)):
			continue
		if bool(ch1.get(flag_name, false)) and frame_id != "":
			selected_frames.append(frame_id)

	if remedy_id != DEFAULT_REMEDY and not selected_frames.has("overbroad_remedy"):
		selected_frames.append("overbroad_remedy")

	var proposed_frame: String = FRAME_DEFAULT
	for frame_id in FRAME_PRIORITY:
		if selected_frames.has(frame_id):
			proposed_frame = frame_id
			break

	var patience_delta_total: int = 0
	var trust_delta_total: int = 0
	for frame_id in selected_frames:
		var frame: Dictionary = _frames.get(frame_id, {})
		patience_delta_total += int(frame.get("judicial_patience_delta_on_select", 0))
		trust_delta_total += int(frame.get("halina_trust_delta_on_select", 0))

	var starting_patience: int = max(0, 5 + patience_delta_total)
	var meets_minimum: bool = required_count >= minimum_required

	return {
		"required_count": required_count,
		"required_total": SLOT_ORDER.size(),
		"minimum_required": minimum_required,
		"meets_minimum": meets_minimum,
		"requested_remedy": remedy_id,
		"selected_frames": selected_frames,
		"proposed_frame": proposed_frame,
		"judicial_patience_delta": patience_delta_total,
		"halina_trust_delta": trust_delta_total,
		"starting_judicial_patience": starting_patience,
	}


## apply_packet_assessment — writes proposed_frame + patience when minimum
## packet completeness is met. This is the only hard gate.
func apply_packet_assessment() -> Dictionary:
	var score: Dictionary = evaluate_packet()
	if not bool(score.get("meets_minimum", false)):
		var minimum_required: int = int(score.get("minimum_required", 0))
		_set_status("Need at least %d required elements before filing." % minimum_required)
		score["applied"] = false
		return score

	var remedy_id: String = str(score.get("requested_remedy", DEFAULT_REMEDY))
	_write_chapter1("proposed_frame", str(score.get("proposed_frame", FRAME_DEFAULT)))
	_write_chapter1("judicial_patience", int(score.get("starting_judicial_patience", 5)))
	_write_chapter1("decoy_overbroad_remedy", remedy_id != DEFAULT_REMEDY)

	var required_count: int = int(score.get("required_count", 0))
	var required_total: int = int(score.get("required_total", SLOT_ORDER.size()))
	_set_status("Packet applied: %d/%d elements, remedy '%s'." % [required_count, required_total, remedy_id])
	score["applied"] = true
	return score


func _connect_packet_controls() -> void:
	_slot_address_option.item_selected.connect(_on_slot_option_selected.bind(SLOT_NON_CURRENT_ADDRESS))
	_slot_landlord_option.item_selected.connect(_on_slot_option_selected.bind(SLOT_LANDLORD_KNOWLEDGE))
	_slot_notice_option.item_selected.connect(_on_slot_option_selected.bind(SLOT_ACTUAL_NOTICE_WINDOW))
	_slot_authority_option.item_selected.connect(_on_slot_option_selected.bind(SLOT_NO_THIRD_PARTY_AUTHORITY))
	_remedy_option.item_selected.connect(_on_remedy_option_selected)
	_apply_packet_button.pressed.connect(_on_apply_packet_pressed)


func _on_slot_option_selected(index: int, slot_key: String) -> void:
	var values: Array = _slot_option_values.get(slot_key, [])
	if index < 0 or index >= values.size():
		return
	var evidence_id: String = str(values[index])
	if not assign_evidence_to_slot(slot_key, evidence_id):
		_set_status("That evidence does not support %s." % SLOT_LABELS.get(slot_key, slot_key))


func _on_remedy_option_selected(index: int) -> void:
	if index < 0 or index >= _remedy_option_values.size():
		return
	set_requested_remedy(_remedy_option_values[index])


func _on_decoy_toggled(pressed: bool, decoy_flag: String) -> void:
	set_decoy_selected(decoy_flag, pressed)


func _on_apply_packet_pressed() -> void:
	apply_packet_assessment()


func _load_evidence() -> void:
	var parsed: Dictionary = _load_json_dictionary(EVIDENCE_FILE)
	if parsed.is_empty():
		return
	if not parsed.get("evidence", {}) is Dictionary:
		push_error("BlueBinder: evidence_ch1.json missing Dictionary 'evidence' block")
		return
	_evidence = parsed["evidence"]


func _load_frames() -> void:
	var parsed: Dictionary = _load_json_dictionary(FRAMES_FILE)
	if parsed.is_empty():
		return
	if not parsed.get("frames", {}) is Dictionary:
		push_error("BlueBinder: argument_frames_ch1.json missing Dictionary 'frames' block")
		return
	_frames = parsed["frames"]


func _load_json_dictionary(path: String) -> Dictionary:
	var f: FileAccess = FileAccess.open(path, FileAccess.READ)
	if f == null:
		push_error("BlueBinder: could not open %s" % path)
		return {}
	var raw: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Dictionary):
		push_error("BlueBinder: %s is not a JSON object" % path)
		return {}
	return parsed


func _refresh_ordered_ids_from_surface() -> void:
	_ordered_ids.clear()
	for key in _evidence.keys():
		var evidence_id: String = String(key)
		var card: Dictionary = _evidence.get(evidence_id, {})
		if _is_card_surfaced(evidence_id, card):
			_ordered_ids.append(evidence_id)
	if _active_index >= _ordered_ids.size():
		_active_index = max(0, _ordered_ids.size() - 1)


func _build_tabs() -> void:
	for child in _page_tabs.get_children():
		_page_tabs.remove_child(child)
		child.queue_free()
	for i in range(_ordered_ids.size()):
		var evidence_id: String = _ordered_ids[i]
		var card: Dictionary = _evidence.get(evidence_id, {})
		var btn: Button = _make_tab(evidence_id, card, i == _active_index)
		_page_tabs.add_child(btn)


func _make_tab(evidence_id: String, card: Dictionary, active: bool) -> Button:
	var btn: Button = Button.new()
	btn.text = _card_label(evidence_id, card)
	btn.toggle_mode = true
	btn.button_pressed = active
	btn.custom_minimum_size = Vector2(128.0, 36.0)
	btn.clip_text = true
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_on_tab_pressed.bind(evidence_id))
	return btn


func _on_tab_pressed(evidence_id: String) -> void:
	var idx: int = _ordered_ids.find(evidence_id)
	if idx >= 0:
		_show_page(idx)


func _show_page(idx: int) -> void:
	if _ordered_ids.is_empty():
		_page_body_title.text = "No surfaced evidence yet"
		_page_body_summary.text = "Surface evidence through dialogue and investigation, then return to the binder."
		_clear_press_lines()
		_tags_footer.text = ""
		_refresh_tab_active_state()
		return

	idx = clamp(idx, 0, _ordered_ids.size() - 1)
	_active_index = idx
	var evidence_id: String = _ordered_ids[idx]
	var card: Dictionary = _evidence.get(evidence_id, {})

	_page_body_title.text = _card_label(evidence_id, card)
	_page_body_summary.text = _card_summary(evidence_id, card)
	_render_press_lines(card.get("press_lines", []))
	_tags_footer.text = _format_tags(card)
	_refresh_tab_active_state()


func _clear_press_lines() -> void:
	for child in _press_lines_container.get_children():
		_press_lines_container.remove_child(child)
		child.queue_free()


func _render_press_lines(lines: Variant) -> void:
	_clear_press_lines()
	if not (lines is Array):
		return
	var arr: Array = lines
	if arr.is_empty():
		return
	for ln in arr:
		var lbl: Label = Label.new()
		lbl.text = "- " + String(ln)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_press_lines_container.add_child(lbl)


func _format_tags(card: Dictionary) -> String:
	var parts: Array[String] = []
	var arg_tags: Variant = card.get("argument_tags", [])
	if arg_tags is Array:
		for t in arg_tags:
			parts.append(String(t))
	var ctx_tags: Variant = card.get("context_tags", [])
	if ctx_tags is Array:
		for t in ctx_tags:
			parts.append(String(t))
	if parts.is_empty():
		return ""
	return "Tags: " + ", ".join(parts)


func _card_label(evidence_id: String, card: Dictionary) -> String:
	var label: String = String(card.get("display_name", "")).strip_edges()
	if label != "":
		return label
	return _humanize_token(evidence_id)


func _card_summary(_evidence_id: String, card: Dictionary) -> String:
	var summary: String = String(card.get("summary", "")).strip_edges()
	if summary != "":
		return summary

	var supported_slots: Array[String] = []
	var raw_support: Variant = card.get("supports_packet_slots", [])
	if raw_support is Array:
		for slot_id in raw_support:
			var slot_key: String = str(slot_id)
			if SLOT_LABELS.has(slot_key):
				supported_slots.append(String(SLOT_LABELS[slot_key]))
	if not supported_slots.is_empty():
		return "Supports: %s." % ", ".join(supported_slots)

	var source_text: String = String(card.get("source", "")).strip_edges()
	if source_text != "":
		return "Source: %s." % _humanize_token(source_text)

	return "Summary pending in evidence_ch1.json."


func _build_slot_options() -> void:
	var slot_to_node: Dictionary = {
		SLOT_NON_CURRENT_ADDRESS: _slot_address_option,
		SLOT_LANDLORD_KNOWLEDGE: _slot_landlord_option,
		SLOT_ACTUAL_NOTICE_WINDOW: _slot_notice_option,
		SLOT_NO_THIRD_PARTY_AUTHORITY: _slot_authority_option,
	}
	var ch1: Dictionary = _chapter1()
	for slot_key in SLOT_ORDER:
		var option: OptionButton = slot_to_node.get(slot_key, null)
		if option == null:
			continue
		option.clear()
		var values: Array[String] = [""]
		option.add_item("[Unassigned]")
		for evidence_id in _ordered_ids:
			var card: Dictionary = _evidence.get(evidence_id, {})
			if _card_supports_slot(card, slot_key):
				values.append(evidence_id)
				option.add_item(_card_label(evidence_id, card))
		_slot_option_values[slot_key] = values

		var slot_state_key: String = SLOT_STATE_KEYS.get(slot_key, "")
		var selected_value: String = String(ch1.get(slot_state_key, ""))
		var selected_index: int = values.find(selected_value)
		if selected_index < 0:
			selected_index = 0
			if selected_value != "":
				_write_chapter1(slot_state_key, "")
				_write_chapter1(slot_key, false)
		option.select(selected_index)


func _build_remedy_options() -> void:
	_remedy_option.clear()
	_remedy_option_values.clear()
	for entry in REMEDY_OPTIONS:
		var remedy_id: String = str(entry.get("id", ""))
		if remedy_id == "":
			continue
		_remedy_option_values.append(remedy_id)
		_remedy_option.add_item(str(entry.get("label", remedy_id)))

	var remedy_value: String = String(_chapter1().get(REMEDY_STATE_KEY, DEFAULT_REMEDY))
	if not _is_known_remedy(remedy_value):
		remedy_value = DEFAULT_REMEDY
		_write_chapter1(REMEDY_STATE_KEY, remedy_value)

	var selected_index: int = _remedy_option_values.find(remedy_value)
	if selected_index < 0:
		selected_index = 0
	_remedy_option.select(selected_index)


func _build_decoy_options() -> void:
	for child in _decoy_container.get_children():
		_decoy_container.remove_child(child)
		child.queue_free()
	_decoy_checkboxes.clear()

	var ch1: Dictionary = _chapter1()
	for defn in DECOY_DEFINITIONS:
		var flag_name: String = str(defn.get("flag", ""))
		if flag_name == "":
			continue
		if bool(defn.get("requires_halina", false)) and not bool(ch1.get("halina_met", false)):
			continue

		var checkbox := CheckBox.new()
		checkbox.focus_mode = Control.FOCUS_NONE
		checkbox.button_pressed = bool(ch1.get(flag_name, false))

		var frame_id: String = str(defn.get("frame_id", ""))
		var frame_label: String = _frame_display_name(frame_id, str(defn.get("fallback_label", flag_name)))
		checkbox.text = frame_label
		checkbox.toggled.connect(_on_decoy_toggled.bind(flag_name))
		_decoy_container.add_child(checkbox)
		_decoy_checkboxes[flag_name] = checkbox


func _frame_display_name(frame_id: String, fallback: String) -> String:
	var frame: Dictionary = _frames.get(frame_id, {})
	var display_name: String = String(frame.get("display_name", "")).strip_edges()
	if display_name != "":
		return display_name
	return fallback


func _card_supports_slot(card: Dictionary, slot_key: String) -> bool:
	var raw_support: Variant = card.get("supports_packet_slots", [])
	if not (raw_support is Array):
		return false
	for slot in raw_support:
		if String(slot) == slot_key:
			return true
	return false


func _is_card_surfaced(evidence_id: String, card: Dictionary) -> bool:
	var sets_flag: String = String(card.get("sets_flag", ""))
	if sets_flag == "":
		return true
	if not sets_flag.begins_with("chapter1."):
		return true

	var flag_name: String = sets_flag.substr("chapter1.".length())
	var ch1: Dictionary = _chapter1()
	if not ch1.has(flag_name):
		return false
	var value: Variant = ch1[flag_name]
	if value is bool:
		return bool(value)
	if value is String:
		return String(value) == evidence_id
	return false


func _minimum_required_elements() -> int:
	var frame: Dictionary = _frames.get(FRAME_DEFAULT, {})
	if frame.is_empty():
		return 3
	var requirements: Dictionary = frame.get("packet_requirements", {})
	if requirements.is_empty():
		return 3
	return int(requirements.get("minimum_required_elements", 3))


func _render_packet_status_preview() -> void:
	var score: Dictionary = evaluate_packet()
	var required_count: int = int(score.get("required_count", 0))
	var required_total: int = int(score.get("required_total", SLOT_ORDER.size()))
	var remedy_id: String = str(score.get("requested_remedy", DEFAULT_REMEDY))
	var frame_id: String = str(score.get("proposed_frame", FRAME_DEFAULT))
	var minimum_required: int = int(score.get("minimum_required", 0))
	var status: String = "%d/%d required elements. Remedy: %s. Frame: %s." % [required_count, required_total, remedy_id, frame_id]
	if required_count < minimum_required:
		status += " (Need %d to apply.)" % minimum_required
	_set_status(status)


func _set_status(text: String) -> void:
	_packet_status_label.text = text


func _is_known_decoy_flag(decoy_flag: String) -> bool:
	for defn in DECOY_DEFINITIONS:
		if str(defn.get("flag", "")) == decoy_flag:
			return true
	return false


func _is_known_remedy(remedy_id: String) -> bool:
	for entry in REMEDY_OPTIONS:
		if str(entry.get("id", "")) == remedy_id:
			return true
	return false


func _ensure_state_defaults() -> void:
	var ch1: Dictionary = _chapter1()
	if ch1.is_empty():
		return
	for slot_key in SLOT_ORDER:
		var state_key: String = SLOT_STATE_KEYS.get(slot_key, "")
		if state_key != "" and not ch1.has(state_key):
			ch1[state_key] = ""
	if not ch1.has(REMEDY_STATE_KEY):
		ch1[REMEDY_STATE_KEY] = DEFAULT_REMEDY


func _chapter1() -> Dictionary:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return {}
	if not state_node.get("data") is Dictionary:
		return {}
	var data: Dictionary = state_node.get("data")
	if not data.get("chapter1", {}) is Dictionary:
		return {}
	return data["chapter1"]


func _write_chapter1(flag_name: String, value: Variant) -> void:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return
	var data: Dictionary = state_node.get("data")
	if not data.has("chapter1") or not data["chapter1"] is Dictionary:
		return
	if not data["chapter1"].has(flag_name):
		## Keep writes schema-safe and loud enough for debugging.
		push_warning("BlueBinder: chapter1.%s is not declared in State.reset_state()" % flag_name)
		return
	data["chapter1"][flag_name] = value
	var sigs: Node = get_node_or_null("/root/Signals")
	if sigs != null and sigs.has_signal("chapter1_flag_changed"):
		sigs.chapter1_flag_changed.emit(flag_name, value)


func _refresh_tab_active_state() -> void:
	var children: Array = _page_tabs.get_children()
	for i in range(children.size()):
		var btn: Button = children[i] as Button
		if btn != null:
			btn.button_pressed = (i == _active_index)


func _humanize_token(value: String) -> String:
	var parts: PackedStringArray = value.replace("-", "_").split("_", false)
	if parts.is_empty():
		return value
	var words: Array[String] = []
	for part in parts:
		var token: String = String(part).strip_edges()
		if token == "":
			continue
		if token.length() <= 3 and token.to_lower() == token:
			words.append(token.to_upper())
		else:
			words.append(token.substr(0, 1).to_upper() + token.substr(1).to_lower())
	return " ".join(words)


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_right"):
		_show_page(min(_active_index + 1, _ordered_ids.size() - 1))
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_left"):
		_show_page(max(_active_index - 1, 0))
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		var binder_ui: Node = get_node_or_null("/root/BinderUI")
		if binder_ui != null and binder_ui.has_method("close"):
			binder_ui.close()
		get_viewport().set_input_as_handled()
		return
