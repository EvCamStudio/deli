## PilotMap — peta Kota Medan top-down untuk vertical slice.
## Membangun tile ground/water/bridge, collision, area air, dan properti statis.
extends Node2D
class_name PilotMap

const TILE: int = 16
const MAP_W: int = 60
const MAP_H: int = 34

# Tile kota pada atlas city_tileset.png (baris 3-5).
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
	source.texture = load("res://assets/tilesets/city_tileset.png")
	source.texture_region_size = Vector2i(TILE, TILE)
	for y in range(6):
		for x in range(8):
			source.create_tile(Vector2i(x, y))
	_tileset.add_source(source, 0)
	ground.tile_set = _tileset
	water.tile_set = _tileset
	bridge.tile_set = _tileset
	TopdownMap.apply_water_visuals(water, false)

func _hash(x: int, y: int, seed_value: int = 0) -> int:
	return abs((x * 73856093) ^ (y * 19349663) ^ (seed_value * 83492791)) % 1000

func _paint_ground() -> void:
	# Trotoar beton jadi alas seluruh kota (tidak ada hamparan rumput liar).
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

	# Jalan vertikal: dua lajur, masing-masing dua petak, berhenti sebelum plaza selatan (y=28).
	for vx in [20, 44]:
		for y in range(28):
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
		for y in range(28):
			if y in [8, 9, 10, 11, 12, 13]:
				continue
			ground.set_cell(Vector2i(vx - 1, y), 0, T_CURB_RIGHT, 0)
			ground.set_cell(Vector2i(vx + 2, y), 0, T_CURB_LEFT, 0)
		# Kanstin penutup ujung jalan vertikal sebelum plaza pejalan kaki
		ground.set_cell(Vector2i(vx, 28), 0, T_CURB_DOWN, 0)
		ground.set_cell(Vector2i(vx + 1, 28), 0, T_CURB_DOWN, 0)

	# Got dan manhole.
	for p in [
		Vector2i(11, 12), Vector2i(33, 12), Vector2i(55, 12),
		Vector2i(18, 25), Vector2i(23, 5), Vector2i(42, 25), Vector2i(47, 6),
	]:
		ground.set_cell(p, 0, T_DRAIN, 0)
	for p in [Vector2i(30, 11), Vector2i(51, 10), Vector2i(20, 25), Vector2i(45, 7)]:
		ground.set_cell(p, 0, T_MANHOLE, 0)

func _river_top(_x: int) -> int:
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
	var cell := Vector2i(int(floor(pos.x / TILE)), int(floor(pos.y / TILE)))
	if cell.x < 0 or cell.x >= MAP_W or cell.y < 0 or cell.y >= MAP_H:
		return false
	return water.get_cell_source_id(cell) != -1 and bridge.get_cell_source_id(cell) == -1

func _build_boundaries() -> void:
	var w: float = MAP_W * TILE
	var h: float = MAP_H * TILE
	_add_collision(Vector2(w * 0.5, -8), Vector2(w, 16))
	_add_collision(Vector2(w * 0.5, h + 8), Vector2(w, 16))
	_add_collision(Vector2(-8, h * 0.5), Vector2(16, h))
	_add_collision(Vector2(w + 8, h * 0.5), Vector2(16, h))

func _build_water_areas() -> void:
	# Menggunakan pembangun kolisi & area per tile air supaya kanal kota akurat dan jembatan tetap bisa dilalui.
	TopdownMap.build_water_collisions_and_areas(get_parent(), water, bridge, MAP_W, MAP_H, TILE)

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
	# Deret 6 gedung modern jalan utara kota berjarak mundur (y=94) memberi trotoar pejalan kaki lebar 50px (3+ tile) dari tepi jalan aspal (y=144).
	# Tertata rapi dalam 3 blok tanpa menimpa jalan vertikal (Block 1: x<304, Block 2: 368<x<688, Block 3: x>752).
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_apartment.png", Vector2(85, 94), Vector2(96, 22), 0.38)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_office_glass.png", Vector2(215, 94), Vector2(92, 22), 0.38)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_corporate_tower.png", Vector2(430, 94), Vector2(96, 22), 0.38)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_helipad_tower.png", Vector2(610, 94), Vector2(92, 22), 0.38)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_condo_terrace.png", Vector2(804, 94), Vector2(94, 22), 0.35)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_brick_complex.png", Vector2(905, 94), Vector2(94, 22), 0.35)

	# Deret pasar sayur Bang Jali & warung kuliner bantaran selatan kota di plaza pejalan kaki (y=490).
	# Berjarak mundur lapang 42px dari ujung jalan vertikal (y=448), memberi ruang lapang bagi pejalan kaki & pembeli.
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/market_sayur.png", Vector2(140, 490), Vector2(106, 22), 0.42)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/warung_madura.png", Vector2(435, 490), Vector2(90, 22), 0.36)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/warung_toko_jaya.png", Vector2(615, 490), Vector2(96, 22), 0.36)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/warung_bu_sri.png", Vector2(850, 490), Vector2(100, 22), 0.36)

func _spawn_trees() -> void:
	# Pohon kamboja rapi di sudut pekarangan kota (tidak menghalangi jalan / bangunan, bebas tumpang tindih)
	var entries: Array[Dictionary] = [
		{"pos": Vector2(28, 70), "kind": "kamboja"},
		{"pos": Vector2(40, 410), "kind": "kamboja"},
		{"pos": Vector2(920, 410), "kind": "kamboja"},
	]
	for entry in entries:
		var pos: Vector2 = entry.get("pos", Vector2.ZERO)
		var kind: String = str(entry.get("kind", "kamboja"))
		TopdownMap.spawn_tree(get_parent(), pos, kind)

func _spawn_city_props() -> void:
	# Lampu jalan di kedua sisi jalan raya utama.
	for x in [96, 240, 432, 624, 816]:
		_spawn_prop("lamp.png", Vector2(x, 158))
	for x in [96, 288, 480, 672, 864]:
		_spawn_prop("lamp.png", Vector2(x, 206))
	# Lampu di plaza selatan dan alun-alun timur (pada trotoar beton di atas tanggul kanal).
	for p in [Vector2(64, 498), Vector2(525, 498), Vector2(832, 498)]:
		_spawn_prop("lamp.png", p)
	_spawn_prop("lamp.png", Vector2(784, 224))

	# Bangku taman (pada trotoar beton tepi kanal dan plaza, tidak mengapung di air).
	for p in [Vector2(608, 238), Vector2(650, 238), Vector2(280, 520), Vector2(520, 520), Vector2(750, 520)]:
		_spawn_prop("bench.png", p)
	for p in [Vector2(800, 224), Vector2(844, 224)]:
		_spawn_prop("bench.png", p)

	# Hidran kebakaran.
	for p in [Vector2(208, 206), Vector2(592, 206), Vector2(880, 206)]:
		_spawn_prop("hydrant.png", p)

	# Lampu lalu lintas di sudut persimpangan jalan aspal.
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
	if texture == null:
		return
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
	var texture: Texture2D = load("res://assets/sprites/props/car.png")
	if texture == null:
		return
	sprite.texture = texture
	sprite.modulate = tint
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(16, 26)
	var col := CollisionShape2D.new()
	col.shape = shape
	body.add_child(col)
	get_parent().add_child.call_deferred(body)
