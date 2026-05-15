extends SceneTree

func _init():
    var dir = DirAccess.open("res://art/portraits")
    if dir:
        dir.list_dir_begin()
        var file_name = dir.get_next()
        while file_name != "":
            if !dir.current_is_dir() and file_name.ends_with(".png"):
                var img = Image.new()
                img.load("res://art/portraits/" + file_name)
                print(file_name, ": ", img.get_width(), "x", img.get_height())
            file_name = dir.get_next()
    quit()
