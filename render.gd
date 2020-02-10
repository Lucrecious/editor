extends Node2D

onready var _editor := get_parent().get_parent() as GameEditor
onready var _grid := LutUtils.get_child_by_type(get_parent(), EditorGrid) as EditorGrid
onready var _regions := LutUtils.get_child_by_type(get_parent(), EditorRegions) as EditorRegions
onready var _view := LutUtils.get_child_by_type(get_parent(), EditorView) as EditorView

func _draw() -> void:
	#_draw_regions()
	_draw_selected_boxes()

func _draw_regions() -> void:
	var regions := _regions.all()
	
	for region in regions:
		var rect := (region as EditorRegion).rect()
		rect = Rect2(
			_grid.to_pixels(rect.position),
			_grid.to_pixels(rect.size))
		
		draw_rect(rect, Color.red)

func _draw_selected_boxes():
	var selected := _editor.get_selected()
	
	for select in selected:
		if select is EditorRegion:
			_draw_region_select(select as EditorRegion)
	
	if not selected.empty():
		_select_first(selected.front())

func _select_first(select):
	if select is EditorRegion:
		_draw_region_transformation_hints(select as EditorRegion)

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
	
	draw_rect(rect.grow(3 * _view.get_zoom()), Color.yellow, false)










