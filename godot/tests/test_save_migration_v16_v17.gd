extends SceneTree
## test_save_migration_v16_v17.gd — headless migration tests for v16 → v17.
## v17 adds seven chapter1 keys per PROPOSAL_player_driven_argument.md §3:
##   - binder_read_envelope: bool  (default false)
##   - binder_read_renewal: bool   (default false)
##   - binder_read_renumbering: bool (default false)
##   - proposed_frame: String      (default "")
##   - whimsy_co_counsel_posture: String (default "")
##   - judicial_patience: int      (default 5)
##   - witness_cooperation: int    (default 0)
##
## Three read-state flags, two synthesis-output enums, two PROPOSALS.md §10
## resource counters. Idempotent; non-destructive.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v16_v17.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v16→v17] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v16→v17] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v16_to_v17_adds_all_seven_keys()
	_test_v16_to_v17_preserves_existing()
	_test_idempotency()
	_test_reset_state_declares_new_keys()
	_test_missing_chapter1_handled()
	_test_full_v1_to_v17_chain()
	_test_resource_counter_defaults()

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

## T1: State.SAVE_VERSION constant is >= 17. Future-bump safe.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 17, "SAVE_VERSION >= 17")
	state_node.free()

## T2: A v16 save without the new keys gets all seven added with correct defaults.
func _test_v16_to_v17_adds_all_seven_keys() -> void:
	print("[T2] v16→v17 adds all seven new keys with defaults")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"murrow_choice": "professional",
		},
		"dialogue_states_seen": [],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 16)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("binder_read_envelope"), "binder_read_envelope key exists")
	_assert(ch1["binder_read_envelope"] == false, "binder_read_envelope defaults false")
	_assert(ch1.has("binder_read_renewal"), "binder_read_renewal key exists")
	_assert(ch1["binder_read_renewal"] == false, "binder_read_renewal defaults false")
	_assert(ch1.has("binder_read_renumbering"), "binder_read_renumbering key exists")
	_assert(ch1["binder_read_renumbering"] == false, "binder_read_renumbering defaults false")
	_assert(ch1.has("proposed_frame"), "proposed_frame key exists")
	_assert(ch1["proposed_frame"] == "", "proposed_frame defaults empty string")
	_assert(typeof(ch1["proposed_frame"]) == TYPE_STRING, "proposed_frame is String")
	_assert(ch1.has("whimsy_co_counsel_posture"), "whimsy_co_counsel_posture key exists")
	_assert(ch1["whimsy_co_counsel_posture"] == "", "whimsy_co_counsel_posture defaults empty string")
	_assert(ch1.has("judicial_patience"), "judicial_patience key exists")
	_assert(ch1["judicial_patience"] == 5, "judicial_patience defaults 5")
	_assert(typeof(ch1["judicial_patience"]) == TYPE_INT, "judicial_patience is int")
	_assert(ch1.has("witness_cooperation"), "witness_cooperation key exists")
	_assert(ch1["witness_cooperation"] == 0, "witness_cooperation defaults 0")
	_assert(typeof(ch1["witness_cooperation"]) == TYPE_INT, "witness_cooperation is int")
	save_node.free()

## T3: Pre-existing chapter1 keys survive v16→v17 migration.
func _test_v16_to_v17_preserves_existing() -> void:
	print("[T3] preserves existing keys")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"met_murrow": true,
			"won_court": true,
			"halina_trust": 7,
			"coffee_retry_decision": "retry",
			"state_choice": "blunt",
			"murrow_choice": "friendly",
		},
		"dialogue_states_seen": ["asia_first_meeting"],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 16)
	_assert(migrated["chapter1"]["met_pig"] == true, "met_pig preserved")
	_assert(migrated["chapter1"]["met_murrow"] == true, "met_murrow preserved")
	_assert(migrated["chapter1"]["won_court"] == true, "won_court preserved")
	## halina_trust 7 (≥ 5) → migrated to halina_stance = "high" at v27.
	_assert(not migrated["chapter1"].has("halina_trust"), "halina_trust erased by v27 migration")
	_assert(migrated["chapter1"].get("halina_stance", "") == "high", "halina_trust 7 → halina_stance 'high'")
	_assert(migrated["chapter1"]["coffee_retry_decision"] == "retry", "coffee_retry_decision preserved")
	_assert(migrated["chapter1"]["state_choice"] == "blunt", "state_choice preserved")
	_assert(migrated["chapter1"]["murrow_choice"] == "friendly", "murrow_choice preserved")
	_assert(migrated["dialogue_states_seen"].has("asia_first_meeting"), "dialogue_states_seen preserved")
	save_node.free()

## T4: Running the migration twice is idempotent. Pre-set values are not clobbered.
func _test_idempotency() -> void:
	print("[T4] idempotency — re-running does not clobber existing values")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": false,
			"binder_read_envelope": true,
			"proposed_frame": "defective_service_135bis",
			"judicial_patience": 3,
		},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 16)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 16)
	_assert(first["chapter1"]["binder_read_envelope"] == second["chapter1"]["binder_read_envelope"],
		"binder_read_envelope same after double migration")
	_assert(second["chapter1"]["binder_read_envelope"] == true, "pre-set true preserved (not clobbered)")
	_assert(second["chapter1"]["proposed_frame"] == "defective_service_135bis", "proposed_frame preserved")
	_assert(second["chapter1"]["judicial_patience"] == 3, "judicial_patience pre-set 3 preserved")
	save_node.free()

