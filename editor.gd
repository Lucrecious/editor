extends Node2D

class_name GameEditor

signal selected_changed

onready var _terminal := $HUD/Terminal
onready var _regions := $GameMaker/Model/Space/Regions as EditorRegions
onready var _objects := $GameMaker/Model/Space/Objects as EditorObjects
onready var _view := $GameMaker/Model/Space/View as EditorView
onready var _grid := $GameMaker/Model/Space/Grid as EditorGrid
onready var _world := $GameMaker/Model/World
onready var _render := $GameMaker/Model/Space/Render

onready var _gamemaker := $GameMaker

var fsm := FSM.new()

var _event_current

var _selected := []

func _connect_drawing_updates() -> void:
	_regions.connect('regions_changed', _render, 'regions_changed')
	connect('selected_changed', _render, 'update')
	_view.connect('view_changed', self, '_update_grid')
	_grid.connect('grid_changed', _render, 'update')
	_objects.connect('objects_changed', _render, 'objects_changed')
	
	_regions.connect('regions_changed', _gamemaker, 'regions_changed')
	_objects.connect('objects_changed', _gamemaker, 'objects_changed')

func _update_grid() -> void:
	_grid.set_view(_view.get_rect2())

func _ready() -> void:
	_connect_drawing_updates()
	
	_grid.set_view(_view.get_rect2())
	
	fsm.add_transition(_state_idle, _state_move_selected, _to_move_selected)
	fsm.add_transition(_state_move_selected, _state_idle, _from_move_selected)
	
	fsm.add_transition(_state_idle, _state_scale_selected, _to_scale_selected)
	fsm.add_transition(_state_scale_selected, _state_idle, _from_scale_selected)
	
	fsm.add_transition(_state_idle, _state_move_view, _to_move_view)
	fsm.add_transition(_state_move_view, _state_idle, _from_move_view)
	
	fsm.add_transition(_state_idle, _state_play, _to_play)
	fsm.add_transition(_state_play, _state_idle, _from_play)
	
	fsm.state(_state_idle)

func get_selected() -> Array:
	return _selected.duplicate()

func _unhandled_input(event):
	_event_current = event
	fsm.update(get_physics_process_delta_time())

func _select_obj(object):
	_selected = [object]
	emit_signal('selected_changed')

func _select(add : bool) -> void:
	if not add:
		_selected.clear()
	
	var mpos := _grid.to_coords(get_global_mouse_position(), true)
	var region = _regions.get_at(mpos)
	if region:
		if add and region in _selected:
			_selected.erase(region)
		else:
			_selected.append(region)
			
		emit_signal('selected_changed')
		return
	
	mpos = _grid.to_coords(get_global_mouse_position(), false)
	var object = _objects.get_at(mpos)
	if object:
		if add and object in _selected:
			_selected.erase(object)
		else:
			_selected.append(object)
		
		emit_signal('selected_changed')
		return
	
	emit_signal('selected_changed')


func _on_Terminal_command_entered(command : Dictionary) -> void:
	var cmd = command['cmd']
	if cmd == null: return
	
	match cmd:
		EditorCommands.Unknown:
			_terminal.output.put(['[Unknown Command]'])
		EditorCommands.Add:
			_run_add_command(command['params'])
		EditorCommands.Set:
			_run_set_command(command['params'])
		EditorCommands.Toggle:
			_run_toggle_command(command['params'][0])

func _run_toggle_command(param : String) -> void:
	match param:
		EditorCommands.AllParam:
			_render.toggle_grid_visible()
			_render.toggle_hints_visible()
			return
		EditorCommands.GridParam:
			_render.toggle_grid_visible()
			return
		EditorCommands.HintsParam:
			_render.toggle_hints_visible()
			return
	
	_terminal.output.put_error_line("'%s' is not valid for 'toggle'" % param)

func _run_add_command(params : Array) -> void:
	var object = params[0]
	var location = params[1]
	var template_name = params[2]
	var template = EditorTemplates.get_template(template_name)
	var pos = _get_create_position(location)
	var added = null
	match object:
		EditorCommands.RegionParam:
			added = _regions.create(pos, Vector2(1, 1), template)
		EditorCommands.SpawnerParam:
			if template_name == EditorTemplates.PlayerTemplate:
				added = _objects.add_object(pos + Vector2(.5, .5), EditorObjectTypes.PlayerSpawner)
			else:
				added = _objects.add_object(pos + Vector2(.5, .5), EditorObjectTypes.Spawner)
		
	assert(added)
	_select_obj(added)

