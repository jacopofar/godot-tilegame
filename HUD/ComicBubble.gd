extends CanvasLayer

var current_comic =  null

static func say(target: Node2D, text: String):
	var comic = load("res://HUD/ComicBubble.tscn").instance()
	comic.get_node("Label").text = text
	comic.offset = target.position
	target.add_child(comic)
	ComicBubble.current_comic = comic

func _input(event):
	if current_comic == null:
		return
	# TODO here there's no management of the other types of input
	# but this is just an experiment to see how to intercept input in Godot
	if event.is_action_pressed("interact"):
		current_comic.queue_free()
		current_comic = null
		print("I am comic bubble, they are interacting with", event)
		get_tree().set_input_as_handled()
	else:
		print("Comig bubble does not know how to react to", event)

