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
		_maps[rect.name.to_lower()] = _create_map(rect as EditorTilesetGroup)

func _create_map(ref_rect : EditorTilesetGroup) -> EditorTilesetMap:
	var rect := Rect2(ref_rect.rect_position, ref_rect.rect_size)
	var exempts := _get_bitmask_rules(ref_rect.get_children())
	var tiles := _get_tiles_for_group(rect, exempts)
	var map := EditorTilesetMap.new(ref_rect.tilemap().name, tiles, exempts.values(), -1)
	return map

func _get_bitmask_rules(bitmask_rules : Array) -> Dictionary:
	var ids := {}
	
	for rule in bitmask_rules:
		var coord := rule.get_coord() as Vector2
		ids[coord] = rule
	
	return ids

func _get_tiles_for_group(rect : Rect2, exempts : Dictionary) -> Dictionary:
	var tiles := {}
	for tilemap in _tilemaps.get_children():
		assert(tilemap is TileMap)
		var start := tilemap.world_to_map(rect.position) as Vector2
		var end := tilemap.world_to_map(rect.end) as Vector2
		var size := end - start
		for c in size.x: for r in size.y:
			var coord := Vector2(start.x + c, start.y + r)
			var id := tilemap.get_cellv(coord) as int
			if id == TileMap.INVALID_CELL: continue
			if _is_exempt(coord, exempts): continue
			tiles[coord] = id
	
	return tiles

func _is_exempt(coord : Vector2, exempts : Dictionary) -> bool:
	var rule = exempts.get(coord)
	if not rule: return false
	return true





