extends Node2D

class_name EditorView

var zoom := 1.0
var zoom_min := 0.5
var zoom_max := 3.0

onready var camera := LutUtils.get_child_by_type(self, Camera2D) as Camera2D


func magnify(factor : float) -> void:
	zoom = max(zoom_min, zoom / factor)

func shrink(factor : float) -> void:
	zoom = min(zoom_max, zoom * factor)

func get_rect2() -> Rect2:
	var rect2 := Rect2()
	
	var size := camera.get_viewport_rect().size * zoom
	var pos := global_position
	
	rect2.position = Vector2(pos.x - size.x, pos.y - size.y)
	rect2.size = Vector2(size.x * 2, size.y * 2)
	
	return rect2


func _process(delta):
	var zoom_diff = zoom - camera.zoom.x
	if zoom_diff:
		zoom(zoom_diff)

func zoom(zoom_diff : float):
	if abs(zoom_diff) < 0.001:
		camera.zoom.x = zoom
		camera.zoom.y = zoom
		return
		
	var z = lerp(camera.zoom.x, zoom, .2)
	camera.zoom.x = z
	camera.zoom.y = z










