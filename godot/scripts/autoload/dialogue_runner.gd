extends Node
## DialogueRunner — resolves NPC dialogue against State.data.
## Sole writer: Code role (see AGENTS.md §File ownership).\
##
## Lifecycle:
##   _ready()  — loads all JSON files from data/dialogues/ and merges
##               asia_hint_states_ch1.json's V1.A states into the "asia"
##               catalogue entry. The legacy data/asia_hints.json was
##               retired in Chapter 1 Phase A.3 (see asia_hints.json.bak).
##   On Signals.dialogue_requested(npc_id) — picks the best matching state and
##               emits Signals.dialogue_line_ready(speaker, npc_id, lines).
##
## Trigger evaluation:
##   Each state entry may have a "trigger" string of &&-separated clauses,
##   with optional || groups for simple alternatives.
##   Clause format:  "chapter1.met_pig == true"
##                   "chapter1.met_murrow != false"
##   LHS is a dotted path into State.data. RHS is compared as a string.
##   All clauses in one && group must pass; any || group may match.
##
## Selection priority:
##   1. First state whose trigger evaluates to true (in JSON order).
##   2. If no states match: a random entry from the "idle_flavor" array.
##   3. If idle_flavor is also empty: a hard-coded fallback line.
##
## Multi-speaker lines (option 1):
##   A state's "lines" array may mix plain strings and speaker-override objects:
##     "lines": [
##       "NPC speaks (string — NPC who owns this tree is the speaker).",
##       { "speaker": "cula", "text": "Cula responds." },
##       "NPC speaks again."
##     ]
##   Speaker ids are resolved via character_registry.json (res://data/).
##   String entries use the owning NPC's display name (the display_name arg
##   passed to _on_dialogue_requested). Backward compatibility: string-only
##   states are unaffected.
##   A whole state may also declare "speaker": "asia" to make plain-string
##   lines in that state use a different default speaker and portrait.

const DIALOGUES_DIR: String = "res://data/dialogues/"
## Chapter 1 Phase A.3: V1.A canonical Asia hint surface. States merged
## into the "asia" catalogue entry after the dir loop loads asia.json so
## asia.json's first-meeting states (met_asia==false) keep their priority
## and the met_asia flag-flip on_dismiss still fires.
const ASIA_HINT_STATES_PATH: String = "res://data/dialogues/asia_hint_states_ch1.json"
## Filename of the Asia hint states JSON (used to skip it during the
## dir-loop pass — it is loaded once, explicitly, and merged into "asia").
const ASIA_HINT_STATES_FILENAME: String = "asia_hint_states_ch1.json"
const CHARACTER_REGISTRY_PATH: String = "res://data/character_registry.json"
const FALLBACK_LINE: String = "..."

## _catalogue — map of npc_id -> parsed dialogue Dict.
var _catalogue: Dictionary = {}
var _active_state_mutations: Array = []

## Active options state — set when a matched state has an `options` block.
## Cleared on option commit (or on dismiss if the player exits without
## committing — though the dialogue box must always commit when options
## are present, so this is defensive).
var _active_options_write_path: String = ""
var _active_options_present: bool = false

## _active_options_choices — the full choices Array from the current options block.
## Stored so _on_dialogue_option_committed can read each choice's trust_delta.
var _active_options_choices: Array = []

## _active_trust_path — dotted State.data path to increment when the committed
## choice carries a trust_delta. Set from options.trust_path; empty if not declared.
var _active_trust_path: String = ""

## Chain state — set when the matched state's options block carries "chain": true.
## On option commit the runner suppresses dismiss and immediately re-fires
## dialogue_requested for the same NPC so the box transitions to the next state.
var _active_chain: bool = false

## _active_once_state_id — id of a "once": true state that just matched.
## Persisted to State.data.dialogue_states_seen on dismiss / commit so the
## same state cannot match a second time. Empty string when the active state
## is not once-flagged. Must be appended BEFORE chain re-fire so the chain
## walk skips the same state on the second pass.
var _active_once_state_id: String = ""

## Last-request cache — needed to re-fire the request during a chain.
var _last_npc_id: String = ""
var _last_display_name: String = ""

## _character_registry — map of character_id -> display name String.
var _character_registry: Dictionary = {}


