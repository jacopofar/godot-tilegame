extends KinematicBody2D

var opened = false

func on_interact():
	if opened:
		print("Already opened...")
	else:
		$Sprite.frame = 1
		
