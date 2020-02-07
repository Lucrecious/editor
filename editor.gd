extends Node2D

class_name GameEditor

signal selected_changed

onready var _terminal := $HUD/Terminal
onready var _regions := $Space/Regions as EditorRegions
onready var _view := $Space/View as EditorView
onready var _grid := $Space/Grid as EditorGrid

var fsm := FSM.new()

var _event_current

var _selected := []

func _ready() -> void:
	_grid.set_view(_view.get_rect2())
	fsm.add_transition(state_idle, state_move_view, to_move_view)
	fsm.add_transition(state_move_view, state_idle, from_move_view)
	
	fsm.state(state_idle)

func get_selected() -> Array:
	return _selected.duplicate()

func _unhandled_input(event):
	_event_current = event
	fsm.update(get_physics_process_delta_time())

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

var state_idle := FSMQuickState.new(fsm)\
	.add_main(self, "state_idle_main")
func state_idle_main() -> void:
	if Input.is_action_just_pressed("editor_zoom_in"):
		_view.magnify(1.3)
	elif Input.is_action_just_pressed("editor_zoom_out"):
		_view.shrink(1.3)
	elif Input.is_action_just_pressed("editor_select"):
		var add := Input.is_action_pressed("editor_modifier")
		_select(add)

var state_move_view := FSMQuickState.new(fsm)\
	.add_main(self, "_state_move_view_main")
func _state_move_view_main() -> void:
	if _event_current is InputEventMouseMotion:
		var rel = (_event_current as InputEventMouseMotion).relative
		_view.global_position -= Vector2(rel.x, rel.y) * _view.get_zoom()
	
	_grid.set_view(_view.get_rect2())

var to_move_view := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "_to_move_view_evaluation")
func _to_move_view_evaluation() -> bool:
	return Input.is_action_just_pressed("editor_alt")

var from_move_view := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "_from_move_view_evaluation")
func _from_move_view_evaluation() -> bool:
	return Input.is_action_just_released("editor_alt")








