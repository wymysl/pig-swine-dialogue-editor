extends SceneTree
## test_save_migration_v12_v13.gd — headless migration tests for v12 → v13.
## v13 declares two flags referenced by dialogue JSON without a State slot:
##   chapter1.won_court (bool, default false)
##     Asia hint states 10/11 in asia_hint_states_ch1.json — runner's
##     bare-truthiness clause `!chapter1.won_court` resolved to null on the
##     missing slot and those states could never match.
##   chapter1.coffee_retry_decision (string, default "")
##     barista.json coffee_retry_prompt options write_path — runner's
##     _set_state_value silently no-opped on the missing slot.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v12_v13.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v12→v13] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v12→v13] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v12_to_v13_adds_won_court()
	_test_v12_to_v13_adds_coffee_retry_decision()
	_test_v12_to_v13_preserves_existing()
	_test_idempotency()
	_test_reset_state_declares_won_court()
	_test_reset_state_declares_coffee_retry_decision()
	_test_full_v1_to_v13_chain()

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

## T1: State.SAVE_VERSION == 13.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 13, "SAVE_VERSION >= 13")
	state_node.free()

## T2: A v12 save without won_court gets it added.
func _test_v12_to_v13_adds_won_court() -> void:
	print("[T2] v12→v13 adds won_court")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"court_won_procedural_reset": false,
		},
		"dialogue_states_seen": [],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 12)
	_assert(migrated["chapter1"].has("won_court"), "won_court key exists")
	_assert(migrated["chapter1"]["won_court"] == false, "won_court defaults false")
	save_node.free()

## T2b: A v12 save without coffee_retry_decision gets it added as "".
func _test_v12_to_v13_adds_coffee_retry_decision() -> void:
	print("[T2b] v12→v13 adds coffee_retry_decision")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"coffee_buff": "alert",
		},
		"dialogue_states_seen": [],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 12)
	_assert(migrated["chapter1"].has("coffee_retry_decision"), "coffee_retry_decision key exists")
	_assert(migrated["chapter1"]["coffee_retry_decision"] == "", "coffee_retry_decision defaults empty string")
	_assert(typeof(migrated["chapter1"]["coffee_retry_decision"]) == TYPE_STRING, "coffee_retry_decision is String")
	save_node.free()

## T3: Pre-existing chapter1 keys survive migration.
func _test_v12_to_v13_preserves_existing() -> void:
	print("[T3] preserves existing keys")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"court_won_procedural_reset": true,
		},
		"dialogue_states_seen": ["some_state"],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 12)
	_assert(migrated["chapter1"]["met_pig"] == true, "met_pig preserved")
	_assert(migrated["chapter1"]["court_won_procedural_reset"] == true, "court_won_procedural_reset preserved")
	_assert(migrated["dialogue_states_seen"].has("some_state"), "dialogue_states_seen preserved")
	save_node.free()

## T4: Running the same migration twice is idempotent.
func _test_idempotency() -> void:
	print("[T4] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {"met_pig": false},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 12)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 12)
	_assert(first["chapter1"]["won_court"] == second["chapter1"]["won_court"], "won_court same after double migration")
	save_node.free()

## T5: reset_state() declares won_court.
func _test_reset_state_declares_won_court() -> void:
	print("[T5] reset_state declares won_court")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(fresh.has("chapter1"), "chapter1 dict exists")
	_assert(fresh["chapter1"].has("won_court"), "won_court in reset_state")
	_assert(fresh["chapter1"]["won_court"] == false, "won_court defaults false")
	state_node.free()

## T5b: reset_state() declares coffee_retry_decision as "".
func _test_reset_state_declares_coffee_retry_decision() -> void:
	print("[T5b] reset_state declares coffee_retry_decision")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(fresh["chapter1"].has("coffee_retry_decision"), "coffee_retry_decision in reset_state")
	_assert(fresh["chapter1"]["coffee_retry_decision"] == "", "coffee_retry_decision defaults empty string")
	state_node.free()

## T6: Full v1 → v13 migration chain.
func _test_full_v1_to_v13_chain() -> void:
	print("[T6] full v1→v13 chain")
	var save_node := _save()
	var v1: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save_node.migrate_save(v1, 1)
	_assert(migrated.has("chapter1"), "chapter1 exists after full chain")
	_assert(migrated["chapter1"].has("won_court"), "won_court exists after full chain")
	_assert(migrated["chapter1"]["won_court"] == false, "won_court false after full chain")
	_assert(migrated["chapter1"].has("coffee_retry_decision"), "coffee_retry_decision exists after full chain")
	_assert(migrated["chapter1"]["coffee_retry_decision"] == "", "coffee_retry_decision empty after full chain")
	_assert(migrated.has("dialogue_states_seen"), "dialogue_states_seen exists after full chain")
	_assert(migrated.has("badges"), "badges exists after full chain")
	_assert(migrated.has("routes_unlocked"), "routes_unlocked exists after full chain")
	_assert(migrated.has("coffee"), "coffee exists after full chain")
	_assert(migrated.has("settings"), "settings exists after full chain")
	_assert(migrated["chapter1"].has("halina_trust"), "halina_trust exists (v11 step regression check)")
	save_node.free()
