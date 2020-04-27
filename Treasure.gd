extends KinematicBody2D

var opened = false

func on_interact():
	if opened:
		print("Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		ComicBubble.say(self, "I'm a chest!")

