extends CanvasLayer

onready var terminal := $Terminal

func _ready():
	terminal.visible = false

func _unhandled_input(event):
	if Input.is_action_just_pressed("editor_enter"):
		terminal.visible = true
		terminal.focus()
		get_tree().set_input_as_handled()
	elif Input.is_action_just_pressed("editor_esc"):
		terminal.visible = false
		terminal.unfocus()
		get_tree().set_input_as_handled()