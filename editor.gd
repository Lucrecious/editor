extends Node2D

class_name GameEditor

onready var _terminal := $HUD/Terminal

func _on_Terminal_command_entered(command : Dictionary) -> void:
	print(command)
	var cmd = command['cmd']
	if cmd == null: return
	
	match cmd:
		EditorCommands.Unknown:
			_terminal.output.put([str(OS.get_ticks_msec())])