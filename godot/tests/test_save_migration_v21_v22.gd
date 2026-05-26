extends SceneTree
## test_save_migration_v21_v22.gd — headless migration tests for v21 → v22.
##
## v22 renames chapter1.bonus_evidence_collected → chapter1.client_meeting_evidence.
## The flag is a string enum that records which bonus evidence item the player
## collected during the client meeting (stance-dependent). Old name described
## acquisition; new name reflects narrative role.
##
## Per the save-migration test pattern documented in
## test_save_migration_v17_v18.gd, T1 asserts SAVE_VERSION >= 22 (NOT == 22)
## so the test survives future bumps.
##
## Run: godot --headless --path godot --script tests/test_save_migration_v21_v22.gd

var _pass_count: int = 0
var _fail_count: int = 0
var _test_count: int = 0

func _init() -> void:
	_run_all()
	if _fail_count > 0:
		printerr("[v21→v22] FAILED: %d / %d tests failed" % [_fail_count, _test_count])
		quit(1)
	else:
		print("[v21→v22] ALL PASS: %d / %d" % [_pass_count, _test_count])
		quit(0)

func _run_all() -> void:
	_test_save_version_constant()
	_test_v21_renames_key()
	_test_v21_preserves_value()
	_test_v21_empty_string_preserved()
	_test_v21_no_old_key_fallback()
	_test_old_key_removed()
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

## T1: State.SAVE_VERSION constant is >= 22.
func _test_save_version_constant() -> void:
	print("[T1] SAVE_VERSION constant")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	_assert(state_node.SAVE_VERSION >= 22, "SAVE_VERSION >= 22")
	state_node.free()

## T2: A v21 save with bonus_evidence_collected gets it renamed.
func _test_v21_renames_key() -> void:
	print("[T2] v21→v22 renames bonus_evidence_collected")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"bonus_evidence_collected": "wojcik_witness_statement",
			"client_meeting_stance": "sympathetic",
			"halina_met": true,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 21)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("client_meeting_evidence"), "client_meeting_evidence key exists after rename")
	_assert(not ch1.has("bonus_evidence_collected"), "bonus_evidence_collected key removed")
	save_node.free()

## T3: The value is preserved under the new key name.
func _test_v21_preserves_value() -> void:
	print("[T3] value preserved after rename")
	var save_node := _save()
	for evidence_id in ["wojcik_witness_statement", "return_to_sender_slip",
			"lease_1962_inheritance_1987", "landlord_contact"]:
		var old: Dictionary = {
			"chapter1": {"bonus_evidence_collected": evidence_id},
		}
		var migrated: Dictionary = save_node.migrate_save(old, 21)
		_assert(migrated["chapter1"]["client_meeting_evidence"] == evidence_id,
			"value '%s' preserved under new key" % evidence_id)
	save_node.free()

## T4: Empty string is preserved (player skipped the bonus evidence pickup).
func _test_v21_empty_string_preserved() -> void:
	print("[T4] empty string preserved")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"bonus_evidence_collected": "",
			"halina_met": true,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 21)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1.has("client_meeting_evidence"), "client_meeting_evidence key exists")
	_assert(ch1["client_meeting_evidence"] == "", "empty string preserved")
	_assert(not ch1.has("bonus_evidence_collected"), "old key removed")
	save_node.free()

## T5: A v21 save that already has client_meeting_evidence and no old key
##     is left unchanged (e.g. save that went through v8 migration after
##     this code landed).
func _test_v21_no_old_key_fallback() -> void:
	print("[T5] save with only new key is unchanged")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"client_meeting_evidence": "return_to_sender_slip",
			"halina_met": true,
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 21)
	var ch1: Dictionary = migrated["chapter1"]
	_assert(ch1["client_meeting_evidence"] == "return_to_sender_slip",
		"existing client_meeting_evidence value untouched")
	_assert(not ch1.has("bonus_evidence_collected"), "no stale key introduced")
	save_node.free()

## T6: Old key is fully removed after migration (not just shadowed).
func _test_old_key_removed() -> void:
	print("[T6] bonus_evidence_collected absent in migrated save")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"bonus_evidence_collected": "landlord_contact",
		},
	}
	var migrated: Dictionary = save_node.migrate_save(old, 21)
	_assert(not migrated["chapter1"].has("bonus_evidence_collected"),
		"bonus_evidence_collected not present after migration")
	save_node.free()

## T7: Running the migration twice is idempotent.
func _test_idempotency() -> void:
	print("[T7] idempotency")
	var save_node := _save()
	var old: Dictionary = {
		"chapter1": {
			"bonus_evidence_collected": "wojcik_witness_statement",
		},
	}
	var first: Dictionary = save_node.migrate_save(old.duplicate(true), 21)
	var second: Dictionary = save_node.migrate_save(first.duplicate(true), 21)
	_assert(first["chapter1"]["client_meeting_evidence"] == second["chapter1"]["client_meeting_evidence"],
		"client_meeting_evidence same after double migration")
	_assert(not second["chapter1"].has("bonus_evidence_collected"),
		"bonus_evidence_collected absent after double migration")
	save_node.free()

## T8: reset_state() declares client_meeting_evidence with "" default.
func _test_reset_state_declares_new_key() -> void:
	print("[T8] reset_state declares client_meeting_evidence")
	var state_script := load("res://scripts/autoload/state.gd") as GDScript
	var state_node := Node.new()
	state_node.set_script(state_script)
	var fresh: Dictionary = state_node.reset_state()
	_assert(fresh.has("chapter1"), "chapter1 dict exists")
	var ch1: Dictionary = fresh["chapter1"]
	_assert(ch1.has("client_meeting_evidence"),
		"client_meeting_evidence declared in reset_state")
	_assert(ch1["client_meeting_evidence"] == "",
		"client_meeting_evidence reset_state default is empty string")
	_assert(not ch1.has("bonus_evidence_collected"),
		"bonus_evidence_collected absent from reset_state")
	state_node.free()

## T9: Missing chapter1 dictionary does not crash migration.
func _test_missing_chapter1_handled() -> void:
	print("[T9] missing chapter1 dict does not crash")
	var save_node := _save()
	var old: Dictionary = {}
	var migrated: Dictionary = save_node.migrate_save(old, 21)
	_assert(not migrated.has("chapter1") or
		(migrated["chapter1"].has("client_meeting_evidence") and
		 not migrated["chapter1"].has("bonus_evidence_collected")),
		"no crash and either chapter1 absent or keys correct")
	save_node.free()
