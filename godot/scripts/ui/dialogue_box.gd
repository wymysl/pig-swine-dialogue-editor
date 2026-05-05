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

@onready var _panel: Panel = $Panel
@onready var _speaker_label: Label = $Panel/SpeakerLabel
@onready var _text_label: Label = $Panel/TextLabel

var _visible_now: bool = false
var _lines: Array = []
var _current_line_idx: int = 0


func _ready() -> void:
	## Must process always so _unhandled_input fires while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	var sigs = get_node_or_null("/root/Signals")
	if sigs:
		sigs.dialogue_line_ready.connect(_on_dialogue_line_ready)
	_panel.visible = false


func _on_dialogue_line_ready(speaker: String, lines: Array) -> void:
	if lines.is_empty():
		return
	_speaker_label.text = speaker
	_lines = lines
	_current_line_idx = 0
	_text_label.text = str(_lines[_current_line_idx])
	_panel.visible = true
	_visible_now = true
	get_tree().paused = true


func _unhandled_input(event: InputEvent) -> void:
	if not _visible_now:
		return
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_current_line_idx += 1
		if _current_line_idx < _lines.size():
			_text_label.text = str(_lines[_current_line_idx])
		else:
			_panel.visible = false
			_visible_now = false
			get_tree().paused = false
			var sigs = get_node_or_null("/root/Signals")
			if sigs:
				sigs.dialogue_dismissed.emit()
