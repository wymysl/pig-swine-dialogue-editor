extends SceneTree

func _init():
    var scene = load("res://scenes/interiors/pig_swine_office.tscn").instantiate()
    var asia = scene.get_node("Asia")
    var visual = asia.get_node("Visual")
    print("Asia default_facing: ", asia.default_facing)
    print("Asia animation: ", visual.animation)
    quit()
