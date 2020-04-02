extends KinematicBody2D

# Player movement speed
export var speed: int = 150


func _physics_process(delta):
	var direction: Vector2

	direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	# avoid diagonal movement
	if abs(direction.x) > abs(direction.y):
		direction.y = 0
	else:
		direction.x = 0

	direction = direction.normalized()
	var movement = speed * direction * delta
	# warning-ignore:return_value_discarded
	move_and_collide(movement)
