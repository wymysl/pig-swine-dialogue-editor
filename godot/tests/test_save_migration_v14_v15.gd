extends SceneTree
## test_save_migration_v14_v15.gd — headless migration tests for v14 → v15.
## v15 adds chapter1.state_choice (string, default ""). The key was referenced
## by dialogue_runner write_path but not declared in reset_state(), so writes
## silently no-opped. v15 adds the slot; writer plumbing is future work.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v14_v15.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v14→v15] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v14→v15] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v14_to_v15_adds_state_choice()
	_test_v14_to_v15_preserves_existing()
	_test_idempotency()
	_test_reset_state_declares_state_choice()
	_test_missing_chapter1_handled()
	_test_full_v1_to_v15_chain()

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

## T1: State.SAVE_VERSION constant is >= 15.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 15, "SAVE_VERSION >= 15")
	state_node.free()

## T2: A v14 save without state_choice gets the key added as "".
func _test_v14_to_v15_adds_state_choice() -> void:
	print("[T2] v14→v15 adds state_choice")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"won_court": false,
		},
		"dialogue_states_seen": [],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 14)
	_assert(migrated["chapter1"].has("state_choice"), "state_choice key exists")
	_assert(migrated["chapter1"]["state_choice"] == "", "state_choice defaults empty string")
	_assert(typeof(migrated["chapter1"]["state_choice"]) == TYPE_STRING, "state_choice is String")
	save_node.free()

## T3: Pre-existing chapter1 keys survive v14→v15 migration.
func _test_v14_to_v15_preserves_existing() -> void:
	print("[T3] preserves existing keys")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"won_court": true,
			"halina_trust": 7,
			"coffee_retry_decision": "retry",
		},
		"dialogue_states_seen": ["asia_first_meeting"],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 14)
	_assert(migrated["chapter1"]["met_pig"] == true, "met_pig preserved")
	_assert(migrated["chapter1"]["won_court"] == true, "won_court preserved")
	_assert(migrated["chapter1"]["halina_trust"] == 7, "halina_trust preserved")
	_assert(migrated["chapter1"]["coffee_retry_decision"] == "retry", "coffee_retry_decision preserved")
	_assert(migrated["dialogue_states_seen"].has("asia_first_meeting"), "dialogue_states_seen preserved")
	save_node.free()

## T4: Running the same migration twice is idempotent.
func _test_idempotency() -> void:
	print("[T4] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {"met_pig": false},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 14)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 14)
	_assert(first["chapter1"]["state_choice"] == second["chapter1"]["state_choice"],
		"state_choice same after double migration")
	_assert(second["chapter1"]["state_choice"] == "", "state_choice still empty on re-run")
	save_node.free()

## T5: reset_state() declares state_choice as "".
func _test_reset_state_declares_state_choice() -> void:
	print("[T5] reset_state declares state_choice")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(fresh.has("chapter1"), "chapter1 dict exists")
	_assert(fresh["chapter1"].has("state_choice"), "state_choice in reset_state")
	_assert(fresh["chapter1"]["state_choice"] == "", "state_choice defaults empty string")
	## Regression: trust-meter flags still present (v11 step).
	_assert(fresh["chapter1"].has("halina_trust"), "halina_trust still in reset_state")
	_assert(fresh["chapter1"].has("won_court"), "won_court still in reset_state")
	_assert(fresh["chapter1"].has("coffee_retry_decision"), "coffee_retry_decision still in reset_state")
	state_node.free()

## T6: A save with a chapter1 dict but no state_choice gets the key silently.
## A save without chapter1 at all is not migrated (guard in save.gd).
func _test_missing_chapter1_handled() -> void:
	print("[T6] missing chapter1 dict is not crashed on")
	var save_node := _save()
	## The v15 branch only writes into chapter1 if it exists. A save that
	## somehow never got chapter1 should survive without a crash.
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 14)
	## chapter1 was not present and v15 guard skips it — no key, no crash.
	_assert(not migrated.has("chapter1") or migrated["chapter1"].has("state_choice"),
		"no crash and either chapter1 absent or state_choice present")
	save_node.free()

## T7: Full v1 → v15 chain includes state_choice.
func _test_full_v1_to_v15_chain() -> void:
	print("[T7] full v1→v15 chain")
	var save_node := _save()
	var v1: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save_node.migrate_save(v1, 1)
	_assert(migrated.has("chapter1"), "chapter1 exists after full chain")
	_assert(migrated["chapter1"].has("state_choice"), "state_choice exists after full chain")
	_assert(migrated["chapter1"]["state_choice"] == "", "state_choice empty after full chain")
	## Regression checks for earlier steps in the chain.
	_assert(migrated["chapter1"].has("won_court"), "won_court exists (v13 step regression)")
	_assert(migrated["chapter1"].has("halina_trust"), "halina_trust exists (v11 step regression)")
	_assert(migrated["chapter1"].has("coffee_retry_decision"), "coffee_retry_decision exists (v13 regression)")
	_assert(migrated.has("dialogue_states_seen"), "dialogue_states_seen exists (v12 regression)")
	_assert(migrated.has("badges"), "badges exists (v8 regression)")
	_assert(migrated.has("routes_unlocked"), "routes_unlocked exists (v8 regression)")
	_assert(migrated.has("coffee"), "coffee exists (v9 regression)")
	_assert(migrated.has("settings"), "settings exists (v10 regression)")
	save_node.free()
