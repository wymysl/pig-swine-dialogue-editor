extends Area2D
## NPC — placeholder interactive character node.
## Sole writer: Code role (see AGENTS.md §File ownership).
##
## Pattern: mirrors door.gd. Player walks into CollisionShape2D, presses the
## interact action (ui_accept / E), DialogueRunner receives the signal and
## resolves the correct dialogue line.
##
## Spawning: add as Area2D node in a scene; set exported vars in the inspector
## or via the .tscn file. Collision layer 3 (npc), mask 2 (player).

## npc_id must match the key in data/dialogues/<npc_id>.json.
@export var npc_id: String = ""

## display_name is the canonical form used by DialogueRunner as the speaker.
## Rule A compliance: "Asia", "Mr. Pig", "Murrow" (see AGENTS.md §Naming).
@export var display_name: String = ""

## display_name_after_meeting — speaker label used once first_meeting_flag is true.
## Leave empty to always use display_name (default behaviour; existing NPCs unaffected).
@export var display_name_after_meeting: String = ""

## first_meeting_flag — the chapter1 sub-key (e.g. "met_murrow") whose true value
## signals that the first-meeting state is complete. Leave empty to disable switching.
@export var first_meeting_flag: String = ""

## prompt_anchor_path — NodePath whose target node anchors the [E] interaction
## prompt instead of `self`. Use this when the NPC's interaction Area2D is
## visually separate from the NPC's sprite (e.g., DeskFront triggers Asia's
## dialogue but Asia is behind the counter; without this, [E] renders on the
## desk surface and occludes Asia's sprite). Leave empty to use `self` as the
## anchor (default; the typical NPC case).
@export var prompt_anchor_path: NodePath = NodePath()

## npc_color: visual identifier rendered as a small ColorRect.
@export var npc_color: Color = Color(0.5, 0.5, 0.5, 1.0)

@export var default_facing: String = "front"

## presence_flags — list of `State.data.chapter1.<flag>` keys that gate this
## NPC's visibility. Empty array (default) means the NPC is always present
## regardless of chapter1 flag state — this is the canonical answer for
## chapter-1 office NPCs (Mr. Pig, Murrow) under the current beat structure.
##
## See CONVENTIONS.md §"NPC presence schema". Beats themselves are narrative
## concepts in `narrative_revision/beats/`; they are NOT runtime state.
@export var presence_flags: Array[String] = []

## presence_logic — how `presence_flags` combine.
##   "any" (default): NPC is visible when at least one listed flag is true.
##   "all":           NPC is visible only when every listed flag is true.
## Ignored when `presence_flags` is empty (NPC is always visible).
@export_enum("any", "all") var presence_logic: String = "any"

## Width and height of the visual body rectangle.
const BODY_W: float = 24.0
const BODY_H: float = 32.0

var _player_inside: bool = false
var _player: Node2D = null
var _prompt: Node
var _is_interacting: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	var sigs = get_node_or_null("/root/Signals")
	if sigs and sigs.has_signal("dialogue_ended"):
		sigs.dialogue_ended.connect(_on_dialogue_ended)
	if sigs and sigs.has_signal("chapter1_flag_changed"):
		sigs.chapter1_flag_changed.connect(_on_chapter1_flag_changed)

	## Build the visual body at runtime so the .tscn file stays lean.
	if not has_node("Visual"):
		var visual := ColorRect.new()
		visual.name = "Visual"
		visual.color = npc_color
		visual.offset_left = -BODY_W * 0.5
		visual.offset_top = -BODY_H * 0.5
		visual.offset_right = BODY_W * 0.5
		visual.offset_bottom = BODY_H * 0.5
		add_child(visual)

	## Build the interaction collision shape if none exists in the scene.
	var has_shape = false
	for child in get_children():
		if child is CollisionShape2D:
			has_shape = true
			break
	if not has_shape:
		var shape := CollisionShape2D.new()
		var rect := RectangleShape2D.new()
		rect.size = Vector2(BODY_W + 8.0, BODY_H + 8.0)
		shape.shape = rect
		add_child(shape)

	var prompt_scene = load("res://scenes/ui/interaction_prompt.tscn")
	if prompt_scene:
		_prompt = prompt_scene.instantiate()
		add_child(_prompt)
		## If a custom anchor is configured, override the default parent anchor.
		## Phase-8 polish for the DeskFront/Asia case (see prompt_anchor_path
		## docstring above).
		if not prompt_anchor_path.is_empty():
			var anchor_node = get_node_or_null(prompt_anchor_path)
			if anchor_node != null and anchor_node is Node2D and _prompt.has_method("set_anchor_node"):
				_prompt.set_anchor_node(anchor_node)
				
	# Deferred to ensure visual nodes are ready
	call_deferred("_set_facing", default_facing)

	## Initial presence evaluation. Re-runs whenever a chapter1 flag changes,
	## via Signals.chapter1_flag_changed (see CONVENTIONS.md §"NPC presence
	## schema").
	_update_presence()


func _on_chapter1_flag_changed(_flag_name: String, _new_value: Variant) -> void:
	_update_presence()


func _update_presence() -> void:
	var present := _evaluate_presence()
	visible = present
	## Disable Area2D detection while hidden so the player can't trigger
	## dialogue against an invisible NPC.
	monitoring = present
	monitorable = present
	if not present:
		## If the player happened to be standing inside our trigger when we
		## disappeared, clear the prompt state so we don't leave a stale [E]
		## hovering over empty space.
		_player_inside = false
		_player = null
		if _prompt and _prompt.has_method("hide_prompt"):
			_prompt.hide_prompt()


