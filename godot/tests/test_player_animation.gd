extends SceneTree

func _init() -> void:
	var player_script = load("res://scripts/actors/player.gd")
	var player = player_script.new()
	var anim = AnimatedSprite2D.new()
	anim.name = "Visual"
	player.add_child(anim)
	player.anim = anim
	
	player._update_facing(Vector2(0, -1))
	if player._last_facing != "back":
		printerr("FAIL: Expected back, got ", player._last_facing)
		quit(1)
		return
		
	player._update_facing(Vector2(-1, 0))
	if player._last_facing != "left":
		printerr("FAIL: Expected left, got ", player._last_facing)
		quit(1)
		return
		
	player._update_facing(Vector2(1, 1))
	if player._last_facing != "front_right":
		printerr("FAIL: Expected front_right, got ", player._last_facing)
		quit(1)
		return

	print("PASS — test_player_animation.gd")
	quit(0)
