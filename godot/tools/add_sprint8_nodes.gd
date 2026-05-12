@tool
extends SceneTree

func _init() -> void:
	# 1. Update pig_swine_office.tscn
	var office_path = "res://scenes/interiors/pig_swine_office.tscn"
	var office_packed = ResourceLoader.load(office_path)
	if office_packed:
		var root = office_packed.instantiate()
		
		# Procedural Binder
		if not root.has_node("ProceduralBinder"):
			var pb = load("res://scripts/actors/pickup.gd").new()
			pb.name = "ProceduralBinder"
			pb.item_id = "procedural_binder"
			pb.state_flag_path = "chapter1.has_law_binder"
			pb.display_name = "Procedural Binder"
			pb.pickup_line = "A heavy tome on administrative law. Better take it."
			pb.position = Vector2(560, 300) # near Mr. Pig
			pb.collision_layer = 4
			pb.collision_mask = 2
			root.add_child(pb)
			pb.owner = root
			
		# Murrow Sprite
		var murrow = root.get_node_or_null("Murrow")
		if murrow:
			if murrow.has_node("Visual") and murrow.get_node("Visual") is ColorRect:
				murrow.get_node("Visual").free()
			
			if not murrow.has_node("Visual"):
				var spr = Sprite2D.new()
				spr.name = "Visual"
				spr.texture = load("res://art/sprites/murrow/murrow_idle_front.png")
				spr.position = Vector2(0, -8)
				murrow.add_child(spr)
				spr.owner = root
				
		var new_packed = PackedScene.new()
		new_packed.pack(root)
		ResourceSaver.save(new_packed, office_path)
		print("Updated pig_swine_office.tscn")
		root.queue_free()

	# 2. Update archive_room.tscn
	var archive_path = "res://scenes/interiors/archive_room.tscn"
	var archive_packed = ResourceLoader.load(archive_path)
	if archive_packed:
		var root = archive_packed.instantiate()
		
		# Rights Memo
		if not root.has_node("RightsMemo"):
			var rm = load("res://scripts/actors/pickup.gd").new()
			rm.name = "RightsMemo"
			rm.item_id = "rights_memo"
			rm.state_flag_path = "chapter1.has_rights_memo"
			rm.display_name = "Rights Memo"
			rm.pickup_line = "A dusty memo concerning suspect rights."
			rm.position = Vector2(400, 200) # on a shelf area
			rm.collision_layer = 4
			rm.collision_mask = 2
			root.add_child(rm)
			rm.owner = root
			
		# Crab Sprite
		var crab = root.get_node_or_null("Crab")
		if crab:
			if crab.has_node("Visual") and crab.get_node("Visual") is ColorRect:
				crab.get_node("Visual").free()
				
			if not crab.has_node("Visual"):
				var spr = Sprite2D.new()
				spr.name = "Visual"
				spr.texture = load("res://art/sprites/crab/crab_idle_front.png")
				spr.position = Vector2(0, -8)
				crab.add_child(spr)
				spr.owner = root
				
		var new_packed = PackedScene.new()
		new_packed.pack(root)
		ResourceSaver.save(new_packed, archive_path)
		print("Updated archive_room.tscn")
		root.queue_free()

	# 3. Update cafe_paragraf.tscn
	var cafe_path = "res://scenes/interiors/cafe_paragraf.tscn"
	var cafe_packed = ResourceLoader.load(cafe_path)
	if cafe_packed:
		var root = cafe_packed.instantiate()
		
		# Coffee Machine
		if not root.has_node("CoffeeMachine"):
			var cm = load("res://scripts/actors/minigame_trigger.gd").new()
			cm.name = "CoffeeMachine"
			cm.minigame_scene_path = "res://scenes/minigames/coffee_brewing.tscn"
			cm.position = Vector2(300, 200) # near Whimsy
			cm.collision_layer = 4
			cm.collision_mask = 2
			root.add_child(cm)
			cm.owner = root
			
		# Whimsy Sprite
		var whimsy = root.get_node_or_null("Whimsy")
		if whimsy:
			if whimsy.has_node("Visual") and whimsy.get_node("Visual") is ColorRect:
				whimsy.get_node("Visual").free()
				
			if not whimsy.has_node("Visual"):
				var spr = Sprite2D.new()
				spr.name = "Visual"
				spr.texture = load("res://art/sprites/whimsy/whimsy_idle_front.png")
				spr.position = Vector2(0, -8)
				whimsy.add_child(spr)
				spr.owner = root
				
		var new_packed = PackedScene.new()
		new_packed.pack(root)
		ResourceSaver.save(new_packed, cafe_path)
		print("Updated cafe_paragraf.tscn")
		root.queue_free()

	print("Done modifying scenes.")
	quit()
