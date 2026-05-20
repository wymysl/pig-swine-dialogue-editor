extends SceneTree
## test_save_migration_v20_v21.gd — headless migration tests for v20 → v21.
##
## v21 adds a single Chapter 1 boolean — cula_postcard_reaction_shown —
## introduced by the 2026-05-19 critique F4 partial fix. The flag gates
## Cula's previously-orphaned Beat 14 postcard reaction (postcard_swine_ch1
## ::cula_postcard_reaction) and is consumed by the trigger on the
## existing whimsy_archaic_deflection state.
##
## Per the save-migration test pattern documented in
## test_save_migration_v17_v18.gd, T1 asserts SAVE_VERSION >= 21 (NOT == 21)
## so the test survives future bumps. The other tests follow the established
## add-key-default-false / preserve-existing / idempotency / reset_state
## declaration coverage.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v20_v21.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v20→v21] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v20→v21] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v20_to_v21_adds_flag()
	_test_v20_to_v21_preserves_existing()
	_test_idempotency()
	_test_reset_state_declares_new_key()
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

## T1: State.SAVE_VERSION constant is >= 21.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 21, "SAVE_VERSION >= 21")
	state_node.free()

## T2: A v20 save without the new flag gets it added with false default.
func _test_v20_to_v21_adds_flag() -> void:
	print("[T2] v20→v21 adds cula_postcard_reaction_shown")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": true,
			"received_swine_postcard": true,
			"postcard_asia_announced": true,
			"postcard_body_read": true,
			"pig_postcard_reaction_shown": true,
			"whimsy_postcard_deflection_shown": false,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 20)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("cula_postcard_reaction_shown"), "cula_postcard_reaction_shown key exists")
	_assert(ch1["cula_postcard_reaction_shown"] == false, "cula_postcard_reaction_shown defaults false")
	_assert(typeof(ch1["cula_postcard_reaction_shown"]) == TYPE_BOOL, "cula_postcard_reaction_shown is TYPE_BOOL")
	## Regression: prior keys remain untouched.
	_assert(ch1["pig_postcard_reaction_shown"] == true, "pig_postcard_reaction_shown preserved true")
	_assert(ch1["whimsy_postcard_deflection_shown"] == false, "whimsy_postcard_deflection_shown preserved false")
	_assert(ch1["received_swine_postcard"] == true, "received_swine_postcard preserved true")
	save_node.free()

## T3: A pre-existing cula_postcard_reaction_shown = true is preserved.
func _test_v20_to_v21_preserves_existing() -> void:
	print("[T3] preserves pre-existing flag")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"cula_postcard_reaction_shown": true,
			"pig_postcard_reaction_shown": true,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 20)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1["cula_postcard_reaction_shown"] == true, "cula_postcard_reaction_shown preserved true")
	save_node.free()

## T4: Running the migration twice is idempotent.
func _test_idempotency() -> void:
	print("[T4] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"met_pig": false,
		},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 20)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 20)
	_assert(first["chapter1"]["cula_postcard_reaction_shown"] == second["chapter1"]["cula_postcard_reaction_shown"],
		"cula_postcard_reaction_shown same after double migration")
	_assert(second["chapter1"]["cula_postcard_reaction_shown"] == false, "default false preserved on re-run")
	save_node.free()

## T5: reset_state() declares the v21 key with false default.
func _test_reset_state_declares_new_key() -> void:
	print("[T5] reset_state declares cula_postcard_reaction_shown")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(fresh.has("chapter1"), "chapter1 dict exists")
	var ch1: Dictionary = fresh["chapter1"]
	_assert(ch1.has("cula_postcard_reaction_shown"), "cula_postcard_reaction_shown declared in reset_state")
	_assert(ch1["cula_postcard_reaction_shown"] == false, "cula_postcard_reaction_shown reset_state default false")
	state_node.free()

## T6: Missing chapter1 dictionary does not crash migration.
func _test_missing_chapter1_handled() -> void:
	print("[T6] missing chapter1 dict is not crashed on")
	var save_node := _save()
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 20)
	_assert(not migrated.has("chapter1") or migrated["chapter1"].has("cula_postcard_reaction_shown"),
		"no crash and either chapter1 absent or v21 key present")
	save_node.free()
