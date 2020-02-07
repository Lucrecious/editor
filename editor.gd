extends Node2D

class_name GameEditor

signal selected_changed

onready var _terminal := $HUD/Terminal
onready var _regions := $Space/Regions as EditorRegions
onready var _view := $Space/View as EditorView
onready var _grid := $Space/Grid as EditorGrid

var _selected := []

func get_selected() -> Array:
	return _selected.duplicate()

func _unhandled_input(event):
	if event.is_action("editor_select") and\
		Input.is_action_just_pressed("editor_select"):
		var add := Input.is_action_pressed("editor_modifier")
		_select(add)
		
func _select(add : bool) -> void:
	if not add:
		_selected.clear()
	
	var mpos := _grid.to_coords(get_global_mouse_position())
	var region = _regions.get_at(mpos)
	
	if region:
		if add and region in _selected:
			_selected.erase(region)
		else:
			_selected.append(region)
	
	
	emit_signal("selected_changed")

func _on_Terminal_command_entered(command : Dictionary) -> void:
	var cmd = command['cmd']
	if cmd == null: return
	
	match cmd:
		EditorCommands.Unknown:
			_terminal.output.put(['[Unknown Command]'])
		EditorCommands.Create:
			var object = command['params'][0]
			var location = command['params'][1]
			match object:
				EditorCommands.RegionParam:
					var pos = _get_create_position(location)
					_regions.create(pos, Vector2(1, 1))
					_terminal.output.put(['Region created'])

func _get_create_position(location : String) -> Vector2:
	if location == EditorCommands.CursorParam:
		return _grid.to_coords(get_global_mouse_position())
		
	var default := _view.to_world(Vector2(.756, .51))
	return _grid.to_coords(default)
	








