extends SceneTree

var scene
var asia

func _init():
    scene = load("res://scenes/interiors/pig_swine_office.tscn").instantiate()
    root.add_child(scene)
    asia = scene.get_node("Asia")
    
    var t = create_timer(4.0)
    t.timeout.connect(_check_pos)

func _check_pos():
    print("Asia pos at 4s: ", asia.global_position)
    print("Is patrolling: ", asia.is_patrolling)
    
    var t = create_timer(2.0)
    t.timeout.connect(_check_pos_2)
    
func _check_pos_2():
    print("Asia pos at 6s: ", asia.global_position)
    print("Is patrolling: ", asia.is_patrolling)
    quit()
