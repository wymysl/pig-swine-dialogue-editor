extends SceneTree

func _init():
    var img = Image.new()
    var err = img.load("res://../../../.gemini/antigravity/brain/0100b3f4-afb9-415e-a318-94b3825634ec/media__1778268799783.png")
    if err != OK:
        print("Failed to load image: ", err)
        quit()
        return

    print("Image size: ", img.get_width(), "x", img.get_height())
    print("Top-left pixel: ", img.get_pixel(0, 0).to_html(false))
    quit()
