extends Node2D

var _maps := {}

onready var _groups := $Groups
onready var _tilemaps := $TileMaps

func maps() -> Dictionary:
	return _maps.duplicate(false)

func _ready():
	assert(_tilemaps.get_child_count())
	_create_tilesets()

func _create_tilesets() -> void:
	for rect in _groups.get_children():
		_maps[rect.name.to_lower()] = _create_map(rect as ReferenceRect)

func _create_map(ref_rect : ReferenceRect) -> EditorTilesetMap:
	var rect := Rect2(ref_rect.rect_position, ref_rect.rect_size)
	var _tiles := _get_tiles_for_group(rect)
	var map := EditorTilesetMap.new(_tiles, -1)
	return map

func _get_tiles_for_group(rect : Rect2) -> Dictionary:
	var tiles := {}
	for tilemap in _tilemaps.get_children():
		assert(tilemap is TileMap)
		var start := tilemap.world_to_map(rect.position) as Vector2
		var end := tilemap.world_to_map(rect.end) as Vector2
		var size := end - start
		for c in size.x: for r in size.y:
			var coords := Vector2(start.x + c, start.y + r)
			var id := tilemap.get_cellv(coords) as int
			if id == TileMap.INVALID_CELL: continue
			tiles[coords] = id
	
	return tiles
