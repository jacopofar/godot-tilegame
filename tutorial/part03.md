Now we have a simple game in which the player can open a chest and see a custom message in an ugly rectangle.

## Export for the web
Exporting the game for the web is pretty easy. Go to *Project -> Export* and click to *Add...* to add an export template. Install the HTML5 one and then click to *Export project* and save it somewhere leaving the default settings.

One of the file, with extension `.wasm`, is the game engine compiled to Webassembly, then you have the `.pck` which contains the game resources and scripts, the `.html` page and some other files. Notice that you cannot just double click on the html file; instead, it has to be served.

Godot can serve it for you, by clicking on the icon close to the play button with a 5 in a shield (the symbol of HTML5) it will open a browser on the current version of the game. However, you cannot access it from other devices (e.g. from a phone) because of security reason it is restricted to localhost (that is, the same machine running Godot).

To serve it, you can export the project and use a web server to serve the resulting static files. A simple option is to use `python3 -m http.server`, if you have Python installed (you should, since I plan to use it later in this project) and use your local IP address. If this is impossible you can publish the game on any web host (like your own website, Github/Gitlab pages) or if nothing else works try a tool like ngrok.

Notice that both Firefox and Chrome allow you to simulate mobile devices using the web development tools, and I found that mode to replicate well enough the behavior of the real thing. In Firefox is called "responsive design mode" and in Chrome is the "device toolbar", both available in the webdev toolbar. Godot also has an option under *Project Settings -> Input devices -> Emulate Touch From Mouse*.

You may notice some issue by running the game like this:
* the portion of the world shown in the window is too big (this was true earlier as well, but with the browser it becomes more visible)
* it doesn't work on mobile, since there are no arrow keys to press to move the character around

your mileage may vary, it depends on your screen resolution on both the computer and the phone/tablet/smart-fridge and your personal taste. I decided for my case to change these project settings:

* width and height (under general -> Display -> Window) both at 512 pixels
* rendering -> quality: intended usage set to 2D

## Add mouse and multitouch movements

Mobile devices like tables or phones usually have no keyboard, so we need to allow the player to be moved another way. Additionally, it may be nice to allow the use of the mouse also on desktop, in case the user prefers it.

First, let's go to project settings and add a new event called `click`, associated with the left mouse button.

Now, add `var mouse_pressed: bool = false` at the beginning of the player code, and in the `_input` function, add this:

```GDScript
	if event.is_action_pressed("click"):
		mouse_pressed = true
	if event.is_action_released("click"):
		mouse_pressed = false
```

the mouse emits two event, one for when we click and the other for the button release, and we change a boolean variable accordingly to reflect the mouse state.

Then, in the `_physics_process`, we change the first lines to this:

```GDScript
	if mouse_pressed:
		direction = position.direction_to(get_global_mouse_position())
	else:
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
```

now when the mouse click is pressed the player will ignore the current keyboard action and use the mouse position instead. `get_global_mouse_position()` is a neat helper that calculates the position of the mouse cursor in the world coordinate system, then `direction_to` produces the normalized vector telling us in which direction the player should move to reach the cursor.

Notice that the code after that doens't need any change, it uses the `direction` vector to actually move the player and change the animation without caring about the source of the value.

If you try the game now, the player should follow the mouse cursor but also the keyboard (just not both at the same time!), but unfortunately it doesn't work on a mobile device (or the browser in mobile mode).

