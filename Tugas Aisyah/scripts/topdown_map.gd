## TopdownMap — peta top-down prosedural untuk Level 1, 2, dan 4.
## Tema: "hulu" (hutan & mata air), "desa" (sawah & kampung), "hilir" (pesisir & mangrove).
extends Node2D
class_name TopdownMap

const TILE: int = 16
const MAP_W: int = 60
const MAP_H: int = 34
const PATH_ROW: int = 16

@export var theme: String = "hulu"

@onready var ground: TileMapLayer = $Ground
@onready var water: TileMapLayer = $Water
@onready var bridge: TileMapLayer = $Bridge

var _tileset: TileSet
var _decor: TileMapLayer
var _seed: int = 11

func _ready() -> void:
	match theme:
		"desa": _seed = 23
		"hilir": _seed = 37
		_: _seed = 11
	_build_decor_layer()
	_build_tileset()
	_paint_ground()
	_paint_water()
	_paint_decor()
	_build_boundaries()
	_build_water_areas()
	_spawn_props()
	_spawn_reeds()

# ─── Tileset ─────────────────────────────────────────────────────────────────

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
	_decor.tile_set = _tileset

func _build_decor_layer() -> void:
	_decor = get_node_or_null("Decor") as TileMapLayer
	if _decor == null:
		_decor = TileMapLayer.new()
		_decor.name = "Decor"
		_decor.z_index = -5
		add_child(_decor)

# ─── Ground ──────────────────────────────────────────────────────────────────

func _hash(x: int, y: int, seed_value: int = 0) -> int:
	return abs((x * 73856093) ^ (y * 19349663) ^ (seed_value * 83492791) ^ (_seed * 2654435761)) % 1000

func _paint_ground() -> void:
	for y in range(MAP_H):
		for x in range(MAP_W):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(_hash(x, y) % 3, 0), 0)

	# Jalan utama kiri–kanan.
	for x in range(MAP_W):
		for y in [PATH_ROW, PATH_ROW + 1]:
			var atlas := Vector2i(3, 0) if theme == "hulu" else Vector2i(4 + _hash(x, y) % 2, 0)
			ground.set_cell(Vector2i(x, y), 0, atlas, 0)

	match theme:
		"hulu": _paint_hulu_ground()
		"desa": _paint_desa_ground()
		"hilir": _paint_hilir_ground()

func _paint_hulu_ground() -> void:
	# Jalur tanah menuju pondok penjaga dan tepi sungai.
	for y in range(10, PATH_ROW + 1):
		ground.set_cell(Vector2i(8, y), 0, Vector2i(3, 0), 0)
		ground.set_cell(Vector2i(9, y), 0, Vector2i(4, 0), 0)
	for y in range(12, 21):
		ground.set_cell(Vector2i(44, y), 0, Vector2i(3, 0), 0)
		ground.set_cell(Vector2i(45, y), 0, Vector2i(4, 0), 0)
	# Halaman pondok.
	for x in range(4, 11):
		for y in range(11, 14):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(3 + _hash(x, y) % 2, 0), 0)

func _paint_desa_ground() -> void:
	# Jalan kampung bercabang.
	for y in range(8, PATH_ROW + 1):
		for x in [8, 9, 30, 31, 52, 53]:
			ground.set_cell(Vector2i(x, y), 0, Vector2i(3 + _hash(x, y) % 2, 0), 0)
	# Jalan menuju dermaga di tepi sungai.
	for y in range(PATH_ROW, 27):
		ground.set_cell(Vector2i(30, y), 0, Vector2i(3, 0), 0)
		ground.set_cell(Vector2i(31, y), 0, Vector2i(4, 0), 0)
	# Petak sawah dengan alur tanah.
	var fields: Array[Rect2i] = [Rect2i(14, 4, 11, 7), Rect2i(34, 4, 11, 7), Rect2i(48, 6, 9, 7)]
	for field in fields:
		for x in range(field.position.x, field.end.x):
			for y in range(field.position.y, field.end.y):
				var atlas := Vector2i(3, 0) if y % 2 == 0 else Vector2i(4, 0)
				ground.set_cell(Vector2i(x, y), 0, atlas, 0)

