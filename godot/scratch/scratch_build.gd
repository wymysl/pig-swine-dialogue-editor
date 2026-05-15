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
            tm.set_cell(0, Vector2i(x, y), 0, Vector2i(0, 0))
            
    # Walls (perimeter)
    for x in range(24):
        tm.set_cell(0, Vector2i(x, 0), 1, Vector2i(0, 0))
        tm.set_cell(0, Vector2i(x, 15), 1, Vector2i(0, 0))
    for y in range(16):
        tm.set_cell(0, Vector2i(0, y), 1, Vector2i(0, 0))
        tm.set_cell(0, Vector2i(23, y), 1, Vector2i(0, 0))
        
    # Update terrains (wait, we shouldn't manually set terrain auto-tiles if we are just calling set_cell.
    # To use auto-tiling, we call set_cells_terrain_connect)
    var wall_cells = []
    for x in range(24):
        wall_cells.append(Vector2i(x, 0))
        wall_cells.append(Vector2i(x, 15))
    for y in range(16):
        wall_cells.append(Vector2i(0, y))
        wall_cells.append(Vector2i(23, y))
        
    var floor_cells = []
    for x in range(24):
        for y in range(16):
            if not (x == 0 or x == 23 or y == 0 or y == 15):
                floor_cells.append(Vector2i(x, y))
    
    tm.set_cells_terrain_connect(0, floor_cells, 0, 0)
    tm.set_cells_terrain_connect(0, wall_cells, 0, 1)
    
    var packed = PackedScene.new()
    packed.pack(root)
    ResourceSaver.save(packed, "res://test_office.tscn")
    print("Done building test_office.tscn")
    quit()
