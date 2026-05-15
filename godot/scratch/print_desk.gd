extends SceneTree
func _init():
    var img = Image.new()
    img.load("res://art/props/receptionL.png")
    for y in range(0, img.get_height(), 50):
        var row = ""
        for x in range(0, img.get_width(), 25):
            row += "#" if img.get_pixel(x, y).a > 0.1 else "."
        print("%04d %s" % [y, row])
    quit()
