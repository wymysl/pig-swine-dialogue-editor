extends SceneTree
## test_motion_packet_assembly.gd — focused BlueBinder v1 packet tests.
## Covers surfaced-only evidence visibility, slot/remedy/decoy state writes,
## incapacity gating by halina_met, and packet scoring/apply minimum gate.

var _pass_count: int = 0
var _fail_count: int = 0

var _state_node: Node = null
var _binder: CanvasLayer = null


func _init() -> void:
	print("[TestMotionPacket] Starting...")
	await process_frame

	_state_node = get_root().get_node_or_null("/root/State")
	if _state_node == null:
		_fail("State autoload not registered")
		_finish()
		return

	var packed: PackedScene = load("res://scenes/ui/blue_binder.tscn") as PackedScene
	if packed == null:
		_fail("blue_binder.tscn loads")
		_finish()
		return
	_binder = packed.instantiate() as CanvasLayer
	if _binder == null:
		_fail("blue_binder scene root is CanvasLayer")
		_finish()
		return

	get_root().add_child(_binder)
	await process_frame

	_test_surfaced_evidence_only()
	_test_slot_and_remedy_state_writes()
	_test_incapacity_gate()
	_test_packet_scoring_and_apply_gate()
	_test_packet_controls_are_keyboard_focusable()

	if _binder != null:
		_binder.queue_free()

	_finish()


func _reset_state() -> void:
	_state_node.data = _state_node.reset_state()


func _ch1() -> Dictionary:
	return _state_node.data["chapter1"]


func _refresh_binder() -> void:
	if _binder != null and _binder.has_method("refresh_from_state"):
		_binder.refresh_from_state()


func _test_surfaced_evidence_only() -> void:
	print("[T1] surfaced-evidence filtering")
	_reset_state()
	var ch1: Dictionary = _ch1()
	ch1["binder_read_envelope"] = true
	ch1["binder_read_renewal"] = true
	ch1["surfaced_notice_timeline"] = true
	_refresh_binder()

	var surfaced: Array = _binder.get_surfaced_evidence_ids()
	_assert(surfaced.has("envelope_address_number_seven"), "envelope evidence is surfaced")
	_assert(surfaced.has("renewal_2019_number_twelve"), "renewal evidence is surfaced")
	_assert(surfaced.has("notice_timeline_april"), "timeline evidence is surfaced")
	_assert(not surfaced.has("payment_receipts_sikorska"), "unsurfaced payment receipts are hidden")
	_assert(not surfaced.has("sikorska_age_visible"), "halina-only evidence hidden before meeting")


func _test_slot_and_remedy_state_writes() -> void:
	print("[T2] slot + remedy state writes")
	_reset_state()
	var ch1: Dictionary = _ch1()
	ch1["binder_read_envelope"] = true
	ch1["binder_read_renewal"] = true
	ch1["surfaced_notice_timeline"] = true
	ch1["surfaced_resident_no_authority"] = true
	_refresh_binder()

	var ok_assign: bool = _binder.assign_evidence_to_slot("element_non_current_address", "envelope_address_number_seven")
	_assert(ok_assign, "assign non-current slot accepts supported evidence")
	_assert(ch1["packet_slot_address_non_current"] == "envelope_address_number_seven", "slot write persisted")
	_assert(ch1["element_non_current_address"] == true, "element flag set true on assignment")

	var invalid_assign: bool = _binder.assign_evidence_to_slot("element_landlord_knowledge", "envelope_address_number_seven")
	_assert(not invalid_assign, "assign rejects unsupported evidence for landlord slot")
	_assert(ch1["packet_slot_landlord_knowledge"] == "", "rejected assignment keeps landlord slot empty")

	var remedy_ok: bool = _binder.set_requested_remedy("merits_dismissal")
	_assert(remedy_ok, "remedy selector accepts merits_dismissal")
	_assert(ch1["packet_requested_remedy"] == "merits_dismissal", "requested remedy persisted")


