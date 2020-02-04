extends Node2D

onready var view := LutUtils.get_child_by_type(self, EditorView) as EditorView
onready var grid := LutUtils.get_child_by_type(self, EditorGrid) as EditorGrid

func _ready():
	grid.set_view(view.get_rect2())

func _physics_process(delta):
	if Input.is_action_pressed("player_up"):
		view.set_zoom(view.get_zoom() + .01)
		grid.set_view(view.get_rect2())
	
	if Input.is_action_pressed("player_down"):
		view.global_position.y += 1
		grid.set_view(view.get_rect2())
