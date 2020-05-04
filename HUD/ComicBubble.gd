extends CanvasLayer

func say(target: Node2D, text: String):
	var comic = load("res://HUD/ComicBubble.tscn").instance()
	comic.get_node("Label").text = text
	comic.offset = target.position
	target.add_child(comic)

func _input(event):
	if event.is_action_pressed("interact"):
		print("I am comic bubble, they are interacting")
