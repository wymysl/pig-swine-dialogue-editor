extends SceneTree

func _init():
    var img1 = Image.new()
    img1.load("res://art/portraits/asia.png")
    var img2 = Image.new()
    img2.load("res://art/portraits/pig.png")
    print("asia: ", img1.get_width(), "x", img1.get_height())
    print("pig: ", img2.get_width(), "x", img2.get_height())
    quit()