This happens because the touch screen produces a different type of event: since these input devices have the possibility of multitouch and have no concept of "hover" (they don't know where your finger is until you touch the surface) Godot models these input events in a different way.

You can have a look at the [official Godot's input event tutorial](https://docs.godotengine.org/en/latest/tutorials/inputs/inputevent.html) for a detailed explanation, it also explains how it's possible to intercept events, which will be useful later when working on the UI.

Let's add two more variables to the player:

```GDScript
var touch_pressed: bool = false
var touch_initial_direction: Vector2 =  Vector2(0, 1)
```

then at the beginning of the `_input` function:

```GDScript
	if event is InputEventScreenTouch:
		var world_position = get_canvas_transform().xform_inv(event.position)
		touch_pressed = event.is_pressed()
		touch_initial_direction = position.direction_to(world_position)
		return
```

this will store a flag to indicate whether a multitouch event is happening or not and what is the target point. We also have to use `get_canvas_transform()` to get the transformation matrix or the canvas used by the player and invoke its `xform_inv` method to translate the coordinates of the touch event (relative to the screen) to world coordinates.

The multitouch event also has an `index` property in case the user uses more than one finger (indeed, it's a *multi* touch). Here this case is ignored, using two or more fingers will move the character in the direction of the first one touching the screen, but be aware that you can implement more sophisticated behaviors than this.

The code to move the player becomes:

```GDScript
func _physics_process(delta):
	var direction: Vector2

	if mouse_pressed:
		direction = position.direction_to(get_global_mouse_position())
	elif touch_pressed:
		direction = touch_initial_direction
	else:
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
    # ...
```

so it uses the mouse, then the multitouch and then the keyboard to calculate the intended direction, and proceeds to use it as usual to move the player and set the animation.

## Interact with the mouse and multitouch

Now that the movement is possible on different devices, we need to make the interaction with objects possible as well.
For the mouse and multitouch I'm going to define an area around the player where the input is considered an intent to interact, and not to move: when the user clicks close to the player, we assume it's to interact with the object.

First, we add a new exported variable `interaction_range: float = 50.0`, which is the distance in pixels from the player and the touch event for it to be considered an interaction instead of a movement.

After that, we have to use Vector2 method `distance_to` to compare the distance and generate the appropriate event.
The code of the player now looks like this:

```GDScript
extends KinematicBody2D

# Player movement speed
export var speed: int = 150
export var interaction_range: float = 50.0

var mouse_pressed: bool = false
var touch_pressed: bool = false
var touch_initial_direction: Vector2 =  Vector2(0, 1)

func _physics_process(delta):
	var direction: Vector2

	if mouse_pressed:
		direction = position.direction_to(get_global_mouse_position())
	elif touch_pressed:
		direction = touch_initial_direction
	else:
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")


	# avoid diagonal movement
	if abs(direction.x) > abs(direction.y):
		direction.y = 0
		if direction.x > 0:
			$AnimationPlayer.play("right")
		else:
			$AnimationPlayer.play("left")
	else:
		direction.x = 0
		if direction.y > 0:
			$AnimationPlayer.play("down")
		else:
			$AnimationPlayer.play("up")
	if direction.x == 0 and direction.y == 0:
		$AnimationPlayer.stop()
	else:
		# try a movement only if there is something to do
		direction = direction.normalized()
		var movement = speed * direction * delta
		# warning-ignore:return_value_discarded
		move_and_collide(movement)
		$RayCast2D.cast_to = direction.normalized() * 32


func _input(event):
	# see https://docs.godotengine.org/en/latest/tutorials/inputs/inputevent.html
	var is_interaction = false
	if event.is_action_pressed("interact"):
		is_interaction = true

	if event is InputEventScreenTouch:
		touch_pressed = event.is_pressed()
		var world_position = get_canvas_transform().xform_inv(event.position)
		if position.distance_to(world_position) < interaction_range:
			is_interaction = true
		else:
			touch_initial_direction = position.direction_to(world_position)
			return
	if event.is_action_pressed("click"):
		if position.distance_to(get_global_mouse_position()) < interaction_range:
			is_interaction = true
		else:
			mouse_pressed = true
	if event.is_action_released("click"):
		mouse_pressed = false
	if is_interaction:
		var target = $RayCast2D.get_collider()
		if target != null:
			if target.has_method("on_interact"):
				target.on_interact()
			else:
				print_debug("Cannot interact with this")

```
