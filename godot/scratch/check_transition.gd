extends SceneTree

func _init():
    var img = Image.new()
    img.load("res://art/props/receptionL.png")
    
    var transition_y = 0
    for y in range(32, 1045):
        var max_x_in_row = 0
        for x in range(img.get_width() - 1, -1, -1):
            if img.get_pixel(x, y).a > 0.1:
                max_x_in_row = x
                break
        if max_x_in_row > 800:
            transition_y = y
            break
            
    print("Transition Y: ", transition_y)
    quit()
