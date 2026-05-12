extends AudioStreamPlayer

func _ready() -> void:
	var root = get_tree().root
	var existing_bgm = root.get_node_or_null("BGM")
	
	if existing_bgm and existing_bgm is AudioStreamPlayer:
		var same_track = false
		if existing_bgm.stream and self.stream:
			if existing_bgm.stream == self.stream or existing_bgm.stream.resource_path == self.stream.resource_path:
				same_track = true
				
		if same_track:
			# The exact same track is already playing. Kill this new one so the old one continues smoothly.
			queue_free()
			return
		else:
			# A different track was playing. Stop it and replace it.
			existing_bgm.name = "BGM_Old"
			existing_bgm.queue_free()
			
	# We are the new active music. Reparent to root so we survive room transitions.
	# We must defer the removal because the scene tree is locked during _ready.
	call_deferred("_do_reparent")

func _do_reparent() -> void:
	var tree = get_tree()
	if not tree:
		return
	var root = tree.root
	
	var p = get_parent()
	if p:
		p.remove_child(self)
	
	root.add_child(self)
	self.name = "BGM"
	
	if not playing and autoplay:
		play()
