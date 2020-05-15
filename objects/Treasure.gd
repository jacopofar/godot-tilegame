extends KinematicBody2D
export var content_description: String = "[missing content]"

var opened = false

func on_interact():
	if opened:
		Dialogue.say("Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		print("CONTENT:", content_description)
		Dialogue.say("This chest contains: " + content_description)
