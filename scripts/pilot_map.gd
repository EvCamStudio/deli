## PilotMap — peta Kota Medan top-down untuk vertical slice.
## Membangun tile ground/water/bridge, collision, area air, dan properti statis.
extends Node2D
class_name PilotMap

const TILE: int = 16
const MAP_W: int = 60
const MAP_H: int = 34
const TREE_WIND_MATERIAL := preload("res://assets/shaders/tree_wind_material.tres")

# Tile kota pada atlas pilot_tileset.png (baris 3-5).
const T_ASPHALT := [Vector2i(0, 3), Vector2i(1, 3), Vector2i(3, 4)]
const T_DASH_H := Vector2i(2, 3)
const T_DASH_V := Vector2i(3, 3)
const T_WALK := [Vector2i(4, 3), Vector2i(6, 4)]
const T_CURB_DOWN := Vector2i(5, 3)
const T_CURB_UP := Vector2i(4, 4)
const T_CURB_LEFT := Vector2i(0, 5)
const T_CURB_RIGHT := Vector2i(1, 5)
const T_CROSS_H := Vector2i(6, 3)   # garis tegak: menyeberang jalan vertikal
const T_CROSS_V := Vector2i(7, 3)   # garis datar: menyeberang jalan horizontal
const T_PLAZA := [Vector2i(0, 4), Vector2i(1, 4)]
const T_MANHOLE := Vector2i(2, 4)
const T_DRAIN := Vector2i(5, 4)
const T_PLANTER := Vector2i(2, 5)

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
	_spawn_city_props()

func _build_tileset() -> void:
	_tileset = TileSet.new()
	_tileset.tile_size = Vector2i(TILE, TILE)
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/tilesets/pilot_tileset.png")
	source.texture_region_size = Vector2i(TILE, TILE)
	for y in range(6):
		for x in range(8):
			source.create_tile(Vector2i(x, y))
	_tileset.add_source(source, 0)
	ground.tile_set = _tileset
	water.tile_set = _tileset
	bridge.tile_set = _tileset

func _hash(x: int, y: int, seed_value: int = 0) -> int:
	return abs((x * 73856093) ^ (y * 19349663) ^ (seed_value * 83492791)) % 1000

func _paint_ground() -> void:
	# Trotoar beton jadi alas seluruh kota (tidak ada hamparan rumput).
	for y in range(MAP_H):
		for x in range(MAP_W):
			ground.set_cell(Vector2i(x, y), 0, T_WALK[_hash(x, y) % T_WALK.size()], 0)

	# Plaza pejalan kaki di selatan.
	for x in range(2, MAP_W - 2):
		for y in range(29, MAP_H):
			ground.set_cell(Vector2i(x, y), 0, T_PLAZA[_hash(x, y, 4) % 2], 0)

	# Alun-alun timur di depan toko.
	for x in range(47, MAP_W - 2):
		for y in range(12, 16):
			ground.set_cell(Vector2i(x, y), 0, T_PLAZA[_hash(x, y, 7) % 2], 0)

	# Jalan raya utama (horizontal), dua lajur + garis putus tengah.
	for x in range(MAP_W):
		for y in [10, 11]:
			ground.set_cell(Vector2i(x, y), 0, T_ASPHALT[_hash(x, y, 2) % 3], 0)
		ground.set_cell(Vector2i(x, 10), 0, T_DASH_H, 0)

	# Jalan vertikal: dua lajur, masing-masing dua petak.
	for vx in [20, 44]:
		for y in range(MAP_H):
			if y in [10, 11]:
				continue
			for x in [vx, vx + 1]:
				ground.set_cell(Vector2i(x, y), 0, T_ASPHALT[_hash(x, y, 6) % 3], 0)
			ground.set_cell(Vector2i(vx, y), 0, T_DASH_V, 0)

	# Zebra cross di setiap persimpangan.
	for vx in [20, 44]:
		for x in [vx - 2, vx - 1, vx + 2, vx + 3]:
			for y in [10, 11]:
				ground.set_cell(Vector2i(x, y), 0, T_CROSS_V, 0)
		for y in [8, 9, 12, 13]:
			for x in [vx, vx + 1]:
				ground.set_cell(Vector2i(x, y), 0, T_CROSS_H, 0)

	# Kanstin trotoar pada sisi yang menghadap aspal.
	for x in range(MAP_W):
		if x in [20, 21, 44, 45]:
			continue
		ground.set_cell(Vector2i(x, 9), 0, T_CURB_DOWN, 0)
		ground.set_cell(Vector2i(x, 12), 0, T_CURB_UP, 0)
	for vx in [20, 44]:
		for y in range(MAP_H):
			if y in [8, 9, 10, 11, 12, 13]:
				continue
			ground.set_cell(Vector2i(vx - 1, y), 0, T_CURB_RIGHT, 0)
			ground.set_cell(Vector2i(vx + 2, y), 0, T_CURB_LEFT, 0)

	# Got dan manhole.
	for p in [
		Vector2i(11, 12), Vector2i(33, 12), Vector2i(55, 12),
		Vector2i(18, 25), Vector2i(23, 5), Vector2i(42, 25), Vector2i(47, 6),
	]:
		ground.set_cell(p, 0, T_DRAIN, 0)
	for p in [Vector2i(30, 11), Vector2i(51, 10), Vector2i(20, 25), Vector2i(45, 7)]:
		ground.set_cell(p, 0, T_MANHOLE, 0)

