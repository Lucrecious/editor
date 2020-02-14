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

func to_coords(pixels : Vector2) -> Vector2:
	return Vector2(to_coordsf(pixels.x), to_coordsf(pixels.y))

func to_coordsf(pixels : float) -> int:
	var coord := pixels / Constants.BLOCK_SIZE
	if coord < 0: coord -= 1
	return int(coord)

