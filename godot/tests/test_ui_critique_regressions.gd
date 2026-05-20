extends SceneTree
## test_ui_critique_regressions.gd — focused guards for 2026-05-19 UI critique fixes.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	await process_frame
	_test_binder_action_removed()
	await _test_dialogue_speaker_hierarchy()
	await _test_battle_screen_resource_labels()
	_finish()


func _test_binder_action_removed() -> void:
	print("[T1] legacy binder action")
	_assert(not InputMap.has_action("binder"), "legacy binder input action is removed")
	_assert(InputMap.has_action("case_folder_toggle"), "case_folder_toggle remains the live folder action")


func _test_dialogue_speaker_hierarchy() -> void:
	print("[T2] dialogue hierarchy")
	var packed: PackedScene = load("res://scenes/ui/dialogue_box.tscn") as PackedScene
	_assert(packed != null, "dialogue_box.tscn loads")
	if packed == null:
		return
	var instance: Node = packed.instantiate()
	get_root().add_child(instance)
	await process_frame
	var speaker: Label = instance.get_node_or_null("Panel/SpeakerLabel") as Label
	var text: Label = instance.get_node_or_null("Panel/TextLabel") as Label
	_assert(speaker != null, "SpeakerLabel exists")
	_assert(text != null, "TextLabel exists")
	if speaker != null and text != null:
		_assert(speaker.get_theme_font_size("font_size") > text.get_theme_font_size("font_size"), "speaker label is larger than body text")
	instance.queue_free()


func _test_battle_screen_resource_labels() -> void:
	print("[T3] battle screen resources")
	var packed: PackedScene = load("res://scenes/ui/battle_screen.tscn") as PackedScene
	_assert(packed != null, "battle_screen.tscn loads")
	if packed == null:
		return
	var instance: Node = packed.instantiate()
	get_root().add_child(instance)
	await process_frame
	_assert(instance.get_script() != null, "battle screen has a real script")
	var cooperation_bar: ProgressBar = instance.get_node_or_null("CooperationBar") as ProgressBar
	var patience_bar: ProgressBar = instance.get_node_or_null("PatienceBar") as ProgressBar
	var cooperation_label: Label = instance.get_node_or_null("CooperationValueLabel") as Label
	var patience_label: Label = instance.get_node_or_null("PatienceValueLabel") as Label
	_assert(cooperation_bar != null and not cooperation_bar.show_percentage, "cooperation bar hides percentage-only text")
	_assert(patience_bar != null and not patience_bar.show_percentage, "patience bar hides percentage-only text")
	_assert(cooperation_label != null and cooperation_label.text == "10/10", "cooperation value label shows value/max")
	_assert(patience_label != null and patience_label.text == "10/10", "patience value label shows value/max")
	if instance.has_method("set_witness_cooperation"):
		instance.call("set_witness_cooperation", 7, 10)
	if instance.has_method("set_judicial_patience"):
		instance.call("set_judicial_patience", 4, 10)
	_assert(cooperation_label != null and cooperation_label.text == "7/10", "cooperation label updates through controller")
	_assert(patience_label != null and patience_label.text == "4/10", "patience label updates through controller")
	instance.queue_free()


func _assert(condition: bool, msg: String) -> void:
	if condition:
		_pass_count += 1
		print("  PASS: ", msg)
	else:
		_fail_count += 1
		printerr("  FAIL: ", msg)


func _finish() -> void:
	print("[UICritiqueRegressionTest] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		quit(0)
