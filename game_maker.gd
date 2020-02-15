extends Node2D

onready var _regions := $Model/Space/Regions

func _ready():
	pass # Replace with function body.

func regions_changed(cmd : String, region : EditorRegion) -> void:
	pass