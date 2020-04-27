extends CanvasLayer

func say(target: Node2D, text: String):
	var comic = load("res://ComicBubble.tscn").instance()
	comic.get_node("Label").text = text
	comic.offset = target.position
	target.add_child(comic)
