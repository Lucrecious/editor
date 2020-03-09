extends Node2D

var _regions_collisions := {}
var _objects_nodes := {}

const WorldCollisionScene := preload('res://src/game/environment/collision/collision.tscn')
const SpawnerScenePath := 'res://src/game/meta/character_spawner.tscn'

onready var _regions := $Model/Space/Regions as EditorRegions
onready var _world := $Model/World as EditorWorld
onready var _grid := $Model/Space/Grid

onready var _game := $Game
onready var _tilemaps := $Game/TileMaps
onready var _copy_tilemaps := $Model/World/Setup/TileMaps
onready var _collisions := $Game/Collision
onready var _characters := $Game/Characters

func objects_changed(cmd : String, object : EditorObject) -> void:
	match cmd:
		EditorCommands.Add:
			_objects_nodes[object] = _add_object(object)
		EditorCommands.Transformation:
			if not object in _objects_nodes: return
			_transform_object(object)

func _add_object(object : EditorObject) -> Node2D:
	match object.get_type():
		EditorObjectTypes.Spawner,\
		EditorObjectTypes.PlayerSpawner:
			assert(object.get_property(EditorObjProp.Spawn))
			var packed_scene := load(SpawnerScenePath)
			var scene := packed_scene.instance() as Node2D
			_add_node_to_game(_characters, scene)
			scene.owner = _game
			
			scene.global_position = _grid.to_pixels(object.get_position())
			scene.spawn = object.get_property(EditorObjProp.Spawn)
			return scene
	
	assert(false)
	return null

func _transform_object(object : EditorObject) -> void:
	assert(object in _objects_nodes)
	var node := _objects_nodes[object] as CharSpawner
	node.global_position = _grid.to_pixels(object.get_position())
	

func regions_changed(cmd : String, region : EditorRegion) -> void:
	match cmd:
		EditorCommands.Transformation:
			if region.get_texture():
				_set_collision(region)
		EditorCommands.TextureParam:
			if not region.get_texture():
				_remove_collision(region)
			else:
				_set_collision(region)
	
	_update_tilemaps()

func _remove_collision(region : EditorRegion) -> void:
	var collision := _regions_collisions.get(region, null) as WorldCollision
	if not collision: return
	_tilemaps.remove_child(collision)
	collision.queue_free()
	

func _set_collision(region : EditorRegion) -> void:
	var collision := _regions_collisions.get(region, null) as WorldCollision
	if not collision:
		collision = WorldCollisionScene.instance()
		collision.set_texture(region.get_texture())
		_add_node_to_game(_collisions, collision)
		_regions_collisions[region] = collision
	
	var rect := region.rect()
	rect.position = _grid.to_pixels(rect.position)
	rect.size = _grid.to_pixels(rect.size)
	collision.set_collision_as_rect(rect)

func _update_tilemaps() -> void:
	clear_tilemaps()
	var coverage_map := _regions.get_region_coverage_map()
	var region_groups := _get_region_groups(coverage_map)
	for region_group in region_groups.keys():
		_draw_regions(region_group, coverage_map, region_groups[region_group])

func _get_region_groups(coverage_map : Dictionary) -> Dictionary:
	var region_groups := {}
	
	for region in _regions.all():
		var tileset := (region as EditorRegion).get_tileset()
		if not tileset: continue
		var group := region_groups.get(tileset, []) as Array
		group.append(region)
		region_groups[tileset] = group
	
	return region_groups

func _draw_regions(name : String, coverage_map : Dictionary, regions : Array) -> bool:
	if not _world.map_exists_for_tileset(name):
		assert(false)
		return false
	
	var tilemap_names := _world.get_required_tilemap_names(regions) as Array
	var tilemaps := _add_tilemaps(tilemap_names) as Dictionary
	
	if tilemaps.empty():
		assert(false)
		return false
	
	var aggregate := {}
	
	for region in regions:
		var coverage := coverage_map[region] as Dictionary
		for coord in coverage.keys():
			aggregate[coord] = 0
	
	_world.set_ids(name, tilemaps, aggregate)
	
	return true

func clear_tilemaps() -> void:
	for tilemap in _tilemaps.get_children():
		assert(tilemap is TileMap)
		tilemap.clear()

func _add_tilemaps(tilemap_names : Array) -> Dictionary: 
	var tilemaps := {}
	for n in tilemap_names:
		var tilemap := _tilemaps.get_node_or_null(n) as TileMap
		if tilemap:
			tilemaps[n] = tilemap
			continue
			
		tilemap = _copy_tilemaps.get_node_or_null(n) as TileMap
		if not tilemap: return {}
	
		var packed := PackedScene.new()
		packed.pack(tilemap)
	
		var new_tilemap := packed.instance() as TileMap
		_set_collision_layer_mask(new_tilemap)
		_add_node_to_game(_tilemaps, new_tilemap)
		new_tilemap.clear()
		tilemaps[n] = new_tilemap
	
	_sort_tilemaps(LutUtils.get_children_by_type(_tilemaps, TileMap))
	
	return tilemaps

func _set_collision_layer_mask(tilemap : TileMap):
	tilemap.collision_layer = LutMath.set_1bits([CollisionLayer.SolidWorld])
	tilemap.collision_mask = 0

func _add_node_to_game(path : Node, node : Node) -> void:
	path.add_child(node)
	node.owner = _game

func _sort_tilemaps(tilemaps : Array) -> void:
	var actual_order := []
	for c in _copy_tilemaps.get_children():
		actual_order.append(c.name)
	
	tilemaps.sort_custom(TileMapSorter.new(actual_order), 'compare')
	
	for i in range(tilemaps.size()):
		_tilemaps.move_child(tilemaps[i], i)

class TileMapSorter:
	var _actual_order : Array
	func _init(actual_order):
		_actual_order = actual_order
	
	func compare(t1 : TileMap, t2 : TileMap) -> bool:
		var t1i := _actual_order.find(t1.name)
		assert(t1i != -1)
		
		var t2i := _actual_order.find(t2.name)
		assert(t2i != -1)
		
		return t1i < t2i
