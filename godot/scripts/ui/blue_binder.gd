extends CanvasLayer
## BlueBinder — controller for scenes/ui/blue_binder.tscn.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Renders evidence cards from data/evidence_ch1.json as case-file pages.
## Reads chapter1.binder_read_* (and chapter1.bonus_evidence_collected /
## chapter1.has_rights_memo) to visually distinguish read vs unread cards.
## Does NOT write any state in v0; opening or turning pages is passive.
##
## v0 scope per PROPOSAL_player_driven_argument.md §2 v2 deliverable.
## v1 will add the state-write hooks (auto-read on view OR
## explicit "Press to read" interaction — design call pending).
##
## Visual register:
##   Paper background: Palette H "Court Interior" Dirty Linen #b8a890.
##   Body text:        Palette H Institutional Wood #3a2818 (WCAG AA pass).
##   Period-frozen 1990s/2000s office paper; no proprietary fonts.
##
## Non-color signals for unread state (AGENTS.md §Stack invariants — no
## information by color alone):
##   - Tab label gets a "⚠" prefix.
##   - Body summary is replaced with "[ Not yet read in the case file. ]"
##     in italics; press lines and full tag list are hidden.
##   - The active page header gets the same "⚠ Unread" suffix.

const EVIDENCE_FILE: String = "res://data/evidence_ch1.json"
const UNREAD_PREFIX: String = "⚠ "
const UNREAD_BODY: String = "[ Not yet read in the case file. ]"

## Order is determined by JSON key insertion order, which Godot 4 Dictionary
## iteration preserves. Cards render as tabs in this order, left to right.
var _evidence: Dictionary = {}
var _ordered_ids: Array[String] = []
var _active_index: int = 0

@onready var _page_tabs: HBoxContainer = $BinderRoot/PageTabs
@onready var _page_body_title: Label = $BinderRoot/PageBody/PageBodyTitle
@onready var _page_body_summary: Label = $BinderRoot/PageBody/PageBodySummary
@onready var _press_lines_container: VBoxContainer = $BinderRoot/PageBody/PressLines
@onready var _tags_footer: Label = $BinderRoot/PageBody/TagsFooter


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_load_evidence()
	_build_tabs()
	_show_page(0)


## _load_evidence — read data/evidence_ch1.json into _evidence and
## _ordered_ids. On any malformation, push_error and leave both empty;
## the binder still renders, just with no cards.
func _load_evidence() -> void:
	var f: FileAccess = FileAccess.open(EVIDENCE_FILE, FileAccess.READ)
	if f == null:
		push_error("BlueBinder: could not open %s" % EVIDENCE_FILE)
		return
	var raw: String = f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(raw)
	if not (parsed is Dictionary):
		push_error("BlueBinder: evidence_ch1.json is not a JSON object")
		return
	var root: Dictionary = parsed
	if not root.has("evidence"):
		push_error("BlueBinder: evidence_ch1.json missing 'evidence' key")
		return
	var ev: Variant = root["evidence"]
	if not (ev is Dictionary):
		push_error("BlueBinder: evidence_ch1.json 'evidence' is not an object")
		return
	_evidence = ev
	_ordered_ids.clear()
	for key in _evidence.keys():
		_ordered_ids.append(String(key))


## refresh_from_state — called by BinderUI autoload before each open() so
## tab read/unread visual state reflects the current chapter1 flags.
func refresh_from_state() -> void:
	_build_tabs()
	_show_page(_active_index)


func _build_tabs() -> void:
	if _page_tabs == null:
		return
	for child in _page_tabs.get_children():
		_page_tabs.remove_child(child)
		child.queue_free()
	for i in range(_ordered_ids.size()):
		var id: String = _ordered_ids[i]
		var card: Dictionary = _evidence.get(id, {})
		var read: bool = _is_card_read(id, card)
		var btn: Button = _make_tab(id, card, read, i == _active_index)
		_page_tabs.add_child(btn)


