extends Node

class_name EditorWorld

onready var _maps := $Setup.maps() as Dictionary
onready var _tilemaps := $Setup/TileMaps

func _ready() -> void:
	$Setup.visible = false

func set_ids(name : String, tilemaps : Dictionary, layout : Dictionary):
	(_maps[name] as EditorTilesetMap).set_ids(tilemaps, layout)

func map_exists_for_tileset(tileset : String) -> bool:
	return tileset in _maps

func get_required_tilemap_names(regions : Array) -> Array:
	var required_tilemap_names := {}
	
	for region in regions:
		var map := _maps[region.get_tileset()] as EditorTilesetMap
		for tilemap_names in map.get_required_tilemap_names():
			required_tilemap_names[tilemap_names] = true
		
	return required_tilemap_names.keys()






