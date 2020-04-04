This document logs the steps followed to create this project.

## Basic project setup
First, we create an empty Godot 3.2 project and put it under git version control, to track all the changes.

In Project Settings go to the window section and set mode to 2D and aspect to "keep", to ensure it will have a consistent look across screen sizes, and in rendering > quality > 2d enable the option "use pixel snap" to have a better display of single pixels.

Then we install the [Tiled map importer](https://github.com/vnen/godot-tiled-importer) plugin. It has to be activated (Project -> Project Settings -> plugin tab).

Using tiled, we create an empty orthogonal map, with squared cells of size 32 pixels.
The map is saved in the project folder under `maps/wordls01.tmx`

Then, we download a free tileset from [opengameart](https://opengameart.org/content/rpg-tiles-cobble-stone-paths-town-objects) and save it under `maps/tilesets/PathAndObjects.png`.
Same with [this other tileset](https://opengameart.org/content/lpc-tile-atlas) that goes under `maps/tilesets/Atlas` (this time is a folder so I can easily keep track of the attribution).

In Tiled, create a new tileset and use this file. Choose white as the transparent color and "embed into map" to avoid an extra file (optional).
Now I can draw some tiles in the map and save it.

In Godot, I create a scene in the project called `Player` with a KinematicBody2D as the root element called `Player`.
I download the [RPG character](https://opengameart.org/content/rpg-character) spritesheet and put it under `sprites/MainGuySpriteSheet.png`.
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

There's a last step to conclude the basic setup, and it is the camera: if you move the character out of the screen you'll notice it keeps moving but the camera doesn't.

To do this add a Camera2D object to the Player scene, and ensure its property `Current` is on (by default is not). Then you probably want to set the `drag margin` properties to on as well, so the camera will move only when the character is a bit outside the center, not all the time, which is nicer for the human playing the game.


## Player animation

The sprite includes the frames for the player in different poses, so to animate it we have to change the frame fast enough to create the illusion of the movement, and pick the right ones to match the direction of the player.

But first we have a problem: if I change the sprite hframe/vframe/frame properties to get the other sprites for the same object, representing different states during the movement, they are cut and/or "jumpy". This happens because the spritesheet I used has some space between the elements, and godot expects a grid. I didn't find an easy way to deal with this spacing, if you do let me know. What I do is simply edit the image and make it compact. I use Piskel, a FOSS pixel editor which has a very neat support for spritesheet, including the possibility to see the animation as we edit it, which really saves a lot of time!

This is managed by a specific type of node called `AnimationPlayer`.
Let's add it to the Player scene, on the bottom of the e3ditor there's an animation panel where we define the animations.
Clicking on `Animation -> New` we set up the `right` animation.
Now, looking at the sprite properties you can see there's a key simbol close to most of them: clicking on it we can add a keyframe, which is a reference value that will be caltered by the animation. Moving in the animation timeline we can change the value and press the key button again to store different states. You can click on the button on the right of the animation track to set the mode, I used continuous, and in the AnimationPlayer you can set the speed, I used 3.

Now we have to map the animation sequences to the movement, so the code to move the character becomes:

```GDScript

if abs(direction.x) > abs(direction.y):
		direction.y = 0
		if direction.x > 0:
			$AnimationPlayer.play("right")
		else:
			$AnimationPlayer.play("left")
	else:
		direction.x = 0
		if direction.y > 0:
			$AnimationPlayer.play("down")
		else:
			$AnimationPlayer.play("up")
```

the `$` sign is a concise way to refer to a node down the hierarchy, so we invoke the `play` method of the AnimationPlayer and it runs the animation for us by changing the properties of the sprite according to the keyframes.

Notice that we can test only the player scene and not load the rest of the game by clicking on the `Play Scene` button on the top right.

When we stop moving the animation will continue, because we never said to stop it! To fix this, add this instruction:

```GDScript
	if direction.x == 0 and direction.y == 0:
		$AnimationPlayer.stop()
```

now when we stop pressing the arrow button the animation goes at the first keyframe and stops.