func _paint_hilir_ground() -> void:
	# Jalur kampung nelayan.
	for y in range(10, PATH_ROW + 1):
		ground.set_cell(Vector2i(8, y), 0, Vector2i(3 + _hash(8, y) % 2, 0), 0)
		ground.set_cell(Vector2i(9, y), 0, Vector2i(4, 0), 0)
	for y in range(12, PATH_ROW + 1):
		ground.set_cell(Vector2i(50, y), 0, Vector2i(3, 0), 0)
		ground.set_cell(Vector2i(51, y), 0, Vector2i(4, 0), 0)
	# Pantai berpasir.
	for x in range(MAP_W):
		for y in range(24, 28):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 1), 0)

# ─── Water ───────────────────────────────────────────────────────────────────

func _paint_water() -> void:
	match theme:
		"hulu": _water_hulu()
		"desa": _water_desa()
		"hilir": _water_hilir()

func _paint_water_cell(x: int, y: int) -> void:
	water.set_cell(Vector2i(x, y), 0, Vector2i(_hash(x, y) % 2, 1), 0)

func _paint_sand_cell(x: int, y: int) -> void:
	ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 1), 0)

func _paint_bridge_cell(x: int, y: int) -> void:
	bridge.set_cell(Vector2i(x, y), 0, Vector2i(6 + _hash(x, y) % 2, 1), 0)

func _water_hulu() -> void:
	# Mata air di hulu: kolam kecil dengan tepi pasir.
	for x in range(23, 37):
		for y in range(3, 8):
			if x == 23 or x == 36 or y == 3 or y == 7:
				_paint_sand_cell(x, y)
			else:
				_paint_water_cell(x, y)
	# Sungai kecil membelah peta dari utara ke selatan.
	for y in range(MAP_H):
		for x in range(28, 32):
			if y in [PATH_ROW, PATH_ROW + 1]:
				_paint_bridge_cell(x, y)
			elif not (y >= 3 and y <= 7):
				_paint_water_cell(x, y)
		if not (y >= 3 and y <= 7):
			_paint_sand_cell(27, y)
			_paint_sand_cell(32, y)

func _water_desa() -> void:
	# Sungai lebar di sisi selatan desa.
	for x in range(MAP_W):
		for y in range(27, 31):
			_paint_water_cell(x, y)
		_paint_sand_cell(x, 26)
		_paint_sand_cell(x, 31)
	# Dermaga kayu kecil di tepi sungai.
	for x in range(30, 33):
		for y in range(25, 30):
			_paint_bridge_cell(x, y)

func _water_hilir() -> void:
	# Laut di sisi selatan.
	for x in range(MAP_W):
		for y in range(28, MAP_H):
			_paint_water_cell(x, y)
	# Muara sungai yang bermuara ke laut.
	for y in range(8, 28):
		for x in range(44, 48):
			if y in [PATH_ROW, PATH_ROW + 1]:
				_paint_bridge_cell(x, y)
			else:
				_paint_water_cell(x, y)
		_paint_sand_cell(43, y)
		_paint_sand_cell(48, y)

# ─── Decorations ─────────────────────────────────────────────────────────────

func _is_open_grass(x: int, y: int) -> bool:
	if x < 1 or x >= MAP_W - 1 or y < 1 or y >= MAP_H - 1:
		return false
	if y >= PATH_ROW - 1 and y <= PATH_ROW + 2:
		return false
	var atlas: Vector2i = ground.get_cell_atlas_coords(Vector2i(x, y))
	return atlas.y == 0 and atlas.x <= 2