func _test_incapacity_gate() -> void:
	print("[T3] incapacity decoy gate by halina_met")
	_reset_state()
	_refresh_binder()

	var blocked: bool = _binder.set_decoy_selected("decoy_incapacity", true)
	_assert(not blocked, "incapacity decoy blocked before halina_met")
	_assert(_ch1()["decoy_incapacity"] == false, "incapacity flag remains false before gate")

	_ch1()["halina_met"] = true
	_refresh_binder()
	var allowed: bool = _binder.set_decoy_selected("decoy_incapacity", true)
	_assert(allowed, "incapacity decoy allowed after halina_met")
	_assert(_ch1()["decoy_incapacity"] == true, "incapacity flag writes true after gate")


func _test_packet_scoring_and_apply_gate() -> void:
	print("[T4] packet scoring + minimum apply gate")
	_reset_state()
	var ch1: Dictionary = _ch1()
	ch1["binder_read_envelope"] = true
	ch1["binder_read_renewal"] = true
	ch1["surfaced_notice_timeline"] = true
	ch1["surfaced_resident_no_authority"] = true
	_refresh_binder()

	## Only two required slots -> apply must fail the minimum gate (3).
	_binder.assign_evidence_to_slot("element_non_current_address", "renewal_2019_number_twelve")
	_binder.assign_evidence_to_slot("element_landlord_knowledge", "renewal_2019_number_twelve")
	var blocked: Dictionary = _binder.apply_packet_assessment()
	_assert(blocked.get("applied", true) == false, "apply blocked below minimum required elements")

	## Add third slot and set overbroad remedy via requested remedy choice.
	_binder.assign_evidence_to_slot("element_timely_actual_notice_motion", "notice_timeline_april")
	_binder.set_requested_remedy("dismissal_with_prejudice")
	var applied: Dictionary = _binder.apply_packet_assessment()
	_assert(applied.get("applied", false) == true, "apply succeeds at/above minimum elements")
	_assert(ch1["proposed_frame"] == "overbroad_remedy", "remedy choice drives overbroad_remedy frame")
	_assert(ch1["decoy_overbroad_remedy"] == true, "overbroad-remedy decoy set from non-procedural remedy")
	_assert(ch1["judicial_patience"] == 3, "judicial patience starts at 3 after overbroad-remedy penalty")


func _test_packet_controls_are_keyboard_focusable() -> void:
	print("[T5] keyboard focusable packet controls")
	_reset_state()
	var ch1: Dictionary = _ch1()
	ch1["binder_read_envelope"] = true
	ch1["halina_met"] = true
	_refresh_binder()

	for path in [
		"BinderRoot/PageBody/PacketPanel/PacketVBox/AddressSlotOption",
		"BinderRoot/PageBody/PacketPanel/PacketVBox/LandlordSlotOption",
		"BinderRoot/PageBody/PacketPanel/PacketVBox/NoticeSlotOption",
		"BinderRoot/PageBody/PacketPanel/PacketVBox/AuthoritySlotOption",
		"BinderRoot/PageBody/PacketPanel/PacketVBox/RemedyOption",
		"BinderRoot/PageBody/PacketPanel/PacketVBox/ApplyPacketButton",
	]:
		var control: Control = _binder.get_node_or_null(path) as Control
		_assert(control != null, path + " exists")
		_assert(control != null and control.focus_mode != Control.FOCUS_NONE, path + " accepts focus")

	var tab_bar: HBoxContainer = _binder.get_node_or_null("BinderRoot/PageTabs") as HBoxContainer
	_assert(tab_bar != null, "PageTabs exists")
	_assert(tab_bar != null and tab_bar.get_child_count() > 0, "surfaced evidence builds a tab")
	if tab_bar != null:
		for child in tab_bar.get_children():
			if child is Control:
				_assert(child.focus_mode != Control.FOCUS_NONE, "evidence tab accepts focus")

	var decoy_container: VBoxContainer = _binder.get_node_or_null("BinderRoot/PageBody/PacketPanel/PacketVBox/DecoyOptions") as VBoxContainer
	_assert(decoy_container != null, "DecoyOptions exists")
	_assert(decoy_container != null and decoy_container.get_child_count() > 0, "decoy checkboxes are built")
	if decoy_container != null:
		for child in decoy_container.get_children():
			if child is CheckBox:
				_assert(child.focus_mode != Control.FOCUS_NONE, "decoy checkbox accepts focus")


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: ", msg)
	else:
		_fail_count += 1
		printerr("  FAIL: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[TestMotionPacket] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[TestMotionPacket] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[TestMotionPacket] PASS")
		quit(0)
