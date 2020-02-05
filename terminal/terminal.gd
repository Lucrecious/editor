extends Control

signal command_entered(command)

onready var output := $Text/Output
onready var command := $Text/Command

func _ready():
	command.connect('text_entered', self, '_pressed_enter')

func focus():
	command.grab_focus()

func unfocus():
	command.release_focus()

func _pressed_enter(text : String) -> void:
	text = text.strip_edges()
	if text.empty(): return;
	
	var result = _parse(text)
	
	emit_signal('command_entered', result)
	command.clear()

func _parse(command : String) -> Dictionary:
	assert(not command.strip_edges().empty())
	
	var parsed = { 'cmd' : EditorCommands.Unknown, 'params' : [] }
	
	var split = command.split(' ')
	if split[0] == 'create':
		parsed['cmd'] = EditorCommands.CreateRegion
	
	return parsed





