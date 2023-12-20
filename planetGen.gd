extends Node

func createPlanet():
	var node = $Planet.new()
	print(node.get_meta("Momentum"))
	# the parent can be get_tree().get_root() or some other node
	get_tree().get_root().add_child(node)
	# ownership is different, I think it's not the same root as the root node
	node.set_owner(get_tree().get_edited_scene_root())
	print("Planet formed from rock and stone")
	
