## PilotMap — peta Kota Medan top-down untuk vertical slice.
## Membangun tile ground/water/bridge, collision, area air, dan properti statis.
extends Node2D
class_name PilotMap

const TILE: int = 16
const MAP_W: int = 60
const MAP_H: int = 34

@onready var ground: TileMapLayer = $Ground
@onready var water: TileMapLayer = $Water
@onready var bridge: TileMapLayer = $Bridge

var _tileset: TileSet

func _ready() -> void:
	_build_tileset()
	_paint_ground()
	_paint_water()
	_build_boundaries()
	_build_water_areas()
	_spawn_buildings()
	_spawn_trees()
	_spawn_reed_clusters()

func _build_tileset() -> void:
	_tileset = TileSet.new()
	_tileset.tile_size = Vector2i(TILE, TILE)
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/tilesets/pilot_tileset.png")
	source.texture_region_size = Vector2i(TILE, TILE)
	for y in range(4):
		for x in range(8):
			source.create_tile(Vector2i(x, y))
	_tileset.add_source(source, 0)
	ground.tile_set = _tileset
	water.tile_set = _tileset
	bridge.tile_set = _tileset

func _hash(x: int, y: int, seed_value: int = 0) -> int:
	return abs((x * 73856093) ^ (y * 19349663) ^ (seed_value * 83492791)) % 1000

