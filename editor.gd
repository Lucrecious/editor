extends Node2D

onready var view := LutUtils.get_child_by_type(self, EditorView) as EditorView
onready var grid := LutUtils.get_child_by_type(self, EditorGrid) as EditorGrid

var zoom_max = 3
var zoom_min = .5
var zoom_current = 1

func _ready():
	grid.set_view(view.get_rect2())

func _input(event : InputEvent) -> void:
	if Input.is_action_just_pressed("editor_zoom_in"):
		view.magnify(1.3)
	
	if Input.is_action_just_pressed("editor_zoom_out"):
		view.shrink(1.3)
	
	grid.set_view(view.get_rect2())









