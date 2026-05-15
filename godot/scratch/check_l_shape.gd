extends SceneTree

func _init():
    var img = Image.new()
    img.load("res://art/props/receptionL.png")
    
    print("Row Y=50:")
    var row = ""
    for x in range(250, 1250, 50):
        row += "#" if img.get_pixel(x, 50).a > 0.1 else "."
    print(row)
    
    print("Row Y=500:")
    row = ""
    for x in range(250, 1250, 50):
        row += "#" if img.get_pixel(x, 500).a > 0.1 else "."
    print(row)
    
    print("Row Y=1000:")
    row = ""
    for x in range(250, 1250, 50):
        row += "#" if img.get_pixel(x, 1000).a > 0.1 else "."
    print(row)
    quit()