func _paint_decor() -> void:
	var bush_count: int = {"hulu": 95, "desa": 38, "hilir": 48}.get(theme, 40)
	for i in range(bush_count):
		var x: int = 2 + _hash(i, 7, 3) % (MAP_W - 4)
		var y: int = 2 + _hash(i, 11, 5) % (MAP_H - 4)
		if not _is_open_grass(x, y):
			continue
		var atlas := Vector2i(6, 2) if i % 4 != 0 else Vector2i(7, 2)
		_decor.set_cell(Vector2i(x, y), 0, atlas, 0)
	if theme == "desa":
		_paint_field_fences()

func _paint_field_fences() -> void:
	var fields: Array[Rect2i] = [Rect2i(14, 4, 11, 7), Rect2i(34, 4, 11, 7), Rect2i(48, 6, 9, 7)]
	for field in fields:
		for x in range(field.position.x - 1, field.end.x + 1):
			_decor.set_cell(Vector2i(x, field.position.y - 1), 0, Vector2i(4 + x % 2, 2), 0)
			_decor.set_cell(Vector2i(x, field.end.y), 0, Vector2i(4 + x % 2, 2), 0)
		for y in range(field.position.y, field.end.y):
			_decor.set_cell(Vector2i(field.position.x - 1, y), 0, Vector2i(4, 2), 0)
			_decor.set_cell(Vector2i(field.end.x, y), 0, Vector2i(4, 2), 0)

# ─── Collision & water areas ─────────────────────────────────────────────────

func _build_boundaries() -> void:
	var w: float = MAP_W * TILE
	var h: float = MAP_H * TILE
	_add_collision(Vector2(w * 0.5, -8), Vector2(w, 16))
	_add_collision(Vector2(w * 0.5, h + 8), Vector2(w, 16))
	_add_collision(Vector2(-8, h * 0.5), Vector2(16, h))
	_add_collision(Vector2(w + 8, h * 0.5), Vector2(16, h))

func _build_water_areas() -> void:
	match theme:
		"hulu":
			_add_water_rect(Vector2(30.0 * TILE, 17.0 * TILE), Vector2(4.0 * TILE, 34.0 * TILE))
			_add_water_rect(Vector2(29.5 * TILE, 5.5 * TILE), Vector2(14.0 * TILE, 5.0 * TILE))
		"desa":
			_add_water_rect(Vector2(30.0 * TILE, 29.0 * TILE), Vector2(60.0 * TILE, 4.0 * TILE))
		"hilir":
			_add_water_rect(Vector2(30.0 * TILE, 31.0 * TILE), Vector2(60.0 * TILE, 6.0 * TILE))
			_add_water_rect(Vector2(46.0 * TILE, 18.0 * TILE), Vector2(4.0 * TILE, 20.0 * TILE))

func _add_water_rect(center: Vector2, size: Vector2) -> void:
	var area := Area2D.new()
	area.set_script(load("res://scripts/water_area.gd"))
	area.position = center
	var shape := RectangleShape2D.new()
	shape.size = size
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

# ─── Props ───────────────────────────────────────────────────────────────────

