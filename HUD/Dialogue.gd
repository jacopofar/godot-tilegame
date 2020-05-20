extends Node

func say(text: String, color=Color(0,0,0)):
	var tie = get_node("/root/Main/TextConvCanvas/DialogRect/TextInterfaceEngine")
	tie.set_color(color)
	tie.buff_text(text, 0.003)
	tie.buff_text("\n")
	tie.set_state(tie.STATE_OUTPUT)
