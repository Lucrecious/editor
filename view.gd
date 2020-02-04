extends Node2D

class_name EditorView

onready var camera := LutUtils.get_child_by_type(self, Camera2D) as Camera2D

func get_zoom() -> float:
	return camera.zoom.x

func set_zoom(zoom : float) -> void:
	camera.zoom.x = zoom
	camera.zoom.y = zoom

func get_rect2() -> Rect2:
	var rect2 := Rect2()
	
	var size := camera.get_viewport_rect().size * camera.zoom.x
	print(size)
	var pos := global_position
	
	rect2.position = Vector2(pos.x - size.x, pos.y - size.y)
	rect2.size = Vector2(size.x * 2, size.y * 2)
	
	return rect2
