extends Area2D
## PigIdleZone — fires Mr. Pig dialogue if the player lingers nearby.
## Behavior splits on whether Mr. Pig has been met yet.
##
## Phase-8 (post-playtest):
##   Before chapter1.met_pig — the zone is a first-meeting trigger. After
##   DELAY_FIRST_MEETING seconds within the zone, emits
##   Signals.dialogue_requested("pig", "Mr. Pig"). DialogueRunner resolves
##   the standard first-meeting state in pig.json. After dialogue is dismissed,
##   met_pig is set true (per pig.json on_dismiss) and this trigger is no
##   longer active for first-meeting purposes.
##
##   After chapter1.met_pig — the zone falls back to the original ambient-line
##   behavior (a small set of philosophical-impatience lines), one per cycle,
##   firing at most LINES.size() times per scene load before going silent.
##
## Suppression rule: if the player initiates dialogue with Mr. Pig via [E]
## while inside the zone, the linger timer is suppressed for that visit. The
## timer resets on exit so a new visit without [E] still triggers normally.

const ZONE_BARBS_PATH: String = "res://data/zone_barbs.json"
const NPC_ID: String = "pig"

## LINES — defensive in-code fallback only. Canonical values live in
## data/zone_barbs.json::pig and are loaded on _ready().
const LINES: Array = [
	"Every second you stand still, a client somewhere is also standing still. This is a coincidence I cannot afford.",
	"Standing still is a philosophical position, Dr. A. Cula. I do not endorse it professionally."
]
const DELAY_FIRST_MEETING: float = 3.0
const DELAY_AMBIENT: float = 3.0

var _player_inside: bool = false
var _timer: float = 0.0
var _line_idx: int = 0
var _first_meeting_fired: bool = false
var _player_engaged: bool = false
var _lines: Array = LINES


func _ready() -> void:
	_lines = _load_zone_barbs()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var sigs = get_node_or_null("/root/Signals")
	if sigs and sigs.has_signal("dialogue_requested"):
		sigs.dialogue_requested.connect(_on_dialogue_requested)


func _load_zone_barbs() -> Array:
	var file: FileAccess = FileAccess.open(ZONE_BARBS_PATH, FileAccess.READ)
	if file == null:
		return LINES
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		return LINES
	var lines: Variant = parsed.get(NPC_ID, [])
	if not (lines is Array) or lines.is_empty():
		return LINES
	return lines


func _on_dialogue_requested(npc_id: String, _display_name: String) -> void:
	## Player pressed [E] to talk to Mr. Pig while inside the zone — suppress linger.
	if npc_id == "pig" and _player_inside:
		_player_engaged = true


func _process(delta: float) -> void:
	if not _player_inside or _player_engaged:
		return
	if get_tree().paused:
		_timer = 0.0
		return

	var state_node = get_node_or_null("/root/State")
	var met_pig: bool = false
	if state_node:
		met_pig = state_node.data.get("chapter1", {}).get("met_pig", false)

	## Pre-meeting branch: fire first-meeting dialogue once, then disable.
	if not met_pig:
		if _first_meeting_fired:
			return
		_timer += delta
		if _timer < DELAY_FIRST_MEETING:
			return
		_first_meeting_fired = true
		var sigs = get_node_or_null("/root/Signals")
		if sigs:
			sigs.dialogue_requested.emit("pig", "Mr. Pig")
		return

	## Post-meeting branch: ambient flavor, cycling through lines once each.
	if _line_idx >= _lines.size():
		return
	_timer += delta
	if _timer < DELAY_AMBIENT:
		return
	var sigs2 = get_node_or_null("/root/Signals")
	if sigs2:
		sigs2.dialogue_line_ready.emit("Mr. Pig", "pig", [_lines[_line_idx]])
	_line_idx += 1
	_timer = 0.0


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_timer = 0.0
		_player_engaged = false


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_timer = 0.0
		_player_engaged = false