func _river_top(x: int) -> int:
	# Di kota, sungai diluruskan jadi kanal dengan tanggul beton.
	return 15

func _paint_water() -> void:
	for x in range(MAP_W):
		var top: int = _river_top(x)
		var bottom: int = top + 3
		var is_bridge: bool = x in [20, 21, 44, 45]
		# Tanggul beton, bukan pasir. Kolom jembatan dibiarkan: di situ
		# sudah tergambar aspal/zebra cross jalan.
		if not is_bridge:
			ground.set_cell(Vector2i(x, top - 1), 0, T_CURB_DOWN, 0)
			ground.set_cell(Vector2i(x, bottom + 1), 0, T_CURB_UP, 0)
		for y in range(top, bottom + 1):
			if is_bridge:
				# Jembatan aspal: jalan menyambung, garis tengah ikut.
				if x == 20 or x == 44:
					bridge.set_cell(Vector2i(x, y), 0, T_DASH_V, 0)
				else:
					bridge.set_cell(Vector2i(x, y), 0, T_ASPHALT[_hash(x, y, 5) % 2], 0)
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

func _paint_planter(pos: Vector2) -> void:
	var tx: int = int(floor(pos.x / TILE)) - 1
	var ty: int = int(floor(pos.y / TILE)) - 1
	for y in range(ty, ty + 2):
		for x in range(tx, tx + 2):
			if x < 0 or y < 0 or x >= MAP_W or y >= MAP_H:
				continue
			if y in [10, 11] or x in [20, 21, 44, 45]:
				continue
			ground.set_cell(Vector2i(x, y), 0, T_PLANTER, 0)

func _spawn_tree(pos: Vector2) -> void:
	if is_in_water(pos):
		return
	_paint_planter(pos)
	var texture: Texture2D = load("res://assets/sprites/props/tree.png")
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.material = TREE_WIND_MATERIAL
	sprite.position = Vector2(0, -texture.get_height() * 0.5)
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10, 8)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -4)
	body.add_child(col)
	get_parent().add_child.call_deferred(body)

func _spawn_city_props() -> void:
	# Lampu jalan di kedua sisi jalan raya.
	for x in [96, 240, 432, 624, 816]:
		_spawn_prop("lamp.png", Vector2(x, 158))
	for x in [96, 288, 480, 672, 864]:
		_spawn_prop("lamp.png", Vector2(x, 206))
	# Lampu di plaza selatan dan alun-alun timur.
	for p in [Vector2(64, 498), Vector2(448, 498), Vector2(832, 498)]:
		_spawn_prop("lamp.png", p)
	_spawn_prop("lamp.png", Vector2(784, 250))

	# Bangku.
	for p in [Vector2(608, 238), Vector2(650, 238), Vector2(144, 520), Vector2(520, 520)]:
		_spawn_prop("bench.png", p)
	for p in [Vector2(800, 244), Vector2(844, 244)]:
		_spawn_prop("bench.png", p)

	# Hidran.
	for p in [Vector2(208, 206), Vector2(592, 206), Vector2(880, 206)]:
		_spawn_prop("hydrant.png", p)

	# Lampu lalu lintas di sudut persimpangan.
	for p in [Vector2(304, 158), Vector2(368, 158), Vector2(688, 158), Vector2(752, 158)]:
		_spawn_prop("traffic_light.png", p)

	# Pagar di tepi jembatan kanal.
	for bx in [320, 352, 704, 736]:
		_spawn_prop("rail.png", Vector2(bx, 304))

	# Mobil terparkir / melintas.
	_spawn_car(Vector2(240, 176), true, Color(0.82, 0.24, 0.22))
	_spawn_car(Vector2(600, 176), true, Color(0.28, 0.5, 0.78))
	_spawn_car(Vector2(336, 400), false, Color(0.94, 0.86, 0.52))
	_spawn_car(Vector2(720, 432), false, Color(0.52, 0.7, 0.54))

func _spawn_prop(prop: String, pos: Vector2) -> void:
	var texture: Texture2D = load("res://assets/sprites/props/" + prop)
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = pos + Vector2(0, -texture.get_height() * 0.5)
	get_parent().add_child.call_deferred(sprite)

func _spawn_car(pos: Vector2, horizontal: bool, tint: Color) -> void:
	var body := StaticBody2D.new()
	body.position = pos
	body.rotation_degrees = 90.0 if horizontal else 0.0
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = load("res://assets/sprites/props/car.png")
	sprite.modulate = tint
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 26)
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)
	get_parent().add_child.call_deferred(body)
