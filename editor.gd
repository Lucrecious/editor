extends Node2D

onready var view := LutUtils.get_child_by_type(self, EditorView) as EditorView
onready var grid := LutUtils.get_child_by_type(self, EditorGrid) as EditorGrid

func _ready():
	grid.set_view(view.get_rect2())

func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("editor_zoom_in"):
		view.magnify(1.3)
	elif Input.is_action_just_pressed("editor_zoom_out"):
		view.shrink(1.3)
	elif Input.is_action_pressed("editor_alt") and event is InputEventMouseMotion:
		var rel = (event as InputEventMouseMotion).relative
		view.global_position -= Vector2(rel.x, rel.y) * view.zoom
	
	grid.set_view(view.get_rect2())









