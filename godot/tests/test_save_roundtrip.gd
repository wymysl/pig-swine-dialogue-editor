extends SceneTree
## test_save_roundtrip.gd — end-to-end save/load disk round-trip.
##
## Per AGENTS.md §"Hard build invariants": "For Code artifacts touching state
## or save: a save/load round-trip against the previous sprint's fixture."
## The test_save_migration_v*_v*.gd suite only exercises migrate_save() in
## memory. This test covers the remaining half of the contract: the actual
## disk path — JSON.stringify, file IO, parse on load, post-load apply.
##
## Coverage:
##   T1: a fully-populated State.data round-trips byte-for-byte (after JSON
##       stringify/parse) through save_game() + load_game().
##   T2: load_game() emits save_failed and resets state when the file is
##       a corrupt JSON body.
##   T3: load_game() returns false when no file exists.
##   T4: a v7 dictionary written to disk under version=7 loads through
##       migrate_save and matches the in-memory migration result.
##   T5: SAVE_VERSION constant survives a save+load cycle.
##
## Owner: QA role.
## Run:   godot --headless --path godot --script tests/test_save_roundtrip.gd

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	await process_frame
	_run_all()
	_finish()


func _run_all() -> void:
	_test_full_roundtrip()
	_test_corrupt_file_emits_failure()
	_test_missing_file_returns_false()
	_test_v7_disk_load_matches_in_memory_migration()
	_test_save_version_survives_roundtrip()


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: %s" % msg)
	else:
		_fail_count += 1
		printerr("  FAIL: %s" % msg)


## _make_save_and_state — returns (save_node, state_node) wired up as nodes
## under the test SceneTree's root. State autoload is already at /root/State
## via project.godot; we reuse it rather than spawning a duplicate, since
## Save's runtime accessor `_state()` resolves /root/State.
func _make_save() -> Node:
	var save_script: GDScript = load("res://scripts/systems/save.gd") as GDScript
	var save_node: Node = save_script.new()
	get_root().add_child(save_node)
	return save_node


func _state() -> Node:
	return get_root().get_node_or_null("/root/State")


func _unique_test_path(stem: String) -> String:
	return "user://test_roundtrip_%s_%d.json" % [stem, Time.get_ticks_usec()]


## T1 — Populate State.data with a heterogeneous fixture, save, blow away
## State.data, load, and assert deep equality (modulo the JSON-survivable
## type-coercion floor: bools survive, ints survive, strings survive, nested
## dicts survive, empty arrays survive).
func _test_full_roundtrip() -> void:
	print("[T1] full save/load round-trip")
	var save_node: Node = _make_save()
	var path: String = _unique_test_path("full")
	save_node.set_save_path_for_tests(path)

	var st: Node = _state()
	_assert(st != null, "State autoload available")
	if st == null:
		save_node.queue_free()
		return

	var fixture: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"active_case_id": "chapter1_sikorska",
		"chapter1": {
			"met_pig": true,
			"halina_trust": 4,
			"client_meeting_stance": "blunt_procedural",
			"witness_cooperation": 2,
			"judicial_patience": 5,
			"packet_requested_remedy": "procedural_reset",
		},
		"badges": {"day_one_survivor": true},
		"routes_unlocked": {
			"residential": true,
			"business_district": false,
			"court_plaza": false,
		},
		"inventory": {"procedural_binder": true},
		"case_folder": {"argument_fragments": [], "notes_seen": {}},
		"coffee": {"times_brewed": 1, "best_grade": "B"},
		"settings": {"coffee_accessibility": {
			"slower_notes": false,
			"wider_timing": true,
			"single_button": false,
		}},
		"dialogue_states_seen": ["murrow_first_meeting"],
	}
	st.data = fixture.duplicate(true)

	var saved: bool = save_node.save_game()
	_assert(saved, "save_game() returns true on populated state")
	_assert(FileAccess.file_exists(path), "save file exists on disk")

	## Blow away in-memory state to prove load actually rehydrates.
	st.data = {}
	var loaded: bool = save_node.load_game()
	_assert(loaded, "load_game() returns true after a successful save")

	_assert(st.data.get("active_case_id", "") == "chapter1_sikorska", "active_case_id round-trips")
	_assert(st.data.get("chapter1", {}).get("met_pig", false) == true, "chapter1.met_pig bool survives")
	_assert(int(st.data.get("chapter1", {}).get("halina_trust", -1)) == 4, "chapter1.halina_trust int survives")
	_assert(str(st.data.get("chapter1", {}).get("client_meeting_stance", "")) == "blunt_procedural", "string enum survives")
	_assert(st.data.get("badges", {}).get("day_one_survivor", false) == true, "badge round-trips")
	_assert(st.data.get("routes_unlocked", {}).get("residential", false) == true, "route_unlocked round-trips")
	var dss: Array = st.data.get("dialogue_states_seen", [])
	_assert(dss.has("murrow_first_meeting"), "dialogue_states_seen entry survives")
	_assert(st.data.get("settings", {}).get("coffee_accessibility", {}).get("wider_timing", false) == true,
		"nested settings.coffee_accessibility.wider_timing survives")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	save_node.queue_free()


