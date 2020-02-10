extends Node

class_name EditorTiles

onready var _maps := $Setup.maps() as Dictionary

var _tilemap : TileMap

func _ready() -> void:
	$Setup.visible = false
	var tilemap := TileMap.new()
	tilemap.cell_size = Vector2(Constants.BLOCK_SIZE, Constants.BLOCK_SIZE)
	tilemap.tile_set = $Setup/TileMaps/Forground1.tile_set
	add_child(tilemap)
	_tilemap = tilemap

func draw_regions(name : String, regions : Array) -> bool:
	var map := _maps.get(name) as EditorTilesetMap
	if not map: return false
	
	_tilemap.clear()
	
	var aggregate := {}
	
	for region in regions:
		var rect := (region as EditorRegion).rect()
		for dx in rect.size.x: for dy in rect.size.y:
			var coord := Vector2( rect.position.x + dx,rect.position.y + dy)
			aggregate[coord] = 0
	
	aggregate = map.set_ids(aggregate)
	
	for coord in aggregate.keys():
		_tilemap.set_cellv(coord, aggregate[coord])
	
	return true






