extends Control

signal command_entered(command)

onready var output := $Text/Output
onready var command := $Text/Command

func _ready():
	command.connect("text_entered", self, "_pressed_enter")

func focus():
	command.grab_focus()

func unfocus():
	command.release_focus()

func _pressed_enter(text : String) -> void:
	if text.empty(): return;
	
	var result = _parse(text)
	
	emit_signal("command_entered", result)
	command.clear()

func _parse(command : String) -> Dictionary:
	return { "cmd" : EditorCommands.Unknown, "params" : [] }