func _ready() -> void:
	var sigs = get_node_or_null("/root/Signals")
	if sigs:
		sigs.dialogue_requested.connect(_on_dialogue_requested)
		sigs.dialogue_dismissed.connect(_on_dialogue_dismissed)
		if sigs.has_signal("dialogue_option_committed"):
			sigs.dialogue_option_committed.connect(_on_dialogue_option_committed)
	_load_character_registry()
	_load_all_dialogues()

func _on_dialogue_dismissed() -> void:
	## "once": true bookkeeping runs unconditionally — a once-state with no
	## on_dismiss actions still needs to be recorded as seen, otherwise the
	## next request would re-fire it.
	if _active_once_state_id != "":
		_mark_once_seen(_active_once_state_id)
		_active_once_state_id = ""
	_apply_mutations()


## _apply_mutations — processes the on_dismiss mutation queue. Handles
## "set" (dotted path write), "award_badge", and "unlock_route" actions.
## Clears the queue after processing. Called by both _on_dialogue_dismissed
## and _on_dialogue_option_committed to avoid duplicating the loop.
func _apply_mutations() -> void:
	if _active_state_mutations.is_empty():
		return
	var state_node = get_node_or_null("/root/State")
	if state_node == null:
		return
	var sigs = get_node_or_null("/root/Signals")
	for mut in _active_state_mutations:
		if mut is Dictionary and mut.has("set") and mut.has("value"):
			var path = mut["set"] as String
			var val = mut["value"]
			_set_state_value(state_node.data, path, val)
			if path.begins_with("chapter1."):
				var flag_name = path.substr(9)
				if sigs and sigs.has_signal("chapter1_flag_changed"):
					sigs.chapter1_flag_changed.emit(flag_name, val)
		elif mut is Dictionary and mut.has("award_badge"):
			## Contract: badge_id must already exist in State.data.badges
			## (declared in State.reset_state() / save migration). Unknown
			## ids are rejected with a warning to keep the schema authoritative.
			var badge_id: String = str(mut["award_badge"])
			if state_node.data.has("badges") and state_node.data["badges"] is Dictionary \
					and state_node.data["badges"].has(badge_id):
				state_node.data["badges"][badge_id] = true
				if sigs and sigs.has_signal("badge_awarded"):
					sigs.badge_awarded.emit(badge_id)
			else:
				push_warning("DialogueRunner: award_badge unknown badge_id '%s'; declare it in State.reset_state().badges first" % badge_id)
		elif mut is Dictionary and mut.has("unlock_route"):
			## Same contract as award_badge: route_id must be pre-declared.
			var route_id: String = str(mut["unlock_route"])
			if state_node.data.has("routes_unlocked") and state_node.data["routes_unlocked"] is Dictionary \
					and state_node.data["routes_unlocked"].has(route_id):
				state_node.data["routes_unlocked"][route_id] = true
				if sigs and sigs.has_signal("route_unlocked"):
					sigs.route_unlocked.emit(route_id)
			else:
				push_warning("DialogueRunner: unlock_route unknown route_id '%s'; declare it in State.reset_state().routes_unlocked first" % route_id)
	_active_state_mutations.clear()


