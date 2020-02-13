extends Node2D

class_name EditorTilemapBitmaskRule

export(NodePath) var tilemap : NodePath
export(int, FLAGS, 'NW', 'N', 'NE', 'W', 'E', 'SW', 'S', 'SE') var bitmask := 0
export(Vector2) var relative := Vector2()

onready var _tilemap := get_node(tilemap) as TileMap

func get_tilemap_name() -> String:
	return _tilemap.name

func get_coord() -> Vector2:
	return _tilemap.world_to_map(global_position)

func get_id() -> int:
	var coord := _tilemap.world_to_map(global_position)
	var id := _tilemap.get_cellv(coord)
	return id

func get_relative() -> Vector2:
	return relative

func get_bitmask() -> int:
	return bitmask

func _ready() -> void:
	assert(_tilemap)