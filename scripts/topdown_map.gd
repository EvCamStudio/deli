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
	# Jalur tanah dari pintu rumah Ibu ke jalan utama.
	_paint_door_path(6, 7, 13)

func _paint_desa_ground() -> void:
	# Jalur tanah dari pintu tiap bangunan ke jalan utama.
	_paint_door_path(8, 9, 13)
	_paint_door_path(30, 31, 13)
	_paint_door_path(52, 53, 13)
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
	# Jalur tanah dari pintu tiap bangunan ke jalan utama.
	_paint_door_path(6, 7, 13)
	_paint_door_path(24, 25, 13)
	_paint_door_path(52, 53, 13)
	# Pantai berpasir.
	for x in range(MAP_W):
		for y in range(24, 28):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 1), 0)

func _paint_door_path(x_left: int, x_right: int, y_top: int) -> void:
	for y in range(y_top, PATH_ROW + 1):
		ground.set_cell(Vector2i(x_left, y), 0, Vector2i(3, 0), 0)
		ground.set_cell(Vector2i(x_right, y), 0, Vector2i(4, 0), 0)

# ─── Water ───────────────────────────────────────────────────────────────────

func _paint_water() -> void:
	match theme:
		"hulu": _water_hulu()
		"desa": _water_desa()
		"hilir": _water_hilir()

func _paint_water_cell(x: int, y: int) -> void:
	water.set_cell(Vector2i(x, y), 0, Vector2i(_hash(x, y) % 2, 1), 0)

## Cek memakai tile air yang benar-benar tergambar supaya bentuk sungai
## yang berkelok/kolam lonjong tetap akurat.
func is_in_water(pos: Vector2) -> bool:
	var cell := Vector2i(int(floor(pos.x / TILE)), int(floor(pos.y / TILE)))
	if cell.x < 0 or cell.x >= MAP_W or cell.y < 0 or cell.y >= MAP_H:
		return false
	return _is_water_cell(cell)

func _paint_sand_cell(x: int, y: int) -> void:
	ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 1), 0)

func _paint_bridge_cell(x: int, y: int) -> void:
	bridge.set_cell(Vector2i(x, y), 0, Vector2i(6 + _hash(x, y) % 2, 1), 0)

func _water_hulu() -> void:
	# Bentuk air dihitung dulu sebagai satu kesatuan, lalu digambar.
	# Dengan begitu kolam mata air benar-benar menyatu dengan sungai
	# (tidak terpotong garis pasir seperti versi sebelumnya).
	var water_cells: Dictionary = {}

	# Sungai utama: lebar 4 tile, mengalir utara → selatan dengan
	# lengkung halus agar tidak terlihat seperti balok.
	for y in range(MAP_H):
		var bend: float = 0.0
		# Lengkung hanya di hilir jembatan supaya sambungan kolam–sungai
		# tetap lurus dan tidak terlihat patah.
		if y >= PATH_ROW:
			bend = sin(PI * float(y - PATH_ROW) / 16.0)
		var center: int = 30 + int(round(bend))
		for x in range(center - 2, center + 2):
			water_cells[Vector2i(x, y)] = true

	# Mata air: kolam lonjong di hulu, menyatu dengan aliran sungai.
	# Sedikit variasi radial membuat tepinya tidak terlihat seperti balok.
	var pond_center := Vector2(30.0, 6.5)
	var pond_radius := Vector2(5.4, 4.2)
	for y in range(0, 13):
		for x in range(21, 40):
			var dx: float = float(x) + 0.5 - pond_center.x
			var dy: float = float(y) + 0.5 - pond_center.y
			var nx: float = dx / pond_radius.x
			var ny: float = dy / pond_radius.y
			var angle: float = atan2(ny, nx)
			var wobble: float = 1.0 + 0.10 * sin(angle * 3.0 + 0.9) + 0.06 * sin(angle * 5.0 - 1.3)
			if nx * nx + ny * ny <= wobble * wobble:
				water_cells[Vector2i(x, y)] = true

	# Air sungai + jembatan kayu di jalan utama.
	for cell: Vector2i in water_cells.keys():
		if cell.y == PATH_ROW or cell.y == PATH_ROW + 1:
			_paint_bridge_cell(cell.x, cell.y)
		else:
			_paint_water_cell(cell.x, cell.y)

	# Tepi pasir mengikuti kontur air, tanpa menutup jalan.
	for cell: Vector2i in water_cells.keys():
		for dy in range(-1, 2):
			for dx in range(-1, 2):
				if dx == 0 and dy == 0:
					continue
				var n := Vector2i(cell.x + dx, cell.y + dy)
				if water_cells.has(n):
					continue
				if n.x < 0 or n.x >= MAP_W or n.y < 0 or n.y >= MAP_H:
					continue
				if n.y == PATH_ROW or n.y == PATH_ROW + 1:
					continue
				_paint_sand_cell(n.x, n.y)

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
	# Jangan menaruh semak/batu di atas air atau jembatan.
	if water.get_cell_source_id(Vector2i(x, y)) != -1:
		return false
	if bridge.get_cell_source_id(Vector2i(x, y)) != -1:
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

