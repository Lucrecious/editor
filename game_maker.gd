extends Node2D

onready var _regions := $Model/Space/Regions as EditorRegions
onready var _world := $Model/World as EditorWorld

onready var _tilemaps := $Game/TileMaps
onready var _copy_tilemaps := $Model/World/Setup/TileMaps
onready var _collisions := $Game/Collision

func _ready():
	pass # Replace with function body.

func regions_changed(cmd : String, region : EditorRegion) -> void:
	_update_tilemaps()

func _update_tilemaps() -> void:
	clear_tilemaps()
	var coverage_map := _regions.get_region_coverage_map()
	var region_groups := _get_region_groups(coverage_map)
	for region_group in region_groups.keys():
		_draw_regions(region_group, coverage_map, region_groups[region_group])

func _get_region_groups(coverage_map : Dictionary) -> Dictionary:
	var region_groups := {}
	
	for region in _regions.all():
		var tileset := (region as EditorRegion).get_tileset()
		if not tileset: continue
		var group := region_groups.get(tileset, []) as Array
		group.append(region)
		region_groups[tileset] = group
	
	return region_groups

func _draw_regions(name : String, coverage_map : Dictionary, regions : Array) -> bool:
	if not _world.map_exists_for_tileset(name):
		assert(false)
		return false
	
	var tilemap_names := _world.get_required_tilemap_names(regions) as Array
	var tilemaps := _add_tilemaps(tilemap_names) as Dictionary
	
	if tilemaps.empty():
		assert(false)
		return false
	
	var aggregate := {}
	
	for region in regions:
		var coverage := coverage_map[region] as Dictionary
		for coord in coverage.keys():
			aggregate[coord] = 0
	
	_world.set_ids(name, tilemaps, aggregate)
	
	return true

func clear_tilemaps() -> void:
	for tilemap in _tilemaps.get_children():
		assert(tilemap is TileMap)
		tilemap.clear()

func _add_tilemaps(tilemap_names : Array) -> Dictionary: 
	var tilemaps := {}
	for n in tilemap_names:
		var tilemap := _tilemaps.get_node_or_null(n) as TileMap
		if tilemap:
			tilemaps[n] = tilemap
			continue
			
		tilemap = _copy_tilemaps.get_node_or_null(n) as TileMap
		if not tilemap: return {}
	
		var packed := PackedScene.new()
		packed.pack(tilemap)
	
		var new_tilemap := packed.instance() as TileMap
		_tilemaps.add_child(new_tilemap)
		new_tilemap.clear()
		tilemaps[n] = new_tilemap
	
	_sort_tilemaps(LutUtils.get_children_by_type(self, TileMap))
	
	return tilemaps

func _sort_tilemaps(tilemaps : Array) -> void:
	var actual_order := []
	for c in _tilemaps.get_children():
		actual_order.append(c.name)
	
	tilemaps.sort_custom(TileMapSorter.new(actual_order), 'compare')
	
	for i in range(tilemaps.size()):
		_tilemaps.move_child(tilemaps[i], i)

class TileMapSorter:
	var _actual_order : Array
	func _init(actual_order):
		_actual_order = actual_order
	
	func compare(t1 : TileMap, t2 : TileMap) -> bool:
		var t1i := _actual_order.find(t1.name)
		assert(t1i != -1)
		
		var t2i := _actual_order.find(t2.name)
		
		return t1i < t2i