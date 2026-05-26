extends Area2D
## BehindDeskZone — fires Asia dialogue if the player lingers behind the
## reception counter. Behavior splits on whether Asia has been met yet.
##
## Phase-8 (post-playtest):
##   Before chapter1.met_asia — the zone is a first-meeting trigger. After
##   DELAY seconds, sets chapter1.met_asia_via_behind = true and emits
##   Signals.dialogue_requested("asia", "Asia"). DialogueRunner's first matching
##   state is the apology+recognition variant in asia.json. After dialogue is
##   dismissed, met_asia is set true (per asia.json on_dismiss) and the trigger
##   is permanently disabled for this scene load.
##
##   After chapter1.met_asia — the zone falls back to the original ambient-line
##   behavior (random short Asia lines). _fired prevents repeat spam.
##
## Suppression rule: if the player initiates dialogue with Asia via [E] while
## inside the zone, the linger timer is suppressed for that visit. The timer
## resets on exit so a new visit without [E] still triggers normally.

const ZONE_BARBS_PATH: String = "res://data/zone_barbs.json"
const NPC_ID: String = "asia"

## LINES — defensive in-code fallback only. Canonical values live in
## data/zone_barbs.json::asia and are loaded on _ready().
const LINES: Array = [
	"Dr. A. Cula? Are you looking for paperclips?",
	"If you need to print something, just ask.",
	"I would love to chat with you, but I have all this chaos to manage.",
	"Have you lost something?",
	"I'm wondering who even uses fax anymore."
]
const DELAY_FIRST_MEETING: float = 2.0
const DELAY_AMBIENT: float = 2.0

var _player_inside: bool = false
var _timer: float = 0.0
var _fired: bool = false
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
		push_warning("BehindDeskZone: could not open %s — using hardcoded fallback lines." % ZONE_BARBS_PATH)
		return LINES
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not (parsed is Dictionary):
		push_warning("BehindDeskZone: %s is not a JSON object — using hardcoded fallback lines." % ZONE_BARBS_PATH)
		return LINES
	var lines: Variant = parsed.get(NPC_ID, [])
	if not (lines is Array) or lines.is_empty():
		push_warning("BehindDeskZone: %s missing or empty key '%s' — using hardcoded fallback lines." % [ZONE_BARBS_PATH, NPC_ID])
		return LINES
	return lines


func _on_dialogue_requested(npc_id: String, _display_name: String) -> void:
	## Player pressed [E] to talk to Asia while inside the zone — suppress linger.
	if npc_id == "asia" and _player_inside:
		_player_engaged = true
		_fired = true


func _process(delta: float) -> void:
	if not _player_inside or _fired or _player_engaged:
		return
	## Don't interrupt an existing dialogue.
	if get_tree().paused:
		_timer = 0.0
		return

	var state_node = get_node_or_null("/root/State")
	var met_asia: bool = false
	if state_node:
		met_asia = state_node.data.get("chapter1", {}).get("met_asia", false)

	var delay: float = DELAY_AMBIENT if met_asia else DELAY_FIRST_MEETING
	_timer += delta
	if _timer < delay:
		return

	_fired = true
	var sigs = get_node_or_null("/root/Signals")
	if not sigs:
		return

	if not met_asia:
		## First-meeting via behind-counter approach.
		## Set the gating flag, then route through DialogueRunner so the
		## apology+recognition state in asia.json fires.
		if state_node:
			state_node.data["chapter1"]["met_asia_via_behind"] = true
			if sigs and sigs.has_signal("chapter1_flag_changed"):
				sigs.chapter1_flag_changed.emit("met_asia_via_behind", true)
		sigs.dialogue_requested.emit("asia", "Asia")
	else:
		## Ambient line; post-meeting flavor.
		sigs.dialogue_line_ready.emit("Asia", "asia", [_lines[randi() % _lines.size()]])


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_timer = 0.0
		_fired = false
		_player_engaged = false


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_timer = 0.0
		_fired = false
		_player_engaged = false
