extends SceneTree
## test_chapter1_v17_flag_coverage.gd — registry cross-reference for SAVE_VERSION 17.
##
## Asserts that chapter1.json new_state_flags and State.reset_state().chapter1
## agree on the seven flags added in bc45550 (SAVE_VERSION 17 — player-driven
## argument scaffolding per PROPOSAL_player_driven_argument.md §3).
##
## Seven v17 flags:
##   binder_read_envelope     bool  default false
##   binder_read_renewal      bool  default false
##   binder_read_renumbering  bool  default false
##   proposed_frame           string enum  default ""
##   whimsy_co_counsel_posture string enum  default ""
##   judicial_patience        int   default 5
##   witness_cooperation      int   default 0
##
## Run: godot --headless --path godot --script tests/test_chapter1_v17_flag_coverage.gd

const CHAPTER1_PATH: String = "res://data/chapters/chapter1.json"
const FRAMES_PATH: String = "res://data/argument_frames_ch1.json"
const WHIMSY_DRAFT_PATH: String = "res://data/_drafts/whimsy_player_driven_2026-05-15.json"

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v17Coverage] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v17Coverage] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version()
	_test_registry_runtime_cross_reference()
	_test_enum_values_match_data_files()
	_test_int_defaults_match_runtime()
	_test_bool_defaults_are_false()
	_test_v15_v16_regression()
	_test_bonus_evidence_enum_regression()

func _assert(condition: bool, msg: String) -> void:
	_test_count += 1
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)

## Load chapter1.json and return the parsed Dictionary.  Returns {} on error.
func _load_chapter1() -> Dictionary:
	var file := FileAccess.open(CHAPTER1_PATH, FileAccess.READ)
	if file == null:
		printerr("  ERROR: cannot open %s" % CHAPTER1_PATH)
		_fail_count += 1
		_test_count += 1
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		printerr("  ERROR: JSON.parse_string failed for %s" % CHAPTER1_PATH)
		_fail_count += 1
		_test_count += 1
		return {}
	return parsed as Dictionary

## Load any JSON file. Returns {} on error; caller checks emptiness.
func _load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed as Dictionary

## Instantiate a fresh State node from the script (no autoload dependency).
func _state_reset() -> Dictionary:
	var script := load("res://scripts/autoload/state.gd") as GDScript
	var node := Node.new()
	node.set_script(script)
	var fresh: Dictionary = node.reset_state()
	node.free()
	return fresh

## Build a Dictionary from new_state_flags keyed by the bare flag name
## (strip "chapter1." prefix; skip non-chapter1 keys).
func _registry_chapter1_flags(chapter_data: Dictionary) -> Dictionary:
	var result: Dictionary = {}
	var flags: Array = chapter_data.get("new_state_flags", [])
	for entry in flags:
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var full_key: String = str(entry.get("key", ""))
		if full_key.begins_with("chapter1."):
			var short: String = full_key.substr(len("chapter1."))
			result[short] = entry
	return result

## ── T1 ── SAVE_VERSION >= 17
func _test_save_version() -> void:
	print("[T1] SAVE_VERSION >= 17")
	var script := load("res://scripts/autoload/state.gd") as GDScript
	var node := Node.new()
	node.set_script(script)
	_assert(node.SAVE_VERSION >= 17, "State.SAVE_VERSION >= 17")
	node.free()

