extends CanvasLayer

func say(target: Node2D, text: String):
	var comic = load("res://HUD/ComicBubble.tscn").instance()
	comic.get_node("Label").text = text
	comic.offset = target.position
	target.add_child(comic)
	comic.get_node("AnimationPlayer").play("fadeout")


func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
