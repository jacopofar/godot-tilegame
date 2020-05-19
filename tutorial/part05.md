The treasure chests show a different message when they are interacted with a second time, but there's no track of what
they actually contained nor a way to integrate different events (e.g. a door only opens when a switch has been clicked)

## Add a global state object

As done before for the Dialog, let's creacte a new scene called `GameState`, which will contain a Node (type Node, the most
basic type) called `GameState`. Set it as Autoload.

Now we can add all the logic to keep track of the game state here. Start with:

```GDScript
extends Node

var known_items = {}
var possessed_items: Array = []

func register_item(id: int, name: String):
	known_items[id] = name

func get_id_from_name(name: String):
	var pos = known_items.values().find(name)
	if pos == -1:
		return -1
	else:
		return known_items.keys()[pos]

func pick_item(id: int):
	possessed_items.append(id)

func has_item(id: int):
	return possessed_items.has(id)

```

here we have a list of ids for the possessed objects, and methods to register a new object, add an id to the inventory
and check if an id is already there. The inventory can contain the same object id multiple times.

The treasure chest code now becomes:

```GDScript

extends KinematicBody2D
export var content_description: String = "[missing content]"

var content_id: int

var opened = false

func _ready():
	content_id = GameState.get_id_from_name(content_description)
	if content_id == -1:
		content_id =  randi()
		GameState.register_item(content_id, content_description)

func on_interact():
	if opened:
		Dialogue.say("Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		print("CONTENT:", content_description)
		Dialogue.say("This chest contains: " + content_description)
		if GameState.has_item(content_id):
			Dialogue.say("You already had one")
		else:
			Dialogue.say("It's new!")
		GameState.pick_item(content_id)
```

by adding more treasure chests with the same item you can see that the dialogue content changes depending on the fact a
similar item was already taken.
A problem to notice is that we simply randomly invent an item ID when it's not found, so not only it could collide but
there's no mapping shared across sessions, and each time we play the id for an item will be different. This requires a
central table mapping the ids to the items.

## Create a catalogue of items