## T5: reset_state() declares every new key with the correct default.
func _test_reset_state_declares_new_keys() -> void:
	print("[T5] reset_state declares all v17 keys")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(fresh.has("chapter1"), "chapter1 dict exists")
	var ch1: Dictionary = fresh["chapter1"]
	_assert(ch1.has("binder_read_envelope") and ch1["binder_read_envelope"] == false,
		"binder_read_envelope declared false")
	_assert(ch1.has("binder_read_renewal") and ch1["binder_read_renewal"] == false,
		"binder_read_renewal declared false")
	_assert(ch1.has("binder_read_renumbering") and ch1["binder_read_renumbering"] == false,
		"binder_read_renumbering declared false")
	_assert(ch1.has("proposed_frame") and ch1["proposed_frame"] == "",
		"proposed_frame declared empty string")
	_assert(ch1.has("whimsy_co_counsel_posture") and ch1["whimsy_co_counsel_posture"] == "",
		"whimsy_co_counsel_posture declared empty string")
	_assert(ch1.has("judicial_patience") and ch1["judicial_patience"] == 5,
		"judicial_patience declared 5")
	_assert(ch1.has("witness_cooperation") and ch1["witness_cooperation"] == 0,
		"witness_cooperation declared 0")
	## Regression: stance fields present (v27 replaced halina_trust).
	_assert(ch1.has("halina_stance"), "halina_stance in reset_state (v27 rename)")
	_assert(ch1.has("state_choice"), "state_choice still in reset_state (v15 regression)")
	_assert(ch1.has("murrow_choice"), "murrow_choice still in reset_state (v16 regression)")
	state_node.free()

## T6: A save without chapter1 at all is not crashed on (v17 guard).
func _test_missing_chapter1_handled() -> void:
	print("[T6] missing chapter1 dict is not crashed on")
	var save_node := _save()
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 16)
	_assert(not migrated.has("chapter1") or migrated["chapter1"].has("binder_read_envelope"),
		"no crash and either chapter1 absent or new keys present")
	save_node.free()

## T7: Full v1 → v17 chain includes every new key, with regression on prior versions.
func _test_full_v1_to_v17_chain() -> void:
	print("[T7] full v1→v17 chain")
	var save_node := _save()
	var v1: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save_node.migrate_save(v1, 1)
	_assert(migrated.has("chapter1"), "chapter1 exists after full chain")
	var ch1: Dictionary = migrated["chapter1"]
	## v17 keys.
	_assert(ch1.has("binder_read_envelope") and ch1["binder_read_envelope"] == false,
		"binder_read_envelope after full chain")
	_assert(ch1.has("proposed_frame") and ch1["proposed_frame"] == "",
		"proposed_frame after full chain")
	_assert(ch1.has("judicial_patience") and ch1["judicial_patience"] == 5,
		"judicial_patience after full chain")
	_assert(ch1.has("witness_cooperation") and ch1["witness_cooperation"] == 0,
		"witness_cooperation after full chain")
	## Regression checks for earlier steps.
	_assert(ch1.has("state_choice"), "state_choice exists (v15 regression)")
	_assert(ch1.has("murrow_choice"), "murrow_choice exists (v16 regression)")
	_assert(ch1.has("won_court"), "won_court exists (v13 regression)")
	_assert(ch1.has("halina_stance"), "halina_stance exists (v27 rename of halina_trust)")
	_assert(ch1.has("coffee_retry_decision"), "coffee_retry_decision exists (v13 regression)")
	_assert(migrated.has("dialogue_states_seen"), "dialogue_states_seen exists (v12 regression)")
	_assert(migrated.has("badges"), "badges exists (v8 regression)")
	_assert(migrated.has("routes_unlocked"), "routes_unlocked exists (v8 regression)")
	_assert(migrated.has("coffee"), "coffee exists (v9 regression)")
	_assert(migrated.has("settings"), "settings exists (v10 regression)")
	save_node.free()

## T8: Resource counter defaults are integers, not strings — type-safety check.
##     Prevents the dialogue editor / runner from mis-treating these as
##     write_path strings.
func _test_resource_counter_defaults() -> void:
	print("[T8] judicial_patience and witness_cooperation are typed integers")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 16)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(typeof(ch1["judicial_patience"]) == TYPE_INT,
		"judicial_patience is TYPE_INT after migration")
	_assert(typeof(ch1["witness_cooperation"]) == TYPE_INT,
		"witness_cooperation is TYPE_INT after migration")
	## Cross-check against reset_state — they must agree.
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(typeof(fresh["chapter1"]["judicial_patience"]) == typeof(ch1["judicial_patience"]),
		"reset_state and migration agree on judicial_patience type")
	_assert(typeof(fresh["chapter1"]["witness_cooperation"]) == typeof(ch1["witness_cooperation"]),
		"reset_state and migration agree on witness_cooperation type")
	state_node.free()
	save_node.free()
