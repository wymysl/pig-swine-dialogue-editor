extends SceneTree
## test_save_migration_v17_v18.gd — headless migration tests for v17 → v18.
## v18 adds explicit Chapter 1 packet-foundation booleans:
##   surfaced_payment_receipts, surfaced_notice_timeline,
##   surfaced_tenancy_act_window, surfaced_property_transfer,
##   surfaced_sikorska_age, surfaced_resident_no_authority,
##   element_non_current_address, element_landlord_knowledge,
##   element_timely_actual_notice_motion, element_no_third_party_cure,
##   decoy_merits, decoy_notice_period, decoy_standing_wrong_party,
##   decoy_overbroad_remedy, decoy_incapacity.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v17_v18.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v17→v18] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v17→v18] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v17_to_v18_adds_all_packet_keys()
	_test_v17_to_v18_preserves_existing()
	_test_idempotency()
	_test_reset_state_declares_new_keys()
	_test_missing_chapter1_handled()
	_test_full_v1_to_v18_chain()

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

func _v18_bool_keys() -> Array:
	return [
		"surfaced_payment_receipts",
		"surfaced_notice_timeline",
		"surfaced_tenancy_act_window",
		"surfaced_property_transfer",
		"surfaced_sikorska_age",
		"surfaced_resident_no_authority",
		"element_non_current_address",
		"element_landlord_knowledge",
		"element_timely_actual_notice_motion",
		"element_no_third_party_cure",
		"decoy_merits",
		"decoy_notice_period",
		"decoy_standing_wrong_party",
		"decoy_overbroad_remedy",
		"decoy_incapacity",
	]

## T1: State.SAVE_VERSION constant is >= 18.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 18, "SAVE_VERSION >= 18")
	state_node.free()

## T2: A v17 save without packet-foundation booleans gets all keys with false defaults.
func _test_v17_to_v18_adds_all_packet_keys() -> void:
	print("[T2] v17→v18 adds all packet-foundation keys")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"proposed_frame": "defective_service_135bis",
			"judicial_patience": 4,
			"witness_cooperation": 2,
		},
		"dialogue_states_seen": [],
	}
	var migrated: Dictionary = save_node.migrate_save(old, 17)
	var ch1: Dictionary = migrated["chapter1"]
	for key in _v18_bool_keys():
		_assert(ch1.has(key), "%s key exists" % key)
		_assert(ch1[key] == false, "%s defaults false" % key)
		_assert(typeof(ch1[key]) == TYPE_BOOL, "%s is TYPE_BOOL" % key)
	## Regression: v17 keys remain untouched.
	_assert(ch1["proposed_frame"] == "defective_service_135bis", "proposed_frame preserved while adding v18 keys")
	_assert(ch1["judicial_patience"] == 4, "judicial_patience preserved while adding v18 keys")
	_assert(ch1["witness_cooperation"] == 2, "witness_cooperation preserved while adding v18 keys")
	save_node.free()

## T3: Pre-existing packet booleans are preserved (migration does not clobber true values).
func _test_v17_to_v18_preserves_existing() -> void:
	print("[T3] preserves existing packet keys")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"surfaced_notice_timeline": true,
			"element_non_current_address": true,
			"decoy_notice_period": true,
			"proposed_frame": "notice_period_failure",
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 17)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1["surfaced_notice_timeline"] == true, "surfaced_notice_timeline preserved true")
	_assert(ch1["element_non_current_address"] == true, "element_non_current_address preserved true")
	_assert(ch1["decoy_notice_period"] == true, "decoy_notice_period preserved true")
	_assert(ch1["proposed_frame"] == "notice_period_failure", "proposed_frame preserved")
	## Newly added keys still appear.
	_assert(ch1.has("surfaced_resident_no_authority"), "missing v18 key backfilled")
	_assert(ch1["surfaced_resident_no_authority"] == false, "backfilled key defaults false")
	save_node.free()

## T4: Running the migration twice is idempotent.
func _test_idempotency() -> void:
	print("[T4] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": false,
			"decoy_incapacity": true,
		},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 17)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 17)
	_assert(first["chapter1"]["decoy_incapacity"] == second["chapter1"]["decoy_incapacity"],
		"decoy_incapacity same after double migration")
	_assert(second["chapter1"]["decoy_incapacity"] == true, "pre-set true preserved")
	_assert(second["chapter1"]["element_no_third_party_cure"] == false, "missing key remains default false on re-run")
	save_node.free()

## T5: reset_state() declares every v18 key with false defaults.
func _test_reset_state_declares_new_keys() -> void:
	print("[T5] reset_state declares all v18 keys")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(fresh.has("chapter1"), "chapter1 dict exists")
	var ch1: Dictionary = fresh["chapter1"]
	for key in _v18_bool_keys():
		_assert(ch1.has(key), "%s declared in reset_state" % key)
		_assert(ch1[key] == false, "%s reset_state default false" % key)
	## Regression keys still present.
	_assert(ch1.has("proposed_frame"), "proposed_frame still declared")
	_assert(ch1.has("judicial_patience"), "judicial_patience still declared")
	_assert(ch1.has("witness_cooperation"), "witness_cooperation still declared")
	_assert(ch1.has("court_outcome"), "court_outcome still declared")
	state_node.free()

## T6: Missing chapter1 dictionary does not crash migration.
func _test_missing_chapter1_handled() -> void:
	print("[T6] missing chapter1 dict is not crashed on")
	var save_node := _save()
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 17)
	_assert(not migrated.has("chapter1") or migrated["chapter1"].has("element_non_current_address"),
		"no crash and either chapter1 absent or v18 keys present")
	save_node.free()

## T7: Full v1→v18 chain includes v18 fields and keeps earlier regressions.
func _test_full_v1_to_v18_chain() -> void:
	print("[T7] full v1→v18 chain")
	var save_node := _save()
	var v1: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
	}
	var migrated: Dictionary = save_node.migrate_save(v1, 1)
	_assert(migrated.has("chapter1"), "chapter1 exists after full chain")
	var ch1: Dictionary = migrated["chapter1"]
	for key in _v18_bool_keys():
		_assert(ch1.has(key), "%s exists after full chain" % key)
		_assert(ch1[key] == false, "%s false after full chain" % key)
	## Regression checks across earlier versions.
	_assert(ch1.has("state_choice"), "state_choice exists (v15 regression)")
	_assert(ch1.has("murrow_choice"), "murrow_choice exists (v16 regression)")
	_assert(ch1.has("won_court"), "won_court exists (v13 regression)")
	_assert(ch1.has("halina_stance"), "halina_stance exists (v27 rename of halina_trust)")
	_assert(ch1.has("proposed_frame"), "proposed_frame exists (v17 regression)")
	_assert(ch1.has("judicial_patience"), "judicial_patience exists (v17 regression)")
	_assert(ch1.has("witness_cooperation"), "witness_cooperation exists (v17 regression)")
	_assert(migrated.has("dialogue_states_seen"), "dialogue_states_seen exists (v12 regression)")
	_assert(migrated.has("badges"), "badges exists (v8 regression)")
	_assert(migrated.has("routes_unlocked"), "routes_unlocked exists (v8 regression)")
	_assert(migrated.has("coffee"), "coffee exists (v9 regression)")
	_assert(migrated.has("settings"), "settings exists (v10 regression)")
	save_node.free()
