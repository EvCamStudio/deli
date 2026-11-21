## PilotMap — peta Kota Medan top-down untuk vertical slice.
## Membangun tile ground/water/bridge, collision, area air, dan properti statis.
extends Node2D
class_name PilotMap

const TILE: int = 16
const MAP_W: int = 60
const MAP_H: int = 32

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

	# Plaza pejalan kaki di selatan (kompak, baris 18..25).
	for x in range(2, MAP_W - 2):
		for y in range(18, MAP_H):
			ground.set_cell(Vector2i(x, y), 0, T_PLAZA[_hash(x, y, 4) % 2], 0)

	# Alun-alun timur di depan toko.
	for x in range(47, MAP_W - 2):
		for y in range(10, 14):
			ground.set_cell(Vector2i(x, y), 0, T_PLAZA[_hash(x, y, 7) % 2], 0)

	# Jalan raya utama (horizontal), 4 lajur aspal lebar + garis putus tengah (Gambar 6).
	for x in range(MAP_W):
		for y in [8, 9, 10, 11]:
			ground.set_cell(Vector2i(x, y), 0, T_ASPHALT[_hash(x, y, 2) % 3], 0)
		ground.set_cell(Vector2i(x, 9), 0, T_DASH_H, 0)

	# Jalan vertikal: 4 lajur aspal lebar (kolom 20..23 dan 44..47), berhenti sebelum plaza selatan (y=18).
	for vx in [20, 44]:
		for y in range(18):
			if y in [8, 9, 10, 11]:
				continue
			for x in range(vx, vx + 4):
				if x == vx + 1:
					ground.set_cell(Vector2i(x, y), 0, T_DASH_V, 0)
				else:
					ground.set_cell(Vector2i(x, y), 0, T_ASPHALT[_hash(x, y, 6) % 3], 0)

	# Zebra cross di setiap persimpangan.
	for vx in [20, 44]:
		# Penyeberangan jalan horizontal (north-south) di sayap kiri dan kanan persimpangan
		for x in [vx - 2, vx - 1, vx + 4, vx + 5]:
			for y in [8, 9, 10, 11]:
				ground.set_cell(Vector2i(x, y), 0, T_CROSS_V, 0)
		# Penyeberangan jalan vertikal (east-west) di sisi utara (y=6..7) dan selatan (y=12..13)
		for y in [6, 7, 12, 13]:
			for x in range(vx, vx + 4):
				ground.set_cell(Vector2i(x, y), 0, T_CROSS_H, 0)

	# Kanstin trotoar pada sisi yang menghadap aspal.
	for x in range(MAP_W):
		if (x >= 20 and x <= 23) or (x >= 44 and x <= 47):
			continue
		ground.set_cell(Vector2i(x, 7), 0, T_CURB_DOWN, 0)
		ground.set_cell(Vector2i(x, 12), 0, T_CURB_UP, 0)
	for vx in [20, 44]:
		for y in range(18):
			if y in [6, 7, 8, 9, 10, 11, 12, 13]:
				continue
			ground.set_cell(Vector2i(vx - 1, y), 0, T_CURB_RIGHT, 0)
			ground.set_cell(Vector2i(vx + 4, y), 0, T_CURB_LEFT, 0)
		# Kanstin penutup ujung jalan vertikal sebelum plaza pejalan kaki
		for x in range(vx, vx + 4):
			ground.set_cell(Vector2i(x, 18), 0, T_CURB_DOWN, 0)

	# Got dan manhole.
	for p in [
		Vector2i(11, 12), Vector2i(33, 12), Vector2i(55, 12),
		Vector2i(18, 17), Vector2i(23, 5), Vector2i(42, 17), Vector2i(47, 5),
	]:
		ground.set_cell(p, 0, T_DRAIN, 0)
	for p in [Vector2i(30, 9), Vector2i(51, 8), Vector2i(19, 17), Vector2i(43, 6)]:
		ground.set_cell(p, 0, T_MANHOLE, 0)

func _river_top(_x: int) -> int:
	# Di kota, kanal tanggul beton berada di baris 14..16.
	return 14