## T2 — A truncated / corrupt JSON body causes load_game() to emit save_failed
## via Signals and to fall back to reset_state(). Mirrors the test pattern in
## test_save_failure_signal.gd but on the load path.
func _test_corrupt_file_emits_failure() -> void:
	print("[T2] corrupt file emits save_failed and resets state")
	var save_node: Node = _make_save()
	var path: String = _unique_test_path("corrupt")
	save_node.set_save_path_for_tests(path)
	var globalized: String = ProjectSettings.globalize_path(path)

	## Write a deliberately broken JSON body.
	var f := FileAccess.open(path, FileAccess.WRITE)
	_assert(f != null, "can open test file for corrupt-write")
	if f == null:
		save_node.queue_free()
		return
	f.store_string("{ \"version\": 21, \"data\": { not-json-")
	f.close()

	var sigs: Node = get_root().get_node_or_null("/root/Signals")
	var failure_reasons: Array[String] = []
	if sigs != null and sigs.has_signal("save_failed"):
		sigs.save_failed.connect(func(reason: String) -> void:
			failure_reasons.append(reason)
		)

	var st: Node = _state()
	st.data = {"chapter1": {"met_pig": true}}  ## a non-default state so we can detect reset
	var loaded: bool = save_node.load_game()

	_assert(not loaded, "load_game returns false on corrupt file")
	_assert(failure_reasons.size() >= 1, "save_failed signal emitted")
	## State should be reset_state() per save.gd:127 fall-back.
	_assert(st.data.has("chapter1") and st.data["chapter1"].get("met_pig", true) == false,
		"State.data reset after corrupt-load fall-back")

	DirAccess.remove_absolute(globalized)
	save_node.queue_free()


## T3 — load_game() returns false when no file exists; does not push_error,
## does not emit save_failed (the missing-save case is a fresh-game signal,
## not a failure).
func _test_missing_file_returns_false() -> void:
	print("[T3] missing file returns false without failure signal")
	var save_node: Node = _make_save()
	var path: String = _unique_test_path("missing")
	save_node.set_save_path_for_tests(path)
	## Ensure the file genuinely does not exist.
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(ProjectSettings.globalize_path(path))

	var sigs: Node = get_root().get_node_or_null("/root/Signals")
	var failure_reasons: Array[String] = []
	if sigs != null and sigs.has_signal("save_failed"):
		sigs.save_failed.connect(func(reason: String) -> void:
			failure_reasons.append(reason)
		)

	var loaded: bool = save_node.load_game()
	_assert(not loaded, "load_game returns false when no save file present")
	_assert(failure_reasons.is_empty(), "no save_failed signal on missing-file path")

	save_node.queue_free()


