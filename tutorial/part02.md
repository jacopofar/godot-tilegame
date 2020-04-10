At this point we can import a tilemap and instantiate a treasure chest for each Tiled object having `otype=Treasure`.

Now we can extend the player to interact with the treasure chest, and encode some behavior in it.

## Action button and player interaction with objects

When the user presses a button, like `enter` or `space`, we want to detect what's the object in front of the character, if any, and interact with it.
So first let's go to *Project settings -> Input map* and create an `interact` action that I associate to space and enter.

Now in the `Player` scene we need to detect when the inetract action is happening, and when it happens calculate what the player character is facing.

In the Player code let's add this:

```GDScript
func _input(event):
	if event.is_action_pressed("interact"):
		print("interact!")
```

The `_input` function is called on any input event, and it receives an `event` object with all the details.
If you play now you'll see that every time you press the interact key the text is printed in the console.

To detect the target of the interaction (if any) we need a way to query the game area in front of the player, and for that Godot offers the `RayCast2D` Node. It is designed to detect what is the first object in some direction froma vector, as if we cast a ray from it.
Let's add one to the Player scene, then set `Enabled` to true and the `y` value to 32, which is the tile size we are using. Notice that if you use Debug -> Visible collision shapes the raycast is visible as an arrow.
The raycast is now pointing always in the same direction, so we need to extend the code for the movement to update the raycast direction as well:

```GDScript
$RayCast2D.cast_to = direction.normalized() * 32
```

This code goes in the same place of the `move_and_collide` call, so when we move the character we also update the raycast direction. You can see that using the collision shape debug.

Now we can modify the interaction code to detect the object we are facing:

```GDScript
func _input(event):
	if event.is_action_pressed("interact"):
		var target = $RayCast2D.get_collider()
		print(target)
```

if you play with it you'll notice that it prints `null` if we are not facing anything (or better, anything that collides), and some object when you face a colliding tile or the treasure chests.

Let's add an interaction, like this: if the object has a method called `on_interact` we simply invoke it:

```GDScript
func _input(event):
	if event.is_action_pressed("interact"):
		var target = $RayCast2D.get_collider()

		if target != null:
			if target.has_method("on_interact"):
				target.on_interact()
			else:
				print_debug("Cannot interact with this")
```

and of course in the treasure chest scene we add the method to the root node script:

```GDScript
func on_interact():
	print("I am a tresure chest, they are interacting with me!")
```
now when playing you will see this message in the console when interacting with the trasure chest.

## Treasure chest action

Let's add to the Treasure Chest scene a state to show the close/open state:

```GDScript

extends KinematicBody2D

var opened = false

func on_interact():
	if opened:
		print("Already opened...")
	else:
		$Sprite.frame = 1
```
this shows the open chest sprite after we interact with it. After it's open, we cannot open it again.

I noticed at this point that when the chest is open the player character can walk on the upper part, because the collision area is now smaller than the sprite, but visually we expect the chest to cover the legs of the character. To adjust this I go to the KinematicBody2D Z-index property and set it to 1 (and leave the *Z as relative* option on). Now the trasure chest sprite is over the character one.
