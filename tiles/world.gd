extends Node

class_name EditorWorld

onready var _maps := $Setup.maps() as Dictionary
onready var _tilemaps := $Setup/TileMaps

func _ready() -> void:
	$Setup.visible = false

func draw_regions(name : String, regions : Array) -> bool:
	var map := _maps.get(name) as EditorTilesetMap
	if not map:
		assert(false)
		return false
	
	var tilemap := get_node_or_null(map.tilemap_name()) as TileMap
	if not tilemap:
		tilemap = _add_tilemap(map.tilemap_name())
		if not tilemap:
			assert(false)
			return false
	
	tilemap.clear()
	
	var aggregate := {}
	
	for region in regions:
		var rect := (region as EditorRegion).rect()
		for dx in rect.size.x: for dy in rect.size.y:
			var coord := Vector2(rect.position.x + dx, rect.position.y + dy)
			aggregate[coord] = 0
	
	aggregate = map.set_ids(aggregate)
	
	for coord in aggregate.keys():
		tilemap.set_cellv(coord, aggregate[coord])
	
	return true

func _add_tilemap(tilemap_name : String) -> TileMap:
	var tilemap := _tilemaps.get_node_or_null(tilemap_name) as TileMap
	if not tilemap:
		assert(false)
		return null
	
	var packed := PackedScene.new()
	packed.pack(tilemap)
	
	var new_tilemap := packed.instance() as TileMap
	add_child(new_tilemap)
	
	return new_tilemap

func _get_required_map_names(regions : Array) -> Array:
	var required_map_names := {}
	
	for region in regions:
		if region.texture in required_map_names: continue
		required_map_names[region.texture] = true
			
	return required_map_names.keys()






