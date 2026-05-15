extends SceneTree

func _init():
    var img = Image.new()
    var err = img.load("res://../art_reference/asia_reception_desk_geometry_guide_transparent.png")
    if err != OK:
        quit()
        return
        
    var w = img.get_width()
    var h = img.get_height()
    print("Dimensions: ", w, "x", h)
    
    var solid_count = 0
    for y in range(h):
        for x in range(w):
            if img.get_pixel(x, y).a > 0.5:
                solid_count += 1
                
    print("Solid pixels: ", solid_count)
    quit()
