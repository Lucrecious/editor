extends Node

class_name EditorObject

var _type := EditorObjectTypes.Unknown
var _snap_to_grid := true
var _position := Vector2(0, 0)
var _properties := {}

func get_select_rect() -> Rect2:
	var pos := _position + Vector2(.5, .5)
	var size := Vector2(.5, .5)
	
	return Rect2(pos - size / 2, size)

func _init(pos : Vector2, type : int) -> void:
	_position = pos
	_type = type
	_properties = EditorObjectTypes.Properties[type].duplicate()

func set_property(name : String, variant) -> bool:
	if not name in _properties: return false
	_properties[name] = variant
	return true

func set_position(position : Vector2) -> void:
	_position = position

func get_position() -> Vector2:
	return _position

func set_snap_to_grid(snap : bool) -> void:
	_snap_to_grid = snap

func get_snap_to_grid() -> bool:
	return _snap_to_grid









