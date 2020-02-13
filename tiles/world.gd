extends Node

class_name EditorWorld

onready var _maps := $Setup.maps() as Dictionary
onready var _tilemaps := $Setup/TileMaps

func _ready() -> void:
	$Setup.visible = false

func map_exists_for_tileset(tileset : String) -> bool:
	return tileset in _maps

func clear_tilemaps() -> void:
	for tilemap in LutUtils.get_children_by_type(self, TileMap):
		tilemap.clear()

func draw_regions(name : String, regions : Array) -> bool:
	var map := _maps.get(name) as EditorTilesetMap
	if not map:
		assert(false)
		return false
	
	var tilemap_names := map.get_required_tilemaps()
	var tilemaps := _add_tilemaps(tilemap_names) as Dictionary
	
	if tilemaps.empty():
		assert(false)
		return false
	
	var aggregate := {}
	
	for region in regions:
		var rect := region.rect() as Rect2
		for dx in rect.size.x: for dy in rect.size.y:
			var coord := Vector2(rect.position.x + dx, rect.position.y + dy)
			aggregate[coord] = 0
	
	map.set_ids(tilemaps, aggregate)
	
	return true

func _add_tilemaps(tilemap_names : Array) -> Dictionary: 
	var tilemaps := {}
	for n in tilemap_names:
		var tilemap := get_node_or_null(n) as TileMap
		if tilemap:
			tilemaps[n] = tilemap
			continue
			
		tilemap = _tilemaps.get_node_or_null(n) as TileMap
		if not tilemap: return {}
	
		var packed := PackedScene.new()
		packed.pack(tilemap)
	
		var new_tilemap := packed.instance() as TileMap
		add_child(new_tilemap)
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
		move_child(tilemaps[i], i)

class TileMapSorter:
	var _actual_order : Array
	func _init(actual_order):
		_actual_order = actual_order
	
	func compare(t1 : TileMap, t2 : TileMap) -> bool:
		var t1i := _actual_order.find(t1.name)
		assert(t1i != -1)
		
		var t2i := _actual_order.find(t2.name)
		
		return t1i < t2i

func _get_required_map_names(regions : Array) -> Array:
	var required_map_names := {}
	
	for region in regions:
		if region.texture in required_map_names: continue
		required_map_names[region.texture] = true
			
	return required_map_names.keys()






