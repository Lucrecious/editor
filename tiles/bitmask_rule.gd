extends Node2D

class_name EditorTilemapBitmaskRule

export(NodePath) var tilemap : NodePath
export(int, FLAGS, 'NW', 'N', 'NE', 'W', 'E', 'SW', 'S', 'SE') var bitmask := 0
export(Vector2) var relative := Vector2()

onready var _tilemap := get_node(tilemap) as TileMap

func _ready() -> void:
	assert(_tilemap)
	
func get_id() -> Dictionary:
	var coord := _tilemap.world_to_map(global_position)
	var id := _tilemap.get_cellv(coord)
	return {'bitmask' :bitmask, 'relative' : relative, 'id' : id, 'tilemap' : _tilemap, 'coord' : coord }