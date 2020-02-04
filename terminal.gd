extends Control

onready var output := $Text/Output
onready var command := $Text/Command

var history := []
var history_max = 11

func _ready():
	command.connect("text_entered", self, "_pressed_enter")

func _pressed_enter(text : String) -> void:
	var result = _command(text)
	
	history.append(result)
	if history.size() >= history_max:
		history.pop_front()
	
	output.text = LutUtils.join(history, "\n")
	
	command.clear()

func _command(command : String) -> String:
	return "Error!"





