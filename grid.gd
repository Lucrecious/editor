extends Node2D

class_name EditorGrid

var _grid := Rect2(Vector2(0, 0), Vector2(0, 0))
var _color := Color.black

func set_view(rect : Rect2) -> void:
	rect.position.x -= fmod(rect.position.x, Constants.BLOCK_SIZE)
	rect.position.y -= fmod(rect.position.y, Constants.BLOCK_SIZE)
	rect.size.x += Constants.BLOCK_SIZE - fmod(rect.size.x, Constants.BLOCK_SIZE)
	rect.size.y += Constants.BLOCK_SIZE - fmod(rect.size.y, Constants.BLOCK_SIZE)
	_grid = rect
	update()

func set_color(color : Color):
	_color = color

func _draw():
	_draw_grid()

func _draw_grid() -> void:
	var top_y = _grid.position.y
	for i in range(_grid.position.x, _grid.end.x + 1, Constants.BLOCK_SIZE):
		draw_line(
			Vector2(i, _grid.position.y),
			Vector2(i, _grid.end.y),
			_color)
	
	for i in range(_grid.position.y, _grid.end.y + 1, Constants.BLOCK_SIZE):
		draw_line(
			Vector2(_grid.position.x, i),
			Vector2(_grid.end.x, i),
			_color)

