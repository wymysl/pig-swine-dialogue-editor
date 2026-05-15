extends SceneTree

func _init():
    var img = Image.new()
    img.load("res://art/props/receptionL.png")
    
    var min_x = img.get_width()
    var max_x = 0
    var min_y = img.get_height()
    var max_y = 0
    
    for y in range(img.get_height()):
        for x in range(img.get_width()):
            if img.get_pixel(x, y).a > 0.1:
                if x < min_x: min_x = x
                if x > max_x: max_x = x
                if y < min_y: min_y = y
                if y > max_y: max_y = y
                
    print("Opaque bounds:")
    print("  Min X: ", min_x)
    print("  Max X: ", max_x)
    print("  Min Y: ", min_y)
    print("  Max Y: ", max_y)
    print("  Width: ", max_x - min_x + 1)
    print("  Height: ", max_y - min_y + 1)
    
    quit()