## ── T2 ── Every key in reset_state().chapter1 appears in new_state_flags.
##         Named assertions for the seven v17 keys.
##         Fails-soft: reports ALL missing keys, not just first.
func _test_registry_runtime_cross_reference() -> void:
	print("[T2] registry ↔ runtime cross-reference")
	var chapter_data := _load_chapter1()
	if chapter_data.is_empty():
		return
	var registry := _registry_chapter1_flags(chapter_data)
	var runtime := _state_reset()
	var ch1: Dictionary = runtime.get("chapter1", {})

	## Explicit named assertions for the seven v17 keys first.
	var v17_keys: Array = [
		"binder_read_envelope",
		"binder_read_renewal",
		"binder_read_renumbering",
		"proposed_frame",
		"whimsy_co_counsel_posture",
		"judicial_patience",
		"witness_cooperation",
	]
	for k in v17_keys:
		_assert(registry.has(k), "v17 key '%s' declared in new_state_flags" % k)
		_assert(ch1.has(k), "v17 key '%s' present in reset_state().chapter1" % k)

	## Full cross-reference: every runtime key must have a registry entry.
	## Fail-soft: collect all missing names and report them individually.
	for runtime_key in ch1.keys():
		if not registry.has(runtime_key):
			_assert(false, "runtime key 'chapter1.%s' not declared in new_state_flags (pre-existing drift)" % runtime_key)

## ── T3 ── Enum-typed flags have _enum blocks whose values match data files.
func _test_enum_values_match_data_files() -> void:
	print("[T3] enum values cross-referenced against data files")
	var chapter_data := _load_chapter1()
	if chapter_data.is_empty():
		return
	var registry := _registry_chapter1_flags(chapter_data)

	## proposed_frame — must include "" + all frame ids from argument_frames_ch1.json.
	if registry.has("proposed_frame"):
		var pf_entry: Dictionary = registry["proposed_frame"]
		var declared_enum: Array = pf_entry.get("_enum", [])
		_assert(declared_enum.size() > 0, "proposed_frame has _enum block")
		_assert(declared_enum[0] == "", "proposed_frame._enum[0] is empty string (unset value)")

		var frames_data := _load_json(FRAMES_PATH)
		if frames_data.is_empty():
			printerr("  WARN: cannot load %s — skipping proposed_frame data cross-check" % FRAMES_PATH)
		else:
			var frame_ids: Array = frames_data.get("frames", {}).keys()
			for fid in frame_ids:
				_assert(declared_enum.has(fid),
					"proposed_frame._enum contains frame id '%s' from argument_frames_ch1.json" % fid)
			## Reverse: every non-empty declared value maps to a real frame id.
			for val in declared_enum:
				if val == "":
					continue
				_assert(frame_ids.has(val),
					"proposed_frame._enum value '%s' maps to a frame in argument_frames_ch1.json" % val)
	else:
		_assert(false, "proposed_frame found in registry (prerequisite for T3)")

	## whimsy_co_counsel_posture — must include "" + 3 posture values from draft.
	if registry.has("whimsy_co_counsel_posture"):
		var wcp_entry: Dictionary = registry["whimsy_co_counsel_posture"]
		var declared_enum: Array = wcp_entry.get("_enum", [])
		_assert(declared_enum.size() > 0, "whimsy_co_counsel_posture has _enum block")
		_assert(declared_enum[0] == "", "whimsy_co_counsel_posture._enum[0] is empty string")

		## Cross-check against the three canonical posture values from the draft.
		## The draft is not loaded by the runtime, so we hard-code the canonical set
		## (sourced from whimsy_player_driven_2026-05-15.json options.choices).
		var canonical_postures: Array = ["procedural_throat", "merits_pivot", "open_register"]
		for posture in canonical_postures:
			_assert(declared_enum.has(posture),
				"whimsy_co_counsel_posture._enum contains '%s'" % posture)
		## Reverse: no undeclared postures in enum beyond the canonical three.
		for val in declared_enum:
			if val == "":
				continue
			_assert(canonical_postures.has(val),
				"whimsy_co_counsel_posture._enum value '%s' is in canonical posture set" % val)
	else:
		_assert(false, "whimsy_co_counsel_posture found in registry (prerequisite for T3)")

