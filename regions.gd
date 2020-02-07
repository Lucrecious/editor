extends Node2D

class_name EditorRegions

signal regions_changed

var _regions := []

var _update_regions_ref := funcref(self, "_update_regions")

func _update_regions() -> void:
	emit_signal("regions_changed")

func create(pos : Vector2, size := Vector2(1, 1)) -> EditorRegion:
	_regions.append(
		EditorRegion.new(
			_update_regions_ref,
			Rect2(pos, size)))
	_update_regions()
	return _regions.back()

func get_at(coords : Vector2) -> EditorRegion:
	for i in range(_regions.size()-1, -1, -1):
		var region := _regions[i] as EditorRegion
		if region.has_point(coords):
			return region
	
	return null

func all() -> Array:
	return _regions.duplicate()