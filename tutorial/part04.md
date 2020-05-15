The message bubble is ugly and it persistes forever.

## Make the message fade and disappear

First we add an `AnimationPlayer` to the comic bubble, and add an animation called "fadeout" to it.
This animation has two tracks which alter the `color` of `ColorRect` and `custom_colors/font_color` of `Label`,
bringing the alpha channel to 100%. I used a speed of 0.5 and an intermediate keyframe to have a period of static
maximum opacity.

Then, to delete the node once it's faded out, we use the `nimation_finished` signal and connect it to a new method in
`CanvasLayer`, which Godot will generate containing only a `pass` instruction, where we insert the deletion:

```GDScript
func _on_AnimationPlayer_animation_finished(anim_name):
	queue_free()
```
In the `say` static method we add:

```GDScript
comic.get_node("AnimationPlayer").play("fadeout")
```

to trigger the animation of the ComicBUbble instance. It's this animation that will fade the comic and then signal its
end to make the bubble node delete itself.

The `_input` function is not necessary now since the message disappears without interaction, so I delete it.

On the Label I set `Autowrap=On` to have the text wrap, and resize it to fit more text.

## Use GodotTIE for a nicer message

This "bubble" is not even a bubble at the moment, and it works only for short messages. An adventure game however needs
to show longer texts, allow choices and inputs, show effects and more, so luckily someone developed
[a plugin called gododTIE](https://github.com/henriquelalves/GodotTIE), where TIE stands for Text Interface Engine.
The plugin is not updated since 2018 at the moment of writing (May 2020) but works fine with the latest stable,
Godot 3.2.

By default it ships with the __Cave-Story__ font, a nice font from the homonymous game with a CC-BY-SA license.
I like it, but keep in mind that this font does not cover non-latin characters. So I decided to use a
[Google Noto Font](https://www.google.com/get/noto/), which is still TTF and free and covers many scripts.
Additionally, a [small change to the plugin](https://github.com/henriquelalves/GodotTIE/pull/12) allows to input
Unicode characters.

To install the script you can use the Godot addon manager and install GodotTIE or just copy-paste the files. Then you
have to enable the addon from the project settings as done before for the Tiled importer.

In the main scene I add a CanvasLayer node, which can be configured to not follow the viewport and so is used as a
canvas, static on the screen.
As a child, I add a `NinePatchRect` called *DialogRect*: this is a node type with a vertical and horizontal band that is
stretched preserving the corners, ideal for dialogs of arbitrary size. With Piskel I draw a simple frame and use it.

Then, as a child of DialogRect we add the `TextInterfaceEngine`, a node type introduced by the addon.

I want the dialog to be on the bottom part of the screen, which we set to be 512x512 pixels, so the settings I
choose are:

```
# DialogRect
margin_left = 10.0
margin_top = 400.0
margin_right = 500.0
margin_bottom = 500.0
# TextInterfaceEngine
margin_left = 5.0
margin_right = 485.0
margin_bottom = 100.0
```

they are in the `Rect` section of both nodes.

The code of the ComicBubble becomes:

```GDScript
func say(target: Node2D, text: String, color=Color(0,0,0)):
	var tie = get_node("/root/Main/TextConvCanvas/DialogRect/TextInterfaceEngine")
	tie.set_color(color)
	tie.buff_text("\n")
	tie.buff_text(text, 0)
	tie.set_state(tie.STATE_OUTPUT)
```
This code gets the TIE node from the main scene and calls the TIE-specific methods to trigger text display.
Since the rect and label used previously are replaced by TIE, we can delete them.

If you run the game now you'll notice that the dialogue box is aloways there even when empty, and the player can move
while a dialogue is going on.

### Make the dialogue box appear and disappear

Let's go on the DialogRect node and set the `visible` property to False so it's not visible at the start.
In the code of the TIE addon, `text_interface_engine.gd`, I add `var hidden: bool = true` at the beginning to have a
flag representing the visibility of this box.

I add two functions:

```GDScript
func _show_box():
	get_parent().visible = true
	hidden = false

func _hide_box():
	get_parent().visible = false
	clear_text()
	hidden = true
```

as helpers to change the visibility. This will be useful if in the future I want some animation or another mechanism.

The internal functioning of the addon is complex, and it has many functions, for now suffice to say there's a `_buffer`
which is a list of pending actions (like text to display, breaks or inputs to ask) and `_state` which represents the
current state, for example whether the TIE component is waiting for input or displaying text.
It's a finite state machine.

When `_buffer.size() > 0` we know the dialog is going on, so by calling the `_show_box` in `buff_text` and `_hide_box`
when we reach a break state and the buffer is empty we can have the box appear when there's text and disappear when
done.

However, this isn't enough: we want to wait for the user input to hide the box and the content, and we want the player
to not move around until the dialog is over. Additionally, the TIE works only with keyboard input, but the game should
accept mouse and multitouch events.

### Intercept mouse and multitouch events, prevent them from reaching the player

This part is tricky, it required some experimentation and probably will change in the future. You can directly look at
`text_interface_engine.gd` to get the complete code. Here, I'll try to explain as best as I can what I learned and how
it works.

Godot inputs, as mentioned in [the official Godot guide about input](https://docs.godotengine.org/en/latest/tutorials/inputs/inputevent.html#how-does-it-work) can be managed by `_input` and `_unhandled_input` on each node.
Every event (keyboard, mouse, touch, etc.) will be sent to the `_input` functions in a specific order and then, if they
didn't invoke `get_tree().set_input_as_handled()`, is passed to `_unhandled_input`.
Ideally, one uses `_input` for GUI elements which need to catch the user focus, and `_unhandled_input` for movements
and in-game actions. Here, I consider the TIE node as a sort of GUI (in fact I put the ComicBubble element in the HUD
folder).

At the bottom of the `_input` function, inside the `if` checking for the fact that the input is a `InputEventKey`, I
invoke the `capture_input()` function, which contains this:

```GDScript
func capture_input():
	# if the buffer is not empty the dialogue is not over
	if _buffer.size() > 0:
		# let's wait for it without letting the input propagate
		get_tree().set_input_as_handled()
	else:
		if not hidden:
			# the last input closes the box but still is not propagated
			get_tree().set_input_as_handled()
			_hide_box()
```
this function not only marks the input as handled so it will not move the player, it also checks that, if there is
no more text to display, the box gets hidden. This ensures the player reads the text and confirms it, instead of making
the box disappear immediately by itself.

Notice that nothing in this function assumes the event is a keyboard one, we'll be able to reuse it for other event
types. For the other types of events we add:

```GDScript
# the player can click to proceed, too, to read further
if event.is_action_pressed("click"):
    # is on a break? resume
    if(_state == 1 and _on_break):
        resume_break()
    capture_input()

# do not have a rogue release event propagate
if event.is_action_released("click"):
    if not hidden:
        get_tree().set_input_as_handled()

# same for touch screen
if event is InputEventScreenTouch:
    if event.pressed:
        # is on a break? resume
        if(_state == 1 and _on_break):
            resume_break()
        capture_input()
    else:
        if not hidden:
            get_tree().set_input_as_handled()
```

The logic is similar to what has been done for the player, one important note is that when the "release" event happen
in both cases we avoid letting this spurious event go unhandled, or it may mess with game logic `_input` functions,
which will receive a release event without the corresponding press.

This allows to use the dialog box with the mouse or the touchpad, which I find very nice!

A last thing: if you try it now you'll notice that the player can still be moved with the keyboard when the dialogue is
open. Why does it happen, if the marked the input as handled? This is because even though `_unhandled_input` does not
receive the keyboard event, which you can easily test using some `print_debug`, we are in the `_physics_process`
function of the player node. While the two input functions are called for each event, the physics function is called at
each loop, many times a second, no matter what. Using `Input.get_action_strength` there we read the state of the
keyboard which represents the actual state no matter if the GUI marked the input as handled.

So we have to change the behavior a bit. Add `var keyboard_pressed: bool = false` at the beginning of the Player code,
then in the `_unhandled_input` add:

```GDScript
if (event.is_action_pressed("ui_down")
    or event.is_action_pressed("ui_up")
    or event.is_action_pressed("ui_left")
    or event.is_action_pressed("ui_right")
    ):
    keyboard_pressed = true
if (event.is_action_released("ui_down")
    or event.is_action_released("ui_up")
    or event.is_action_released("ui_left")
    or event.is_action_released("ui_right")
    ):
    keyboard_pressed = false
```
now the `keyboard_pressed` variable represents whether the player has pressed a button "intended" for the player.
In the `_physics_process` we change the check for the direction like this:

```GDScript
	if mouse_pressed:
		direction = position.direction_to(get_global_mouse_position())
	elif touch_pressed:
		direction = touch_initial_direction
	elif keyboard_pressed:
		direction.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		direction.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
```

the last `elif` ensures the input from the keyboard is ignored if the Player node didn't receive the proper key press.

### Change the name of the ComicBubble

At this point the name `ComicBubble` is not very telling, and so I rename it to `Dialogue`. Also I change its type to
Node and remove `target` from the arguments of `say()`, it's not used since the dialogue box does not need a target to
set its coordinates.
Unfortunately Godot doesn't automatically rename references, so ou have to go to the settings and delete the now invalid
Autoload object and put the new name back, and change the reference in `TreasureChest` to refer to it as well.
