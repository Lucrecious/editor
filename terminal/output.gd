extends Label

var buffer := []

func _ready() -> void:
	var font := get_theme().default_font
	max_lines_visible = int(rect_size.y / font.get_height()) - 1

func put(lines : Array) -> void:
	for line in lines:
		put_line(line)

func put_line(line : String) -> void:
	assert(line.find('\n') == -1)
	_add_line(line)

func put_error_line(line : String) -> void:
	assert(line.find('\n') == -1)
	_add_line('[%s]' % line)

func _add_line(line : String) -> void:
	buffer.push_front(line)
	var font := get_theme().default_font
	
	if buffer.size() >= max_lines_visible:
		buffer.resize(max_lines_visible)
	
	var display = buffer.duplicate()
	display.invert()
	text = LutUtils.join(display, "\n")











