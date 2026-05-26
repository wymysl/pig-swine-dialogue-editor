extends SceneTree
## test_save_migration_v24_v25.gd — headless migration tests for v24 → v25.
##
## v25 adds chapter1.client_fee_collected and chapter1.pig_court_win_acknowledged
## (bool, false) — Beat 13 close sequencing flags. The first records Pig's
## Beat-13 acknowledgement of the 5,000 PLN Sikorska fee per story.txt §Beat 13;
## the second sequences the coffee_machine_ch1.json env-beat to fire AFTER
## Pig has spoken. Both unblock promotion of the PENDING Beat-13 drafts that
## had been waiting on the declaration since 2026-05-14 and 2026-05-17.
##
## Per the save-migration test pattern (feedback_pig_swine_save_migration_test_pattern.md),
## T1 asserts SAVE_VERSION >= 25 (NOT == 25) so the test survives future bumps.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v24_v25.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v24→v25] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v24→v25] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v24_adds_beat13_flags()
	_test_v24_preserves_existing_flags()
	_test_idempotency()
	_test_reset_state_declares_fields()
	_test_missing_chapter1_handled()
	_test_chain_from_v1()

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

## T1: SAVE_VERSION is at least 25.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION >= 25")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 25, "SAVE_VERSION >= 25")
	state_node.free()

## T2: A v24 save gets both Beat-13 flags injected as false.
func _test_v24_adds_beat13_flags() -> void:
	print("[T2] v24 save gets client_fee_collected and pig_court_win_acknowledged as false")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"phase2_round_results": [],
			"court_outcome": "",
			"picked_up_article_8": false,
			"picked_up_article_10": false,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 24)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("client_fee_collected"), "client_fee_collected added")
	_assert(ch1["client_fee_collected"] == false, "client_fee_collected is false")
	_assert(ch1.has("pig_court_win_acknowledged"), "pig_court_win_acknowledged added")
	_assert(ch1["pig_court_win_acknowledged"] == false, "pig_court_win_acknowledged is false")
	## Pre-existing fields preserved.
	_assert(ch1.get("picked_up_article_8", "missing") == false, "picked_up_article_8 preserved")
	_assert(ch1.get("court_outcome", "missing") == "", "court_outcome preserved")
	save_node.free()

## T3: A v24 save that already has the Beat-13 flags set to true keeps them true.
func _test_v24_preserves_existing_flags() -> void:
	print("[T3] existing true Beat-13 flags preserved across migration")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"client_fee_collected": true,
			"pig_court_win_acknowledged": true,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 24)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1["client_fee_collected"] == true, "client_fee_collected true preserved")
	_assert(ch1["pig_court_win_acknowledged"] == true, "pig_court_win_acknowledged true preserved")
	save_node.free()

## T4: Running the migration twice is idempotent.
func _test_idempotency() -> void:
	print("[T4] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"court_outcome": "standard",
		},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 24)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 24)
	_assert(second["chapter1"].has("client_fee_collected"), "still present after double migration")
	_assert(second["chapter1"]["client_fee_collected"] == false, "still false after double migration")
	_assert(second["chapter1"].has("pig_court_win_acknowledged"), "still present after double migration")
	_assert(second["chapter1"]["pig_court_win_acknowledged"] == false, "still false after double migration")
	save_node.free()

## T5: reset_state() declares both fields with false defaults.
func _test_reset_state_declares_fields() -> void:
	print("[T5] reset_state declares client_fee_collected and pig_court_win_acknowledged")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	var ch1: Dictionary = fresh["chapter1"]
	_assert(ch1.has("client_fee_collected"), "client_fee_collected declared in reset_state")
	_assert(ch1["client_fee_collected"] == false, "client_fee_collected default is false")
	_assert(ch1.has("pig_court_win_acknowledged"), "pig_court_win_acknowledged declared in reset_state")
	_assert(ch1["pig_court_win_acknowledged"] == false, "pig_court_win_acknowledged default is false")
	state_node.free()

## T6: Missing chapter1 dictionary does not crash migration.
func _test_missing_chapter1_handled() -> void:
	print("[T6] missing chapter1 dict does not crash")
	var save_node := _save()
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 24)
	_assert(not migrated.has("chapter1") or
		migrated["chapter1"].get("client_fee_collected", false) == false,
		"no crash and either chapter1 absent or flags correct")
	save_node.free()

## T7: Full v1→v25 migration chain regression — picking a v1 baseline payload
## and walking it through every step lands client_fee_collected /
## pig_court_win_acknowledged as false at the end.
func _test_chain_from_v1() -> void:
	print("[T7] v1 → v25 chain regression")
	var save_node := _save()
	var v1_payload: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save_node.migrate_save(v1_payload, 1)
	_assert(migrated.has("chapter1"), "chain: chapter1 added")
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("client_fee_collected"), "chain: client_fee_collected added")
	_assert(ch1["client_fee_collected"] == false, "chain: client_fee_collected is false")
	_assert(ch1.has("pig_court_win_acknowledged"), "chain: pig_court_win_acknowledged added")
	_assert(ch1["pig_court_win_acknowledged"] == false, "chain: pig_court_win_acknowledged is false")
	_assert(ch1.has("beat13_complete"), "chain: prior Beat-13 flag still present")
	_assert(ch1.has("picked_up_article_8"), "chain: v24 flag still present")
	save_node.free()
