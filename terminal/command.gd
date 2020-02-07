extends LineEdit

signal up_down_entered(direction)

func _gui_input(event):
	if event is InputEventMouse\
	or event is InputEventMouseButton\
	or event is InputEventMouseMotion:
		return
	
	if event.is_action('editor_esc'):
		return
		
	if event.is_action_pressed('editor_up')\
	|| event.is_action_pressed('editor_down'):
		var updown = int(Input.is_action_just_pressed("editor_up")) - int(Input.is_action_just_pressed('editor_down'))
		
		if updown:
			emit_signal("up_down_entered", updown)
	
	accept_event()
