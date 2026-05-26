extends SceneTree
## test_save_migration_v23_v24.gd — headless migration tests for v23 → v24.
##
## v24 adds chapter1.picked_up_article_8 and chapter1.picked_up_article_10
## (bool, false) — overworld pickup flags for the two new Ch1 Casebook
## judgments. The Casebook conditions in judgments.json key on these flags
## to include home_and_family_ch8 and expression_and_press_ch10 in
## get_collected_judgments().
##
## Per the save-migration test pattern (feedback_pig_swine_save_migration_test_pattern.md),
## T1 asserts SAVE_VERSION >= 24 (NOT == 24) so the test survives future bumps.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v23_v24.gd

const FIXTURE_PATH: String = "res://tests/fixtures/save_v24_from_v23.json"

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v23→v24] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v23→v24] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v23_adds_pickup_flags()
	_test_v23_fixture_adds_pickup_flags()
	_test_v23_preserves_existing_flags()
	_test_idempotency()
	_test_reset_state_declares_fields()
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

## T1: SAVE_VERSION is at least 24.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION >= 24")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 24, "SAVE_VERSION >= 24")
	state_node.free()

## T2: A v23 save gets both pickup flags injected as false.
func _test_v23_adds_pickup_flags() -> void:
	print("[T2] v23 save gets picked_up_article_8 and picked_up_article_10 as false")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"phase2_round_results": [],
			"court_outcome": "",
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 23)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("picked_up_article_8"), "picked_up_article_8 added")
	_assert(ch1["picked_up_article_8"] == false, "picked_up_article_8 is false")
	_assert(ch1.has("picked_up_article_10"), "picked_up_article_10 added")
	_assert(ch1["picked_up_article_10"] == false, "picked_up_article_10 is false")
	save_node.free()

## T3: Fixture-backed migration — the saved v23 fixture gains both flags.
func _test_v23_fixture_adds_pickup_flags() -> void:
	print("[T3] v23 fixture migrates to v24 with both pickup flags")
	var fixture: Dictionary = _load_fixture()
	if fixture.is_empty():
		printerr("  SKIP: fixture file not found at " + FIXTURE_PATH)
		return
	var save_node := _save()
	var raw_data: Dictionary = fixture.get("data", fixture)
	var migrated: Dictionary = save_node.migrate_save(raw_data, fixture.get("version", 23))
	if not migrated.has("chapter1"):
		_assert(false, "migrated data has chapter1")
		save_node.free()
		return
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("picked_up_article_8"), "fixture: picked_up_article_8 added")
	_assert(ch1["picked_up_article_8"] == false, "fixture: picked_up_article_8 is false")
	_assert(ch1.has("picked_up_article_10"), "fixture: picked_up_article_10 added")
	_assert(ch1["picked_up_article_10"] == false, "fixture: picked_up_article_10 is false")
	## Verify pre-existing fields survive the migration intact.
	_assert(ch1.get("phase2_round_results", "missing") is Array, "phase2_round_results preserved")
	_assert(ch1.get("court_outcome", "missing") == "", "court_outcome preserved")
	save_node.free()

## T4: A v23 save that already has the pickup flags set to true keeps them true.
func _test_v23_preserves_existing_flags() -> void:
	print("[T4] existing true pickup flags preserved across migration")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"picked_up_article_8": true,
			"picked_up_article_10": true,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 23)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1["picked_up_article_8"] == true, "picked_up_article_8 true preserved")
	_assert(ch1["picked_up_article_10"] == true, "picked_up_article_10 true preserved")
	save_node.free()

## T5: Running the migration twice is idempotent.
func _test_idempotency() -> void:
	print("[T5] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"court_outcome": "standard",
		},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 23)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 23)
	_assert(second["chapter1"].has("picked_up_article_8"), "still present after double migration")
	_assert(second["chapter1"]["picked_up_article_8"] == false, "still false after double migration")
	_assert(second["chapter1"].has("picked_up_article_10"), "still present after double migration")
	_assert(second["chapter1"]["picked_up_article_10"] == false, "still false after double migration")
	save_node.free()

## T6: reset_state() declares both fields with false defaults.
func _test_reset_state_declares_fields() -> void:
	print("[T6] reset_state declares picked_up_article_8 and picked_up_article_10")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	var ch1: Dictionary = fresh["chapter1"]
	_assert(ch1.has("picked_up_article_8"), "picked_up_article_8 declared in reset_state")
	_assert(ch1["picked_up_article_8"] == false, "picked_up_article_8 default is false")
	_assert(ch1.has("picked_up_article_10"), "picked_up_article_10 declared in reset_state")
	_assert(ch1["picked_up_article_10"] == false, "picked_up_article_10 default is false")
	state_node.free()

## T7: Missing chapter1 dictionary does not crash migration.
func _test_missing_chapter1_handled() -> void:
	print("[T7] missing chapter1 dict does not crash")
	var save_node := _save()
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 23)
	_assert(not migrated.has("chapter1") or
		migrated["chapter1"].get("picked_up_article_8", false) == false,
		"no crash and either chapter1 absent or flags correct")
	save_node.free()