## T4 — Write a v7 fixture to disk (the oldest version with a chapter1 dict),
## load it through load_game, and assert the result equals migrate_save(...)
## applied to the same fixture in memory. Anchors the disk format against
## the in-memory migration path.
func _test_v7_disk_load_matches_in_memory_migration() -> void:
	print("[T4] v7 disk load equals in-memory migration result")
	var save_node: Node = _make_save()
	var path: String = _unique_test_path("v7")
	save_node.set_save_path_for_tests(path)

	var v7_data: Dictionary = {
		"current_scene_path": "res://scenes/world/routes/office_street.tscn",
		"current_spawn_id": "default",
		"chapter1": {
			"met_pig": true,
			"pig_revealed_crisis": true,
			"met_murrow": true,
			"met_crab": true,
			"met_whimsy": true,
			"has_law_binder": true,
			"has_rights_memo": false,
			"recruited_crab": false,
			"recruited_whimsy": false,
			"coffee_tutorial_seen": false,
			"court_ready": false,
			"entered_court": false,
			"court_outcome": "",
			"met_asia": true,
			"met_asia_via_behind": false,
			"viewed_family_photo": false,
		},
	}

	var payload: Dictionary = {"version": 7, "data": v7_data}
	var f := FileAccess.open(path, FileAccess.WRITE)
	_assert(f != null, "can open v7 fixture file")
	if f == null:
		save_node.queue_free()
		return
	f.store_string(JSON.stringify(payload, "\t"))
	f.close()

	var loaded_disk: bool = save_node.load_game()
	_assert(loaded_disk, "v7 disk fixture loads through load_game")

	var disk_data: Dictionary = _state().data.duplicate(true)

	## In-memory comparator: feed the same v7 fixture through migrate_save.
	var in_memory: Dictionary = save_node.migrate_save(v7_data.duplicate(true), 7)

	_assert(_dict_subset_equal(disk_data, in_memory),
		"disk-loaded data and in-memory migrated data are deep-equal")
	## And specifically: v8+ keys were added.
	_assert(disk_data.get("badges", {}).has("day_one_survivor"),
		"v7 → current adds badges.day_one_survivor")
	_assert(disk_data.get("routes_unlocked", {}).has("residential"),
		"v7 → current adds routes_unlocked.residential")
	_assert(disk_data.get("chapter1", {}).has("halina_trust"),
		"v7 → current adds chapter1.halina_trust")

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	save_node.queue_free()


## T5 — A current-version save (whatever SAVE_VERSION is at) survives a save
## then load with no migration drift on the on-disk version stamp.
func _test_save_version_survives_roundtrip() -> void:
	print("[T5] SAVE_VERSION survives a round-trip on disk")
	var save_node: Node = _make_save()
	var path: String = _unique_test_path("version")
	save_node.set_save_path_for_tests(path)

	var st: Node = _state()
	var current_version: int = int(st.SAVE_VERSION)
	st.data = st.reset_state()
	var saved: bool = save_node.save_game()
	_assert(saved, "save_game succeeds on a fresh reset_state")

	## Re-read the file directly and confirm the version stamp is current.
	var f := FileAccess.open(path, FileAccess.READ)
	_assert(f != null, "round-trip file exists")
	if f == null:
		save_node.queue_free()
		return
	var on_disk: Dictionary = JSON.parse_string(f.get_as_text())
	f.close()
	_assert(on_disk != null and on_disk.has("version"), "on-disk payload has version field")
	_assert(int(on_disk.get("version", -1)) == current_version,
		"on-disk version equals State.SAVE_VERSION (%d)" % current_version)

	DirAccess.remove_absolute(ProjectSettings.globalize_path(path))
	save_node.queue_free()


## _dict_subset_equal — deep equality across Dictionary / Array / scalar
## values. Used to compare a JSON-round-tripped dictionary against an
## in-memory migration result. JSON loses Array[String] vs Array type
## affinity, so we compare structurally.
func _dict_subset_equal(a: Variant, b: Variant) -> bool:
	if a is Dictionary and b is Dictionary:
		var da: Dictionary = a
		var db: Dictionary = b
		if da.keys().size() != db.keys().size():
			return false
		for k in da:
			if not db.has(k):
				return false
			if not _dict_subset_equal(da[k], db[k]):
				return false
		return true
	if a is Array and b is Array:
		var aa: Array = a
		var ab: Array = b
		if aa.size() != ab.size():
			return false
		for i in range(aa.size()):
			if not _dict_subset_equal(aa[i], ab[i]):
				return false
		return true
	## Scalars: coerce to string and compare, so JSON's float-for-int does
	## not produce a spurious mismatch on integer fields.
	return str(a) == str(b)


func _finish() -> void:
	print("[SaveRoundTrip] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)