func _spawn_props() -> void:
	match theme:
		"hulu":
			_spawn_building("res://assets/sprites/props/house.png", Vector2(112, 208), Vector2(80, 22), Color(0.86, 0.98, 0.86))
			_spawn_trees([
				Vector2(40, 120), Vector2(72, 168), Vector2(48, 360), Vector2(96, 470), Vector2(150, 80),
				Vector2(210, 120), Vector2(260, 60), Vector2(320, 140), Vector2(360, 100), Vector2(400, 440),
				Vector2(360, 380), Vector2(250, 460), Vector2(170, 400), Vector2(520, 90), Vector2(560, 140),
				Vector2(620, 60), Vector2(680, 120), Vector2(740, 80), Vector2(800, 140), Vector2(860, 100),
				Vector2(540, 440), Vector2(600, 380), Vector2(660, 470), Vector2(740, 420), Vector2(820, 460),
				Vector2(900, 380), Vector2(880, 470), Vector2(300, 220), Vector2(620, 220), Vector2(780, 300),
			])
		"desa":
			_spawn_building("res://assets/sprites/props/warung.png", Vector2(136, 208), Vector2(80, 22))
			_spawn_building("res://assets/sprites/props/house.png", Vector2(480, 208), Vector2(80, 22))
			_spawn_building("res://assets/sprites/props/shop.png", Vector2(840, 224), Vector2(80, 22))
			_spawn_trees([
				Vector2(40, 120), Vector2(48, 420), Vector2(120, 470), Vector2(220, 200),
				Vector2(300, 470), Vector2(420, 470), Vector2(560, 200), Vector2(660, 470),
				Vector2(780, 200), Vector2(900, 420), Vector2(920, 120), Vector2(200, 120),
				Vector2(720, 120),
			])
		"hilir":
			_spawn_building("res://assets/sprites/props/warung.png", Vector2(112, 208), Vector2(80, 22))
			_spawn_building("res://assets/sprites/props/house.png", Vector2(400, 208), Vector2(80, 22))
			_spawn_building("res://assets/sprites/props/shop.png", Vector2(840, 208), Vector2(80, 22))
			_spawn_trees([
				Vector2(40, 120), Vector2(160, 80), Vector2(320, 120), Vector2(520, 80),
				Vector2(680, 120), Vector2(880, 80), Vector2(120, 200), Vector2(600, 200),
				Vector2(900, 200), Vector2(300, 470), Vector2(700, 470),
			])
			for pos in [Vector2(120, 432), Vector2(400, 440), Vector2(520, 432), Vector2(720, 440), Vector2(60, 424)]:
				_spawn_mangrove(pos)

func _spawn_building(path: String, pos: Vector2, collision_size: Vector2, tint: Color = Color.WHITE) -> void:
	var texture: Texture2D = load(path)
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.modulate = tint
	sprite.position = Vector2(0, -texture.get_height() * 0.5)
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = collision_size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -collision_size.y * 0.5)
	body.add_child(col)
	get_parent().add_child.call_deferred(body)

func _spawn_trees(positions: Array[Vector2]) -> void:
	for pos in positions:
		_spawn_tree(pos)

func _spawn_tree(pos: Vector2) -> void:
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

func _spawn_mangrove(pos: Vector2) -> void:
	var texture: Texture2D = load("res://assets/sprites/props/mangrove.png")
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.position = Vector2(0, -texture.get_height() * 0.5)
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = Vector2(12, 8)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -4)
	body.add_child(col)
	get_parent().add_child.call_deferred(body)

func _spawn_reeds() -> void:
	match theme:
		"hulu":
			for i in range(18):
				var side: int = 27 if i % 2 == 0 else 32
				var y: int = 40 + _hash(i, 3, 9) % 460
				if y > PATH_ROW * TILE - 12 and y < (PATH_ROW + 2) * TILE + 8:
					continue
				_spawn_reed(Vector2(side * TILE + 8, y))
		"desa":
			for i in range(22):
				var x: int = 20 + _hash(i, 4, 9) % 920
				if x > 30 * TILE - 12 and x < 35 * TILE + 12:
					continue
				_spawn_reed(Vector2(x, 26 * TILE + 4))
		"hilir":
			for i in range(24):
				var x: int = 16 + _hash(i, 5, 9) % 928
				_spawn_reed(Vector2(x, 27 * TILE + 2))

func _spawn_reed(pos: Vector2) -> void:
	var reed := Sprite2D.new()
	reed.texture = load("res://assets/sprites/props/reed.png")
	reed.position = pos
	reed.offset = Vector2(0, -10)
	reed.scale = Vector2(0.8, 1.0)
	reed.z_index = -1
	get_parent().add_child.call_deferred(reed)
