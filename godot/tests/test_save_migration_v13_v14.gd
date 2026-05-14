extends SceneTree
## test_save_migration_v13_v14.gd — headless migration tests for v13 → v14.
## v14 scrubs legacy colliding dialogue state ids from dialogue_states_seen.
## Seven state ids that previously collided across files were renamed with
## NPC prefixes (e.g. `first_meeting` → `murrow_first_meeting`); v14 ensures
## that any save carrying the old (now-ambiguous) ids has them removed so
## they don't ghost-skip the renamed once-states. Non-collider ids survive.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v13_v14.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

const LEGACY_COLLIDERS: Array = [
	"first_meeting",
	"coffee_reaction_perfect",
	"coffee_reaction_bad",
	"coffee_reaction_perfect_recruited",
	"coffee_reaction_bad_recruited",
	"coffee_reaction_perfect_pre_recruit",
	"coffee_reaction_bad_pre_recruit",
]

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v13→v14] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v13→v14] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_scrubs_legacy_colliders()
	_test_preserves_non_collider_ids()
	_test_empty_array_survives()
	_test_missing_array_created()
	_test_idempotency()
	_test_full_chain_carries_scrub()

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

## T1: SAVE_VERSION constant on state.gd is >= 14.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 14, "SAVE_VERSION >= 14")
	state_node.free()

## T2: Every legacy collider id present in a v13 save is scrubbed by v14.
func _test_scrubs_legacy_colliders() -> void:
	print("[T2] scrubs every legacy collider id")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {"met_pig": false},
		"dialogue_states_seen": LEGACY_COLLIDERS.duplicate(),
	}
	var migrated: Dictionary = save_node.migrate_save(old, 13)
	var seen: Array = migrated.get("dialogue_states_seen", [])
	for collider in LEGACY_COLLIDERS:
		_assert(not seen.has(collider), "%s scrubbed" % collider)
	save_node.free()

## T3: Non-collider ids in dialogue_states_seen survive migration.
func _test_preserves_non_collider_ids() -> void:
	print("[T3] preserves non-collider ids")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {"met_pig": false},
		"dialogue_states_seen": [
			"some_renamed_once_state",
			"first_meeting",                    ## collider — should drop
			"client_meeting_intro",
			"coffee_reaction_perfect",          ## collider — should drop
			"asia_first_meeting",
		],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 13)
	var seen: Array = migrated["dialogue_states_seen"]
	_assert(seen.has("some_renamed_once_state"), "renamed once-state survives")
	_assert(seen.has("client_meeting_intro"), "client_meeting_intro survives")
	_assert(seen.has("asia_first_meeting"), "asia_first_meeting survives")
	_assert(not seen.has("first_meeting"), "first_meeting scrubbed")
	_assert(not seen.has("coffee_reaction_perfect"), "coffee_reaction_perfect scrubbed")
	_assert(seen.size() == 3, "exactly 3 non-collider ids survived")
	save_node.free()

## T4: An empty dialogue_states_seen array survives v14 unchanged.
func _test_empty_array_survives() -> void:
	print("[T4] empty array survives")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {"met_pig": false},
		"dialogue_states_seen": [],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 13)
	_assert(migrated.has("dialogue_states_seen"), "key still present")
	_assert(migrated["dialogue_states_seen"] is Array, "still Array type")
	_assert((migrated["dialogue_states_seen"] as Array).size() == 0, "still empty")
	save_node.free()

## T5: A save missing dialogue_states_seen entirely gets an empty Array.
func _test_missing_array_created() -> void:
	print("[T5] missing array is created")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {"met_pig": false},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 13)
	_assert(migrated.has("dialogue_states_seen"), "dialogue_states_seen added")
	_assert(migrated["dialogue_states_seen"] is Array, "is Array type")
	_assert((migrated["dialogue_states_seen"] as Array).size() == 0, "empty Array default")
	save_node.free()

## T6: Re-running v14 migration on an already-migrated save is idempotent.
func _test_idempotency() -> void:
	print("[T6] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {"met_pig": false},
		"dialogue_states_seen": ["first_meeting", "kept_state"],
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 13)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 13)
	_assert(first["dialogue_states_seen"] == second["dialogue_states_seen"], "second migration is no-op")
	_assert(not (first["dialogue_states_seen"] as Array).has("first_meeting"), "collider stays scrubbed on re-run")
	_assert((first["dialogue_states_seen"] as Array).has("kept_state"), "kept_state stays kept on re-run")
	save_node.free()

## T7: Full chain from v1 propagates the scrub.
func _test_full_chain_carries_scrub() -> void:
	print("[T7] full v1→v14 chain carries the scrub")
	var save_node := _save()
	var v1: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save_node.migrate_save(v1, 1)
	## A v1 save can't have once-state ids — the array is created empty by v12.
	## Assert the array exists and is empty after the full chain.
	_assert(migrated.has("dialogue_states_seen"), "array exists after full chain")
	_assert((migrated["dialogue_states_seen"] as Array).is_empty(), "empty after full chain")
	save_node.free()
