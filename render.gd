extends Node2D

const SelectedColor := Color.yellow
const RegionColor := Color.red
const RegionCollisionColor := Color.lightblue
const ObjectColor := Color.green

onready var _editor := get_parent().get_parent().get_parent().get_parent() as GameEditor
onready var _grid := LutUtils.get_child_by_type(get_parent(), EditorGrid) as EditorGrid
onready var _regions := LutUtils.get_child_by_type(get_parent(), EditorRegions) as EditorRegions
onready var _objects := LutUtils.get_child_by_type(get_parent(), EditorObjects) as EditorObjects
onready var _view := LutUtils.get_child_by_type(get_parent(), EditorView) as EditorView

var _grid_color := Color.black

var _grid_visible := true
var _hints_visible := true

func toggle_grid_visible() -> void:
	_grid_visible = not _grid_visible
	update()

func toggle_hints_visible() -> void:
	_hints_visible = not _hints_visible
	update()

func objects_changed(cmd : String, object : EditorObject) -> void:
	update()

func regions_changed(cmd : String, region : EditorRegion) -> void:
	update()

func _draw() -> void:
	if _grid_visible: _draw_grid()
	if _hints_visible:
		_draw_regions()
		_draw_objects()
		_draw_selected_boxes()

func _draw_objects() -> void:
	var objects := _objects.all() as Array
	for obj in objects:
		var rect := obj.get_select_rect() as Rect2
		rect = Rect2(_grid.to_pixels(rect.position),
			_grid.to_pixels(rect.size))
		draw_rect(rect, ObjectColor, false)
		

func _draw_grid() -> void:
	var grid_rect := _grid.get_rect()
	var top_y = grid_rect.position.y
	for i in range(grid_rect.position.x, grid_rect.end.x + 1, Constants.BLOCK_SIZE):
		draw_line(
			Vector2(i, grid_rect.position.y),
			Vector2(i, grid_rect.end.y),
			_grid_color)
	
	for i in range(grid_rect.position.y, grid_rect.end.y + 1, Constants.BLOCK_SIZE):
		draw_line(
			Vector2(grid_rect.position.x, i),
			Vector2(grid_rect.end.x, i),
			_grid_color)

func _draw_regions() -> void:
	var regions := _regions.all()
	
	for region in regions:
		var rect := (region as EditorRegion).rect()
		rect = Rect2(
			_grid.to_pixels(rect.position),
			_grid.to_pixels(rect.size))
		
		if region.get_texture():
			draw_rect(rect, RegionCollisionColor, false)
		else:
			draw_rect(rect, RegionColor, false)

func _draw_selected_boxes():
	var selected := _editor.get_selected()
	
	for select in selected:
		if select is EditorRegion:
			_draw_region_select(select as EditorRegion)
		if select is EditorObject:
			_draw_object_select(select as EditorObject)
	
	if not selected.empty():
		_select_first(selected.front())

func _select_first(select):
	if select is EditorRegion:
		_draw_region_transformation_hints(select as EditorRegion)
	if select is EditorObject:
		_draw_object_transformation_hints(select as EditorObject)

func _draw_object_transformation_hints(object : EditorObject) -> void:
	var rect := object.get_select_rect()
	rect.position = _grid.to_pixels(rect.position)
	rect.size = _grid.to_pixels(rect.size)
	
	draw_rect(rect.grow(-3 * _view.get_zoom()), Color.black, true)

func _draw_region_transformation_hints(region : EditorRegion) -> void:
	var pos := _grid.to_pixels(region.movement_hint_position())
	var size := _grid.to_pixelsf(region.movement_hint_size()) * _view.get_zoom()
	draw_circle(pos, size, Color.black)
	
	pos = _grid.to_pixels(region.scale_hint_position())
	size = _grid.to_pixelsf(region.scale_hint_size()) * _view.get_zoom()
	draw_circle(pos, size, Color.black)

func _draw_region_select(region : EditorRegion) -> void:
	var rect := region.bounding_box()
	rect.position = _grid.to_pixels(rect.position)
	rect.size = _grid.to_pixels(rect.size)
	
	draw_rect(rect.grow(3 * _view.get_zoom()), SelectedColor, false)

func _draw_object_select(object : EditorObject) -> void:
	var rect := object.get_select_rect()
	rect.position = _grid.to_pixels(rect.position)
	rect.size = _grid.to_pixels(rect.size)
	
	draw_rect(rect.grow(3 * _view.get_zoom()), SelectedColor, false)










