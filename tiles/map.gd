extends Reference

class_name EditorTilesetMap

# --1 --2 --4  0 1 2
# --8 xxx -16  3 x 4
# -32 -64 128  5 6 7
const Bits := [1, 2, 4, 8, 16, 32, 64, 128]

var _patterns := {}
var _default_id := TileMap.INVALID_CELL

func set_ids(tiles : Dictionary) -> Dictionary:
	var ids := {}
	var coords := tiles.keys()
	for coord in coords:
		var bitmask := _get_bitmask(tiles, coord)
		bitmask = _ignore_uncovered_corners(bitmask)
		var pattern := _patterns.get(bitmask) as Pattern
		if not pattern:
			ids[coord] = _default_id
			continue
		ids[coord] = pattern.get_id()
	
	return ids

func _init(layout : Dictionary, default_id : int) -> void:
	_create_patterns(layout)
	_default_id = default_id

func _create_patterns(layout : Dictionary) -> void:
	for coord in layout.keys():
		var id := layout.get(coord, TileMap.INVALID_CELL) as int
		if id == TileMap.INVALID_CELL: continue
		var bitmask := _get_bitmask(layout, coord)
		bitmask = _ignore_uncovered_corners(bitmask)
		var pattern := _patterns.get(bitmask, Pattern.new(bitmask)) as Pattern
		pattern.add_id(id)
		_patterns[bitmask] = pattern
	
	return

func _ignore_uncovered_corners(bitmask : int) -> int:
	bitmask = _ignore_uncovered_corner(bitmask, 0, 1, 3)
	bitmask = _ignore_uncovered_corner(bitmask, 2, 1, 4)
	bitmask = _ignore_uncovered_corner(bitmask, 5, 3, 6)
	bitmask = _ignore_uncovered_corner(bitmask, 7, 4, 6)
	
	return bitmask

func _ignore_uncovered_corner(bitmask : int, corner_i : int, edge1_i : int, edge2_i) -> int:
	var bit1 := bool(LutMath.get_bit(bitmask, edge1_i))
	var bit2 := bool(LutMath.get_bit(bitmask, edge2_i))
	
	if not (bit1 and bit2):
		bitmask = LutMath.set_bit(bitmask, corner_i, 0)
	
	return bitmask

func _get_bitmask(layout : Dictionary, coords : Vector2) -> int:
	var bitmask := 0
	var mask := [
		_get_mask_value(layout, coords + Vector2(-1, -1)),
		_get_mask_value(layout, coords + Vector2(0, -1)),
		_get_mask_value(layout, coords + Vector2(1, -1)),
		_get_mask_value(layout, coords + Vector2(-1, 0)),
		_get_mask_value(layout, coords + Vector2(1, 0)),
		_get_mask_value(layout, coords + Vector2(-1, 1)),
		_get_mask_value(layout, coords + Vector2(0, 1)),
		_get_mask_value(layout, coords + Vector2(1, 1))
	]

	for i in range(Bits.size()):
		bitmask += Bits[i] * mask[i]
	
	return bitmask

func _get_mask_value(layout : Dictionary, coords : Vector2) -> int:
	return int(layout.get(coords, TileMap.INVALID_CELL) != TileMap.INVALID_CELL)

class Pattern extends Reference:
	var _ids := {}
	var _bitmask : int
	func _init(bitmask):
		_bitmask = bitmask
	
	func add_id(id : int) -> void:
		_ids[id] = true
	
	func get_id() -> int:
		assert(not _ids.empty())
		var keys = _ids.keys()
		var key = keys[keys.size() % randi()]
		return _ids[key]
	
	func data() -> int: return _bitmask
	
	func equal(bitmask : int) -> bool:
		return bitmask == _bitmask