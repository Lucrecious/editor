extends Reference

class_name EditorRegion

var _rect : Rect2
var _update_regions : FuncRef

func _init(update_regions : FuncRef, rect : Rect2):
	_update_regions = update_regions
	_rect = rect

func move(delta : Vector2) -> void:
	_rect.position += delta
	_update_regions.call_func()

func set_scale(scale : Vector2) -> void:
	_rect.size = Vector2(int(scale.x), int(scale.y))
	_update_regions.call_func()

func has_point(point : Vector2) -> bool:
	return _rect.has_point(point)

func bounding_box() -> Rect2:
	return _rect;

func rect() -> Rect2:
	return _rect

func movement_hint_position() -> Vector2:
	return _rect.position + _rect.size / 2

func movement_hint_size() -> float:
	return .125

func scale_hint_position() -> Vector2:
	return _rect.end

func scale_hint_size() -> float:
	return .125




