extends Control

onready var output := $Text/Output
onready var command := $Text/Command

var history := []
var history_max = 11

func _ready():
	command.connect("text_entered", self, "_command")

func _command(text : String) -> void:
	history.append(text)
	if history.size() >= history_max:
		history.pop_front()
	
	output.text = LutUtils.join(history, "\n")
	
	command.clear()