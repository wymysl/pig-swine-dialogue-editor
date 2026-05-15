extends SceneTree

func _init():
    var img = Image.new()
    var err = img.load("res://../art_reference/asia_reception_desk_geometry_guide.png")
    if err != OK:
        print("Failed to load image: ", err)
        quit()
        return
        
    var w = img.get_width()
    var h = img.get_height()
    print("Dimensions: ", w, "x", h)
    
    for y in range(0, h, 4):
        var row = ""
        for x in range(0, w, 4):
            var c = img.get_pixel(x, y)
            if c.a < 0.5:
                row += "."
            else:
                row += "#"
        print(row)

    quit()
