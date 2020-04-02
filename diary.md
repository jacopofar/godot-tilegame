This document logs the steps followed to create this project.

## Basic project setup
First, we create an empty Godot 3.2 project and put it under git version control, to track all the changes.

Then we install the [Tiled map importer](https://github.com/vnen/godot-tiled-importer) plugin. It has to be activated (Project -> Project Settings -> plugin tab).

Using tiled, we create an empty orthogonal map, with squared cells of size 32 pixels.
The map is saved in the project folder under `maps/wordls01.tmx`

Then, we download a free tileset from [opengameart](https://opengameart.org/content/rpg-tiles-cobble-stone-paths-town-objects) and save it under `maps/tilesets/PathAndObjects.png`.
Same with [this other tileset](https://opengameart.org/content/lpc-tile-atlas) that goes under `maps/tilesets/Atlas` (this time is a folder so I can easily keep track of the attribution).

In Tiled, create a new tileset and use this file. Choose white as the transparent color and "embed into map" to avoid an extra file (optional).
Now I can draw some tiles in the map and save it.

In Godot, I create a scene in the project called `Pl;ayer` with a KinematicBody2D as the root element called `Player`.
I download the [Sara - Sizard](https://opengameart.org/content/sara-wizard) spritesheet and put it under `sprites/sara-cal.png`.
In Godot we create a Sprite called `Sprite` under the `Player` node, and load the character texture. It's a spritesheet but for now I don't care about the animation. By setting Vframes and Hframes properties in the sprite we just pick one of the elements from the sheet.
Next, by adding a CollisionShape2D as another child of Player and using Shape -> New RectangleShape2D I can place a collision area around the sprite.

Now I create a scene called `GameMain`, add a Node2D as the root and drag and drop the map `world01.tmx` in it.
The plugin imports the tilemap and we should see it the same as in Tiled.

In `Project Setitngs -> Application -> Run` we set this scene as the main one. Now by clicking play we see the tilemap.
Notice that from now one when editing it in Tiled Godot will detect the changes and reimport it on the fly.
Now we add the player to the game: by clicking on the button above the scene tree that looks like a chain link we create an instance of Player and put it under the world.

If we click play now we see the tilemap and the player. Notice that the order of the elements in the tree in the editor is the z-order, so the player node has to be under the world01 one to see the player.

Now we want to be able to move the player around.
Under `Project Settings -> Input map` we can set up the key bindings between the arrow keys or WASD or whatever, abstracting over the exact key pressed in the game logic and allowing later to use a joystick or a gamepad.

In the Player scene, clicking on the root node we add a script, called `Player.gd` as suggested by Godot.

At the top we add the line:

    # Player movement speed
    export var speed: int = 150

this defines a variable visible from the editor, and if we save and go back to the GameMain scene we see this variable in the editor, and can change it.

Then we add the movement, with this code that I copied from the amazing [HeartBeast tutorial](https://youtu.be/TQKXU7iSWUU?t=30)

```GDScript

func _physics_process(delta):
    var direction: Vector2

    direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
    direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

    if abs(direction.x) > abs(direction.y):
        direction.y = 0
    else:
        direction.x = 0

    direction = direction.normalized()
    var movement = speed * direction * delta
    # warning-ignore:return_value_discarded
    move_and_collide(movement)
```

This script locks the movement in one direction as a time, there's no diagonal movement.

Now if we play the game the character can move around.

Let's add some obstacle to the map: in Tiled we add another layer to have objects and a background blend together. Then we can put some obstacle like a stack of wood. Then, click on Edit Tileset and add a collision to this tile.

Save the map in Tiled and play the game in Godot, you now have the collision with the wood pile!