## ── T4 ── Int-typed flags: registry _default matches State.reset_state() value.
func _test_int_defaults_match_runtime() -> void:
	print("[T4] int-typed flag defaults match runtime")
	var chapter_data := _load_chapter1()
	if chapter_data.is_empty():
		return
	var registry := _registry_chapter1_flags(chapter_data)
	var ch1: Dictionary = _state_reset().get("chapter1", {})

	for short_key in registry.keys():
		var entry: Dictionary = registry[short_key]
		if entry.get("_type", "") != "int":
			continue
		var reg_default: Variant = entry.get("default", null)
		var runtime_val: Variant = ch1.get(short_key, null)
		_assert(typeof(runtime_val) == TYPE_INT,
			"'chapter1.%s' is TYPE_INT in reset_state" % short_key)
		_assert(reg_default == runtime_val,
			"'chapter1.%s' registry default (%s) == runtime default (%s)" % [short_key, reg_default, runtime_val])

## ── T5 ── Bool-typed flags: registry _default is false (project convention).
##         A bool defaulting true must be confirmed by a human.
func _test_bool_defaults_are_false() -> void:
	print("[T5] bool-typed flag defaults are false")
	var chapter_data := _load_chapter1()
	if chapter_data.is_empty():
		return
	var registry := _registry_chapter1_flags(chapter_data)

	var v17_bools: Array = ["binder_read_envelope", "binder_read_renewal", "binder_read_renumbering"]
	for k in v17_bools:
		if registry.has(k):
			_assert(registry[k].get("default", null) == false,
				"'chapter1.%s' registry default is false" % k)
		else:
			_assert(false, "'chapter1.%s' missing from registry (bool default check skipped)" % k)

	## Broader pass: any bool-typed entry defaulting true is flagged explicitly.
	for short_key in registry.keys():
		var entry: Dictionary = registry[short_key]
		var reg_type: String = str(entry.get("_type", ""))
		var reg_default: Variant = entry.get("default", null)
		## Detect bool entries by _type OR by literal false default without _type set.
		var is_bool_entry: bool = (reg_type == "bool") or (reg_type == "" and reg_default == false)
		if is_bool_entry and reg_default != false:
			_assert(false,
				"'chapter1.%s' bool flag defaults true — requires human confirmation" % short_key)

## ── T6 ── v15/v16 regression: state_choice and murrow_choice still declared.
func _test_v15_v16_regression() -> void:
	print("[T6] v15/v16 flag regression")
	var chapter_data := _load_chapter1()
	if chapter_data.is_empty():
		return
	var registry := _registry_chapter1_flags(chapter_data)

	## state_choice — declared in Session 39 (354e50b).
	_assert(registry.has("state_choice"),
		"chapter1.state_choice still declared in new_state_flags (v15 regression)")
	## murrow_choice — in state.gd reset_state() but NOT yet in new_state_flags.
	## This assertion is intentionally fail-soft: it records pre-existing drift.
	## If murrow_choice IS registered here, that means a follow-on catch-up landed;
	## the test still passes (assert that it's present OR report missing clearly).
	if registry.has("murrow_choice"):
		_assert(true, "chapter1.murrow_choice declared in new_state_flags (v16 catch-up landed)")
	else:
		## Fail loudly so Agent 9 / morning audit catches this.
		_assert(false,
			"chapter1.murrow_choice MISSING from new_state_flags — pre-existing drift (v16 catch-up pending)")

## ── T7 ── bonus_evidence_collected enum regression: all four values still declared.
func _test_bonus_evidence_enum_regression() -> void:
	print("[T7] bonus_evidence_collected enum regression")
	var chapter_data := _load_chapter1()
	if chapter_data.is_empty():
		return
	var registry := _registry_chapter1_flags(chapter_data)

	if not registry.has("bonus_evidence_collected"):
		_assert(false, "chapter1.bonus_evidence_collected missing from registry")
		return

	var entry: Dictionary = registry["bonus_evidence_collected"]
	var declared_enum: Array = entry.get("_enum", [])

	var expected: Array = [
		"wojcik_witness_statement",
		"return_to_sender_slip",
		"lease_1962_inheritance_1987",
		"landlord_contact",
	]
	for val in expected:
		_assert(declared_enum.has(val),
			"bonus_evidence_collected._enum contains '%s'" % val)
