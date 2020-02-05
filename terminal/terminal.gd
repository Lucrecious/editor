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
	text = text.strip_edges().to_lower()
	if text.empty(): return;
	
	var result = _parse(text)
	
	emit_signal('command_entered', result)
	command.clear()

func _parse(command : String) -> Dictionary:
	assert(not command.strip_edges().empty())
	
	var cmd = { 'cmd' : EditorCommands.Unknown, 'params' : [] }
	
	var split = command.split(' ')
	if split[0] == EditorCommands.Create:
		split.remove(0)
		var create_cmd = _parse_create(split)
		if not create_cmd: return cmd
		return create_cmd
	
	return cmd

func _parse_create(params : Array):
	if params.empty(): return null
	
	if params[0] == EditorCommands.RegionParam:
		var location := EditorCommands.DefaultParam
		if params.size() >= 3\
		and params[1] == EditorCommands.At\
		and params[2] == EditorCommands.CursorParam:
			location = EditorCommands.CursorParam
		
		return {
			'cmd' : EditorCommands.Create,
			'params' : [EditorCommands.RegionParam, location]
		}
	
	return null





