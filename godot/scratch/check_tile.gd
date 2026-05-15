extends SceneTree

func _init():
    var img = Image.new()
    img.load("res://art/tiles/office_tile.png")
    print("Tile size: ", img.get_width(), "x", img.get_height())
    quit()
