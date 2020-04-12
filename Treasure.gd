extends KinematicBody2D

var opened = false

func on_interact():
	if opened:
		print("Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		var comic = load("res://ComicBubble.tscn").instance()
		comic.say(position, "I'm a chest!")
		get_node(".").add_child(comic)

