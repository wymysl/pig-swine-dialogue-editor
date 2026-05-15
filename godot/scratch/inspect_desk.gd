extends SceneTree

func _init():
    var img = Image.new()
    img.load("res://art/props/receptionL.png")
    print("receptionL: ", img.get_width(), "x", img.get_height())
    quit()
