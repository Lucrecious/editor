extends Reference

class_name EditorTilesetMap

# --1 --2 --4  0 1 2
# --8 xxx -16  3 x 4
# -32 -64 128  5 6 7
const Bits := [1, 2, 4, 8, 16, 32, 64, 128]

var _tilemap_name : String
var _patterns := {}
var _bitmask_rules := {}
var _default_id := TileMap.INVALID_CELL

func get_required_tilemap_names() -> Array:
	var tilemaps := { _tilemap_name : true }
	for tilemap_rules in _bitmask_rules.values():
		for rules in tilemap_rules.values(): for rule in rules:
			var tilemap_name = rule.get_tilemap_name()
			tilemaps[tilemap_name] = true
	
	return tilemaps.keys()

func set_ids(tilemaps : Dictionary, layout : Dictionary) -> void:
	var tilemap := tilemaps[tilemap_name()] as TileMap
	for coord in layout.keys():
		var bitmask := _get_bitmask(layout, coord)
		bitmask = _ignore_uncovered_corners(bitmask)
		
		if bitmask in _bitmask_rules:
			_apply_bitmask_rules(tilemaps, bitmask, coord)
		
		var pattern := _patterns.get(bitmask) as Pattern
		if not pattern:
			tilemap.set_cellv(coord, _default_id)
			continue
		
		var id := pattern.get_id()
		tilemap.set_cellv(coord, id)

func tilemap_name() -> String:
	return _tilemap_name

func _apply_bitmask_rules(tilemaps : Dictionary, bitmask : int, coord : Vector2) -> void:
	assert(bitmask in _bitmask_rules)
	var tilemap_bitmasks := _bitmask_rules[bitmask] as Dictionary
	for tilemap_name in tilemap_bitmasks.keys():
		var ids := tilemap_bitmasks[tilemap_name] as Array
		var rule := ids[randi() % ids.size()] as EditorTilemapBitmaskRule
		tilemaps[rule.get_tilemap_name()].set_cellv(
			coord + rule.get_relative(), rule.get_id())

func _init(tilemap_name : String, layout : Dictionary, bitmask_rules : Array, default_id : int) -> void:
	_tilemap_name = tilemap_name
	_create_patterns(layout)
	_fill_bitmask_rules(bitmask_rules)
	_default_id = default_id

func _fill_bitmask_rules(rules : Array) -> void:
	for rs in rules: for r in rs:
		var tilemap_bitmasks := _bitmask_rules.get(r.get_bitmask(), {}) as Dictionary
		var set := tilemap_bitmasks.get(r.get_tilemap_name(), []) as Array
		set.append(r)
		tilemap_bitmasks[r.get_tilemap_name()] = set
		_bitmask_rules[r.get_bitmask()] = tilemap_bitmasks

func _create_patterns(layout : Dictionary) -> void:
	for coord in layout.keys():
		var id = layout.get(coord, null)
		if not id: continue
		if id == TileMap.INVALID_CELL: continue
		var bitmask := _get_bitmask(layout, coord)
		var pattern := _patterns.get(bitmask, Pattern.new(bitmask)) as Pattern
		pattern.add_id(id)
		_patterns[bitmask] = pattern

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
	
	bitmask = _ignore_uncovered_corners(bitmask)
	
	return bitmask

func _get_mask_value(layout : Dictionary, coords : Vector2) -> int:
	return int(layout.get(coords, null) != null)

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
		var key = keys[randi() % keys.size()]
		return key
	
	func data() -> int: return _bitmask
	
	func equal(bitmask : int) -> bool:
		return bitmask == _bitmask
