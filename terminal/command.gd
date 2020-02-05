extends LineEdit

func _gui_input(event):
	if event is InputEventMouse\
	or event is InputEventMouseButton\
	or event is InputEventMouseMotion:
		return
	
	if event.is_action("editor_esc"):
		return
	
	accept_event()
