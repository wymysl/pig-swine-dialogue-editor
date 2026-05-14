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
## _known_speaker_ids — populated from character_registry.json. Used by
## _validate_catalogue to flag unregistered speakers as load-time errors.
var _known_speaker_ids: Dictionary = {}

## ActiveStateContext — the implicit state machine that lives between a
## dialogue_requested and the next dismiss/commit pair, extracted from
## what used to be nine separately-managed instance variables. One struct,
## one lifecycle: `reset_for_walk()` at the top of every _on_dialogue_requested,
## then the matched state populates its fields, then dismiss/commit consume them.
##
## Lifecycle invariants (preserved verbatim from the prior implementation):
##   • `last_npc_id` / `last_display_name` are set BEFORE reset_for_walk so the
##     chain re-fire can read them on commit.
##   • `once_state_id` must be appended to State.data.dialogue_states_seen
##     BEFORE the chain re-fire so the chain walk doesn't re-match the same
##     once-state on its second pass.
##   • `mutations` must be re-asserted (deep-duplicated) AFTER firing the
##     dialogue_line_ready / dialogue_options_ready signals — handlers may
##     run synchronously while a chained state is being loaded, and the
##     state now on screen must own the next dismiss event.
class ActiveStateContext:
	var mutations: Array = []
	var options_present: bool = false
	var options_write_path: String = ""
	## options.choices array — kept so _on_dialogue_option_committed can read
	## the picked choice's trust_delta on commit.
	var options_choices: Array = []
	## State.data path the picked choice's trust_delta is added to. Empty
	## string when the active state doesn't declare a trust meter.
	var trust_path: String = ""
	## True when the matched state's options block declared `chain: true`.
	## Triggers the post-commit dialogue_requested re-fire.
	var chain: bool = false
	## State id of a `once: true` state that just matched. Appended to
	## State.data.dialogue_states_seen on dismiss/commit.
	var once_state_id: String = ""
	## Last request cache — needed so the chain re-fire after a commit can
	## re-call _on_dialogue_requested with the same npc/display arguments.
	var last_npc_id: String = ""
	var last_display_name: String = ""

	## reset_for_walk — clear per-walk state at the top of _on_dialogue_requested.
	## last_npc_id / last_display_name are set BEFORE this call so the chain
	## re-fire can read them; this only resets the fields that the new matched
	## state will (re)populate.
	func reset_for_walk() -> void:
		mutations = []
		options_present = false
		options_write_path = ""
		options_choices = []
		trust_path = ""
		chain = false
		once_state_id = ""

var _ctx: ActiveStateContext = ActiveStateContext.new()

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
	if _ctx.once_state_id != "":
		_mark_once_seen(_ctx.once_state_id)
		_ctx.once_state_id = ""
	_apply_mutations()


## _apply_mutations — processes the on_dismiss mutation queue. Handles
## "set" (dotted path write), "award_badge", and "unlock_route" actions.
## Clears the queue after processing. Called by both _on_dialogue_dismissed
## and _on_dialogue_option_committed to avoid duplicating the loop.
func _apply_mutations() -> void:
	if _ctx.mutations.is_empty():
		return
	var state_node = get_node_or_null("/root/State")
	if state_node == null:
		return
	var sigs = get_node_or_null("/root/Signals")
	for mut in _ctx.mutations:
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
	_ctx.mutations.clear()


