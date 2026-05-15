extends SceneTree

func _init():
    var scene = load("res://scenes/interiors/pig_swine_office.tscn").instantiate()
    var desk = scene.get_node("ReceptionDesk")
    var vis = desk.get_node("Visual")
    var c_bottom = desk.get_node("Collision/CollisionBottom")
    var c_left = desk.get_node("Collision/CollisionLeft")
    
    var tex = vis.texture
    if tex:
        var w = tex.get_width() * vis.scale.x
        var h = tex.get_height() * vis.scale.y
        var top_left = vis.position + vis.offset * vis.scale - Vector2(w/2, h/2)
        print("Visual Sprite Bounding Box:")
        print("  TopLeft: ", top_left)
        print("  Size: ", Vector2(w, h))
        print("  BottomRight: ", top_left + Vector2(w, h))
        
    print("CollisionBottom:")
    var sb = c_bottom.shape.size
    print("  TopLeft: ", c_bottom.position - sb/2)
    print("  Size: ", sb)
    print("  BottomRight: ", c_bottom.position + sb/2)
    
    print("CollisionLeft:")
    var sl = c_left.shape.size
    print("  TopLeft: ", c_left.position - sl/2)
    print("  Size: ", sl)
    print("  BottomRight: ", c_left.position + sl/2)
    
    print("MeetingDivider Wall Global Pos:")
    var wall = scene.get_node("InteriorWalls/MeetingDivider")
    print("  ", scene.get_node("InteriorWalls").transform * wall.position)

    quit()
