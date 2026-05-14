extends SceneTree

func _init() -> void:
	var box_packed: PackedScene = load("res://scenes/ui/dialogue_box.tscn")
	if box_packed == null:
		printerr("[TypewriterTest] FAIL: could not load dialogue_box.tscn")
		quit(1)
		return
		
	var box = box_packed.instantiate()
	get_root().add_child(box)
	await process_frame
	
	if not InputMap.has_action("interact"):
		InputMap.add_action("interact")
		
	box._on_dialogue_line_ready("Tester", "tester", ["This is a test line with quite a few characters."])
	
	# wait a few frames to let process run
	await process_frame
	await process_frame
	
	var text_label = box.get_node("Panel/TextLabel")
	var initial_chars = text_label.visible_characters
	
	# After some delta, visible characters should be > 0 but < total
	box._process(0.1)
	var chars_after_01s = text_label.visible_characters
	
	if chars_after_01s <= initial_chars:
		printerr("[TypewriterTest] FAIL: visible_characters did not increase after _process")
		quit(1)
		return
		
	if chars_after_01s >= text_label.get_total_character_count():
		printerr("[TypewriterTest] FAIL: Text revealed too fast")
		quit(1)
		return
		
	# Now simulate "interact" press to complete early
	var ev = InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	box._unhandled_input(ev)
	
	if text_label.visible_characters != -1:
		printerr("[TypewriterTest] FAIL: Text not fully revealed (-1) after interact press")
		quit(1)
		return
		
	if box._is_typing:
		printerr("[TypewriterTest] FAIL: _is_typing should be false after early completion")
		quit(1)
		return
		
	# Second press should close
	ev = InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	box._unhandled_input(ev)
	
	if box._visible_now:
		printerr("[TypewriterTest] FAIL: Box should be hidden after second press")
		quit(1)
		return

	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		printerr("[TypewriterTest] FAIL: Signals autoload missing")
		quit(1)
		return
	var dismiss_capture: Array = [0]
	sigs.dialogue_dismissed.connect(func() -> void:
		dismiss_capture[0] += 1
	)

	box._on_dialogue_line_ready("Tester", "tester", ["First page.", "Second page."])
	text_label.visible_characters = -1
	box._is_typing = false
	ev = InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	box._unhandled_input(ev)

	if dismiss_capture[0] != 0:
		printerr("[TypewriterTest] FAIL: dialogue_dismissed fired while advancing pages")
		quit(1)
		return
	if not box._visible_now:
		printerr("[TypewriterTest] FAIL: Box should stay visible after page advance")
		quit(1)
		return

	text_label.visible_characters = -1
	box._is_typing = false
	ev = InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	box._unhandled_input(ev)

	if dismiss_capture[0] != 1:
		printerr("[TypewriterTest] FAIL: dialogue_dismissed should fire exactly once on final close")
		quit(1)
		return

	print("[TypewriterTest] PASS")
	quit(0)
