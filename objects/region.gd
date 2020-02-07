extends Reference

class_name EditorRegion

var _rect : Rect2
var _update_regions : FuncRef

func _init(update_regions : FuncRef, rect : Rect2):
	_update_regions = update_regions
	_rect = rect

func has_point(point : Vector2) -> bool:
	return _rect.has_point(point)

func bounding_box() -> Rect2:
	return _rect;

func rect() -> Rect2:
	return _rect