## _on_dialogue_option_committed — fired by DialogueBox when the player
## picks an option from an in-dialogue choice list. Writes the picked
## value to State.data at the active write_path, fires the matched
## state's on_dismiss block (so e.g. `set chapter1.foo` actions still
## run alongside the option write), then clears the active-mutation
## queue so the subsequent dialogue_dismissed handler short-circuits.
func _on_dialogue_option_committed(value: Variant) -> void:
	if not _active_options_present:
		## No active options state — defensive no-op.
		return
	var state_node = get_node_or_null("/root/State")
	var sigs = get_node_or_null("/root/Signals")
	if state_node != null and _active_options_write_path != "":
		_set_state_value(state_node.data, _active_options_write_path, value)
		if _active_options_write_path.begins_with("chapter1.") and sigs and sigs.has_signal("chapter1_flag_changed"):
			var flag_name: String = _active_options_write_path.substr(9)
			sigs.chapter1_flag_changed.emit(flag_name, value)

	## Trust delta: if the options block declared a trust_path and the committed
	## choice carries a non-zero trust_delta, add it to the trust counter now —
	## before the chain re-fires — so the next state's trigger sees the updated value.
	if _active_trust_path != "" and state_node != null:
		var delta: int = 0
		for c in _active_options_choices:
			if c is Dictionary and c.get("value", null) == value:
				delta = int(c.get("trust_delta", 0))
				break
		if delta != 0:
			var current_trust: Variant = _resolve_path(_active_trust_path)
			if current_trust is int or current_trust is float:
				var new_trust: int = int(current_trust) + delta
				_set_state_value(state_node.data, _active_trust_path, new_trust)
				if _active_trust_path.begins_with("chapter1.") and sigs and sigs.has_signal("chapter1_flag_changed"):
					sigs.chapter1_flag_changed.emit(_active_trust_path.substr(9), new_trust)

	## Fire the matched state's on_dismiss block (award_badge, unlock_route,
	## set actions). Clears the queue so the subsequent dialogue_dismissed
	## handler short-circuits on empty queue.
	_apply_mutations()
	_active_options_present = false
	_active_options_write_path = ""
	_active_options_choices = []
	_active_trust_path = ""
	## "once": true bookkeeping — MUST happen before the chain re-fire so the
	## same once-state cannot match a second time on the same walk.
	if _active_once_state_id != "":
		_mark_once_seen(_active_once_state_id)
		_active_once_state_id = ""
	## Chain: if the committed state had "chain": true, signal the box to suppress
	## its dismiss, then immediately re-fire dialogue for the same NPC so the
	## next matching state loads without closing the panel.
	if _active_chain:
		_active_chain = false
		var sigs_chain = _signals()
		if sigs_chain and sigs_chain.has_signal("dialogue_chain_start"):
			sigs_chain.dialogue_chain_start.emit()
		_on_dialogue_requested(_last_npc_id, _last_display_name)


## _mark_once_seen — append state_id to State.data.dialogue_states_seen if
## absent. No-op when State autoload is missing (headless --script mode) or
## the field is mistyped. Save migration v12 guarantees the array exists.
func _mark_once_seen(state_id: String) -> void:
	if state_id == "":
		return
	var state_node = get_node_or_null("/root/State")
	if state_node == null:
		return
	if not state_node.data.has("dialogue_states_seen") \
			or not state_node.data["dialogue_states_seen"] is Array:
		state_node.data["dialogue_states_seen"] = []
	var seen: Array = state_node.data["dialogue_states_seen"]
	if not seen.has(state_id):
		seen.append(state_id)


func _set_state_value(data: Dictionary, path: String, value: Variant) -> void:
	var segments = path.split(".")
	var current = data
	for i in range(segments.size() - 1):
		var seg = segments[i]
		if current is Dictionary and current.has(seg) and current[seg] is Dictionary:
			current = current[seg]
		else:
			return
	var last_seg = segments[segments.size() - 1]
	if current is Dictionary and current.has(last_seg):
		current[last_seg] = value


## _signals — safe accessor; returns null in headless --script mode.
func _signals() -> Node:
	return get_node_or_null("/root/Signals")


## _state_data — safe accessor for State.data dict.
func _state_data() -> Dictionary:
	var st = get_node_or_null("/root/State")
	if st:
		return st.data
	return {}


## _load_character_registry — loads res://data/character_registry.json into
## _character_registry. Non-fatal if the file is absent (falls back to empty dict).
func _load_character_registry() -> void:
	var file := FileAccess.open(CHARACTER_REGISTRY_PATH, FileAccess.READ)
	if file == null:
		push_warning("DialogueRunner: character_registry.json not found at " + CHARACTER_REGISTRY_PATH)
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("DialogueRunner: character_registry.json parse failed")
		return
	## Strip internal doc key; copy only id->name pairs.
	for key in parsed:
		if not key.begins_with("_"):
			_character_registry[key] = str(parsed[key])



## _resolve_speaker — returns the display name for a character_id.
## Falls back to `fallback` if the id is not in the registry.
func _resolve_speaker(character_id: String, fallback: String) -> String:
	if _character_registry.has(character_id):
		return _character_registry[character_id]
	push_warning("DialogueRunner: unknown character_id '%s' in multi-speaker line; using fallback '%s'" % [character_id, fallback])
	return fallback


