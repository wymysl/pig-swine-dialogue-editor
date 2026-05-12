@tool
extends SceneTree

func _init() -> void:
	var scenes = {
		"res://scenes/world/routes/office_street.tscn": Vector2(960, 640),
		"res://scenes/interiors/pig_swine_office.tscn": Vector2(960, 640),
		"res://scenes/interiors/archive_room.tscn": Vector2(640, 480),
		"res://scenes/interiors/cafe_paragraf.tscn": Vector2(640, 480)
	}
	
	for path in scenes.keys():
		var size = scenes[path]
		var packed = ResourceLoader.load(path)
		if not packed:
			print("Missing scene: ", path)
			continue
			
		var root = packed.instantiate()
		if root.has_node("Walls"):
			root.get_node("Walls").free()
			
		var walls = StaticBody2D.new()
		walls.name = "Walls"
		walls.collision_layer = 1
		walls.collision_mask = 0
		root.add_child(walls)
		walls.owner = root
		
		# Top
		var top_col = CollisionShape2D.new()
		top_col.name = "Top"
		var top_shape = RectangleShape2D.new()
		top_shape.size = Vector2(size.x, 16)
		top_col.shape = top_shape
		top_col.position = Vector2(size.x / 2, -8)
		walls.add_child(top_col)
		top_col.owner = root
		
		# Bottom
		var bot_col = CollisionShape2D.new()
		bot_col.name = "Bottom"
		var bot_shape = RectangleShape2D.new()
		bot_shape.size = Vector2(size.x, 16)
		bot_col.shape = bot_shape
		bot_col.position = Vector2(size.x / 2, size.y + 8)
		walls.add_child(bot_col)
		bot_col.owner = root
		
		# Left
		var left_col = CollisionShape2D.new()
		left_col.name = "Left"
		var left_shape = RectangleShape2D.new()
		left_shape.size = Vector2(16, size.y)
		left_col.shape = left_shape
		left_col.position = Vector2(-8, size.y / 2)
		walls.add_child(left_col)
		left_col.owner = root
		
		# Right
		var right_col = CollisionShape2D.new()
		right_col.name = "Right"
		var right_shape = RectangleShape2D.new()
		right_shape.size = Vector2(16, size.y)
		right_col.shape = right_shape
		right_col.position = Vector2(size.x + 8, size.y / 2)
		walls.add_child(right_col)
		right_col.owner = root
		
		var new_packed = PackedScene.new()
		new_packed.pack(root)
		ResourceSaver.save(new_packed, path)
		print("Added Walls to ", path)
		root.queue_free()
		
	print("Done adding walls.")
	quit()
