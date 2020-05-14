extends CanvasLayer

func say(target: Node2D, text: String):
	var comic = load("res://HUD/ComicBubble.tscn").instance()
	comic.get_node("Label").text = text
	comic.offset = target.position
	target.add_child(comic)
	comic.get_node("AnimationPlayer").play("fadeout")
	var tie = get_node("/root/Main/TextConvCanvas/ColorRect/TextInterfaceEngine")
	tie.set_color(Color(0,0,0))
	tie.buff_text("\n")
	tie.buff_text(text, 0.01)
	tie.set_state(tie.STATE_OUTPUT)

func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