## _on_dialogue_option_committed — fired by DialogueBox when the player
## picks an option from an in-dialogue choice list. Writes the picked
## value to State.data at the active write_path, fires the matched
## state's on_dismiss block (so e.g. `set chapter1.foo` actions still
## run alongside the option write), then clears the active-mutation
## queue so the subsequent dialogue_dismissed handler short-circuits.
func _on_dialogue_option_committed(value: Variant) -> void:
	if not _ctx.options_present:
		## No active options state — defensive no-op.
		return
	var state_node = get_node_or_null("/root/State")
	var sigs = get_node_or_null("/root/Signals")
	if state_node != null and _ctx.options_write_path != "":
		_set_state_value(state_node.data, _ctx.options_write_path, value)
		if _ctx.options_write_path.begins_with("chapter1.") and sigs and sigs.has_signal("chapter1_flag_changed"):
			var flag_name: String = _ctx.options_write_path.substr(9)
			sigs.chapter1_flag_changed.emit(flag_name, value)

	## Trust delta: if the options block declared a trust_path and the committed
	## choice carries a non-zero trust_delta, add it to the trust counter now —
	## before the chain re-fires — so the next state's trigger sees the updated value.
	if _ctx.trust_path != "" and state_node != null:
		var delta: int = 0
		for c in _ctx.options_choices:
			if c is Dictionary and c.get("value", null) == value:
				delta = int(c.get("trust_delta", 0))
				break
		if delta != 0:
			var current_trust: Variant = _resolve_path(_ctx.trust_path)
			if current_trust is int or current_trust is float:
				var new_trust: int = int(current_trust) + delta
				_set_state_value(state_node.data, _ctx.trust_path, new_trust)
				if _ctx.trust_path.begins_with("chapter1.") and sigs and sigs.has_signal("chapter1_flag_changed"):
					sigs.chapter1_flag_changed.emit(_ctx.trust_path.substr(9), new_trust)

	## Fire the matched state's on_dismiss block (award_badge, unlock_route,
	## set actions). Clears the queue so the subsequent dialogue_dismissed
	## handler short-circuits on empty queue.
	_apply_mutations()
	## Clear options-scoped fields. Don't touch last_npc_id / last_display_name —
	## the chain re-fire below reads them.
	_ctx.options_present = false
	_ctx.options_write_path = ""
	_ctx.options_choices = []
	_ctx.trust_path = ""
	## "once": true bookkeeping — MUST happen before the chain re-fire so the
	## same once-state cannot match a second time on the same walk.
	if _ctx.once_state_id != "":
		_mark_once_seen(_ctx.once_state_id)
		_ctx.once_state_id = ""
	## Chain: if the committed state had "chain": true, signal the box to suppress
	## its dismiss, then immediately re-fire dialogue for the same NPC so the
	## next matching state loads without closing the panel.
	if _ctx.chain:
		_ctx.chain = false
		var sigs_chain = _signals()
		if sigs_chain and sigs_chain.has_signal("dialogue_chain_start"):
			sigs_chain.dialogue_chain_start.emit()
		_on_dialogue_requested(_ctx.last_npc_id, _ctx.last_display_name)


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
			_known_speaker_ids[key] = true
	## Portrait aliases are valid speaker ids too (registry uses them to share
	## a portrait across two display names; both forms must validate).
	if parsed.has("_portrait_aliases") and parsed["_portrait_aliases"] is Dictionary:
		for alias_id in parsed["_portrait_aliases"]:
			_known_speaker_ids[str(alias_id)] = true



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

	## Schema validation pass — see godot/data/dialogues/_schema.md §Validation.
	## Fails loud with push_error on duplicate state ids, unknown speaker ids,
	## unresolved flag paths, and content-shape violations.
	_validate_catalogue()


## _validate_catalogue — boot-time integrity check across the merged catalogue.
## Replaces the silent-warning-and-continue model with loud push_error so that
## typos, schema drift, and once:true collisions surface before they ship.
## Contract documented in godot/data/dialogues/_schema.md §Validation.
func _validate_catalogue() -> void:
	var declared_paths: Dictionary = {}
	var state_node = get_node_or_null("/root/State")
	if state_node != null:
		_flatten_state_paths(state_node.reset_state(), "", declared_paths)
	else:
		push_warning("DialogueRunner: State autoload missing during validation; flag-path resolution skipped.")

	var seen_ids: Dictionary = {}  ## state_id -> npc_id (first file that declared it)
	var path_re := RegEx.new()
	## Matches dotted identifiers in trigger strings (chapter1.met_pig etc.).
	## Quoted RHS values (e.g. 'over_caffeinated') contain no dots and so are
	## not matched.
	path_re.compile("\\b(\\w+(?:\\.\\w+)+)")

	for npc_id in _catalogue:
		var entry = _catalogue[npc_id]
		if not entry is Dictionary:
			continue
		var states: Array = entry.get("states", [])
		for st in states:
			if not st is Dictionary:
				continue
			_validate_state(st, npc_id, seen_ids, declared_paths, path_re)


