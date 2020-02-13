extends Control

signal command_entered(command)

onready var output := $Text/Output
onready var command := $Text/Command

var _command_history := []
var _command_history_index = -1
var _command_history_max = 20

func _ready():
	command.connect('text_entered', self, '_pressed_enter')
	command.connect('up_down_entered', self, '_search_history')

func focus():
	command.grab_focus()

func unfocus():
	command.release_focus()

func _search_history(direction : int) -> void:
	assert(direction == -1 || direction == 1)
	
	_command_history_index += direction
	
	if _command_history_index < 0:
		_command_history_index = -1
		command.text = ''
	elif _command_history_index >= _command_history.size():
		command.text = '[End of History]'
		if _command_history_index >= _command_history.size() + 1:
			_command_history_index = -1
			command.text = ''
	else:
		command.text = _command_history[_command_history_index]
	
	call_deferred('_move_caret_to_end')

func _move_caret_to_end():
	command.caret_position = command.text.length()

func _pressed_enter(text : String) -> void:
	_command_history_index = -1
	
	text = text.strip_edges().to_lower()
	if text.empty(): return;
	
	var result = _parse(text)
	
	if result['cmd'] != EditorCommands.Unknown:
		_add_history(text)
	
	emit_signal('command_entered', result)
	command.clear()

func _add_history(text : String) -> void:
	if text in _command_history:
		_command_history.erase(text)
	
	_command_history.push_front(text)
		
	if _command_history.size() > _command_history_max:
		_command_history.pop_back()

func _parse(command : String) -> Dictionary:
	assert(not command.strip_edges().empty())
	
	var cmd = { 'cmd' : EditorCommands.Unknown, 'params' : [] }
	
	var split = command.split(' ')
	if split[0] == EditorCommands.Create:
		split.remove(0)
		var create_cmd = _parse_create(split)
		if not create_cmd: return cmd
		return create_cmd
	
	if split[0] == EditorCommands.Set:
		split.remove(0)
		var set_cmd = _parse_set(split)
		if not set_cmd: return cmd
		return set_cmd
	
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

func _parse_set(params : Array):
	if params.size() < 3: return null
	
	if params[0] == EditorCommands.RegionParam:
		params.remove(0)
		return _parse_region_set(params)
	
	return null

func _parse_region_set(params : Array):
	var property := params[0] as String
	var value := params[1] as String
	return {
		'cmd' : EditorCommands.Set,
		'params' : [
			EditorCommands.RegionParam,
			property,
			value
			]
		}





