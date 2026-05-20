extends SceneTree

func _init() -> void:
	var npc_script = load("res://scripts/actors/npc.gd")
	var npc = npc_script.new()
	npc.npc_color = Color.RED
	var player = CharacterBody2D.new()
	player.add_to_group("player")
	
	var root = Node2D.new()
	root.add_child(npc)
	root.add_child(player)
	get_root().add_child(root)
	await process_frame
	
	var prompt = npc._prompt
	if prompt == null:
		printerr("FAIL: Prompt not instantiated")
		quit(1)
		return

	var label: Label = prompt.get_node_or_null("ColorRect/Label") as Label
	if label == null:
		printerr("FAIL: Prompt label missing")
		quit(1)
		return
	if label.text != "[E]":
		printerr("FAIL: Prompt should resolve interact binding as [E], got " + label.text)
		quit(1)
		return
	if prompt.has_method("set_action_name"):
		prompt.set_action_name("case_folder_toggle")
		await process_frame
		if label.text != "[B]":
			printerr("FAIL: Prompt should resolve case_folder_toggle binding as [B], got " + label.text)
			quit(1)
			return
		prompt.set_action_name("interact")
		
	if prompt.visible:
		printerr("FAIL: Prompt should be invisible initially")
		quit(1)
		return
		
	npc._on_body_entered(player)
	if not prompt.visible:
		printerr("FAIL: Prompt should be visible after player entered")
		quit(1)
		return
		
	npc._on_body_exited(player)
	
	var t = create_timer(0.2)
	await t.timeout
	
	if prompt.visible:
		printerr("FAIL: Prompt should be invisible after player exited")
		quit(1)
		return

	print("PASS — test_interaction_prompt.gd")
	quit(0)
