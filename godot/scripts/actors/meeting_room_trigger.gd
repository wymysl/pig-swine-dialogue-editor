extends Area2D
## MeetingRoomTrigger — Beat 7-8 entry gate for the meeting-room sub-area
## inside pig_swine_office.tscn.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Sits south of the meeting-room threshold. When the player walks into
## the trigger area, evaluates three exclusive outcomes:
##
##   A. recruited_whimsy && halina_arrived && !halina_met && client_meeting_stance == ""
##      → dispatch halina.json's client_meeting_intro state. The dialogue box
##        renders the three choices on a dedicated Cula page; player picks;
##        DialogueRunner writes chapter1.client_meeting_stance and chains into
##        the first response state.
##        Subscribed to Signals.chapter1_flag_changed("client_meeting_stance",
##        ...) to disable the boundary once the option commits.
##
##   B. recruited_whimsy && halina_arrived && !halina_met && client_meeting_stance != ""
##      → boundary is already disabled (stance was committed previously),
##        dispatch halina.json directly via Signals.dialogue_requested.
##        Handles re-entry mid-flow (player walked out and back in
##        between stance commit and meeting completion).
##
##   C. halina_met == true (meeting already held)  OR  gating fails
##      → no-op. Player walks through freely once the boundary is disabled.
##
## Companion node: MeetingRoomBoundary (StaticBody2D + CollisionShape2D)
## starts with collision_enabled = true and gets disabled by this script
## after a stance commits. Its node path is exported.

## boundary_path — NodePath to the MeetingRoomBoundary StaticBody2D in the
## owning scene. Its CollisionShape2D (any direct child) gets `disabled = true`
## once a stance commits. Defaults to "../MeetingRoomBoundary" — adjust in
## the inspector if the scene structure changes.
@export var boundary_path: NodePath = NodePath("../MeetingRoomBoundary")

## NPC id dispatched through the dialogue runner.
const HALINA_NPC_ID: String = "halina"
const HALINA_DISPLAY_NAME: String = "Mrs. Sikorska"

var _dispatched_this_entry: bool = false
var _awaiting_stance_commit: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	## Listen for the stance write so we can unlock the boundary the moment
	## the option commits.
	var sigs = get_node_or_null("/root/Signals")
	if sigs and sigs.has_signal("chapter1_flag_changed"):
		sigs.chapter1_flag_changed.connect(_on_chapter1_flag_changed)

	## If a stance was already committed in a prior session/scene-load,
	## disable the boundary immediately so the player isn't blocked.
	_sync_boundary_to_stance()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if _dispatched_this_entry:
		## Prevent double-fire if the trigger overlaps the player on entry.
		return
	var ch1: Dictionary = _chapter1()
	if not (ch1.get("recruited_whimsy", false) and ch1.get("halina_arrived", false)):
		## Gating preconditions not met. Stay silent — player can wander
		## past the trigger without consequence (boundary still blocks
		## the actual room entry until those flags flip and stance picks).
		return
	if ch1.get("halina_met", false):
		## Meeting already held. Nothing more to do here.
		return
	var stance: String = str(ch1.get("client_meeting_stance", ""))
	if stance == "":
		_dispatch_halina_intro_dialogue()
	else:
		_dispatch_halina_dialogue()
	_dispatched_this_entry = true


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		## Reset so a fresh entry can re-evaluate (e.g., after the player
		## backs out post-stance-pick before entering the meeting room).
		_dispatched_this_entry = false


## _dispatch_halina_intro_dialogue — emit dialogue_requested for Halina's
## intro state. DialogueRunner picks client_meeting_intro, emits the intro
## lines and dialogue_options_ready for the three opening approaches.
##
## We set _awaiting_stance_commit so _on_chapter1_flag_changed knows to
## unlock the boundary once the stance write fires. DialogueRunner itself
## handles the chain into the next Halina state.
func _dispatch_halina_intro_dialogue() -> void:
	_awaiting_stance_commit = true
	var sigs = get_node_or_null("/root/Signals")
	if sigs:
		sigs.dialogue_requested.emit(HALINA_NPC_ID, HALINA_DISPLAY_NAME)


## _on_chapter1_flag_changed — chain hook for the stance-commit path.
## When the runner writes client_meeting_stance from the option pick,
## this fires synchronously; we disable the boundary. Skipping when not
## awaiting prevents misfires from unrelated chapter1 flag changes.
func _on_chapter1_flag_changed(flag_name: String, _value: Variant) -> void:
	if not _awaiting_stance_commit:
		return
	if flag_name != "client_meeting_stance":
		return
	_awaiting_stance_commit = false
	_disable_boundary()
	## DialogueRunner's chain:true option flow will immediately request the
	## next Halina state. This trigger only owns the room boundary.


## _dispatch_halina_dialogue — fire halina.json's client_meeting_<stance>
## branch via the standard dialogue request signal. DialogueRunner
## evaluates triggers against the current State, including the stance flag
## we just wrote, so the correct branch is selected automatically.
func _dispatch_halina_dialogue() -> void:
	var sigs = get_node_or_null("/root/Signals")
	if sigs:
		sigs.dialogue_requested.emit(HALINA_NPC_ID, HALINA_DISPLAY_NAME)


## _disable_boundary — flip the boundary's CollisionShape2D off so the
## player can walk into the meeting room. Safe to call multiple times.
func _disable_boundary() -> void:
	var boundary: Node = get_node_or_null(boundary_path)
	if boundary == null:
		push_warning("MeetingRoomTrigger: boundary_path not resolvable: " + str(boundary_path))
		return
	for child in boundary.get_children():
		if child is CollisionShape2D:
			child.disabled = true


## _sync_boundary_to_stance — on scene load, ensure the boundary state
## matches the persisted stance. If a stance was already committed
## (mid-meeting save → reload), the boundary should already be disabled.
func _sync_boundary_to_stance() -> void:
	var stance: String = str(_chapter1().get("client_meeting_stance", ""))
	if stance != "":
		_disable_boundary()


func _chapter1() -> Dictionary:
	var st = get_node_or_null("/root/State")
	if st == null:
		return {}
	return st.data.get("chapter1", {})
