extends KinematicBody2D
export var content_description: String = "[missing content]"

var content_id: int

var opened = false

func _ready():
	content_id = GameState.get_id_from_name(content_description)
	if content_id == -1:
		content_id =  randi()
		GameState.register_item(content_id, content_description)

func on_interact():
	if opened:
		Dialogue.say("Already opened...")
	else:
		opened = true
		$Sprite.frame = 1
		print("CONTENT:", content_description)
		Dialogue.say("This chest contains: " + content_description)
		if GameState.has_item(content_id):
			Dialogue.say("You already had one")
		else:
			Dialogue.say("It's new!")			
		GameState.pick_item(content_id)
