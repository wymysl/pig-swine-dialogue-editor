extends SceneTree

func _init():
    var root = Node2D.new()
    root.name = "PigSwineOffice"
    root.y_sort_enabled = true
    
    var tm = TileMap.new()
    tm.name = "TileMap"
    tm.tile_set = load("res://art/tilesets/office_tileset.tres")
    root.add_child(tm)
    tm.owner = root
    
    # Fill floor 24x16 (0 to 23, 0 to 15)
    for x in range(24):
        for y in range(16):
            tm.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0)) # Assuming source 0 is floor, atlas 0,0
            
    # Walls (perimeter)
    for x in range(24):
        tm.set_cell(0, Vector2i(x, 0), 1, Vector2i(0, 0))
        tm.set_cell(0, Vector2i(x, 15), 1, Vector2i(0, 0))
    for y in range(16):
        tm.set_cell(0, Vector2i(0, y), 1, Vector2i(0, 0))
        tm.set_cell(0, Vector2i(23, y), 1, Vector2i(0, 0))
        
    # Update terrains
    tm.set_cells_terrain_connect(0, tm.get_used_cells(0), 0, 0)
    
    var packed = PackedScene.new()
    packed.pack(root)
    ResourceSaver.save(packed, "res://test_office.tscn")
    print("Done building test_office.tscn")
    quit()
