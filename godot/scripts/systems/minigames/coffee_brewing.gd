extends CanvasLayer
## Coffee Brewing — rhythm-timing minigame engine.
## Implements three phases (Grind, Pour, Serve) with a beat clock,
## four-judgment timing windows, and spec-shaped result dictionary.
##
## Pattern data loaded from res://data/minigames/coffee_patterns.json
## keyed by pattern_id. Difficulty (TUTORIAL / NORMAL) and lane count
## are derived from the loaded pattern.
##
## Pauses the scene tree on _ready(); unpauses and queue_free()s on exit.
## Back-compat: emits both coffee_brewing_completed AND minigame_finished.

## Which pattern to load from coffee_patterns.json.
@export var pattern_id: String = "chapter1_court_coffee"

## Audio stream dictionary — Art (Prompt 5) populates via the inspector.
@export var audio_streams: Dictionary = {}

## Difficulty enum — derived from the loaded pattern's "difficulty" field.
enum Difficulty { TUTORIAL, NORMAL }

## Tutorial timing windows (spec §Timing judgments).
const TUTORIAL_PERFECT_WINDOW: float = 0.075
const TUTORIAL_GOOD_WINDOW: float = 0.140
const TUTORIAL_OKAY_WINDOW: float = 0.220

## Normal timing windows (spec §Timing judgments).
const NORMAL_PERFECT_WINDOW: float = 0.060
const NORMAL_GOOD_WINDOW: float = 0.120
const NORMAL_OKAY_WINDOW: float = 0.190

## Scoring constants from spec §Scoring.
const SCORE_PERFECT: int = 100
const SCORE_GOOD: int = 70
const SCORE_OKAY: int = 35
const BITTER_MISS: int = 25
const BITTER_WRONG: int = 35
const SCORE_POUR_CENTER: int = 150
const SCORE_POUR_OUTER: int = 75
const SCORE_POUR_EARLY: int = 20
const BITTER_POUR_LATE: int = 35

## Grade thresholds — applied to final_score = brew_quality - bitterness.
const GRADE_S_THRESHOLD: int = 600
const GRADE_A_THRESHOLD: int = 450
const GRADE_B_THRESHOLD: int = 300
const GRADE_C_THRESHOLD: int = 150
const GRADE_D_THRESHOLD: int = 50

## Lane → input action mapping.
const LANE_ACTIONS: Array[String] = ["move_left", "move_right", "move_up", "move_down"]

## Runtime text + accessibility tuning.
const COFFEE_TEXT_PATH: String = "res://data/minigames/coffee_text.json"
const SLOWER_NOTES_SCALE: float = 1.4
const WIDER_TIMING_SCALE: float = 1.5

## Prompt-icon texture map — note `icon` strings → PNG sprites.
const PROMPT_TEXTURES: Dictionary = {
	"bean":  preload("res://art/minigames/coffee/prompt_bean.png"),
	"milk":  preload("res://art/minigames/coffee/prompt_milk.png"),
	"sugar": preload("res://art/minigames/coffee/prompt_sugar.png"),
	"file":  preload("res://art/minigames/coffee/prompt_file.png"),
	"mug":   preload("res://art/minigames/coffee/prompt_mug.png"),
	"stamp": preload("res://art/minigames/coffee/prompt_stamp.png"),
}

## Cup-fill ladder — index = clamp(int(progress * 4), 0, 3) where
## progress = brew_quality / MAX_BREW_QUALITY.
const CUP_TEXTURES: Array = [
	preload("res://art/minigames/coffee/coffee_cup_empty.png"),
	preload("res://art/minigames/coffee/coffee_cup_fill_01.png"),
	preload("res://art/minigames/coffee/coffee_cup_fill_02.png"),
	preload("res://art/minigames/coffee/coffee_cup_fill_03.png"),
]

## Visual-meter ranges. Brew quality maxes a bar at the S-grade threshold;
## bitterness maxes the bar before it can dominate brew quality. Pure HUD —
## judgment + grading math still use the raw _brew_quality / _bitterness.
const MAX_BREW_QUALITY: int = GRADE_S_THRESHOLD
const METER_BREW_FULL: int = GRADE_S_THRESHOLD
const METER_BITTER_FULL: int = 300
const METER_FILL_WIDTH: float = 240.0
const METER_FILL_HEIGHT: float = 24.0

## Phase enum.
enum Phase { READY, GRIND, POUR, SERVE, RESULT, EXIT }

## Grade order for best_grade comparison.
const GRADE_ORDER: Dictionary = { "S": 6, "A": 5, "B": 4, "C": 3, "D": 2, "F": 1, "": 0 }

## Active difficulty and timing windows (set by _load_pattern).
var _difficulty: int = Difficulty.TUTORIAL
var _lane_count: int = 2
var _perfect_window: float = TUTORIAL_PERFECT_WINDOW
var _good_window: float = TUTORIAL_GOOD_WINDOW
var _okay_window: float = TUTORIAL_OKAY_WINDOW