func _evaluate_presence() -> bool:
	## Empty list = canonical "always present" — the default for office NPCs
	## (Mr. Pig, Murrow) under the current chapter 1 implementation.
	if presence_flags.is_empty():
		return true
	var state_node = get_node_or_null("/root/State")
	if state_node == null:
		## Defensive: with no State autoload (e.g., headless tests outside the
		## main scene) treat the NPC as present rather than spuriously hiding.
		return true
	var ch1: Dictionary = state_node.data.get("chapter1", {})
	if presence_logic == "all":
		for f in presence_flags:
			if ch1.get(f, false) != true:
				return false
		return true
	## Default "any" semantics.
	for f in presence_flags:
		if ch1.get(f, false) == true:
			return true
	return false


func _on_dialogue_ended() -> void:
	if _is_interacting:
		_is_interacting = false
		_set_facing(default_facing)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside:
		return
	if event.is_action_pressed("interact"):
		_is_interacting = true
		if _player:
			_update_facing(_player.global_position)
		var sigs = get_node_or_null("/root/Signals")
		if sigs:
			var active_name: String = display_name
			if first_meeting_flag != "" and display_name_after_meeting != "":
				var state_node = get_node_or_null("/root/State")
				if state_node and state_node.data.get("chapter1", {}).get(first_meeting_flag, false) == true:
					active_name = display_name_after_meeting
				sigs.dialogue_requested.emit(npc_id, active_name)
			else:
				sigs.dialogue_requested.emit(npc_id, active_name)
		get_viewport().set_input_as_handled()

func _update_facing(target_pos: Vector2) -> void:
	var target_node: Node2D = self
	if not prompt_anchor_path.is_empty():
		var anchor = get_node_or_null(prompt_anchor_path)
		if anchor and anchor is Node2D:
			target_node = anchor
			
	var dir = (target_pos - target_node.global_position).normalized()
	var angle = rad_to_deg(dir.angle())
	if angle < 0:
		angle += 360.0
	
	var facing = "front"
	if angle >= 337.5 or angle < 22.5:
		facing = "right"
	elif angle >= 22.5 and angle < 67.5:
		facing = "front_right"
	elif angle >= 67.5 and angle < 112.5:
		facing = "front"
	elif angle >= 112.5 and angle < 157.5:
		facing = "front_left"
	elif angle >= 157.5 and angle < 202.5:
		facing = "left"
	elif angle >= 202.5 and angle < 247.5:
		facing = "back_left"
	elif angle >= 247.5 and angle < 292.5:
		facing = "back"
	elif angle >= 292.5 and angle < 337.5:
		facing = "back_right"
		
	_set_facing(facing)

func _set_facing(facing: String) -> void:
	var target_node: Node2D = self
	if not prompt_anchor_path.is_empty():
		var anchor = get_node_or_null(prompt_anchor_path)
		if anchor and anchor is Node2D:
			target_node = anchor
			
	var visual = target_node.get_node_or_null("Visual")
	if not visual:
		return
		
	if visual is AnimatedSprite2D:
		play_animation("idle", facing)
	elif visual is Sprite2D and visual.texture != null:
		var tex_path = visual.texture.resource_path
		if tex_path.is_empty():
			return
		
		var last_slash = tex_path.rfind("/")
		if last_slash == -1:
			return
			
		var file_name = tex_path.substr(last_slash + 1)
		var idle_idx = file_name.find("_idle_")
		if idle_idx != -1:
			var prefix_len = last_slash + 1 + idle_idx + 6
			var prefix = tex_path.substr(0, prefix_len)
			var new_path = prefix + facing + ".png"
			if ResourceLoader.exists(new_path):
				visual.texture = load(new_path)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = true
		_player = body
		if _prompt:
			_prompt.show_prompt()


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_inside = false
		_player = null
		if _prompt:
			_prompt.hide_prompt()

func play_animation(action: String, facing: String) -> void:
	var target_node: Node2D = self
	if not prompt_anchor_path.is_empty():
		var anchor = get_node_or_null(prompt_anchor_path)
		if anchor and anchor is Node2D:
			target_node = anchor
			
	var visual = target_node.get_node_or_null("Visual")
	if not visual or not visual is AnimatedSprite2D or not visual.sprite_frames:
		return
		
	var frames = visual.sprite_frames
	
	# Try exact match
	var anim_name = action + "_" + facing
	if frames.has_animation(anim_name) and frames.get_frame_count(anim_name) > 0:
		if visual.animation != anim_name or not visual.is_playing():
			visual.play(anim_name)
		return
		
	# Fallback 1: Diagonal to cardinal for the same action
	var cardinal_map = {
		"front_left": ["front", "left"],
		"front_right": ["front", "right"],
		"back_left": ["back", "left"],
		"back_right": ["back", "right"]
	}
	
	if facing in cardinal_map:
		for card in cardinal_map[facing]:
			var card_anim = action + "_" + card
			if frames.has_animation(card_anim) and frames.get_frame_count(card_anim) > 0:
				if visual.animation != card_anim or not visual.is_playing():
					visual.play(card_anim)
				return
				
	# Fallback 2: Action chain (run -> walk -> idle)
	if action == "run":
		play_animation("walk", facing)
		return
	if action == "walk":
		play_animation("idle", facing)
		return
