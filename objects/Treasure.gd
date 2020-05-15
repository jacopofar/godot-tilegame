extends KinematicBody2D
export var content_description: String = "[missing content]"

var opened = false

func on_interact():
	if opened:
		ComicBubble.say(self, "Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		print("CONTENT:", content_description)
		ComicBubble.say(self, "This chest contains: " + content_description)
