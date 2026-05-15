extends SceneTree

func _init():
    var scene = load("res://scenes/interiors/pig_swine_office.tscn").instantiate()
    var asia = scene.get_node("Asia")
    print("Has FileCabinet: ", asia.get_node_or_null("../FileCabinet") != null)
    quit()