## -----------------------------------------------------------------------
## Runtime state
## -----------------------------------------------------------------------
var _phase: int = Phase.READY
var _phase_time: float = 0.0
var _beat_time: float = 0.0

## Scoring accumulators.
var _brew_quality: int = 0
var _bitterness: int = 0
var _combo: int = 0
var _max_combo: int = 0
var _perfect_hits: int = 0
var _good_hits: int = 0
var _okay_hits: int = 0
var _misses: int = 0
var _wrong_hits: int = 0

## Pattern data — loaded or fallback.
var _phases_data: Dictionary = {}  # { "grind": [...], "pour": [...], "serve": [...] }
var _current_notes: Array = []
var _note_index: int = 0
var _active_notes: Array = []  # notes currently on screen

## Pour state.
var _pour_active: bool = false
var _pour_start_time: float = 0.0
var _pour_target_start: float = 0.0
var _pour_target_end: float = 0.0
var _pour_handled: bool = false

## Accessibility settings.
var _coffee_text: Dictionary = {}
var _slower_notes_selected: bool = false
var _slower_notes_enabled_at_load: bool = false
var _wider_timing_enabled: bool = false
var _single_button_enabled: bool = false
var _wider_timing_used_this_run: bool = false
var _single_button_used_this_run: bool = false
var _pause_open: bool = false

## Node references (populated in _ready).
var _phase_label: Label
var _combo_label: Label
var _brew_meter: Label
var _bitter_meter: Label
var _brew_fill: Sprite2D
var _bitter_fill: Sprite2D
var _cup_sprite: Sprite2D
var _result_panel: Control
var _result_grade_label: Label
var _result_buff_label: Label
var _result_detail_label: Label
var _timing_line: Sprite2D
var _lanes: Array[ColorRect] = []
var _prompt_spawner: Node2D
var _audio_player: AudioStreamPlayer
var _anim_player: AnimationPlayer
var _stamp_admitted: Sprite2D
var _stamp_objected: Sprite2D
var _pause_layer: CanvasLayer
var _pause_title_label: Label
var _slower_notes_toggle: CheckBox
var _wider_timing_toggle: CheckBox
var _single_button_toggle: CheckBox
var _slower_notes_note_label: Label
var _resume_button: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

	_cache_nodes()
	_load_coffee_text()
	_load_accessibility_settings()
	_apply_pause_text()
	_sync_pause_toggles()
	_load_pattern()
	_start_phase(Phase.GRIND)


func _cache_nodes() -> void:
	_phase_label = get_node_or_null("BackgroundPanel/PhaseLabel") as Label
	_combo_label = get_node_or_null("BackgroundPanel/ComboLabel") as Label
	_brew_meter = get_node_or_null("BackgroundPanel/BrewQualityMeter") as Label
	_bitter_meter = get_node_or_null("BackgroundPanel/BitternessMeter") as Label
	_brew_fill = get_node_or_null("BackgroundPanel/BrewQualityMeter/BrewQualityFill") as Sprite2D
	_bitter_fill = get_node_or_null("BackgroundPanel/BitternessMeter/BitternessFill") as Sprite2D
	_cup_sprite = get_node_or_null("BackgroundPanel/CupSprite") as Sprite2D
	_result_panel = get_node_or_null("BackgroundPanel/ResultPanel") as Control
	_result_grade_label = get_node_or_null("BackgroundPanel/ResultPanel/GradeLabel") as Label
	_result_buff_label = get_node_or_null("BackgroundPanel/ResultPanel/BuffLabel") as Label
	_result_detail_label = get_node_or_null("BackgroundPanel/ResultPanel/DetailLabel") as Label
	_timing_line = get_node_or_null("BackgroundPanel/TimingLine") as Sprite2D
	_prompt_spawner = get_node_or_null("BackgroundPanel/PromptSpawner") as Node2D
	_audio_player = get_node_or_null("AudioStreamPlayer") as AudioStreamPlayer
	_anim_player = get_node_or_null("AnimationPlayer") as AnimationPlayer
	_stamp_admitted = get_node_or_null("BackgroundPanel/ResultPanel/StampAdmitted") as Sprite2D
	_stamp_objected = get_node_or_null("BackgroundPanel/ResultPanel/StampObjected") as Sprite2D
	_pause_layer = get_node_or_null("PauseLayer") as CanvasLayer
	_pause_title_label = get_node_or_null("PauseLayer/Panel/TitleLabel") as Label
	_slower_notes_toggle = get_node_or_null("PauseLayer/Panel/SlowerNotesToggle") as CheckBox
	_wider_timing_toggle = get_node_or_null("PauseLayer/Panel/WiderTimingToggle") as CheckBox
	_single_button_toggle = get_node_or_null("PauseLayer/Panel/SingleButtonToggle") as CheckBox
	_slower_notes_note_label = get_node_or_null("PauseLayer/Panel/SlowerNotesNextRunLabel") as Label
	_resume_button = get_node_or_null("PauseLayer/Panel/ResumeButton") as Button

	var track_root: Control = get_node_or_null("BackgroundPanel/TimingTrackRoot") as Control
	if track_root:
		for i in range(4):
			var lane: ColorRect = track_root.get_node_or_null("Lane" + str(i)) as ColorRect
			if lane:
				_lanes.append(lane)

	if _result_panel:
		_result_panel.visible = false
	if _pause_layer:
		_pause_layer.process_mode = Node.PROCESS_MODE_ALWAYS
		_pause_layer.visible = false
	if _resume_button and not _resume_button.pressed.is_connected(_close_pause):
		_resume_button.pressed.connect(_close_pause)
	if _slower_notes_toggle and not _slower_notes_toggle.toggled.is_connected(_on_slower_notes_toggled):
		_slower_notes_toggle.toggled.connect(_on_slower_notes_toggled)
	if _wider_timing_toggle and not _wider_timing_toggle.toggled.is_connected(_on_wider_timing_toggled):
		_wider_timing_toggle.toggled.connect(_on_wider_timing_toggled)
	if _single_button_toggle and not _single_button_toggle.toggled.is_connected(_on_single_button_toggled):
		_single_button_toggle.toggled.connect(_on_single_button_toggled)


