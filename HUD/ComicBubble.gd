extends CanvasLayer

func say(target: Node2D, text: String, color=Color(0,0,0)):
	var tie = get_node("/root/Main/TextConvCanvas/ColorRect/TextInterfaceEngine")
	tie.set_color(color)
	tie.buff_text("\n")
	tie.buff_text(text, 0)
	tie.set_state(tie.STATE_OUTPUT)
