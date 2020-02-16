extends Node2D

class_name EditorObjects

signal objects_changed(cmd, object)

var _objects := []

func all() -> Array:
	return _objects.duplicate()

func get_at(mpos : Vector2) -> EditorObject:
	for obj in _objects:
		var select_rect := (obj as EditorObject).get_select_rect()
		if not select_rect.has_point(mpos): continue
		return obj
	return null

func add_object(pos : Vector2, type : int) -> EditorObject:
	var obj := EditorObject.new(pos, type)
	_objects.append(obj)
	emit_signal('objects_changed', EditorCommands.Add, obj)
	return obj