func _run_set_command(params : Array) -> void:
	if params[0] == EditorCommands.RegionParam:
		params.remove(0)
		_run_set_region_command(params)
		return
	
	_terminal.output.put_error_line(
		"'%s' is not valid for the '%s' command" % params[0] % EditorCommands.Set)
	
func _run_set_region_command(params : Array) -> void:
	if params[0] == EditorCommands.TileSetParam:
		if not _world.map_exists_for_tileset(params[1]):
			_terminal.output.put_error_line(
				"'%s' is not a valid tileset" % params[1])
			return
		
		for selected in _selected:
			if not selected is EditorRegion: continue
			(selected as EditorRegion).set_tileset(params[1])
		return
	
	if params[0] == EditorCommands.TextureParam:
		if not Constants.CollisionTexture.has(params[1]):
			_terminal.output.put_error_line(
				"'%s' is not a valid texture" % params[1])
			return
		
		for selected in _selected:
			if not selected is EditorRegion: continue
			(selected as EditorRegion).set_texture(params[1])
		return
	
	_terminal.output.put_error_line(
		"'%s' is not a property on the region" % params[0])

func _get_create_position(location : String) -> Vector2:
	if location == EditorCommands.CursorParam:
		return _grid.to_coords(get_global_mouse_position())
		
	var default := _view.to_world(Vector2(.756, .51))
	return _grid.to_coords(default)

var _state_play := FSMQuickState.new(fsm)\
	.add_data({ 'hud' : null, 'gamemaker' : null, 'testgame' : null })\
	.add_enter(self, '_state_play_enter')\
	.add_exit(self, '_state_play_exit')
func _state_play_enter(from_state : FSMState) -> void:
	var hud := $HUD
	var gamemaker := $GameMaker
	
	var testgame_packed := PackedScene.new()
	testgame_packed.pack($GameMaker/Game)
	
	_state_play.data['hud'] = hud
	_state_play.data['gamemaker'] = gamemaker
	remove_child(hud)
	remove_child(gamemaker)
	
	var testgame = testgame_packed.instance()
	_state_play.data['testgame'] = testgame
	add_child(testgame)
func _state_play_exit(to_state : FSMState) -> void:
	var hud := _state_play.data['hud'] as Node
	var gamemaker := _state_play.data['gamemaker'] as Node
	var testgame := _state_play.data['testgame'] as Node
	
	remove_child(testgame)
	
	add_child(hud)
	add_child(gamemaker)
	
	_state_play.data['testgame'] = null
	_state_play.data['hud'] = null
	_state_play.data['gamemaker'] = null

var _state_idle := FSMQuickState.new(fsm)\
	.add_main(self, "_state_idle_main")
func _state_idle_main() -> void:
	if Input.is_action_just_pressed("editor_zoom_in"):
		_view.magnify(1.3)
	elif Input.is_action_just_pressed("editor_zoom_out"):
		_view.shrink(1.3)
	elif Input.is_action_just_pressed("editor_select"):
		var add := Input.is_action_pressed("editor_modifier")
		_select(add)

var _state_move_view := FSMQuickState.new(fsm)\
	.add_main(self, "_state_move_view_main")
func _state_move_view_main() -> void:
	if _event_current is InputEventMouseMotion:
		var rel = (_event_current as InputEventMouseMotion).relative
		_view.global_position -= Vector2(rel.x, rel.y) * _view.get_zoom()
	
	_update_grid()

var _state_move_selected := FSMQuickState.new(fsm)\
	.add_data({'alt_coords' : Vector2()})\
	.add_enter(self, "_state_move_selected_enter")\
	.add_main(self, "_state_move_selected_main")
func _state_move_selected_enter(from : FSMState) -> void:
	_state_move_selected.data['alt_coords'] = _grid.to_coords(get_global_mouse_position(), _is_first_selected_snapping())
