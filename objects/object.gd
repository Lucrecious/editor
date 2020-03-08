extends Node

class_name EditorObject

var _type := EditorObjectTypes.Unknown
var _snap_to_grid := false
var _position := Vector2(0, 0)
var _properties := {}

var _update_funcref : FuncRef

func get_select_rect() -> Rect2:
	var pos := _position
	var size := Vector2(.5, .5)
	
	return Rect2(pos - size / 2, size)

func _init(pos : Vector2, type : int, update_funcref : FuncRef) -> void:
	_position = pos
	_type = type
	_update_funcref = update_funcref
	_properties = EditorObjectTypes.Properties[type].duplicate()

func get_type() -> int:
	return _type

func get_property(name : String):
	return _properties.get(name, null)

func set_property(name : String, variant) -> bool:
	if not name in _properties: return false
	_properties[name] = variant
	return true

func move(delta : Vector2) -> void:
	set_position(_position + delta)

func set_position(position : Vector2) -> void:
	_position = position
	_update_funcref.call_func(EditorCommands.Transformation, self)

func get_position() -> Vector2:
	return _position

func set_snap_to_grid(snap : bool) -> void:
	_snap_to_grid = snap

func is_snapping() -> bool:
	return _snap_to_grid