func _load_all_dialogues() -> void:
	## Load every *.json inside DIALOGUES_DIR. The V1.A hint states file is
	## skipped here — loaded explicitly below to be merged into "asia".
	var dir := DirAccess.open(DIALOGUES_DIR)
	if dir == null:
		push_warning("DialogueRunner: dialogues dir not found: " + DIALOGUES_DIR)
		return
	dir.list_dir_begin()
	var fname: String = dir.get_next()
	while fname != "":
		if not dir.current_is_dir() and fname.ends_with(".json"):
			if fname == ASIA_HINT_STATES_FILENAME:
				## Skipped — loaded explicitly to merge into "asia".
				fname = dir.get_next()
				continue
			## Skip non-canonical variants: rewrites, v2 candidates, and the
			## legacy empty dialogues.json. These sit in the dialogues dir as
			## staging / archival files and must not enter the catalogue.
			if fname.contains("_rewrite") or fname.contains("_v2") \
					or fname == "dialogues.json":
				fname = dir.get_next()
				continue
			var npc_id: String = fname.get_basename()
			_load_file(npc_id, DIALOGUES_DIR + fname)
		fname = dir.get_next()
	dir.list_dir_end()

	## Chapter 1 Phase A.3 — merge V1.A Asia hint states into the "asia"
	## catalogue entry. The merge preserves asia.json's first-meeting states
	## (gated met_asia==false, which carry the on_dismiss flag-flip) at the
	## top of the priority list. V1.A's repeatable progression states append
	## after them. Idle_flavor stays asia.json's (V1.A declares none).
	_merge_asia_hint_states()


func _merge_asia_hint_states() -> void:
	var file := FileAccess.open(ASIA_HINT_STATES_PATH, FileAccess.READ)
	if file == null:
		push_warning("DialogueRunner: V1.A Asia hint states not found at " + ASIA_HINT_STATES_PATH)
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		push_error("DialogueRunner: V1.A Asia hint states JSON parse failed")
		return

	var v1a_states: Array = parsed.get("states", [])
	if not _catalogue.has("asia"):
		## No asia.json loaded yet — install V1.A states standalone.
		_catalogue["asia"] = {
			"version": 1,
			"npc_id": "asia",
			"states": v1a_states.duplicate(),
			"idle_flavor": [],
		}

		return

	var asia_entry: Dictionary = _catalogue["asia"]
	var existing_states: Array = asia_entry.get("states", [])
	## Append V1.A states after asia.json's so met_asia==false first-meeting
	## states keep their priority. The runner picks first-match in order.
	var merged: Array = existing_states.duplicate()
	for s in v1a_states:
		merged.append(s)
	asia_entry["states"] = merged
	_catalogue["asia"] = asia_entry



