extends CanvasLayer
## DialogueBox — bottom-of-viewport dialogue display.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Shows a Panel (120px high) anchored to the bottom of the viewport with a
## speaker name label and a text label. Pauses the scene tree while visible
## so player movement stops. Pressing ui_accept (E) dismisses it.
##
## Signal flow:
##   Signals.dialogue_line_ready(speaker, line)  → show()
##   ui_accept while visible                      → hide() + Signals.dialogue_dismissed
##
## Multi-speaker support (option 1):
##   Individual entries in the `lines` array may be dicts of the form
##   { "speaker": "character_id", "text": "Line text." }.
##   When such an entry is the active line, _show_page() updates the speaker
##   label to the display name resolved from DialogueRunner._character_registry
##   (or falls back to the NPC's display_name if the id is unknown).
##   Plain string entries always display the owning NPC's name (_default_speaker).

@onready var _panel: Panel = $Panel
@onready var _portrait: TextureRect = $Panel/PortraitRect
@onready var _speaker_label: Label = $Panel/SpeakerLabel
@onready var _text_label: Label = $Panel/TextLabel
@onready var _options_vbox: VBoxContainer = $Panel/OptionsVBox

const TYPE_SPEED_CHARS_PER_SEC: float = 90.0
const PORTRAIT_PATH: String = "res://art/portraits/%s.png"
const TICK_SOUND_PATH: String = "res://audio/sfx/typewriter_tick.ogg"
const TICK_INTERVAL: float = 0.06

## _portrait_cache — preloaded textures keyed by character_id.
## Built once in _ready() so runtime lookup never touches the filesystem.
var _portrait_cache: Dictionary = {}

var _visible_now: bool = false
var _lines: Array = []
var _current_line_idx: int = 0
var _is_typing: bool = false
var _type_accumulator: float = 0.0
var _tick_timer: float = 0.0
var _tick_player: AudioStreamPlayer

## _default_speaker — the display name of the NPC who owns the dialogue tree.
## Used for plain string entries that do not declare a speaker override.
var _default_speaker: String = ""

## _default_npc_id — stable character key for the owning NPC, set at dialogue start.
## Used for portrait lookup on plain-string lines. Never changes mid-dialogue.
var _default_npc_id: String = ""

## In-dialogue option state (Chapter 1 Phase B polish).
## When dialogue_options_ready fires alongside dialogue_line_ready, the
## options sit pending until the player reaches the last line of the
## dialogue. From there, E commits the selected option (instead of
## dismissing). move_up / move_down navigate. Selected option renders red.
var _options_pending: Array = []  ## Array[{text, value}]
var _options_write_path: String = ""
var _options_selected_idx: int = 0
var _options_active: bool = false  ## true while option labels are visible
const OPTION_COLOR_SELECTED: Color = Color(0.92, 0.18, 0.18, 1.0)  ## red
const OPTION_COLOR_NORMAL: Color   = Color(0.85, 0.85, 0.85, 1.0)  ## light grey


func _ready() -> void:
	## Must process always so _unhandled_input fires while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sigs = get_node_or_null("/root/Signals")
	if sigs:
		sigs.dialogue_line_ready.connect(_on_dialogue_line_ready)
		if sigs.has_signal("dialogue_options_ready"):
			sigs.dialogue_options_ready.connect(_on_dialogue_options_ready)
	_panel.visible = false
	_options_vbox.visible = false
	_build_portrait_cache()
	_tick_player = AudioStreamPlayer.new()
	var tick_stream = load(TICK_SOUND_PATH) as AudioStream
	if tick_stream:
		_tick_player.stream = tick_stream
		_tick_player.volume_db = -6.0
	add_child(_tick_player)