## _make_tab — build one tab Button for a card. Unread tabs get a "⚠"
## prefix; the prefix is the load-bearing non-color signal. The 0.7
## modulate is a mild secondary cue (still WCAG-passable against the
## paper because we drop opacity, not the text color directly).
func _make_tab(id: String, card: Dictionary, read: bool, active: bool) -> Button:
	var btn: Button = Button.new()
	var label: String = String(card.get("display_name", ""))
	if label == "":
		label = id  ## fallback to evidence_id when display_name is unauthored
	if not read:
		label = UNREAD_PREFIX + label
	btn.text = label
	btn.toggle_mode = true
	btn.button_pressed = active
	btn.custom_minimum_size = Vector2(112.0, 36.0)
	btn.clip_text = true
	## Disable focus on tabs so the built-in UI focus traversal doesn't
	## swallow ui_left/ui_right before our _unhandled_input arrow-key
	## navigation can react. Mouse clicks still fire pressed normally.
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_on_tab_pressed.bind(id))
	return btn


func _on_tab_pressed(id: String) -> void:
	var idx: int = _ordered_ids.find(id)
	if idx >= 0:
		_show_page(idx)


## _is_card_read — read predicate. Three patterns covered:
##   bool flag (binder_read_envelope etc.)        — read iff bool true.
##   string-enum (bonus_evidence_collected)        — read iff enum equals id.
##   has_<item> flag (has_rights_memo)             — read iff bool true.
## Cards without a sets_flag or with a non-chapter1 path are considered read.
func _is_card_read(id: String, card: Dictionary) -> bool:
	var sets_flag: String = String(card.get("sets_flag", ""))
	if sets_flag == "":
		return true
	if not sets_flag.begins_with("chapter1."):
		return true
	var flag_name: String = sets_flag.substr("chapter1.".length())
	var state: Node = get_node_or_null("/root/State")
	if state == null or not ("data" in state):
		return false
	var data: Dictionary = state.data
	var ch1: Dictionary = data.get("chapter1", {})
	if not ch1.has(flag_name):
		return false
	var v: Variant = ch1[flag_name]
	if v is bool:
		return bool(v)
	if v is String:
		return String(v) == id
	return false


func _show_page(idx: int) -> void:
	if _ordered_ids.is_empty():
		_page_body_title.text = "(no evidence)"
		_page_body_summary.text = ""
		_clear_press_lines()
		_tags_footer.text = ""
		return
	if idx < 0:
		idx = 0
	if idx >= _ordered_ids.size():
		idx = _ordered_ids.size() - 1
	_active_index = idx
	var id: String = _ordered_ids[idx]
	var card: Dictionary = _evidence.get(id, {})
	var read: bool = _is_card_read(id, card)
	var title_text: String = String(card.get("display_name", ""))
	if title_text == "":
		title_text = id  ## fallback
	if not read:
		title_text = title_text + "   " + UNREAD_PREFIX + "Unread"
	_page_body_title.text = title_text
	if read:
		var summary: String = String(card.get("summary", ""))
		if summary == "":
			summary = "[ Summary text pending Design pass. ]"
		_page_body_summary.text = summary
		_render_press_lines(card.get("press_lines", []))
	else:
		_page_body_summary.text = UNREAD_BODY
		_clear_press_lines()
	_tags_footer.text = _format_tags(card)
	_refresh_tab_active_state()


func _clear_press_lines() -> void:
	if _press_lines_container == null:
		return
	for child in _press_lines_container.get_children():
		_press_lines_container.remove_child(child)
		child.queue_free()


func _render_press_lines(lines: Variant) -> void:
	_clear_press_lines()
	if not (lines is Array):
		return
	var arr: Array = lines
	if arr.is_empty():
		var note: Label = Label.new()
		note.text = "[ Press lines pending Design pass. ]"
		note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_press_lines_container.add_child(note)
		return
	for ln in arr:
		var lbl: Label = Label.new()
		lbl.text = "— " + String(ln)
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		_press_lines_container.add_child(lbl)


## _format_tags — single-line "Tags: a, b, c" string built from
## argument_tags and context_tags. Returns "" when both arrays are empty.
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


func _refresh_tab_active_state() -> void:
	if _page_tabs == null:
		return
	var children: Array = _page_tabs.get_children()
	for i in range(children.size()):
		var btn: Button = children[i] as Button
		if btn != null:
			btn.button_pressed = (i == _active_index)


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
