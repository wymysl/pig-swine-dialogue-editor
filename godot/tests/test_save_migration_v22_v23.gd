extends SceneTree
## test_save_migration_v22_v23.gd — headless migration tests for v22 → v23.
##
## v23 adds chapter1.phase2_round_results (Array) to persist per-citation
## effectiveness results during Phase 2 court rounds. court_outcome is no
## longer written by consume_assembled_packet(); the dispositive outcome is
## computed at end-of-round-3 via _compute_court_outcome().
##
## Per the save-migration test pattern (feedback_pig_swine_save_migration_test_pattern.md),
## T1 asserts SAVE_VERSION >= 23 (NOT == 23) so the test survives future bumps.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v22_v23.gd

const FIXTURE_PATH: String = "res://tests/fixtures/save_v23_from_v22.json"

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v22→v23] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v22→v23] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v22_adds_phase2_round_results()
	_test_v22_fixture_adds_phase2_round_results()
	_test_v22_preserves_existing_array()
	_test_v22_replaces_non_array()
	_test_idempotency()
	_test_reset_state_declares_field()
	_test_missing_chapter1_handled()

func _assert(condition: bool, msg: String) -> void:
	_test_count += 1
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)

func _save() -> Node:
	var script := load("res://scripts/systems/save.gd") as GDScript
	var node := Node.new()
	node.set_script(script)
	return node


func _load_fixture() -> Dictionary:
	var file := FileAccess.open(FIXTURE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		return {}
	return parsed

## T1: State.SAVE_VERSION constant is >= 23.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 23, "SAVE_VERSION >= 23")
	state_node.free()

## T2: A v22 save without phase2_round_results gets it added as [].
func _test_v22_adds_phase2_round_results() -> void:
	print("[T2] v22→v23 adds phase2_round_results")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"court_outcome": "",
			"client_meeting_evidence": "",
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 22)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("phase2_round_results"), "phase2_round_results key exists")
	_assert(ch1["phase2_round_results"] is Array, "phase2_round_results is Array")
	_assert(ch1["phase2_round_results"].size() == 0, "phase2_round_results is empty")
	save_node.free()


## T2b: The checked-in v22 fixture migrates through the same path.
func _test_v22_fixture_adds_phase2_round_results() -> void:
	print("[T2b] v22 fixture migrates")
	var fixture: Dictionary = _load_fixture()
	_assert(not fixture.is_empty(), "fixture loads")
	if fixture.is_empty():
		return
	_assert(int(fixture.get("version", 0)) == 22, "fixture is version 22")
	var save_node := _save()
	var migrated: Dictionary = save_node.migrate_save((fixture["data"] as Dictionary).duplicate(true), int(fixture["version"]))
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("phase2_round_results"), "fixture migration adds phase2_round_results")
	_assert(ch1["phase2_round_results"] is Array, "fixture migration field is Array")
	_assert(ch1["phase2_round_results"].is_empty(), "fixture migration field is empty")
	save_node.free()

## T3: A v22 save that already has phase2_round_results preserves content.
func _test_v22_preserves_existing_array() -> void:
	print("[T3] existing phase2_round_results preserved")
	var save_node := _save()
	var existing_entry: Dictionary = {
		"round": 3,
		"citation_id": "motion_to_set_aside",
		"evidence_id": "renewal_2019_number_twelve",
		"evidence_available": true,
		"effectiveness_bucket": "effective",
		"opponent_move": "procedural_objection_notice_defect",
	}
	var old: Dictionary = {
		"chapter1": {
			"phase2_round_results": [existing_entry],
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 22)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1["phase2_round_results"] is Array, "still an Array")
	_assert(ch1["phase2_round_results"].size() == 1, "entry preserved")
	_assert(ch1["phase2_round_results"][0]["citation_id"] == "motion_to_set_aside",
		"entry content intact")
	save_node.free()

## T4: A v22 save where phase2_round_results is not an Array gets replaced.
func _test_v22_replaces_non_array() -> void:
	print("[T4] non-Array phase2_round_results replaced")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"phase2_round_results": "corrupted",
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 22)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1["phase2_round_results"] is Array, "replaced with Array")
	_assert(ch1["phase2_round_results"].size() == 0, "replaced with empty Array")
	save_node.free()

## T5: Running the migration twice is idempotent.
func _test_idempotency() -> void:
	print("[T5] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"court_outcome": "narrow",
		},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 22)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 22)
	_assert(second["chapter1"]["phase2_round_results"] is Array, "still Array after double migration")
	_assert(second["chapter1"]["phase2_round_results"].size() == 0, "still empty after double migration")
	save_node.free()

## T6: reset_state() declares phase2_round_results with [] default.
func _test_reset_state_declares_field() -> void:
	print("[T6] reset_state declares phase2_round_results")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	var ch1: Dictionary = fresh["chapter1"]
	_assert(ch1.has("phase2_round_results"), "phase2_round_results declared in reset_state")
	_assert(ch1["phase2_round_results"] is Array, "phase2_round_results is Array")
	_assert(ch1["phase2_round_results"].size() == 0, "phase2_round_results default is empty")
	state_node.free()

## T7: Missing chapter1 dictionary does not crash migration.
func _test_missing_chapter1_handled() -> void:
	print("[T7] missing chapter1 dict does not crash")
	var save_node := _save()
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 22)
	_assert(not migrated.has("chapter1") or
		migrated["chapter1"].get("phase2_round_results", []) is Array,
		"no crash and either chapter1 absent or field correct")
	save_node.free()
