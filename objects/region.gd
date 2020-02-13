extends Reference

class_name EditorRegion

var _rect : Rect2
var _tileset := 'grass'

var _update_regions : FuncRef

func _init(update_regions : FuncRef, rect : Rect2):
	_update_regions = update_regions
	_rect = rect

func get_tileset() -> String:
	return _tileset

func set_tileset(tileset : String) -> void:
	_tileset = tileset

func move(delta : Vector2) -> void:
	delta = Vector2(int(delta.x), int(delta.y))
	if delta.x == 0 and delta.y == 0: return
	_rect.position += delta
	_update_regions.call_func()

func set_scale(scale : Vector2) -> void:
	scale = Vector2(max(1, int(scale.x)), max(1, int(scale.y)))
	
	if (_rect.size - scale).length() == 0: return
	
	_rect.size = Vector2(max(1, int(scale.x)), max(1, int(scale.y)))
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