## _build_portrait_cache — loads all portraits from the character registry at startup.
## Uses ResourceLoader.exists() to guard each load so missing portraits never
## throw a hard error. Alias ids (defined in _portrait_aliases) are skipped in
## pass 1 and resolved in pass 2 via texture-reference copy.
func _build_portrait_cache() -> void:
	var file = FileAccess.open("res://data/character_registry.json", FileAccess.READ)
	if file == null:
		print("PORTRAIT: registry file not found")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		print("PORTRAIT: registry parse failed")
		return
	## Collect alias ids so pass 1 skips them — they have no portrait file of their own.
	var aliases = parsed.get("_portrait_aliases", {})
	var alias_ids: Array = aliases.keys() if aliases is Dictionary else []
	## Pass 1 — load portrait files for all non-meta, non-alias ids.
	for char_id in parsed:
		if char_id.begins_with("_"):
			continue
		if char_id in alias_ids:
			continue
		var path: String = PORTRAIT_PATH % char_id
		if not ResourceLoader.exists(path):
			print("PORTRAIT: missing %s" % char_id)
			continue
		var tex = load(path) as Texture2D
		if tex:
			_portrait_cache[char_id] = tex
			print("PORTRAIT: cached %s" % char_id)
	## Pass 2 — resolve _portrait_aliases: copy texture references so alias ids
	## display the same portrait as their target without needing a separate file.
	if aliases is Dictionary:
		for alias_id in aliases:
			var target_id: String = str(aliases[alias_id])
			if _portrait_cache.has(target_id):
				_portrait_cache[alias_id] = _portrait_cache[target_id]
				print("PORTRAIT: alias %s → %s" % [alias_id, target_id])
			else:
				print("PORTRAIT: alias %s target '%s' not in cache" % [alias_id, target_id])


## _set_portrait — displays a cached portrait by character_id.
## Silently hides the portrait rect if no portrait was loaded for that id.
func _set_portrait(character_id: String) -> void:
	if _portrait_cache.has(character_id):
		_portrait.texture = _portrait_cache[character_id]
		_portrait.visible = true
	else:
		_portrait.texture = null
		_portrait.visible = false


func _on_dialogue_line_ready(speaker: String, npc_id: String, lines: Array) -> void:
	if lines.is_empty():
		return
	_default_speaker = speaker
	_default_npc_id = npc_id
	_speaker_label.text = speaker
	_lines = lines
	_current_line_idx = 0
	## Clear stale option state. If the matched state has options, the
	## subsequent dialogue_options_ready signal repopulates these fields.
	_options_pending = []
	_options_write_path = ""
	_options_selected_idx = 0
	_options_active = false
	_options_vbox.visible = false
	_show_page()
	_panel.visible = true
	_visible_now = true
	get_tree().paused = true


## _on_dialogue_options_ready — fired by DialogueRunner immediately after
## dialogue_line_ready when the matched state has an `options` block.
## Stashes choices; rendering happens when the player advances to the
## last line (in _show_page).
func _on_dialogue_options_ready(write_path: String, choices: Array) -> void:
	_options_pending = choices
	_options_write_path = write_path
	_options_selected_idx = 0
	## If we're already on the last line (single-line option states do
	## happen — e.g. one prompt + options), render now.
	if _lines.size() > 0 and _current_line_idx == _lines.size() - 1:
		_render_options()


## _render_options — builds option Labels under the prompt text.
## Re-buildable; clears existing children before populating. Selected
## option uses OPTION_COLOR_SELECTED (red); others use OPTION_COLOR_NORMAL.
func _render_options() -> void:
	if _options_pending.is_empty():
		return
	## Tear down any previous option labels.
	for child in _options_vbox.get_children():
		child.queue_free()
	for i in range(_options_pending.size()):
		var choice = _options_pending[i]
		var label := Label.new()
		label.text = "  " + str(choice.get("text", ""))
		label.add_theme_font_size_override("font_size", 13)
		label.add_theme_color_override("font_color", OPTION_COLOR_NORMAL)
		_options_vbox.add_child(label)
	_options_vbox.visible = true
	_options_active = true
	_highlight_selected_option()


## _highlight_selected_option — recolors all option labels based on
## the current _options_selected_idx. Called after each nav input.
func _highlight_selected_option() -> void:
	var children: Array = _options_vbox.get_children()
	for i in range(children.size()):
		var label = children[i]
		if label is Label:
			if i == _options_selected_idx:
				label.add_theme_color_override("font_color", OPTION_COLOR_SELECTED)
				label.text = "▶ " + str(_options_pending[i].get("text", ""))
			else:
				label.add_theme_color_override("font_color", OPTION_COLOR_NORMAL)
				label.text = "  " + str(_options_pending[i].get("text", ""))


