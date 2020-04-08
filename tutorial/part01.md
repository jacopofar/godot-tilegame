
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
