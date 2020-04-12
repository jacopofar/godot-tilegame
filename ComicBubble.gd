extends CanvasLayer

func say(position: Vector2, text: String):
	$Label.text = text
	offset = position