## _show_page — renders the current line entry.
## If the entry is a dict with "speaker"/"text" fields, resolves the speaker
## display name via DialogueRunner._character_registry and updates the label.
## If the entry is a plain string, uses _default_speaker.
##
## When reaching the last line of a state that carries an `options` block,
## also renders the option list. _options_pending was stashed earlier by
## _on_dialogue_options_ready.
func _show_page() -> void:
	var entry = _lines[_current_line_idx]
	if entry is Dictionary and entry.has("text"):
		## Multi-speaker entry: resolve display name from runner's registry.
		var character_id: String = str(entry.get("speaker", ""))
		var display_name: String = _default_speaker
		if character_id != "":
			var runner = get_node_or_null("/root/DialogueRunner")
			if runner and runner.has_method("_resolve_speaker"):
				display_name = runner._resolve_speaker(character_id, _default_speaker)
		_speaker_label.text = display_name
		_text_label.text = str(entry["text"])
		_set_portrait(character_id)
	else:
		## Plain string entry: owning NPC speaks.
		_speaker_label.text = _default_speaker
		_text_label.text = str(entry)
		_set_portrait(_default_npc_id)
	_text_label.visible_characters = 0
	_type_accumulator = 0.0
	_is_typing = true

	## Render options on the final page if any were stashed for this state.
	if _current_line_idx == _lines.size() - 1 and not _options_pending.is_empty():
		_render_options()
	else:
		_options_vbox.visible = false
		_options_active = false


func _process(delta: float) -> void:
	if _is_typing:
		_type_accumulator += delta * TYPE_SPEED_CHARS_PER_SEC
		_text_label.visible_characters = int(_type_accumulator)
		if _text_label.visible_characters >= _text_label.get_total_character_count():
			_text_label.visible_characters = -1
			_is_typing = false
		else:
			_tick_timer += delta
			if _tick_timer >= TICK_INTERVAL:
				_tick_timer = 0.0
				if _tick_player and _tick_player.stream:
					_tick_player.play()
	else:
		_tick_timer = 0.0


func _unhandled_input(event: InputEvent) -> void:
	if not _visible_now:
		return

	## Option navigation: only when the option list is on screen.
	## move_up / move_down change selection; interact commits.
	if _options_active:
		if event.is_action_pressed("move_up"):
			get_viewport().set_input_as_handled()
			if _options_pending.size() > 0:
				_options_selected_idx = (_options_selected_idx - 1 + _options_pending.size()) % _options_pending.size()
				_highlight_selected_option()
			return
		if event.is_action_pressed("move_down"):
			get_viewport().set_input_as_handled()
			if _options_pending.size() > 0:
				_options_selected_idx = (_options_selected_idx + 1) % _options_pending.size()
				_highlight_selected_option()
			return
		if event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			## If text is still typing, skip the typewriter to full text
			## (matches the standard E-press skip behaviour) without
			## committing yet — only commit on a second press.
			if _is_typing:
				_is_typing = false
				_text_label.visible_characters = -1
				return
			## Commit the selected option, then dismiss the box.
			var picked = _options_pending[_options_selected_idx]
			var value = picked.get("value", null)
			var sigs_opt = get_node_or_null("/root/Signals")
			if sigs_opt and sigs_opt.has_signal("dialogue_option_committed"):
				sigs_opt.dialogue_option_committed.emit(value)
			_dismiss_box()
			return

	## Default flow: advance pages or dismiss.
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		if _is_typing:
			_is_typing = false
			_text_label.visible_characters = -1
		else:
			_current_line_idx += 1
			if _current_line_idx < _lines.size():
				_show_page()
			else:
				_dismiss_box()
			var sigs = get_node_or_null("/root/Signals")
			if sigs:
				sigs.dialogue_dismissed.emit()


## _dismiss_box — common close logic. Hides panel, unpauses tree, fires
## dialogue_ended. dialogue_dismissed is fired by the caller (the
## option-commit path emits it before dismissing; the normal advance
## path emits it after this returns).
func _dismiss_box() -> void:
	_panel.visible = false
	_options_vbox.visible = false
	_options_active = false
	_visible_now = false
	_is_typing = false
	get_tree().paused = false
	var sigs_end = get_node_or_null("/root/Signals")
	if sigs_end:
		sigs_end.dialogue_ended.emit()