func _paint_water() -> void:
	for x in range(MAP_W):
		var top: int = _river_top(x)
		var bottom: int = top + 2
		var is_bridge: bool = (x >= 20 and x <= 23) or (x >= 44 and x <= 47)
		# Tanggul beton, bukan pasir. Kolom jembatan dibiarkan menyambung aspal.
		if not is_bridge:
			ground.set_cell(Vector2i(x, top - 1), 0, T_CURB_DOWN, 0)
			ground.set_cell(Vector2i(x, bottom + 1), 0, T_CURB_UP, 0)
		for y in range(top, bottom + 1):
			if is_bridge:
				# Jembatan aspal: jalan menyambung 4 lajur lebar, garis putus-putus tengah di kolom vx+1.
				if x in [21, 45]:
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
	# Deret 6 gedung modern jalan utara kota (y=60) memberi trotoar pejalan kaki lebar.
	# Tertata rapi dalam 3 blok tanpa menimpa jalan vertikal (Block 1: x<320, Block 2: 384<x<704, Block 3: x>768).
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_apartment.png", Vector2(85, 60), Vector2(96, 22), 0.38)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_office_glass.png", Vector2(215, 60), Vector2(92, 22), 0.38)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_corporate_tower.png", Vector2(440, 60), Vector2(96, 22), 0.38)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_helipad_tower.png", Vector2(610, 60), Vector2(92, 22), 0.38)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_condo_terrace.png", Vector2(814, 60), Vector2(94, 22), 0.35)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/building_brick_complex.png", Vector2(915, 60), Vector2(94, 22), 0.35)

	# Deret pasar sayur Bang Jali & pertokoan kuliner bantaran selatan kota di plaza pejalan kaki (y=350).
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/market_sayur.png", Vector2(140, 350), Vector2(106, 22), 0.42)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/warung_seng_awning.png", Vector2(440, 350), Vector2(98, 22), 0.42)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/market_kelontong.png", Vector2(620, 350), Vector2(96, 22), 0.36)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/market_sembako.png", Vector2(850, 350), Vector2(100, 22), 0.36)

func _spawn_trees() -> void:
	# Pohon kamboja rapi di pekarangan selatan kota (pohon yang menimpa gedung utara dihapus)
	var entries: Array[Dictionary] = [
		{"pos": Vector2(40, 300), "kind": "kamboja"},
		{"pos": Vector2(920, 300), "kind": "kamboja"},
	]
	for entry in entries:
		var pos: Vector2 = entry.get("pos", Vector2.ZERO)
		var kind: String = str(entry.get("kind", "kamboja"))
		TopdownMap.spawn_tree(get_parent(), pos, kind)

func _spawn_city_props() -> void:
	# Lampu jalan di kedua sisi jalan raya utama (kolisi solid di pangkal, Gambar 9).
	for x in [96, 240, 440, 624, 820]:
		_spawn_prop("lamp.png", Vector2(x, 114))
	for x in [96, 288, 480, 660, 864]:
		_spawn_prop("lamp.png", Vector2(x, 194))
	# Lampu di plaza selatan dan alun-alun timur.
	for p in [Vector2(64, 370), Vector2(525, 370), Vector2(832, 370)]:
		_spawn_prop("lamp.png", p)
	_spawn_prop("lamp.png", Vector2(790, 194))

	# Bangku taman
	for p in [Vector2(608, 194), Vector2(650, 194), Vector2(280, 370), Vector2(520, 370), Vector2(750, 370)]:
		_spawn_prop("bench.png", p)

	# Hidran kebakaran.
	for p in [Vector2(208, 194), Vector2(592, 194), Vector2(880, 194)]:
		_spawn_prop("hydrant.png", p)

	# Lampu lalu lintas di sudut persimpangan jalan aspal.
	for p in [Vector2(304, 114), Vector2(400, 114), Vector2(688, 114), Vector2(784, 114)]:
		_spawn_prop("traffic_light.png", p)

	# Pagar pengaman jembatan kanal kota (kiri dan kanan, melintasi air penuh dari tanggul utara ke selatan).
	# Jembatan Barat (kolom 20..23 = x: 320..384, y air: 224..272)
	_spawn_bridge_rail(Vector2(316, 248), true)
	_spawn_bridge_rail(Vector2(388, 248), false)
	# Jembatan Timur (kolom 44..47 = x: 704..768, y air: 224..272)
	_spawn_bridge_rail(Vector2(700, 248), true)
	_spawn_bridge_rail(Vector2(772, 248), false)

func _spawn_bridge_rail(pos: Vector2, is_left: bool) -> void:
	var tex_path := "res://assets/sprites/props/bridge_rail_city_left.png" if is_left else "res://assets/sprites/props/bridge_rail_city_right.png"
	var texture: Texture2D = load(tex_path)
	if texture == null:
		return
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(0, 0)
	body.add_child(sprite)

	# Kolisi penghalang tepi jembatan agar pemain tidak tercebur ke air
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(6, 64)
	col.shape = shape
	col.position = Vector2(0, 0)
	body.add_child(col)

	get_parent().add_child.call_deferred(body)

func _spawn_prop(prop: String, pos: Vector2) -> void:
	var texture: Texture2D = load("res://assets/sprites/props/" + prop)
	if texture == null:
		return
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(0, -texture.get_height() * 0.5)
	body.add_child(sprite)

	# Kolisi solid di pangkal tiang/lampu/hidran agar karakter tidak nembus (Gambar 9)
	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	match prop:
		"lamp.png", "traffic_light.png":
			shape.size = Vector2(8, 6)
			col.position = Vector2(0, -3)
		"hydrant.png":
			shape.size = Vector2(8, 6)
			col.position = Vector2(0, -3)
		"bench.png":
			shape.size = Vector2(20, 8)
			col.position = Vector2(0, -4)
		_:
			shape.size = Vector2(8, 6)
			col.position = Vector2(0, -3)
	col.shape = shape
	body.add_child(col)

	get_parent().add_child.call_deferred(body)
