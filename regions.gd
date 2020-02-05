extends Node2D

class_name EditorRegions

var _regions := []

func create(pos : Vector2, size := Vector2(1, 1)) -> int:
	_regions.append(Rect2(pos, size))
	return _regions.size() - 1

func all() -> Array:
	return _regions.duplicate()