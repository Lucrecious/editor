extends Node2D

onready var grid := LutUtils.get_child_by_type(get_parent(), EditorGrid) as EditorGrid
onready var regions := LutUtils.get_child_by_type(get_parent(), EditorRegions) as EditorRegions

func _ready() -> void:
	# connect region updates to this
	return

func _draw() -> void:
	_draw_regions()

func _draw_regions() -> void:
	var rects := regions.all()
	
	for rect in rects:
		rect = Rect2(
			grid.to_pixels(rect.position),
			grid.to_pixels(rect.size))
		
		draw_rect(rect, Color.red)