func _load_file(npc_id: String, path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_warning("DialogueRunner: cannot open " + path)
		return
	var text: String = file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if parsed == null:
		push_error("DialogueRunner: JSON parse failed for " + path)
		return
	_catalogue[npc_id] = parsed



func _on_dialogue_requested(npc_id: String, display_name: String) -> void:
	## Cache for chain: if this state has "chain":true options, the runner
	## will re-fire dialogue_requested for the same NPC after the commit.
	_last_npc_id = npc_id
	_last_display_name = display_name
	if not _catalogue.has(npc_id):
		push_warning("DialogueRunner: no dialogue data for npc_id='%s'" % npc_id)
		var sigs_fb = _signals()
		if sigs_fb:
			sigs_fb.dialogue_line_ready.emit(display_name, npc_id, [FALLBACK_LINE])
		return

	var data: Dictionary = _catalogue[npc_id]
	var speaker: String = display_name

	## Resolve the persistent seen-states array once per walk so the loop
	## can short-circuit any state already fired with "once": true.
	var seen_states: Array = []
	var state_node_for_seen = get_node_or_null("/root/State")
	if state_node_for_seen != null \
			and state_node_for_seen.data.has("dialogue_states_seen") \
			and state_node_for_seen.data["dialogue_states_seen"] is Array:
		seen_states = state_node_for_seen.data["dialogue_states_seen"]

	## Try each state entry in order.
	var states: Array = data.get("states", [])
	for entry in states:
		var entry_id: String = str(entry.get("id", ""))
		## "once": true skip — a state that has already fired is invisible to
		## the runner so the loop falls through to the next-matching state
		## (and ultimately idle_flavor if nothing else matches).
		if bool(entry.get("once", false)) and entry_id != "" and seen_states.has(entry_id):
			continue
		var trigger: String = entry.get("trigger", "")
		if _evaluate_trigger(trigger):
			var raw_mutations: Array = entry.get("on_dismiss", [])
			_active_state_mutations = raw_mutations.duplicate(true)
			_active_once_state_id = entry_id if bool(entry.get("once", false)) else ""
			var lines: Array = _extract_lines(entry)
			var state_speaker_id: String = str(entry.get("speaker", ""))
			var emit_speaker: String = speaker
			var emit_npc_id: String = npc_id
			if state_speaker_id != "":
				emit_speaker = _resolve_speaker(state_speaker_id, speaker)
				emit_npc_id = state_speaker_id
			var sigs2 = _signals()
			if sigs2:
				sigs2.dialogue_line_ready.emit(emit_speaker, emit_npc_id, lines)
			## Inline-option flow (Chapter 1 Phase B polish). If the state
			## carries an `options` block, emit the choices for the dialogue
			## box to render under the prompt line. The box returns
			## dialogue_option_committed(value) when the player picks.
			_active_options_write_path = ""
			_active_options_present = false
			_active_options_choices = []
			_active_trust_path = ""
			_active_chain = false
			if entry.has("options") and entry["options"] is Dictionary:
				var opts: Dictionary = entry["options"]
				var write_path: String = str(opts.get("write_path", ""))
				var choices: Array = opts.get("choices", [])
				if write_path != "" and choices.size() > 0:
					_active_options_write_path = write_path
					_active_options_present = true
					_active_options_choices = choices
					_active_trust_path = str(opts.get("trust_path", ""))
					## "chain": true — after option commit, runner re-fires the
					## next matching state for this NPC without closing the box.
					_active_chain = opts.get("chain", false)
					if sigs2 and sigs2.has_signal("dialogue_options_ready"):
						sigs2.dialogue_options_ready.emit(write_path, choices)
			## Signal handlers may run synchronously while a chained state is being
			## loaded. Re-assert the matched state's dismiss mutations after the
			## line/options notifications so the state now on screen owns the next
			## dialogue_dismissed event.
			_active_state_mutations = raw_mutations.duplicate(true)
			return

	## Fall back to idle_flavor (random).
	var idle: Array = data.get("idle_flavor", [])
	if idle.size() > 0:
		var chosen = idle[randi() % idle.size()]
		var lines: Array = _extract_lines(chosen) if chosen is Dictionary else [str(chosen)]
		var sigs3 = _signals()
		if sigs3:
			sigs3.dialogue_line_ready.emit(speaker, npc_id, lines)
		return

	## Hard fallback.
	var sigs_hf = _signals()
	if sigs_hf:
		sigs_hf.dialogue_line_ready.emit(speaker, npc_id, [FALLBACK_LINE])


## _extract_lines — handles all dialogue JSON line formats:
##   Simple:        { "line": "Text here." }
##   String array:  { "lines": ["Line one.", "Line two."] }
##   Asia hint:     { "hint": { "neutral": "Text.", ... } }
##   Multi-speaker: { "lines": ["NPC speaks.", {"speaker": "cula", "text": "Cula responds."}, ...] }
##
## Returns the raw lines array so the dialogue box can inspect each entry.
## String entries are spoken by the owning NPC (caller supplies the display name).
## Dict entries with "speaker"/"text" are spoken by the declared character_id
## (resolved to a display name by the dialogue box via resolve_speaker or inline).
func _extract_lines(entry: Dictionary) -> Array:
	if entry.has("lines"):
		var val = entry["lines"]
		if val is Array:
			return val
		elif val is String:
			return [val]
	if entry.has("line"):
		return [entry["line"]]
	if entry.has("hint") and entry["hint"] is Dictionary:
		var hint: Dictionary = entry["hint"]
		## Prefer "neutral", then first available key.
		if hint.has("neutral"):
			return [hint["neutral"]]
		for key in hint:
			return [hint[key]]
	return [FALLBACK_LINE]


## _evaluate_trigger — returns true if the trigger string passes. Supports
## simple OR-of-ANDs expressions:
##   a && b
##   a || b
##   a && b || c && d
## An empty trigger always passes (unconditional match).
func _evaluate_trigger(trigger: String) -> bool:
	if trigger.strip_edges() == "":
		return true
	var groups: Array = trigger.split("||")
	for raw_group in groups:
		if _evaluate_and_group(str(raw_group).strip_edges()):
			return true
	return false


func _evaluate_and_group(group: String) -> bool:
	if group == "":
		push_warning("DialogueRunner: empty OR group in trigger")
		return false
	var clauses: Array = group.split("&&")
	for raw_clause in clauses:
		var clause: String = str(raw_clause).strip_edges()
		if not _evaluate_clause(clause):
			return false
	return true


## _evaluate_clause — evaluates a single clause.
## Supported shapes (in order of detection):
##   "path"           → resolves path, returns truthy
##   "!path"          → resolves path, returns NOT truthy
##   "path == rhs"    → string comparison after _to_compare_str normalisation
##   "path != rhs"    → string comparison, inverted
##   "path >= rhs"    → numeric (int) comparison
##   "path <= rhs"    → numeric (int) comparison
## LHS is a dotted key path into State.data. The bare-truthiness shapes
## were added in Chapter 1 Phase A.3 to support V1.A Asia hint triggers
## ("!chapter1.pig_revealed_crisis", "chapter1.recruited_whimsy && !chapter1.halina_met").
## >= / <= were added in Session 29 for the Halina trust meter tier checks.
func _evaluate_clause(clause: String) -> bool:
	var op: String = ""
	var parts: PackedStringArray
	## >= and <= must be detected before == / != to avoid partial-match confusion.
	if clause.contains(">="):
		op = ">="
		parts = clause.split(">=", false, 1)
	elif clause.contains("<="):
		op = "<="
		parts = clause.split("<=", false, 1)
	elif clause.contains("!="):
		op = "!="
		parts = clause.split("!=", false, 1)
	elif clause.contains("=="):
		op = "=="
		parts = clause.split("==", false, 1)
	else:
		## Bare-truthiness shape: "path" or "!path".
		var negate: bool = clause.begins_with("!")
		var path: String = clause.substr(1).strip_edges() if negate else clause.strip_edges()
		if path == "":
			push_warning("DialogueRunner: empty path in bare-truthiness clause: " + clause)
			return false
		var bare_actual = _resolve_path(path)
		if bare_actual == null:
			push_warning("DialogueRunner: unresolved path '%s' in clause '%s'" % [path, clause])
			return false
		var truthy: bool = _is_truthy(bare_actual)
		return (not truthy) if negate else truthy

	if parts.size() != 2:
		push_warning("DialogueRunner: malformed clause: " + clause)
		return false

	var lhs_path: String = parts[0].strip_edges()
	var rhs_raw: String = parts[1].strip_edges()

	var actual = _resolve_path(lhs_path)
	if actual == null:
		push_warning("DialogueRunner: unresolved path '%s' in clause '%s'" % [lhs_path, clause])
		return false

	## Numeric comparison for >= / <=.
	if op == ">=" or op == "<=":
		var actual_int: int = int(str(actual))
		var expected_int: int = int(rhs_raw.strip_edges())
		if op == ">=":
			return actual_int >= expected_int
		else:
			return actual_int <= expected_int

	## Normalise both sides to string for == / != comparison.
	var actual_str: String = _to_compare_str(actual)
	var expected_str: String = _to_compare_str(rhs_raw)

	if op == "==":
		return actual_str == expected_str
	else:  ## !=
		return actual_str != expected_str


## _is_truthy — bool-ish coercion for bare-truthiness clauses.
##   bool   → itself
##   String → non-empty
##   int    → != 0
##   other  → false (defensive)
func _is_truthy(v: Variant) -> bool:
	if v is bool:
		return v
	if v is String:
		return (v as String).length() > 0
	if v is int:
		return (v as int) != 0
	return false


## _resolve_path — traverses dotted path into State.data.
## Returns null if any segment is missing.
func _resolve_path(path: String) -> Variant:
	var segments: Array = path.split(".")
	var current: Variant = _state_data()
	for seg in segments:
		if current is Dictionary and current.has(seg):
			current = current[seg]
		else:
			return null
	return current


## _to_compare_str — normalises a Variant or string-literal for comparison.
## Strips surrounding quotes if present; lowercases "true"/"false".
func _to_compare_str(v: Variant) -> String:
	var s: String = str(v)
	## Remove surrounding single or double quotes.
	if (s.begins_with('"') and s.ends_with('"')) or \
	   (s.begins_with("'") and s.ends_with("'")):
		s = s.substr(1, s.length() - 2)
	return s.to_lower()
