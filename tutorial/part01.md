
## Terrain edit
Until now in Tiled we used to put single tiles, one by one. However when we want to draw areas with transitioning from tipes of terrain, for example water and grass, we want to add transitions between them, and Tiled offers a function to make it simpler called [Terrain](https://doc.mapeditor.org/en/stable/manual/using-the-terrain-tool/). Notice there's a more advanced functionality called [Wang Tiles](https://doc.mapeditor.org/en/stable/manual/using-wang-tiles/).

This is useful to define areas of grass, water and others much more easily.
All you have to do is to go in the tileset settings, enter the terrain edit mode with the button on the top bar and define the terrains. For each one you need to specify with of the 4 corners of each tile is part of that terrain. When defining multiple terrains you assign the different corners of the appropriate tiles.
Then, in the editor, when clicking on Terrains you can paint with water or grass or whatnot and Tiled will place the correct tiles to perform a nice transition between the two types of terrain.

Notice that this is used by Tiled to make the tilemap design easier, the result is still a grid of tiles that are imported the same as before.

## Add objects to the map
The editor let us edit the tileset, but we want also to place interesting things in the world, like NPC, objects, enemies and so on.
Tiled offers the possibility to insert objects. You can right click to create a new object layer, and insert stuff in there. You can also give objects names and properties. However, by default nothing appears in Godot because this is metadata and has no clear visualization.
To have the objects mapped to something concrete in the scene, we need to do an association between them and the nodes using an import script.
So the process will be this:

* we create a Scene in Godot, e.g. `Treasure.tscn`
* we set up a point in an object layer with type=Treasure
* we write an import script to instantiate a Treasure scene where we have the point

### Create the Treasure scene

We download a [public domain treasure chest sprite](https://opengameart.org/content/modified-32x32-treasure-chest) and save it as `chest2.png`. It is a spritesheet with two images: the closed and opened chest.
In Godot, we create the Treasure.tscn scene. In it we implement the same structure as the `Player` one.
Put a `KinematicBody2D` as a root, and then a `Sprite`. In the Sprite we load the chest image and set `HFrames` to 2 to get only the close (or open) part of the spritesheet.
Then, we add a `CollisionShape2D` and with a rectangular shape cover the chest. Running the scene you should see the chest, and for now we are fine with this.

### Set up a point in Tiled

In Tiled select the object layer (create it it there isn't already one) and press I or click on the point tool to insert a point. Notice that by pressing the `Ctrl` button when moving the cursor you can snap it to the grid.
In the *objects* tab of the right panel you can double click on the object and give it a name, like "Treasure chest", which is useful to keep track of it and appears in Tiled as a label. On the same panel click on the wrench button to edit the object properties.

Using it set the property `otype` to "Treasure" and save. Notice that the object has already an empty "Type" property, we could create a custom property with the same name but to avoid confusion I used "otype" as a short for "object type". Also notice that it is case sensitive so "treasure" won't work.

### Import the object using a post-import script

Now that we have an object to place and a point in the map, we need to instantiate the scene in the right position.

Here things can get a bit ugly, I found that if there is an error in the script sometimes is necessary to restart Godot to rerun it after fixing the code, I'll update the tutorial if I find a nicer way to work with it.

If you click on the `world01.tmx` file and go to the `Import` tab above, you can see that one option is the *Post import script*. This is a script to run after importing the tilemap.

So create a GDScript file called `importer.gd` and paste this code:

```GDScript

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
					new_instance.position = (object.position)

					# Add the node as a child of the scene and sets
					# the scene as its owner. Otherwise, the scene doesn't get modified
					scene.add_child(new_instance)
					new_instance.set_owner(scene)
			# After you processed all the objects, remove the object layer
			node.free()
	# You must return the modified scene
	return scene
```

this is a code from the importer wiki, at the time of writing there are some issues in the original one so it doesn't work on Godot 3.2, but the code above does. I opened a [GitHub issue](https://github.com/vnen/godot-tiled-importer/issues/124) for that.

Setting this script in the Import properties as the post import script, it will run after every change to the map.

It goes through the layers and objects from Tiled and when it finds one it checks the "otype" property and based on that creates the proper instance.

Now if you click on Reimport the game will have a treasure chest that can be moved around in Tiled. Also, you can create multiple points with this otype and it will instantiate multiple treasure chests, which is what I did.

Putting two treasure chests at 1 tile of distance and passing between them I noticed the collision was blocking the character, so I went to the Player scene and changed the collision shape to a `Capsule` with a small margin to make the movement smoother.

Note that clicking on **Debug -> Visible collision shapes** you can see the collision areas when playing.
