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
		opened = true
		$Sprite.frame = 1
```
this shows the open chest sprite after we interact with it. After it's open, we cannot open it again.

I noticed at this point that when the chest is open the player character can walk on the upper part, because the collision area is now smaller than the sprite, but visually we expect the chest to cover the legs of the character. To adjust this I go to the KinematicBody2D Z-index property and set it to 1 (and leave the *Z as relative* option on). Now the trasure chest sprite is over the character one.

## Text messages in the game

`print` is useful for a quick experiment, but of course in a game we want to see the messages in the game itself.
To do so, for now we'll go with a very basic solution to keep working on the game logic, and then will try something fancier.
Let's create a scene called `ComicBubble.tscn`, in which we put a `CanvasLayer` as root node and then a Label and a ColorRect. The CanvasLayer has a few interesting properties: first of all it can be drawn above (or behind) everything which is good for HUD. Then, it's very easy to move it and all the child nodes within the viewport or not.
On the text property of the label I write of course "Hello world!".
I size the label to overlap and be a big smaller than the rectangle, center the text horizontally and vertically and set the color to black.
As for the rectangle, I make it white and a bit transparent (the transparency comes from the alpha channel of the color).
The center of the CanvasItem, that you see in the editor, will be used as the center when positioning it relative to the object, so I place everything a bit above it because that's where I would expect to see comic bubble appear.

For the CanvasLayer script I simply write:

```GDScript

extends CanvasLayer

func say(position: Vector2, text: String):
	$Label.text = text
	offset = position
```

so that the function can be used to set the text without caring about the underlying nodes.

Then, the treasure chest `on_interact` code becomes:


```GDScript

func on_interact():
	if opened:
		print("Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		var comic = load("res://ComicBubble.tscn").instance()
		comic.say(position, "I'm a chest!")
		get_node(".").add_child(comic)
```

Now, if you open the chest you'll see a comic bubble on it.

This is far from beautiful, and by fiddling with it you can notice several problems :

* long messages break the comic bubble
* we cannot have messages with more than one line
* it's ugly: no animation, shades or fancy fonts
* non-latin characters are not shown (this is just the font, except for RTL languages where the issue is more complex)
* messages overlap and never go away, if tou open the two chest it will look ugly
* No formatting, we cannot use bold or italic or colors

these issues can be solved later by modifying the ComicBubble scene. Thanks to the way Godot organizes nodes and instances we can encapsulate all the logic in this scene without affecting how the game uses it.

However, the current approach still needs a few lines of code to show a message.
It would be nice to have a one-liner, and maybe a way to meep track of them so that old messages can disappear when new ones are created.

To do this, we can use a [Singletone (or Autoload)](https://docs.godotengine.org/en/stable/getting_started/step_by_step/singletons_autoload.html)

## Use an Autoload script to offer message functionality

First, go to Project Settings -> Autoload and add the ComicBubble scene to the objects. The name is by default `ComicBubble`, but you can change it: this is the name that will be used to invoke it.

Now let's change `say` to this in the ComicBubble:

```GDScript

func say(target: Node2D, text: String):
	var comic = load("res://ComicBubble.tscn").instance()
	comic.get_node("Label").text = text
	comic.offset = target.position
	target.add_child(comic)

```
This doesn't change the logic, it simply assumes that a `target` element is given and that's the one which will get the message.

Now the invocation, in the `TreasureChest` scene, can be changed in:

```GDScript
ComicBubble.say(self, "I'm a chest!")
```

this single line has the same effect, we only have to pass `self`. If you run it, the game works the same but the code is more concise. Moreover, if we later change the comic bubble logic we don't need to change all the invocations.