## -----------------------------------------------------------------------
## Pause + accessibility settings
## -----------------------------------------------------------------------

func _load_coffee_text() -> void:
	if not FileAccess.file_exists(COFFEE_TEXT_PATH):
		return
	var file := FileAccess.open(COFFEE_TEXT_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if parsed is Dictionary:
		_coffee_text = parsed


func _coffee_text_value(key: String) -> String:
	return str(_coffee_text.get(key, ""))


func _apply_pause_text() -> void:
	if _pause_title_label:
		_pause_title_label.text = _coffee_text_value("pause_title")
	if _slower_notes_toggle:
		_slower_notes_toggle.text = _coffee_text_value("pause_toggle_slower_notes")
	if _wider_timing_toggle:
		_wider_timing_toggle.text = _coffee_text_value("pause_toggle_wider_timing")
	if _single_button_toggle:
		_single_button_toggle.text = _coffee_text_value("pause_toggle_single_button")
	if _slower_notes_note_label:
		_slower_notes_note_label.text = _coffee_text_value("pause_applies_next_run")
	if _resume_button:
		_resume_button.text = _coffee_text_value("pause_resume")


func _coffee_accessibility_settings() -> Dictionary:
	var state_node: Node = get_node_or_null("/root/State")
	if state_node == null:
		return {}
	var data: Dictionary = state_node.data
	if not data.has("settings") or not data["settings"] is Dictionary:
		data["settings"] = {}
	var settings: Dictionary = data["settings"]
	if not settings.has("coffee_accessibility") or not settings["coffee_accessibility"] is Dictionary:
		settings["coffee_accessibility"] = {}
	var coffee_accessibility: Dictionary = settings["coffee_accessibility"]
	var defaults: Dictionary = {
		"slower_notes": false,
		"wider_timing": false,
		"single_button": false,
	}
	for key in defaults:
		if not coffee_accessibility.has(key):
			coffee_accessibility[key] = defaults[key]
	return coffee_accessibility


func _load_accessibility_settings() -> void:
	var settings: Dictionary = _coffee_accessibility_settings()
	_slower_notes_selected = bool(settings.get("slower_notes", false))
	_wider_timing_enabled = bool(settings.get("wider_timing", false))
	_single_button_enabled = bool(settings.get("single_button", false))
	_wider_timing_used_this_run = _wider_timing_enabled
	_single_button_used_this_run = _single_button_enabled


func _sync_pause_toggles() -> void:
	if _slower_notes_toggle:
		_slower_notes_toggle.set_pressed_no_signal(_slower_notes_selected)
	if _wider_timing_toggle:
		_wider_timing_toggle.set_pressed_no_signal(_wider_timing_enabled)
	if _single_button_toggle:
		_single_button_toggle.set_pressed_no_signal(_single_button_enabled)


func _write_accessibility_setting(key: String, enabled: bool) -> void:
	var settings: Dictionary = _coffee_accessibility_settings()
	if settings.is_empty():
		return
	settings[key] = enabled


func _on_slower_notes_toggled(enabled: bool) -> void:
	_slower_notes_selected = enabled
	_write_accessibility_setting("slower_notes", enabled)


func _on_wider_timing_toggled(enabled: bool) -> void:
	_wider_timing_enabled = enabled
	if enabled:
		_wider_timing_used_this_run = true
	_write_accessibility_setting("wider_timing", enabled)


func _on_single_button_toggled(enabled: bool) -> void:
	_single_button_enabled = enabled
	if enabled:
		_single_button_used_this_run = true
	_write_accessibility_setting("single_button", enabled)


func _toggle_pause() -> void:
	if _pause_open:
		_close_pause()
	else:
		_open_pause()


func _open_pause() -> void:
	_pause_open = true
	if _pause_layer:
		_pause_layer.visible = true
	if _resume_button:
		_resume_button.grab_focus()


func _close_pause() -> void:
	_pause_open = false
	if _pause_layer:
		_pause_layer.visible = false


## -----------------------------------------------------------------------
## Pattern loading
## -----------------------------------------------------------------------

func _load_pattern() -> void:
	var pattern: Dictionary = _load_pattern_from_json(pattern_id)
	if pattern.is_empty():
		push_warning("CoffeeBrewing: pattern '%s' not found, using fallback" % pattern_id)
		pattern = _load_pattern_from_json("chapter1_court_coffee")
	if pattern.is_empty():
		push_error("CoffeeBrewing: no patterns available at all")
		return

	pattern = pattern.duplicate(true)
	_slower_notes_enabled_at_load = _slower_notes_selected
	if _slower_notes_enabled_at_load:
		_scale_pattern_times(pattern, SLOWER_NOTES_SCALE)

	## Derive difficulty from pattern.
	var diff_str: String = pattern.get("difficulty", "tutorial")
	if diff_str == "normal":
		_difficulty = Difficulty.NORMAL
		_perfect_window = NORMAL_PERFECT_WINDOW
		_good_window = NORMAL_GOOD_WINDOW
		_okay_window = NORMAL_OKAY_WINDOW
	else:
		_difficulty = Difficulty.TUTORIAL
		_perfect_window = TUTORIAL_PERFECT_WINDOW
		_good_window = TUTORIAL_GOOD_WINDOW
		_okay_window = TUTORIAL_OKAY_WINDOW

	## Derive lane count and hide unused lanes.
	_lane_count = int(pattern.get("lanes", 2))
	_apply_lane_visibility()

	## Split flat note list into per-phase arrays.
	_split_pattern_into_phases(pattern)


func _scale_pattern_times(pattern: Dictionary, time_scale: float) -> void:
	var notes: Array = pattern.get("notes", [])
	for note in notes:
		if note is Dictionary and note.has("time"):
			note["time"] = float(note["time"]) * time_scale

	var pour_events: Array = pattern.get("pour_events", [])
	for pour_event in pour_events:
		if not pour_event is Dictionary:
			continue
		for key in ["start_time", "target_start", "target_end"]:
			if pour_event.has(key):
				pour_event[key] = float(pour_event[key]) * time_scale

	var final_stamp = pattern.get("final_stamp", {})
	if final_stamp is Dictionary and final_stamp.has("time"):
		final_stamp["time"] = float(final_stamp["time"]) * time_scale


func _load_pattern_from_json(pid: String) -> Dictionary:
	var json_path: String = "res://data/minigames/coffee_patterns.json"
	if not FileAccess.file_exists(json_path):
		return {}
	var file := FileAccess.open(json_path, FileAccess.READ)
	if not file:
		return {}
	var parsed = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return {}
	var patterns_dict = parsed.get("patterns", {})
	if not patterns_dict is Dictionary:
		return {}
	if patterns_dict.has(pid):
		return patterns_dict[pid]
	return {}


func _apply_lane_visibility() -> void:
	## Hide lanes 2 and 3 when in 2-lane mode.
	if _lane_count <= 2:
		for i in range(2, _lanes.size()):
			_lanes[i].visible = false
	else:
		for i in range(_lanes.size()):
			_lanes[i].visible = true


func _split_pattern_into_phases(pattern: Dictionary) -> void:
	## The JSON pattern has a flat "notes" array + "pour_events" array.
	## Split notes into grind / serve phases. Pour events become the pour phase.
	var all_notes: Array = pattern.get("notes", [])
	var pour_events: Array = pattern.get("pour_events", [])

	## Find the first pour start time to split grind vs serve.
	var pour_start_time: float = 999.0
	var pour_end_time: float = 0.0
	if pour_events.size() > 0:
		pour_start_time = pour_events[0].get("start_time", 999.0)
		var last_pour: Dictionary = pour_events[pour_events.size() - 1]
		pour_end_time = last_pour.get("target_end", last_pour.get("start_time", 0.0)) + 0.5

	var grind_notes: Array = []
	var serve_notes: Array = []
	for note in all_notes:
		var t: float = note.get("time", 0.0)
		if t < pour_start_time:
			grind_notes.append(note)
		else:
			serve_notes.append(note)

	## Rebase serve note times relative to phase start.
	## Grind notes keep their absolute times (phase starts at beat_time 0).
	## Serve notes are rebased so the first note starts at a comfortable offset.
	var serve_offset: float = pour_end_time if pour_end_time > 0.0 else pour_start_time
	var rebased_serve: Array = []
	for note in serve_notes:
		var n: Dictionary = note.duplicate()
		n["time"] = note.get("time", 0.0) - serve_offset
		rebased_serve.append(n)

	## Build pour phase data from pour_events.
	var pour_notes: Array = []
	for pe in pour_events:
		var pour_note: Dictionary = {
			"time": pe.get("start_time", 0.0) - pour_start_time,
			"lane": -1,
			"icon": "stream",
			"kind": "pour",
			"target_start": pe.get("target_start", 0.0) - pour_start_time,
			"target_end": pe.get("target_end", 0.0) - pour_start_time,
		}
		pour_notes.append(pour_note)

	_phases_data = {
		"grind": grind_notes,
		"pour": pour_notes,
		"serve": rebased_serve,
	}


## -----------------------------------------------------------------------
## Phase management
## -----------------------------------------------------------------------

func _start_phase(phase: int) -> void:
	_phase = phase
	_phase_time = 0.0
	_beat_time = 0.0
	_note_index = 0
	_active_notes.clear()
	_pour_active = false
	_pour_handled = false

	match phase:
		Phase.GRIND:
			_current_notes = _phases_data.get("grind", [])
			_update_phase_label("GRIND")
		Phase.POUR:
			_current_notes = _phases_data.get("pour", [])
			_update_phase_label("POUR")
		Phase.SERVE:
			_current_notes = _phases_data.get("serve", [])
			_update_phase_label("SERVE")
		Phase.RESULT:
			_current_notes = []
			_show_result()
		Phase.EXIT:
			_exit_minigame()


func _update_phase_label(text: String) -> void:
	if _phase_label:
		_phase_label.text = text


func _update_meters() -> void:
	if _brew_fill:
		var brew_ratio: float = clampf(float(_brew_quality) / float(METER_BREW_FULL), 0.0, 1.0)
		_brew_fill.region_rect = Rect2(0.0, 0.0, METER_FILL_WIDTH * brew_ratio, METER_FILL_HEIGHT)
	if _bitter_fill:
		var bitter_ratio: float = clampf(float(_bitterness) / float(METER_BITTER_FULL), 0.0, 1.0)
		_bitter_fill.region_rect = Rect2(0.0, 0.0, METER_FILL_WIDTH * bitter_ratio, METER_FILL_HEIGHT)
	if _combo_label:
		if _combo > 1:
			_combo_label.text = "Combo: " + str(_combo)
		else:
			_combo_label.text = ""
	_update_cup_fill()


func _update_cup_fill() -> void:
	if not _cup_sprite:
		return
	var progress: float = clampf(float(_brew_quality) / float(MAX_BREW_QUALITY), 0.0, 1.0)
	var idx: int = clampi(int(progress * 4.0), 0, CUP_TEXTURES.size() - 1)
	_cup_sprite.texture = CUP_TEXTURES[idx]


func _play_anim(anim_name: String) -> void:
	if _anim_player and _anim_player.has_animation(anim_name):
		_anim_player.play(anim_name)


## -----------------------------------------------------------------------
## Process loop
## -----------------------------------------------------------------------

func _process(delta: float) -> void:
	if _pause_open or _phase == Phase.RESULT or _phase == Phase.EXIT or _phase == Phase.READY:
		return

	_phase_time += delta
	_beat_time += delta

	## Spawn notes that have come due (1.5s lead time before timing line).
	var lead_time: float = 1.5
	while _note_index < _current_notes.size():
		var note: Dictionary = _current_notes[_note_index]
		var note_time: float = note.get("time", 0.0)
		if _beat_time >= note_time - lead_time:
			_spawn_note(note)
			_note_index += 1
		else:
			break

	## Update active notes — move them toward timing line.
	_update_active_notes(delta)

	## Check for missed notes.
	_check_missed_notes()

	## Handle pour phase timing.
	if _pour_active and not _pour_handled:
		_update_pour()

	## Phase auto-advance: when all notes consumed and no active notes remain.
	if _note_index >= _current_notes.size() and _active_notes.size() == 0 and not _pour_active:
		## Small grace period before advancing.
		if _phase_time > _get_phase_duration() + 1.0:
			_advance_phase()

	_update_meters()


func _get_phase_duration() -> float:
	if _current_notes.size() == 0:
		return 0.0
	var last_note: Dictionary = _current_notes[_current_notes.size() - 1]
	return last_note.get("time", 0.0) + 1.0


func _advance_phase() -> void:
	match _phase:
		Phase.GRIND:
			_start_phase(Phase.POUR)
		Phase.POUR:
			_start_phase(Phase.SERVE)
		Phase.SERVE:
			_start_phase(Phase.RESULT)


## -----------------------------------------------------------------------
## Note spawning and movement
## -----------------------------------------------------------------------

func _spawn_note(note: Dictionary) -> void:
	var kind: String = note.get("kind", "tap")

	if kind == "pour":
		## Pour notes don't spawn visual prompts — they set up the pour state.
		_pour_active = true
		_pour_handled = false
		_pour_start_time = _beat_time
		_pour_target_start = note.get("target_start", note.get("time", 0.0) + 0.8)
		_pour_target_end = note.get("target_end", _pour_target_start + 0.8)
		_play("pour_start")
		return

	## Create a themed sprite as the note prompt.
	var icon: String = note.get("icon", "bean")
	var sprite := Sprite2D.new()
	var bean_fallback: Texture2D = PROMPT_TEXTURES["bean"]
	sprite.texture = PROMPT_TEXTURES.get(icon, bean_fallback) as Texture2D

	## Position: lane determines X (lane center: 430 + lane*100 + 45 = 475 + lane*100),
	## starts high (Y = 100), falls toward timing line at Y = 400.
	var lane: int = note.get("lane", 0)
	var lane_x: float = 475.0 + lane * 100.0
	sprite.position = Vector2(lane_x, 100.0)

	if _prompt_spawner:
		_prompt_spawner.add_child(sprite)
	else:
		add_child(sprite)

	_active_notes.append({
		"node": sprite,
		"time": note.get("time", 0.0),
		"lane": lane,
		"kind": kind,
		"icon": icon,
		"judged": false,
	})


func _update_active_notes(_delta: float) -> void:
	## Timing line is at Y ~400 in the background panel.
	var timing_line_y: float = 400.0
	var spawn_y: float = 100.0
	var lead_time: float = 1.5

	for note_data in _active_notes:
		if note_data["judged"]:
			continue
		var note_time: float = note_data["time"]
		var progress: float = (_beat_time - (note_time - lead_time)) / lead_time
		progress = clampf(progress, 0.0, 2.0)
		var node: Node2D = note_data["node"] as Node2D
		if node:
			node.position.y = spawn_y + (timing_line_y - spawn_y) * progress


func _check_missed_notes() -> void:
	var to_remove: Array = []
	for i in range(_active_notes.size()):
		var note_data: Dictionary = _active_notes[i]
		if note_data["judged"]:
			to_remove.append(i)
			continue
		var note_time: float = note_data["time"]
		var diff: float = _beat_time - note_time
		if diff > _okay_window * _timing_window_scale():
			## Missed.
			_register_judgment("miss", note_data)
			note_data["judged"] = true
			to_remove.append(i)

	## Remove judged notes (reverse order to preserve indices).
	to_remove.reverse()
	for idx in to_remove:
		var note_data: Dictionary = _active_notes[idx]
		var node: Node = note_data.get("node")
		if node and is_instance_valid(node):
			node.queue_free()
		_active_notes.remove_at(idx)


## -----------------------------------------------------------------------
## Input handling
## -----------------------------------------------------------------------

func _unhandled_input(event: InputEvent) -> void:
	if _phase == Phase.EXIT:
		return

	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		if _phase != Phase.RESULT:
			_toggle_pause()
		return

	if _pause_open:
		return

	## Result panel dismiss.
	if _phase == Phase.RESULT:
		if event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			_start_phase(Phase.EXIT)
		return

	## Pour release.
	if _pour_active and not _pour_handled:
		if event.is_action_released("interact"):
			get_viewport().set_input_as_handled()
			_judge_pour_release()
			return
		## Pour hold start is handled by the note spawn.
		if event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			return

	if _single_button_enabled:
		if event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			_try_judge_single_button()
			return
		for action in LANE_ACTIONS:
			if event.is_action_pressed(action):
				get_viewport().set_input_as_handled()
				_try_judge_single_button()
				return

	## Stamp input (interact press during serve phase).
	if _phase == Phase.SERVE and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		_try_judge_stamp()
		return

	## Lane tap input.
	for lane_idx in range(LANE_ACTIONS.size()):
		if event.is_action_pressed(LANE_ACTIONS[lane_idx]):
			get_viewport().set_input_as_handled()
			_try_judge_lane(lane_idx)
			return


func _try_judge_lane(lane: int) -> void:
	var best_note: Dictionary = {}
	var best_diff: float = 999.0

	for note_data in _active_notes:
		if note_data["judged"]:
			continue
		if note_data["kind"] != "tap":
			continue
		var diff: float = absf(_beat_time - note_data["time"])
		if diff < best_diff:
			best_diff = diff
			best_note = note_data

	if best_note.is_empty():
		## Wrong input — no note in range.
		_wrong_hits += 1
		_bitterness += BITTER_WRONG
		_combo = 0
		_play("note_miss")
		_play_anim("machine_angry")
		return

	## Check lane match.
	if best_note.get("lane", -1) != lane:
		_wrong_hits += 1
		_bitterness += BITTER_WRONG
		_combo = 0
		_play("note_miss")
		_play_anim("machine_angry")
		return

	## Judge timing.
	var judgment: String = _get_judgment(best_diff)
	_register_judgment(judgment, best_note)
	best_note["judged"] = true


func _try_judge_single_button() -> void:
	var best_note: Dictionary = {}
	var best_diff: float = 999.0

	for note_data in _active_notes:
		if note_data["judged"]:
			continue
		var kind: String = note_data.get("kind", "tap")
		if kind != "tap" and kind != "stamp":
			continue
		var diff: float = absf(_beat_time - note_data["time"])
		if diff < best_diff:
			best_diff = diff
			best_note = note_data

	if best_note.is_empty():
		_wrong_hits += 1
		_bitterness += BITTER_WRONG
		_combo = 0
		_play("note_miss")
		_play_anim("machine_angry")
		return

	var judgment: String = _get_judgment(best_diff)
	_register_judgment(judgment, best_note)
	best_note["judged"] = true
	if best_note.get("kind", "") == "stamp":
		_play("stamp_caffeinated")


func _try_judge_stamp() -> void:
	var best_note: Dictionary = {}
	var best_diff: float = 999.0

	for note_data in _active_notes:
		if note_data["judged"]:
			continue
		if note_data["kind"] != "stamp":
			continue
		var diff: float = absf(_beat_time - note_data["time"])
		if diff < best_diff:
			best_diff = diff
			best_note = note_data

	if best_note.is_empty():
		return

	var judgment: String = _get_judgment(best_diff)
	_register_judgment(judgment, best_note)
	best_note["judged"] = true
	_play("stamp_caffeinated")


func _get_judgment(diff: float) -> String:
	var window_scale: float = _timing_window_scale()
	if diff <= _perfect_window * window_scale:
		return "perfect"
	elif diff <= _good_window * window_scale:
		return "good"
	elif diff <= _okay_window * window_scale:
		return "okay"
	else:
		return "miss"


func _timing_window_scale() -> float:
	if _wider_timing_enabled:
		return WIDER_TIMING_SCALE
	return 1.0


func _register_judgment(judgment: String, _note_data: Dictionary) -> void:
	match judgment:
		"perfect":
			_brew_quality += SCORE_PERFECT
			_combo += 1
			_perfect_hits += 1
			_play("note_perfect")
			_play_anim("machine_happy")
		"good":
			_brew_quality += SCORE_GOOD
			_combo += 1
			_good_hits += 1
			_play("note_hit")
			_play_anim("machine_gurgle")
		"okay":
			_brew_quality += SCORE_OKAY
			## Combo continues in tutorial mode only (spec).
			if _difficulty == Difficulty.TUTORIAL:
				_combo += 1
			else:
				_combo = 0
			_okay_hits += 1
			_play("note_hit")
			_play_anim("machine_gurgle")
		"miss":
			_bitterness += BITTER_MISS
			_combo = 0
			_misses += 1
			_play("note_miss")
			_play_anim("machine_angry")

	if _combo > _max_combo:
		_max_combo = _combo

	_update_meters()


## -----------------------------------------------------------------------
## Pour mechanics
## -----------------------------------------------------------------------

func _update_pour() -> void:
	## Auto-timeout pour if held too long.
	if _beat_time > _pour_target_end + 0.5:
		_judge_pour_release()


func _judge_pour_release() -> void:
	_pour_handled = true
	_pour_active = false
	var release_time: float = _beat_time

	if release_time < _pour_target_start - 0.2:
		## Released too early.
		_brew_quality += SCORE_POUR_EARLY
		_play("note_hit")
	elif release_time >= _pour_target_start and release_time <= _pour_target_end:
		## Check center vs outer.
		var center: float = (_pour_target_start + _pour_target_end) / 2.0
		var half_range: float = (_pour_target_end - _pour_target_start) / 2.0
		var dist_from_center: float = absf(release_time - center)
		if dist_from_center <= half_range * 0.4:
			_brew_quality += SCORE_POUR_CENTER
			_perfect_hits += 1
			_combo += 1
			_play("pour_release_good")
		else:
			_brew_quality += SCORE_POUR_OUTER
			_good_hits += 1
			_combo += 1
			_play("pour_release_good")
	else:
		## Late release.
		_bitterness += BITTER_POUR_LATE
		_combo = 0
		_misses += 1
		_play("note_miss")

	if _combo > _max_combo:
		_max_combo = _combo
	_update_meters()


## -----------------------------------------------------------------------
## Result grading
## -----------------------------------------------------------------------

func _compute_grade() -> Dictionary:
	var final_score: int = _brew_quality - _bitterness
	var grade: String
	var result_name: String
	var buff: String

	if final_score >= GRADE_S_THRESHOLD:
		grade = "S"
		result_name = "perfect_brew"
		buff = "procedurally_alert_plus"
	elif final_score >= GRADE_A_THRESHOLD:
		grade = "A"
		result_name = "good_brew"
		buff = "procedurally_alert"
	elif final_score >= GRADE_B_THRESHOLD:
		grade = "B"
		result_name = "good_brew"
		buff = "procedurally_alert"
	elif final_score >= GRADE_C_THRESHOLD:
		grade = "C"
		result_name = "drinkable_brew"
		buff = "caffeinated"
	elif final_score >= GRADE_D_THRESHOLD:
		grade = "D"
		result_name = "procedural_mud"
		buff = "over_caffeinated"
	else:
		grade = "F"
		result_name = "machine_objects"
		buff = "over_caffeinated"

	return {
		"minigame": "coffee_brewing",
		"context": "chapter1_cafe_tutorial",
		"grade": grade,
		"result": result_name,
		"buff": buff,
		"brew_quality": _brew_quality,
		"bitterness": _bitterness,
		"perfect_hits": _perfect_hits,
		"good_hits": _good_hits,
		"okay_hits": _okay_hits,
		"misses": _misses,
		"assist_used": _assist_used_this_run(),
	}


func _assist_used_this_run() -> bool:
	return _slower_notes_enabled_at_load or _wider_timing_used_this_run or _single_button_used_this_run


func _show_result() -> void:
	_update_phase_label("RESULT")
	var result: Dictionary = _compute_grade()
	var grade_str: String = result["grade"]

	if _result_panel:
		## result_reveal tweens modulate alpha 0 → 1 from this baseline.
		_result_panel.modulate = Color(1, 1, 1, 0)
		_result_panel.visible = true
	if _result_grade_label:
		_result_grade_label.text = "Grade: " + grade_str
	if _result_buff_label:
		_result_buff_label.text = "Status: " + str(result["buff"])
	if _result_detail_label:
		_result_detail_label.text = "Quality: %d  Bitterness: %d  Combo: %d" % [
			_brew_quality, _bitterness, _max_combo
		]

	## Show the stamp that matches the grade — admitted for D and above, objected for F.
	if _stamp_admitted:
		_stamp_admitted.scale = Vector2(1, 1)
		_stamp_admitted.visible = grade_str != "F"
	if _stamp_objected:
		_stamp_objected.scale = Vector2(1, 1)
		_stamp_objected.visible = grade_str == "F"

	if grade_str == "F":
		_play("failure")
	else:
		_play("success")

	_play_anim("result_reveal")
	## Stamp impact lands after the reveal tween settles.
	var tree: SceneTree = get_tree()
	if tree:
		tree.create_timer(0.3).timeout.connect(_on_result_reveal_done)


func _on_result_reveal_done() -> void:
	_play_anim("stamp_impact")


## -----------------------------------------------------------------------
## Exit — write state, emit signals, unpause, free
## -----------------------------------------------------------------------

func _exit_minigame() -> void:
	var result: Dictionary = _compute_grade()
	var buff_string: String = result["buff"]
	var grade_string: String = result["grade"]

	var state_node: Node = get_node_or_null("/root/State")
	var sigs: Node = get_node_or_null("/root/Signals")

	if state_node:
		var data: Dictionary = state_node.data
		## Chapter 1 flags.
		if data.has("chapter1"):
			var ch1: Dictionary = data["chapter1"]
			ch1["coffee_tutorial_seen"] = true
			ch1["coffee_buff"] = buff_string
			ch1["coffee_brew_grade"] = grade_string

			## Emit chapter1_flag_changed for each written flag.
			if sigs:
				sigs.chapter1_flag_changed.emit("coffee_tutorial_seen", true)
				sigs.chapter1_flag_changed.emit("coffee_buff", buff_string)
				sigs.chapter1_flag_changed.emit("coffee_brew_grade", grade_string)

		## Top-level coffee dict.
		if data.has("coffee"):
			var coffee: Dictionary = data["coffee"]
			coffee["tutorial_seen"] = true
			coffee["last_result"] = result["result"]
			coffee["last_grade"] = grade_string
			coffee["last_buff"] = buff_string
			coffee["assist_used"] = result["assist_used"]
			coffee["times_brewed"] = coffee.get("times_brewed", 0) + 1
			## Update best_grade if this grade is better.
			var current_best: String = coffee.get("best_grade", "")
			if GRADE_ORDER.get(grade_string, 0) > GRADE_ORDER.get(current_best, 0):
				coffee["best_grade"] = grade_string

	## Emit signals.
	if sigs:
		sigs.coffee_brewing_completed.emit(result)
		sigs.minigame_finished.emit("coffee_brewing", buff_string)

	## Unpause and free.
	get_tree().paused = false
	queue_free()


## -----------------------------------------------------------------------
## Audio helper
## -----------------------------------------------------------------------

func _play(key: String) -> void:
	if not _audio_player:
		return
	var stream = audio_streams.get(key)
	if stream is AudioStream:
		_audio_player.stream = stream
		_audio_player.play()
