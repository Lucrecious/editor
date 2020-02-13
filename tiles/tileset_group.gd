extends ReferenceRect

class_name EditorTilesetGroup

export(NodePath) var tilemap_path : NodePath

onready var _tilemap := get_node(tilemap_path) as TileMap

func tilemap() -> TileMap:
	return _tilemap