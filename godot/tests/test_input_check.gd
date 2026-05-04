extends SceneTree
## Diagnostic: checks whether the four movement actions exist in InputMap at runtime.
func _init() -> void:
	var actions := InputMap.get_actions()
	print("[InputCheck] Total registered actions: ", actions.size())
	for a: String in ["move_up", "move_down", "move_left", "move_right"]:
		var found: bool = InputMap.has_action(a)
		var events: Array[InputEvent] = InputMap.action_get_events(a) if found else []
		print("[InputCheck] '", a, "': registered=", found, " event_count=", events.size())
		for ev: InputEvent in events:
			print("             └ ", ev)
	quit(0)