func _validate_state(st: Dictionary, npc_id: String, seen_ids: Dictionary, declared_paths: Dictionary, path_re: RegEx) -> void:
	var sid: String = str(st.get("id", ""))
	## State-id uniqueness. Global across all dialogue files: dialogue_states_seen
	## is a flat Array, so a colliding id makes once:true cross-file ghost.
	if sid == "":
		push_error("DialogueRunner: state in npc '%s' has no id." % npc_id)
	elif seen_ids.has(sid):
		push_error("DialogueRunner: duplicate state id '%s' (in '%s' and '%s'). State ids must be globally unique across all dialogue files." % [sid, seen_ids[sid], npc_id])
	else:
		seen_ids[sid] = npc_id

	## Speaker references — state-level + per-line objects.
	var st_speaker: String = str(st.get("speaker", ""))
	if st_speaker != "" and not _known_speaker_ids.has(st_speaker):
		push_error("DialogueRunner: unknown speaker id '%s' in state '%s' (npc '%s'). Add it to character_registry.json or fix the typo." % [st_speaker, sid, npc_id])
	if st.has("lines") and st["lines"] is Array:
		for ln in st["lines"]:
			if ln is Dictionary and ln.has("speaker"):
				var ls: String = str(ln["speaker"])
				if ls != "" and not _known_speaker_ids.has(ls):
					push_error("DialogueRunner: unknown speaker id '%s' in line of state '%s' (npc '%s')." % [ls, sid, npc_id])

	## Trigger paths.
	var trig: String = str(st.get("trigger", ""))
	if trig != "" and not declared_paths.is_empty():
		for m in path_re.search_all(trig):
			var p: String = m.get_string(1)
			if not declared_paths.has(p):
				push_error("DialogueRunner: unresolved flag path '%s' in trigger of state '%s' (npc '%s'). Declare it in State.reset_state() or fix the typo." % [p, sid, npc_id])

	## on_dismiss.set paths.
	if st.has("on_dismiss") and st["on_dismiss"] is Array:
		for mut in st["on_dismiss"]:
			if mut is Dictionary and mut.has("set") and not declared_paths.is_empty():
				var sp: String = str(mut["set"])
				if not declared_paths.has(sp):
					push_error("DialogueRunner: unresolved on_dismiss.set path '%s' in state '%s' (npc '%s')." % [sp, sid, npc_id])

	## options paths.
	if st.has("options") and st["options"] is Dictionary:
		var opts: Dictionary = st["options"]
		var wp: String = str(opts.get("write_path", ""))
		if wp != "" and not declared_paths.is_empty() and not declared_paths.has(wp):
			push_error("DialogueRunner: unresolved options.write_path '%s' in state '%s' (npc '%s')." % [wp, sid, npc_id])
		var tp: String = str(opts.get("trust_path", ""))
		if tp != "" and not declared_paths.is_empty() and not declared_paths.has(tp):
			push_error("DialogueRunner: unresolved options.trust_path '%s' in state '%s' (npc '%s')." % [tp, sid, npc_id])

	## Content shape — must have lines (>=1 entry), OR options.choices (>=1),
	## OR silent:true. Singular `line: "x"` is no longer accepted; the Phase 2
	## migration rewrote every singular line to a one-element lines array.
	var has_lines: bool = st.has("lines") and st["lines"] is Array and (st["lines"] as Array).size() > 0
	if st.has("line"):
		push_error("DialogueRunner: state '%s' (npc '%s') uses the legacy `line: \"x\"` field. Convert to `lines: [\"x\"]` — see _schema.md." % [sid, npc_id])
	var has_opts_choices: bool = false
	if st.has("options") and st["options"] is Dictionary:
		var choices = (st["options"] as Dictionary).get("choices", [])
		has_opts_choices = choices is Array and (choices as Array).size() > 0
	var is_silent: bool = bool(st.get("silent", false))
	if not (has_lines or has_opts_choices or is_silent):
		push_error("DialogueRunner: state '%s' (npc '%s') has no lines, no options.choices, and is not marked silent:true. Add content or set silent:true to declare deliberate silence." % [sid, npc_id])


## _flatten_state_paths — walk State.reset_state()'s nested Dictionary into a
## flat set of dotted paths. Used by _validate_catalogue to confirm every
## flag path referenced by dialogue resolves to a real slot.
func _flatten_state_paths(d: Variant, prefix: String, out: Dictionary) -> void:
	if not d is Dictionary:
		return
	for k in d:
		var key_s: String = str(k)
		var sub: String = key_s if prefix == "" else (prefix + "." + key_s)
		out[sub] = true
		var v = d[k]
		if v is Dictionary:
			_flatten_state_paths(v, sub, out)


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
	## Set BEFORE reset_for_walk so the chain re-fire can read them.
	_ctx.last_npc_id = npc_id
	_ctx.last_display_name = display_name
	_ctx.reset_for_walk()
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
			_ctx.mutations = raw_mutations.duplicate(true)
			_ctx.once_state_id = entry_id if bool(entry.get("once", false)) else ""
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
			if entry.has("options") and entry["options"] is Dictionary:
				var opts: Dictionary = entry["options"]
				var write_path: String = str(opts.get("write_path", ""))
				var choices: Array = opts.get("choices", [])
				if write_path != "" and choices.size() > 0:
					_ctx.options_write_path = write_path
					_ctx.options_present = true
					_ctx.options_choices = choices
					_ctx.trust_path = str(opts.get("trust_path", ""))
					## "chain": true — after option commit, runner re-fires the
					## next matching state for this NPC without closing the box.
					_ctx.chain = opts.get("chain", false)
					if sigs2 and sigs2.has_signal("dialogue_options_ready"):
						sigs2.dialogue_options_ready.emit(write_path, choices)
			## Signal handlers may run synchronously while a chained state is being
			## loaded. Re-assert the matched state's dismiss mutations after the
			## line/options notifications so the state now on screen owns the next
			## dialogue_dismissed event.
			_ctx.mutations = raw_mutations.duplicate(true)
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


## _extract_lines — pulls the lines array from a matched state or idle entry.
##
## Canonical shape (per godot/data/dialogues/_schema.md):
##   { "lines": [ "string", { "speaker": "<id>", "text": "..." }, ... ] }
##
## String entries are spoken by the state default speaker (state-level
## `speaker` field, else the npc's display_name argument). Dict entries
## with "speaker"/"text" are spoken by the declared character_id.
##
## A state may also declare `silent: true` to deliberately fire without
## emitting any visible line (used as a placeholder for not-yet-authored
## content; the runner emits [FALLBACK_LINE] so the dialogue box renders
## the ellipsis filler). States with neither `lines` nor `silent: true`
## are rejected at boot by _validate_catalogue and never reach this code.
func _extract_lines(entry: Dictionary) -> Array:
	if entry.has("lines"):
		var val = entry["lines"]
		if val is Array:
			return val
		elif val is String:
			return [val]
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
