extends SceneTree
## Verifies DialogueBox only emits dialogue_dismissed when the panel actually
## closes, not when the player advances from one dialogue page to the next.

var _pass_count: int = 0
var _fail_count: int = 0


func _init() -> void:
	print("[DialogueBoxDismissalSignalTest] Starting...")
	await process_frame

	var sigs = get_root().get_node_or_null("/root/Signals")
	if sigs == null:
		_fail("Signals autoload not registered")
		_finish()
		return

	var box_packed: PackedScene = load("res://scenes/ui/dialogue_box.tscn")
	if box_packed == null:
		_fail("Could not load dialogue_box.tscn")
		_finish()
		return

	var box = box_packed.instantiate()
	get_root().add_child(box)
	await process_frame

	var dismiss_count: Array = [0]
	sigs.dialogue_dismissed.connect(func() -> void:
		dismiss_count[0] += 1
	)

	box._on_dialogue_line_ready("Tester", "tester", ["First page.", "Second page."])
	box._is_typing = false
	box._text_label.visible_characters = -1

	var ev := InputEventAction.new()
	ev.action = "interact"
	ev.pressed = true
	box._unhandled_input(ev)

	if dismiss_count[0] == 0 and box._visible_now and box._text_label.text == "Second page.":
		_pass("T1: advancing to page two does not emit dialogue_dismissed")
	else:
		_fail("T1: page advance should keep box open and emit no dismiss; count=%s visible=%s text=%s" % [
			str(dismiss_count[0]), str(box._visible_now), box._text_label.text
		])

	box._is_typing = false
	box._text_label.visible_characters = -1
	box._unhandled_input(ev)

	if dismiss_count[0] == 1 and not box._visible_now:
		_pass("T2: closing after final page emits dialogue_dismissed exactly once")
	else:
		_fail("T2: final close should emit one dismiss and hide box; count=%s visible=%s" % [
			str(dismiss_count[0]), str(box._visible_now)
		])

	## T3 — pressing E while typewriter is still revealing text should NOT
	## emit dialogue_dismissed. It should only complete the text reveal.
	## Regression test for a bug where the _is_typing branch fell through
	## to the dialogue_dismissed emit.
	dismiss_count[0] = 0
	box._on_dialogue_line_ready("Tester", "tester", ["One slow line."])
	## Simulate mid-typing state: visible_characters < total means typing.
	box._is_typing = true
	box._text_label.visible_characters = 3
	box._unhandled_input(ev)

	if dismiss_count[0] == 0 and box._visible_now and box._is_typing == false \
			and box._text_label.visible_characters == -1:
		_pass("T3: pressing E during typewriter completes text without dismiss")
	else:
		_fail("T3: typewriter skip should keep box open and not dismiss; count=%s visible=%s typing=%s" % [
			str(dismiss_count[0]), str(box._visible_now), str(box._is_typing)
		])

	box.queue_free()
	paused = false
	_finish()


func _pass(msg: String) -> void:
	_pass_count += 1
	print("[DialogueBoxDismissalSignalTest] PASS: ", msg)


func _fail(msg: String) -> void:
	_fail_count += 1
	printerr("[DialogueBoxDismissalSignalTest] FAIL: ", msg)


func _finish() -> void:
	print("")
	print("[DialogueBoxDismissalSignalTest] Results: %d passed, %d failed" % [_pass_count, _fail_count])
	if _fail_count > 0:
		quit(1)
	else:
		print("[DialogueBoxDismissalSignalTest] PASS")
		quit(0)
