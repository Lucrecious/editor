extends Node2D

class_name EditorGrid

signal grid_changed

var _units := Constants.BLOCK_SIZE
var _grid := Rect2(Vector2(0, 0), Vector2(0, 0))

func get_rect() -> Rect2:
	return _grid

func set_view(rect : Rect2) -> void:
	rect.position.x -= fmod(rect.position.x, Constants.BLOCK_SIZE)
	rect.position.y -= fmod(rect.position.y, Constants.BLOCK_SIZE)
	rect.size.x += Constants.BLOCK_SIZE - fmod(rect.size.x, Constants.BLOCK_SIZE)
	rect.size.y += Constants.BLOCK_SIZE - fmod(rect.size.y, Constants.BLOCK_SIZE)
	_grid = rect
	emit_signal("grid_changed")

func to_pixels(coords : Vector2) -> Vector2:
	return coords * _units

func to_pixelsf(coord : float) -> float:
	return coord * _units

func to_coords(pixels : Vector2, to_int := true) -> Vector2:
	return Vector2(to_coordsf(pixels.x, to_int), to_coordsf(pixels.y, to_int))

func to_coordsf(pixels : float, to_int := true) -> float:
	var coord := pixels / Constants.BLOCK_SIZE
	if coord < 0 and to_int: coord -= 1.0
	return int(coord) if to_int else coord

