extends SceneTree
## tests/test_npc_presence.gd — exercises the `presence_flags` /
## `presence_logic` machinery on npc.gd and verifies that the office
## NPCs' canonical default ("always present") holds under every
## representative chapter1 flag state in the current schema.
##
## Tests:
##   T1: empty presence_flags → NPC visible.
##   T2: single flag, "any" logic → visible iff flag is true; re-evaluates
##       on Signals.chapter1_flag_changed.
##   T3: two flags, "any" logic → visible iff at least one flag is true.
##   T4: two flags, "all" logic → visible iff both flags are true; flipping
##       one flag back to false re-hides on signal.
##   T5: Area2D `monitoring` / `monitorable` are disabled while hidden so
##       the player cannot trigger dialogue against an invisible NPC.
##   T6: Canonical office roster — Mr. Pig and Murrow (empty presence_flags
##       by default) remain visible across every representative chapter1
##       flag state. Asia and the not-yet-existing Halina are out of scope
##       per the prompt spec.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[TestNPCPresence] Starting...")
	await process_frame

	var npc_script := load("res://scripts/actors/npc.gd") as GDScript
	if npc_script == null:
		_fail("Could not load npc.gd")
		_finish()
		return

	var state_node = get_root().get_node_or_null("/root/State")
	if state_node == null:
		_fail("State autoload not available")
		_finish()
		return

	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		_fail("Signals autoload not available")
		_finish()
		return
	if not sigs.has_signal("chapter1_flag_changed"):
		_fail("Signals.chapter1_flag_changed not declared")
		_finish()
		return

	## Helper: reset every bool flag in chapter1 to false. Leaves non-bool
	## fields (court_outcome, etc.) untouched.
	var reset_ch1 := func() -> void:
		var d: Dictionary = state_node.data["chapter1"]
		for k in d.keys():
			if typeof(d[k]) == TYPE_BOOL:
				d[k] = false

	## --- T1: empty presence_flags → visible.
	reset_ch1.call()
	var n1 := _make_npc(npc_script, "t1", [] as Array[String], "any")
	get_root().add_child(n1)
	await process_frame
	if n1.visible:
		_pass("T1: empty presence_flags → visible by default")
	else:
		_fail("T1: empty presence_flags should be visible, got visible=false")

	## --- T2: single flag, "any" logic.
	reset_ch1.call()
	var n2 := _make_npc(npc_script, "t2", ["met_pig"] as Array[String], "any")
	get_root().add_child(n2)
	await process_frame
	if not n2.visible:
		_pass("T2a: single flag any, flag=false → hidden")
	else:
		_fail("T2a: expected hidden, got visible=true")
	state_node.data["chapter1"]["met_pig"] = true
	sigs.chapter1_flag_changed.emit("met_pig", true)
	await process_frame
	if n2.visible:
		_pass("T2b: single flag any, flag=true → visible after signal")
	else:
		_fail("T2b: expected visible after signal, still hidden")

	## --- T3: two flags, "any" semantics.
	reset_ch1.call()
	var n3 := _make_npc(npc_script, "t3", ["met_pig", "met_murrow"] as Array[String], "any")
	get_root().add_child(n3)
	await process_frame
	if not n3.visible:
		_pass("T3a: any-of-two, both false → hidden")
	else:
		_fail("T3a: expected hidden, got visible=true")
	state_node.data["chapter1"]["met_murrow"] = true
	sigs.chapter1_flag_changed.emit("met_murrow", true)
	await process_frame
	if n3.visible:
		_pass("T3b: any-of-two, one true → visible")
	else:
		_fail("T3b: expected visible, still hidden")

	## --- T4: two flags, "all" semantics; flip-back re-hides.
	reset_ch1.call()
	var n4 := _make_npc(npc_script, "t4", ["met_pig", "met_murrow"] as Array[String], "all")
	get_root().add_child(n4)
	await process_frame
	state_node.data["chapter1"]["met_pig"] = true
	sigs.chapter1_flag_changed.emit("met_pig", true)
	await process_frame
	if not n4.visible:
		_pass("T4a: all-of-two, only one true → hidden")
	else:
		_fail("T4a: expected hidden, got visible=true")
	state_node.data["chapter1"]["met_murrow"] = true
	sigs.chapter1_flag_changed.emit("met_murrow", true)
	await process_frame
	if n4.visible:
		_pass("T4b: all-of-two, both true → visible")
	else:
		_fail("T4b: expected visible, still hidden")
	state_node.data["chapter1"]["met_pig"] = false
	sigs.chapter1_flag_changed.emit("met_pig", false)
	await process_frame
	if not n4.visible:
		_pass("T4c: all-of-two, flag re-flipped → re-hidden after signal")
	else:
		_fail("T4c: expected re-hidden after flag flipped false")

	## --- T5: monitoring / monitorable disabled while hidden.
	reset_ch1.call()
	var n5 := _make_npc(npc_script, "t5", ["recruited_crab"] as Array[String], "any")
	get_root().add_child(n5)
	await process_frame
	if not n5.visible and not n5.monitoring and not n5.monitorable:
		_pass("T5a: hidden NPC has monitoring=false and monitorable=false")
	else:
		_fail("T5a: expected hidden+monitoring=false+monitorable=false, got visible=%s monitoring=%s monitorable=%s" \
			% [n5.visible, n5.monitoring, n5.monitorable])
	state_node.data["chapter1"]["recruited_crab"] = true
	sigs.chapter1_flag_changed.emit("recruited_crab", true)
	await process_frame
	if n5.visible and n5.monitoring and n5.monitorable:
		_pass("T5b: visible NPC has monitoring=true and monitorable=true")
	else:
		_fail("T5b: expected visible+monitoring=true+monitorable=true, got visible=%s monitoring=%s monitorable=%s" \
			% [n5.visible, n5.monitoring, n5.monitorable])

	## --- T6: canonical office roster — MrPig and Murrow are always present.
	## Both use the default empty presence_flags; we simulate each in turn
	## and confirm visibility holds across every representative chapter1
	## state today.
	var mr_pig := _make_npc(npc_script, "pig", [] as Array[String], "any")
	var murrow := _make_npc(npc_script, "murrow", [] as Array[String], "any")
	get_root().add_child(mr_pig)
	get_root().add_child(murrow)
	await process_frame
	var states := [
		{},
		{"met_pig": true},
		{"met_pig": true, "pig_revealed_crisis": true},
		{"met_pig": true, "pig_revealed_crisis": true, "met_murrow": true},
		{"has_law_binder": true, "recruited_crab": true},
		{"recruited_crab": true, "recruited_whimsy": true, "court_ready": true},
		{"entered_court": true},
		{"entered_court": true, "court_outcome": "won"},
	]
	var canonical_ok := true
	var failing_state: Variant = null
	for s in states:
		reset_ch1.call()
		for k in s.keys():
			state_node.data["chapter1"][k] = s[k]
		sigs.chapter1_flag_changed.emit("__bulk__", true)
		await process_frame
		if not (mr_pig.visible and murrow.visible):
			canonical_ok = false
			failing_state = s
			break
	if canonical_ok:
		_pass("T6: MrPig and Murrow stay visible across canonical chapter1 states")
	else:
		_fail("T6: MrPig/Murrow should stay visible under " + str(failing_state) \
			+ " (pig.visible=%s, murrow.visible=%s)" % [mr_pig.visible, murrow.visible])

	_finish()


func _make_npc(npc_script: GDScript, id: String, flags: Array[String], logic: String) -> Area2D:
	var n := Area2D.new()
	n.set_script(npc_script)
	n.npc_id = id
	n.display_name = id
	n.presence_flags = flags
	n.presence_logic = logic
	return n


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[TestNPCPresence] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestNPCPresence] FAIL: ", msg)


func _finish() -> void:
	print("[TestNPCPresence] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestNPCPresence] PASS")
		quit(0)
