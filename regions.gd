extends Node2D

class_name EditorRegions

signal regions_changed(command, region)

var _regions := []

var _update_regions_ref := funcref(self, "_update_regions")

func _update_regions(command : String, region : EditorRegion) -> void:
	emit_signal("regions_changed", command, region)

func get_region_coverage_map() -> Dictionary:
	var coverage_map := {}
	
	for i in range(_regions.size()):
		var r := _regions[i]  as EditorRegion
		var coverage := _get_coverage_coords(r)
		
		for j in range(i):
			coverage = _subtract_region(r, coverage, _regions[j])
		
		coverage_map[r] = coverage
	
	return coverage_map

func _subtract_region(
	region : EditorRegion,
	coverage : Dictionary,
	subtract_region : EditorRegion) -> Dictionary:
		var rect := region.rect()
		var subRect := subtract_region.rect()
		
		var clip := rect.clip(subRect)
		
		for x in range(clip.position.x, clip.end.x):
			for y in range(clip.position.y, clip.end.y):
				coverage.erase(Vector2(x, y))
		
		return coverage
		

func _get_coverage_coords(region : EditorRegion) -> Dictionary:
	var coverage := {}
	
	var rect := region.rect()
	for x in range(rect.position.x, rect.end.x):
		for y in range(rect.position.y, rect.end.y):
			coverage[Vector2(x, y)] = true
	
	return coverage

func create(pos : Vector2, size := Vector2(1, 1)) -> EditorRegion:
	_regions.append(
		EditorRegion.new(
			_update_regions_ref,
			Rect2(pos, size)))
	_update_regions(EditorCommands.Add, _regions.back())
	return _regions.back()

func get_at(coords : Vector2) -> EditorRegion:
	for i in range(_regions.size()-1, -1, -1):
		var region := _regions[i] as EditorRegion
		if region.has_point(coords):
			return region
	
	return null

func all() -> Array:
	return _regions.duplicate()