extends KinematicBody2D
export var content_id: String = "MISSING"

var opened = false

func on_interact():
	if opened:
		Dialogue.say("Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		Dialogue.say("This chest contains: " + content_id)

		if GameState.has_item(content_id):
			Dialogue.say("You already had one")
		else:
			Dialogue.say("It's new!")			
		GameState.pick_item(content_id)