func _is_water_cell(cell: Vector2i) -> bool:
	return water.get_cell_source_id(cell) != -1 and bridge.get_cell_source_id(cell) == -1

func _build_water_areas() -> void:
	# Area air dibangun dari tile air yang sudah digambar supaya bentuk
	# kolam/sungai yang tidak kotak tetap terdeteksi dengan tepat.
	var area := Area2D.new()
	area.set_script(load("res://scripts/water_area.gd"))
	var shape_total: int = 0
	for y in range(MAP_H):
		var x: int = 0
		while x < MAP_W:
			if not _is_water_cell(Vector2i(x, y)):
				x += 1
				continue
			var start: int = x
			while x < MAP_W and _is_water_cell(Vector2i(x, y)):
				x += 1
			var width: int = x - start
			var shape := RectangleShape2D.new()
			shape.size = Vector2(width * TILE, TILE)
			var col := CollisionShape2D.new()
			col.shape = shape
			col.position = Vector2((start + width * 0.5) * TILE, (y + 0.5) * TILE)
			area.add_child(col)
			shape_total += 1
	if shape_total > 0:
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
				Vector2(40, 120), Vector2(48, 360), Vector2(96, 470), Vector2(150, 80),
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
				Vector2(40, 120), Vector2(48, 420), Vector2(120, 424), Vector2(220, 200),
				Vector2(300, 424), Vector2(560, 200), Vector2(660, 424),
				Vector2(772, 200), Vector2(900, 420), Vector2(920, 120), Vector2(200, 120),
				Vector2(720, 120),
			])
		"hilir":
			_spawn_building("res://assets/sprites/props/warung.png", Vector2(112, 208), Vector2(80, 22))
			_spawn_building("res://assets/sprites/props/house.png", Vector2(400, 208), Vector2(80, 22))
			_spawn_building("res://assets/sprites/props/shop.png", Vector2(840, 208), Vector2(80, 22))
			_spawn_trees([
				Vector2(40, 120), Vector2(160, 80), Vector2(320, 120), Vector2(520, 80),
				Vector2(680, 120), Vector2(880, 80), Vector2(200, 176), Vector2(600, 200),
				Vector2(908, 200), Vector2(260, 440), Vector2(760, 440),
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

func _spawn_mangrove(pos: Vector2) -> void:
	if is_in_water(pos):
		return
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
			_spawn_reeds_on_banks(22)
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

## Sebaran alang-alang tepat di tepi pasir yang bersebelahan dengan air,
## jadi selalu mengikuti kontur sungai/kolam.
func _spawn_reeds_on_banks(count: int) -> void:
	var spots: Array[Vector2] = []
	for y in range(1, MAP_H - 1):
		for x in range(1, MAP_W - 1):
			var cell := Vector2i(x, y)
			if water.get_cell_source_id(cell) != -1:
				continue
			var atlas: Vector2i = ground.get_cell_atlas_coords(cell)
			if atlas.y != 1 or atlas.x < 4 or atlas.x > 5:
				continue
			if not _touches_water(cell):
				continue
			spots.append(Vector2(x * TILE + TILE * 0.5, y * TILE + TILE * 0.5))
	for i in range(count):
		if spots.is_empty():
			return
		var idx: int = _hash(i, 3, 9) % spots.size()
		_spawn_reed(spots[idx])
		spots.remove_at(idx)

func _touches_water(cell: Vector2i) -> bool:
	for offset: Vector2i in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
		if water.get_cell_source_id(cell + offset) != -1:
			return true
	return false

func _spawn_reed(pos: Vector2) -> void:
	var reed := Sprite2D.new()
	reed.texture = load("res://assets/sprites/props/reed.png")
	reed.position = pos
	reed.offset = Vector2(0, -10)
	reed.scale = Vector2(0.8, 1.0)
	reed.z_index = -1
	get_parent().add_child.call_deferred(reed)
