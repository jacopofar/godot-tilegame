extends Node

# Traverse the node tree and replace Tiled objects
func post_import(scene):
	# Load scenes to instantiate and add to the level
	var Treasure = load("res://Treasure.tscn")
	
	# The scene variable contains the nodes as you see them in the editor.
	# scene itself points to the top node. Its children are the tile and object layers.
	for node in scene.get_children():
		# To know the type of a node, check if it is an instance of a base class
		# The addon imports tile layers as TileMap nodes and object layers as Node2D
		if node is TileMap:
			# Process tile layers. E.g. read the ID of the individual tiles and
			# replace them with random variations, or instantiate scenes on top of them
			pass
		elif node is Node2D:
			for object in node.get_children():
				# Assume all objects have a custom property named "type" and get its value
				var type = object.get_meta("otype")

				var node_to_clone = null
				if type == "Treasure":
					node_to_clone = Treasure
				else:
					print("Unknown type: ", type)

				if node_to_clone:
					var new_instance = node_to_clone.instance()
					new_instance.content_description = object.get_meta("content_description")
					new_instance.position = (object.position)
					# Add the node as a child of the scene and sets
					# the scene as its owner. Otherwise, the scene doesn't get modified
					scene.add_child(new_instance)
					new_instance.set_owner(scene)
			# After you processed all the objects, remove the object layer
			node.free()
	# You must return the modified scene
	return scene
