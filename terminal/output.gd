extends Label

var buffer := []

func _ready() -> void:
	pass

func put(lines : Array) -> void:
	for line in lines:
		_add_line(line)

func _add_line(line : String) -> void:
	buffer.push_front(line)
	var font := get_theme().default_font
	
	var h = font.get_height() * (buffer.size() + 1)
	
	if h >= rect_size.y:
		buffer.pop_back()
	
	text = LutUtils.join(buffer, "\n")











