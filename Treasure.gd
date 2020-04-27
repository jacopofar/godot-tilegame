extends KinematicBody2D
export var content_description: String = "[missing content]"

var opened = false

func on_interact():
	if opened:
		print("Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		ComicBubble.say(self, "This chest contains:" + content_description)