func _paint_ground() -> void:
	for y in range(MAP_H):
		for x in range(MAP_W):
			var atlas := Vector2i(_hash(x, y) % 3, 0)
			# garis pohon/tepi atas dan bawah terasa lebih liar
			if y <= 1 or y >= MAP_H - 2:
				atlas = Vector2i(_hash(x, y, 9) % 3, 0)
			ground.set_cell(Vector2i(x, y), 0, atlas, 0)

	# jalan utama
	for x in range(2, 58):
		for y in [10, 11]:
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)

	# jalur vertikal ke jembatan dan bangunan
	for y in range(8, 16):
		ground.set_cell(Vector2i(20, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(21, y), 0, Vector2i(5, 0), 0)
		ground.set_cell(Vector2i(44, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(45, y), 0, Vector2i(5, 0), 0)
	for y in range(22, 25):
		ground.set_cell(Vector2i(20, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(21, y), 0, Vector2i(5, 0), 0)
		ground.set_cell(Vector2i(44, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(45, y), 0, Vector2i(5, 0), 0)

	# alun-alun batu di timur
	for x in range(48, 58):
		for y in range(12, 16):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(6 + _hash(x, y) % 2, 0), 0)

	# jalur menuju gerbang
	for x in range(57, 60):
		for y in [10, 11]:
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)

	# jalur ke warung, rumah, toko
	for y in range(8, 11):
		ground.set_cell(Vector2i(8, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(9, y), 0, Vector2i(5, 0), 0)
		ground.set_cell(Vector2i(30, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(31, y), 0, Vector2i(5, 0), 0)
	for y in range(9, 13):
		ground.set_cell(Vector2i(52, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(53, y), 0, Vector2i(5, 0), 0)

	# bunga liar
	for i in range(110):
		var x: int = 2 + _hash(i, 4, 2) % (MAP_W - 4)
		var y: int = 2 + _hash(i, 8, 3) % (MAP_H - 4)
		if y >= 15 and y <= 22:
			continue
		if ground.get_cell_source_id(Vector2i(x, y)) == 0:
			var atlas: Vector2i = ground.get_cell_atlas_coords(Vector2i(x, y))
			if atlas.y == 0 and atlas.x <= 2:
				ground.set_cell(Vector2i(x, y), 0, Vector2i(2, 0), 0)

func _river_top(x: int) -> int:
	return int(round(18.0 + sin(float(x) * 0.18) * 1.2)) - 3

func _paint_water() -> void:
	for x in range(MAP_W):
		var top: int = _river_top(x)
		var bottom: int = top + 3
		# tepi pasir
		ground.set_cell(Vector2i(x, top - 1), 0, Vector2i(4 + _hash(x, top) % 2, 1), 0)
		ground.set_cell(Vector2i(x, bottom + 1), 0, Vector2i(4 + _hash(x, bottom) % 2, 1), 0)
		var is_bridge: bool = x in [20, 21, 44, 45]
		for y in range(top, bottom + 1):
			if is_bridge:
				bridge.set_cell(Vector2i(x, y), 0, Vector2i(6 + _hash(x, y) % 2, 1), 0)
			else:
				water.set_cell(Vector2i(x, y), 0, Vector2i(_hash(x, y) % 2, 1), 0)

func is_in_water(pos: Vector2) -> bool:
	var tile_x: int = int(floor(pos.x / TILE))
	if tile_x < 0 or tile_x >= MAP_W:
		return false
	var top: int = _river_top(tile_x)
	var bottom: int = top + 3
	return pos.y >= top * TILE and pos.y < (bottom + 1) * TILE

func _build_boundaries() -> void:
	var w: float = MAP_W * TILE
	var h: float = MAP_H * TILE
	_add_collision(Vector2(w * 0.5, -8), Vector2(w, 16))
	_add_collision(Vector2(w * 0.5, h + 8), Vector2(w, 16))
	_add_collision(Vector2(-8, h * 0.5), Vector2(16, h))
	_add_collision(Vector2(w + 8, h * 0.5), Vector2(16, h))

func _build_water_areas() -> void:
	# Pecah per segmen agar kolom jembatan tetap bisa dilewati tanpa efek air.
	_add_river_segment(0, 20)
	_add_river_segment(22, 44)
	_add_river_segment(46, MAP_W)

func _add_river_segment(x_start: int, x_end: int) -> void:
	if x_end <= x_start:
		return
	var top_min: int = 999
	var bottom_max: int = -1
	for x in range(x_start, x_end):
		var top: int = _river_top(x)
		top_min = mini(top_min, top)
		bottom_max = maxi(bottom_max, top + 3)
	var y0: float = float(top_min * TILE)
	var y1: float = float((bottom_max + 1) * TILE)
	var area := Area2D.new()
	area.set_script(load("res://scripts/water_area.gd"))
	area.position = Vector2((x_start + x_end) * 0.5 * TILE, (y0 + y1) * 0.5)
	var shape := RectangleShape2D.new()
	shape.size = Vector2((x_end - x_start) * TILE, y1 - y0)
	var col := CollisionShape2D.new()
	col.shape = shape
	area.add_child(col)
	get_parent().add_child.call_deferred(area)

func _add_collision(pos: Vector2, size: Vector2) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var shape := RectangleShape2D.new()
	shape.size = size
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)
	get_parent().add_child.call_deferred(body)

func _spawn_buildings() -> void:
	_spawn_building("res://assets/sprites/props/warung.png", Vector2(136, 132), Vector2(80, 22))
	_spawn_building("res://assets/sprites/props/house.png", Vector2(480, 132), Vector2(80, 22))
	_spawn_building("res://assets/sprites/props/shop.png", Vector2(840, 148), Vector2(80, 22))

func _spawn_building(path: String, pos: Vector2, collision_size: Vector2) -> void:
	var texture: Texture2D = load(path)
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(0, -texture.get_height() * 0.5)
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = collision_size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -collision_size.y * 0.5)
	body.add_child(col)
	get_parent().add_child.call_deferred(body)

func _spawn_trees() -> void:
	var positions: Array[Vector2] = [
		Vector2(40, 90), Vector2(70, 120), Vector2(230, 84), Vector2(280, 116),
		Vector2(360, 70), Vector2(410, 96), Vector2(560, 92), Vector2(610, 120),
		Vector2(700, 80), Vector2(760, 104), Vector2(916, 84),
		Vector2(48, 470), Vector2(120, 500), Vector2(250, 480), Vector2(330, 512),
		Vector2(460, 486), Vector2(590, 508), Vector2(680, 474), Vector2(820, 505),
		Vector2(920, 480), Vector2(150, 360), Vector2(690, 360), Vector2(790, 370),
	]
	for pos in positions:
		_spawn_tree(pos)

func _spawn_tree(pos: Vector2) -> void:
	if is_in_water(pos):
		return
	var texture: Texture2D = load("res://assets/sprites/props/tree.png")
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(0, -texture.get_height() * 0.5)
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 8)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -4)
	body.add_child(col)
	get_parent().add_child.call_deferred(body)

func _spawn_reed_clusters() -> void:
	for i in range(26):
		var x: int = 12 + _hash(i, 21, 5) % (MAP_W * TILE - 24)
		var top: int = _river_top(int(x / TILE))
		var y: int = top * TILE - 4
		if x > 310 and x < 360:
			continue
		if x > 690 and x < 750:
			continue
		var reed := Sprite2D.new()
		reed.texture = load("res://assets/sprites/props/reed.png")
		reed.position = Vector2(x, y)
		reed.offset = Vector2(0, -10)
		reed.scale = Vector2(0.8, 1.0)
		reed.z_index = -1
		get_parent().add_child.call_deferred(reed)