func _state_move_selected_main() -> void:
	if not _event_current is InputEventMouseMotion: return
	var event := _event_current as InputEventMouseMotion
	
	var _last_alt_coords := _state_move_selected.data['alt_coords'] as Vector2
	var _now_alt_coords := _grid.to_coords(get_global_mouse_position(), _is_first_selected_snapping())
	
	var delta := _now_alt_coords - _last_alt_coords
	
	_state_move_selected.data['alt_coords'] = _now_alt_coords
	
	_move_selected(delta)

func _move_selected(delta : Vector2) -> void:
	assert(not _selected.empty())
	
	for select in _selected:
		select.move(delta)

var _state_scale_selected := FSMQuickState.new(fsm)\
	.add_data({'alt_pos': Vector2(), 'scale': Vector2()})\
	.add_enter(self, '_state_scale_selected_enter')\
	.add_main(self, '_state_scale_selected_main')
func _state_scale_selected_enter(from_state : FSMState) -> void:
	_state_scale_selected.data['alt_pos'] = get_global_mouse_position()
	_state_scale_selected.data['scale'] = _selected.front().rect().size
func _state_scale_selected_main() -> void:
	if not _event_current is InputEventMouseMotion: return
	var event := _event_current as InputEventMouseMotion
	
	var _last_alt_coords := _state_scale_selected.data['alt_pos'] as Vector2
	var _now_alt_coords := get_global_mouse_position()
	
	var delta := _now_alt_coords - _last_alt_coords
	
	_scale_selected(delta)

func _scale_selected(delta : Vector2):
	var region := _selected.front() as EditorRegion
	var scale = _state_scale_selected.data['scale']
	var delta_grid = _grid.to_coords(delta)
	
	region.set_scale(scale + delta_grid)

var _to_play := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, '_to_play_evaluation')
func _to_play_evaluation() -> bool:
	return Input.is_action_just_released('editor_test')

var _from_play := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, '_from_play_evaluation')
func _from_play_evaluation() -> bool:
	return Input.is_action_just_released('editor_esc')

var _to_scale_selected := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "_to_scale_selected_evaluation")
func _to_scale_selected_evaluation() -> bool:
	if not Input.is_action_just_pressed("editor_alt"): return false
	if _selected.empty(): return false
	
	var select = _selected.front()
	if select is EditorRegion:
		return _is_scaling_region(select as EditorRegion)
	
	return false

var _from_scale_selected := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "_from_scale_selected_evaluation")
func _from_scale_selected_evaluation() -> bool:
	return Input.is_action_just_released("editor_alt")

var _to_move_view := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "_to_move_view_evaluation")
func _to_move_view_evaluation() -> bool:
	return Input.is_action_just_pressed("editor_alt")

var _from_move_view := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "_from_move_view_evaluation")
func _from_move_view_evaluation() -> bool:
	return Input.is_action_just_released("editor_alt")

var _to_move_selected := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "_to_move_selected_evaluation")
func _to_move_selected_evaluation() -> bool:
	if not Input.is_action_just_pressed("editor_alt"): return false
	if _selected.empty(): return false
	
	var select = _selected.front()
	if select is EditorRegion:
		return _is_moving_region(select as EditorRegion)
		
	if select is EditorObject:
		return _is_moving_object(select as EditorObject)
	
	return false

var _from_move_selected := FSMQuickTransition.new(fsm)\
	.set_evaluation(self, "_from_move_selected_evaluation")
func _from_move_selected_evaluation() -> bool:
	return Input.is_action_just_released("editor_alt")

func _is_moving_region(region : EditorRegion) -> bool:
	return _cursor_within(region.movement_hint_position(), region.movement_hint_size())

func _is_moving_object(object : EditorObject) -> bool:
	var mpos := _grid.to_coords(get_global_mouse_position(), false) as Vector2
	return object.get_select_rect().has_point(mpos)

func _is_scaling_region(region : EditorRegion) -> bool:
	return _cursor_within(region.scale_hint_position(), region.scale_hint_size())

func _cursor_within(pos : Vector2, max_distance : float) -> bool:
	var cpos := _grid.to_pixels(pos)
	var mpos := get_global_mouse_position()
	var distance := (cpos - mpos).length()
	return distance < _grid.to_pixelsf(max_distance) * _view.get_zoom()

func _is_first_selected_snapping() -> bool:
	assert(not _selected.empty())
	return _selected.front() is EditorRegion\
		or (_selected.front() is EditorObject and _selected.front().is_snapping())




