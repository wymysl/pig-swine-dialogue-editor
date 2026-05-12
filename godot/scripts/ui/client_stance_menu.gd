extends CanvasLayer
## ClientStanceMenu — Beat 7 interview-tone picker.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Modal three-button prompt that captures Cula's interview tone for the
## Beat 8 Halina meeting. The choice writes
## `State.data.chapter1.client_meeting_stance` to one of:
##   "sympathetic" — lead with how she's holding up
##   "blunt_procedural" — lead with the timeline
##   "technical" — lead with the lease history
##
## Button wording per V1.4 pack §B.1 (stance-aligned interview tones) in
## Cula's register from his bible. Internal taxonomy names are NEVER shown
## to the player — only the in-register choices.
##
## Lifecycle:
##   instantiate as a child of the office scene
##   _ready() pauses the SceneTree and grabs keyboard focus
##   on any button press: writes State + emits Signals.chapter1_flag_changed +
##                        emits stance_picked + queue_free()
##
## Style intentionally mirrors dialogue_box.tscn: CanvasLayer (layer=10),
## Panel anchored bottom, dimming overlay across the rest of the viewport.

signal stance_picked(stance: String)

## Three-tuple of (button text, stance enum value, internal taxonomy label).
## Order matches V1.4 pack §B.1 default canonical order. Taxonomy label is
## kept in the data for debug; it is NEVER rendered as a player-facing label.
const STANCES: Array = [
	{ "text": "Lead with how she's holding up.", "stance": "sympathetic", "_taxonomy": "Sympathetic" },
	{ "text": "Lead with the timeline.",          "stance": "blunt_procedural", "_taxonomy": "Blunt-procedural" },
	{ "text": "Lead with the lease history.",     "stance": "technical", "_taxonomy": "Technical" },
]

@onready var _dim: ColorRect = $Dim
@onready var _panel: Panel = $Panel
@onready var _btn_sympathetic: Button = $Panel/VBox/BtnSympathetic
@onready var _btn_blunt: Button = $Panel/VBox/BtnBluntProcedural
@onready var _btn_technical: Button = $Panel/VBox/BtnTechnical


func _ready() -> void:
	## Must process always so input fires while the tree is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS

	## Wire buttons. Each closure captures its stance value.
	_btn_sympathetic.text = STANCES[0]["text"]
	_btn_blunt.text       = STANCES[1]["text"]
	_btn_technical.text   = STANCES[2]["text"]
	_btn_sympathetic.pressed.connect(func() -> void: _commit(STANCES[0]["stance"]))
	_btn_blunt.pressed.connect(      func() -> void: _commit(STANCES[1]["stance"]))
	_btn_technical.pressed.connect(  func() -> void: _commit(STANCES[2]["stance"]))

	## Pause the scene tree so the player can't wander off mid-pick.
	get_tree().paused = true

	## Default keyboard focus to the first button so E/Enter works without
	## a click. Matches dialogue_box ergonomics.
	_btn_sympathetic.grab_focus()


## _commit — write stance to State, fire signal, dismiss.
## Called from each button's pressed handler with that button's stance value.
## Idempotent against double-clicks: if menu is already mid-dismiss the
## queue_free() prevents re-entry.
func _commit(stance: String) -> void:
	var state_node = get_node_or_null("/root/State")
	if state_node:
		state_node.data["chapter1"]["client_meeting_stance"] = stance
	var sigs = get_node_or_null("/root/Signals")
	if sigs and sigs.has_signal("chapter1_flag_changed"):
		sigs.chapter1_flag_changed.emit("client_meeting_stance", stance)
	get_tree().paused = false
	stance_picked.emit(stance)
	queue_free()
