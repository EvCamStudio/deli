## TopdownMap — peta top-down prosedural untuk Level 1, 2, dan 4.
## Tema: "hulu" (hutan & mata air), "desa" (sawah & kampung), "hilir" (pesisir & mangrove).
extends Node2D
class_name TopdownMap

const TILE: int = 16
const MAP_W: int = 60
const MAP_H: int = 34
const PATH_ROW: int = 16
const BUILDING_BAND_SRC_PX: int = 8

static var _building_polygon_cache: Dictionary = {}

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

## Membangun TileSet 32x32 (8x8 atlas) terpadu pada skala 0.5 agar koordinat grid 16px tetap terjaga.
static func build_curated_tileset(layers: Array) -> TileSet:
	var ts := TileSet.new()
	ts.tile_size = Vector2i(32, 32)
	var source := TileSetAtlasSource.new()
	source.texture = load("res://assets/tilesets/pilot_tileset.png")
	source.texture_region_size = Vector2i(32, 32)
	for y in range(8):
		for x in range(8):
			source.create_tile(Vector2i(x, y))
	ts.add_source(source, 0)
	for layer in layers:
		if layer is TileMapLayer:
			layer.tile_set = ts
			layer.scale = Vector2(0.5, 0.5)
	return ts

func _build_tileset() -> void:
	_tileset = build_curated_tileset([ground, water, bridge, _decor])
	apply_water_visuals(water, theme == "hulu" or theme == "hilir")

## Menerapkan shader air sungai keruh & animasi arus mengalir pada layer Water.
static func apply_water_visuals(water_layer: TileMapLayer, vertical_flow: bool = false) -> void:
	if water_layer == null:
		return
	var shader: Shader = load("res://shaders/murky_water.gdshader")
	var strip: Texture2D = load("res://assets/tilesets/water_keruh_strip.png")
	if shader == null or strip == null:
		return
	var mat := ShaderMaterial.new()
	mat.shader = shader
	mat.set_shader_parameter("water_strip", strip)
	mat.set_shader_parameter("vertical_flow", vertical_flow)
	water_layer.material = mat

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
			var roll: int = _hash(x, y, 13)
			var atlas := Vector2i(_hash(x, y) % 3, 0)
			if roll < 95:
				atlas = Vector2i(roll % 3, 3)  # taburan bunga & semanggi alami di padang rumput
			elif theme == "hulu" and roll >= 965 and (y < PATH_ROW - 2 or y > PATH_ROW + 3):
				atlas = Vector2i(4 if roll % 2 == 0 else 3, 3)  # lumut/genangan rimba hulu
			elif theme == "hilir" and y < 22 and roll >= 960 and (y < PATH_ROW - 2 or y > PATH_ROW + 3):
				atlas = Vector2i(6 if roll % 2 == 0 else 5, 3)  # tanah lembap rawa hilir
			ground.set_cell(Vector2i(x, y), 0, atlas, 0)

	# Jalan utama kiri–kanan.
	for x in range(MAP_W):
		for y in [PATH_ROW, PATH_ROW + 1]:
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)

	match theme:
		"hulu": _paint_hulu_ground()
		"desa": _paint_desa_ground()
		"hilir": _paint_hilir_ground()

	autotile_dirt_paths(ground, MAP_W, MAP_H, _seed)

static func _is_road_dirt_cell(ground_layer: TileMapLayer, cell: Vector2i, map_w: int, map_h: int) -> bool:
	if cell.x < 0 or cell.x >= map_w or cell.y < 0 or cell.y >= map_h:
		return false
	var a: Vector2i = ground_layer.get_cell_atlas_coords(cell)
	return (a.y == 0 and a.x in [3, 4, 5]) or (a.y in [4, 5] and (a.y == 4 or a.x <= 5))

static func _is_meadow_grass_cell(ground_layer: TileMapLayer, cell: Vector2i, map_w: int, map_h: int) -> bool:
	if cell.x < 0 or cell.x >= map_w or cell.y < 0 or cell.y >= map_h:
		return true
	var a: Vector2i = ground_layer.get_cell_atlas_coords(cell)
	return (a.y == 0 and a.x <= 2) or (a.y == 3)

## Mengubah tepi dan sudut jalan tanah menjadi ubin transisi rumput-tanah secara otomatis.
static func autotile_dirt_paths(ground_layer: TileMapLayer, map_w: int, map_h: int, seed_value: int = 0) -> void:
	var targets: Array[Vector2i] = []
	for y in range(map_h):
		for x in range(map_w):
			var c := Vector2i(x, y)
			if _is_road_dirt_cell(ground_layer, c, map_w, map_h):
				targets.append(c)
	for c in targets:
		var n := _is_meadow_grass_cell(ground_layer, c + Vector2i(0, -1), map_w, map_h)
		var s := _is_meadow_grass_cell(ground_layer, c + Vector2i(0, 1), map_w, map_h)
		var w := _is_meadow_grass_cell(ground_layer, c + Vector2i(-1, 0), map_w, map_h)
		var e := _is_meadow_grass_cell(ground_layer, c + Vector2i(1, 0), map_w, map_h)
		var road_var: int = abs((c.x * 73856093) ^ (c.y * 19349663) ^ (seed_value * 83492791)) % 2
		var atlas := Vector2i(4 + road_var, 0)
		if n and s and not w and not e:
			atlas = Vector2i(5, 5)
		elif w and e and not n and not s:
			atlas = Vector2i(4, 5)
		elif n and w and not s and not e:
			atlas = Vector2i(4, 4)
		elif n and e and not s and not w:
			atlas = Vector2i(5, 4)
		elif s and w and not n and not e:
			atlas = Vector2i(6, 4)
		elif s and e and not n and not w:
			atlas = Vector2i(7, 4)
		elif n and not s and not w and not e:
			atlas = Vector2i(0, 4)
		elif s and not n and not w and not e:
			atlas = Vector2i(1, 4)
		elif w and not e and not n and not s:
			atlas = Vector2i(2, 4)
		elif e and not w and not n and not s:
			atlas = Vector2i(3, 4)
		elif not n and not s and not w and not e:
			if _is_meadow_grass_cell(ground_layer, c + Vector2i(-1, -1), map_w, map_h):
				atlas = Vector2i(0, 5)
			elif _is_meadow_grass_cell(ground_layer, c + Vector2i(1, -1), map_w, map_h):
				atlas = Vector2i(1, 5)
			elif _is_meadow_grass_cell(ground_layer, c + Vector2i(-1, 1), map_w, map_h):
				atlas = Vector2i(2, 5)
			elif _is_meadow_grass_cell(ground_layer, c + Vector2i(1, 1), map_w, map_h):
				atlas = Vector2i(3, 5)
		ground_layer.set_cell(c, 0, atlas, 0)

func _paint_hulu_ground() -> void:
	# Jalur tanah dari pintu rumah Ibu & rumah tetangga ke jalan utama.
	_paint_door_path(6, 7, 13)
	_paint_door_path(16, 17, 13)
	# Gang kecil kampung ke rumah warga di sisi barat daya.
	for y in range(PATH_ROW, 29):
		ground.set_cell(Vector2i(13, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(14, y), 0, Vector2i(5, 0), 0)
	for x in range(6, 15):
		ground.set_cell(Vector2i(x, 28), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(x, 29), 0, Vector2i(5, 0), 0)
	# Sedikit tanah lapang alami di papan pantun.
	ground.set_cell(Vector2i(17, 18), 0, Vector2i(7, 3), 0)

func _paint_desa_ground() -> void:
	# Jalur tanah dari pintu deret utara ke jalan utama.
	_paint_door_path(7, 8, 13)
	_paint_door_path(30, 31, 13)
	_paint_door_path(52, 53, 14)
	# Jalan menuju dermaga di tepi sungai + gang vertikal ke deret rumah bantaran selatan.
	for y in range(PATH_ROW, 27):
		ground.set_cell(Vector2i(30, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(31, y), 0, Vector2i(5, 0), 0)
	for y in range(PATH_ROW, 26):
		ground.set_cell(Vector2i(19, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(49, y), 0, Vector2i(5, 0), 0)
	# Jalan kampung bantaran sungai menyusuri deretan rumah selatan (y=25).
	for x in range(5, 56):
		ground.set_cell(Vector2i(x, 25), 0, Vector2i(4 + _hash(x, 25) % 2, 0), 0)
	# Petak kebun sayur tertata sejajar di utara dengan bedengan tanah gembur.
	var fields: Array[Rect2i] = [Rect2i(14, 4, 10, 6), Rect2i(35, 4, 10, 6), Rect2i(48, 4, 9, 6)]
	for f_idx in range(fields.size()):
		var field: Rect2i = fields[f_idx]
		for x in range(field.position.x, field.end.x):
			for y in range(field.position.y, field.end.y):
				var atlas: Vector2i
				if f_idx == 2:
					# Petak timur: alur vertikal berbibit
					atlas = Vector2i(2, 6) if (x + y) % 3 == 0 else Vector2i(3, 6)
				elif y % 2 == 0:
					atlas = Vector2i(2, 6) if (x + f_idx) % 2 == 0 else Vector2i(1, 6)
				else:
					atlas = Vector2i(0, 6)
				ground.set_cell(Vector2i(x, y), 0, atlas, 0)

func _paint_hilir_ground() -> void:
	# Jalur tanah dari pintu deret rumah sepanjang jalan utama.
	_paint_door_path(6, 7, 13)
	_paint_door_path(15, 16, 13)
	_paint_door_path(24, 25, 13)
	_paint_door_path(35, 36, 13)
	_paint_door_path(52, 53, 13)
	# Gang pemukiman baris belakang utara + akses penghubung ke jalan utama.
	for x in range(6, 35):
		ground.set_cell(Vector2i(x, 6), 0, Vector2i(4 + _hash(x, 6) % 2, 0), 0)
	for y in range(6, PATH_ROW + 1):
		ground.set_cell(Vector2i(20, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(21, y), 0, Vector2i(5, 0), 0)
	for y in range(6, 14):
		ground.set_cell(Vector2i(52, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(53, y), 0, Vector2i(5, 0), 0)
	# Garis tepi rumput-pasir organik di perbatasan pantai.
	for x in range(MAP_W):
		ground.set_cell(Vector2i(x, 23), 0, Vector2i(0, 7), 0)
	# Pantai berpasir + bercak lumpur muara dan tanah retak pesisir.
	for x in range(MAP_W):
		for y in range(24, 28):
			var roll: int = _hash(x, y, 29)
			var atlas := Vector2i(4 + _hash(x, y) % 2, 1)
			if y == 25 and roll < 75:
				atlas = Vector2i(4, 7)  # lumpur pasang surut
			elif y == 24 and roll >= 935:
				atlas = Vector2i(5, 7)  # tanah retak kering
			ground.set_cell(Vector2i(x, y), 0, atlas, 0)

func _paint_door_path(x_left: int, x_right: int, y_top: int) -> void:
	for y in range(y_top, PATH_ROW + 1):
		ground.set_cell(Vector2i(x_left, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(x_right, y), 0, Vector2i(5, 0), 0)

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
	var water_cells: Dictionary = {}

	# Laut di sisi selatan (penuh dari tepi barat ke timur).
	for x in range(MAP_W):
		for y in range(28, MAP_H):
			water_cells[Vector2i(x, y)] = true

	# Sungai muara mengalir utuh dari tepi utara peta (y=0) hingga laut selatan (y=28),
	# sedikit berkelok di hulu jembatan dan melebar di mulut muara agar tidak terlihat terputus.
	for y in range(0, 28):
		var bend: float = 0.0
		if y <= 10:
			bend = -sin(PI * 0.5 * float(10 - y) / 10.0)
		var x_start: int = 44 + int(round(bend))
		var x_end: int = 48 + int(round(bend))
		if y >= 25:
			# Mulut muara melebar alami menuju laut tanpa menyentuh titik mangrove (x=40, x=52).
			x_start = 43
			x_end = 49
		for x in range(x_start, x_end):
			water_cells[Vector2i(x, y)] = true

	for cell: Vector2i in water_cells.keys():
		if cell.y in [PATH_ROW, PATH_ROW + 1] and cell.x >= 44 and cell.x < 48:
			_paint_bridge_cell(cell.x, cell.y)
		else:
			_paint_water_cell(cell.x, cell.y)

	# Tepi pasir mengikuti kontur sungai & muara tanpa menimpa jalan utama.
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
				if n.y in [PATH_ROW, PATH_ROW + 1]:
					continue
				_paint_sand_cell(n.x, n.y)

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
	return (atlas.y == 0 and atlas.x <= 2) or (atlas.y == 3 and atlas.x <= 3)

func _paint_decor() -> void:
	var bush_count: int = {"hulu": 115, "desa": 52, "hilir": 64}.get(theme, 50)
	for i in range(bush_count):
		var x: int = 2 + _hash(i, 7, 3) % (MAP_W - 4)
		var y: int = 2 + _hash(i, 11, 5) % (MAP_H - 4)
		if not _is_open_grass(x, y):
			continue
		var mod: int = i % 6
		var atlas: Vector2i
		if mod <= 1:
			atlas = Vector2i(6, 5)  # semanggi & bunga kecil transparan
		elif mod == 2:
			atlas = Vector2i(7, 5)  # pakis rimba hulu/desa
		elif theme == "hulu" and x >= 40 and x <= 54 and y >= 8 and y <= 14:
			continue  # jaga kawasan reboisasi hutan hulu tetap lapang dari batu/semak besar
		elif mod == 3 or mod == 4:
			atlas = Vector2i(6, 2)  # semak rimbun
		else:
			atlas = Vector2i(7, 2)  # batu berlumut
		_decor.set_cell(Vector2i(x, y), 0, atlas, 0)
	if theme == "desa":
		_paint_field_fences()
	elif theme == "hilir":
		for i in range(18):
			var x: int = 2 + _hash(i, 19, 7) % (MAP_W - 4)
			var y: int = 24 + _hash(i, 23, 11) % 3
			var c := Vector2i(x, y)
			if water.get_cell_source_id(c) == -1 and ground.get_cell_atlas_coords(c).y == 1:
				_decor.set_cell(c, 0, Vector2i(6, 7), 0)  # kerikil & kerang pantai

func _paint_field_fences() -> void:
	var fields: Array[Rect2i] = [Rect2i(14, 4, 10, 6), Rect2i(35, 4, 10, 6), Rect2i(48, 4, 9, 6)]
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
	build_water_collisions_and_areas(get_parent(), water, bridge, MAP_W, MAP_H, TILE)

## Membangun dinding kolisi solid & area air mengikuti tile air (kecuali jembatan/dermaga) agar pemain tidak masuk ke sungai.
static func build_water_collisions_and_areas(parent: Node, water_layer: TileMapLayer, bridge_layer: TileMapLayer, map_w: int, map_h: int, tile_size: int) -> void:
	if parent == null or water_layer == null:
		return
	var area := Area2D.new()
	area.set_script(load("res://scripts/water_area.gd"))
	var body := StaticBody2D.new()
	body.name = "WaterCollision"
	body.collision_layer = 1
	body.collision_mask = 0
	var shape_total: int = 0
	for y in range(map_h):
		var x: int = 0
		while x < map_w:
			var cell := Vector2i(x, y)
			var has_water: bool = water_layer.get_cell_source_id(cell) != -1 and (bridge_layer == null or bridge_layer.get_cell_source_id(cell) == -1)
			if not has_water:
				x += 1
				continue
			var start: int = x
			while x < map_w:
				var next_cell := Vector2i(x, y)
				if water_layer.get_cell_source_id(next_cell) == -1 or (bridge_layer != null and bridge_layer.get_cell_source_id(next_cell) != -1):
					break
				x += 1
			var width: int = x - start
			var x0: float = float(start * tile_size)
			var x1: float = float((start + width) * tile_size)
			var y0: float = float(y * tile_size)
			var y1: float = float((y + 1) * tile_size)
			var solid_size := Vector2(x1 - x0, y1 - y0)
			var solid_center := Vector2((x0 + x1) * 0.5, (y0 + y1) * 0.5)

			# Beri kelonggaran 2px di sisi yang menempel jembatan agar karakter mulus masuk dari tepi jalan tanpa tersangkut margin fisika.
			if bridge_layer != null:
				if start > 0 and bridge_layer.get_cell_source_id(Vector2i(start - 1, y)) != -1:
					x0 += 2.0
				if x < map_w and bridge_layer.get_cell_source_id(Vector2i(x, y)) != -1:
					x1 -= 2.0
				var touches_bridge_above := false
				var touches_bridge_below := false
				for bx in range(start, start + width):
					if y > 0 and bridge_layer.get_cell_source_id(Vector2i(bx, y - 1)) != -1:
						if (bx > 0 and water_layer.get_cell_source_id(Vector2i(bx - 1, y - 1)) == -1) or (bx + 1 < map_w and water_layer.get_cell_source_id(Vector2i(bx + 1, y - 1)) == -1):
							touches_bridge_above = true
					if y + 1 < map_h and bridge_layer.get_cell_source_id(Vector2i(bx, y + 1)) != -1:
						if (bx > 0 and water_layer.get_cell_source_id(Vector2i(bx - 1, y + 1)) == -1) or (bx + 1 < map_w and water_layer.get_cell_source_id(Vector2i(bx + 1, y + 1)) == -1):
							touches_bridge_below = true
				# Hanya tarik batas y pada jembatan yang menempel tepi darat (bukan ujung dermaga buntu seperti Desa).
				if touches_bridge_above:
					y0 += 2.0
				if touches_bridge_below:
					y1 -= 2.0
				solid_size = Vector2(maxf(2.0, x1 - x0), maxf(2.0, y1 - y0))
				solid_center = Vector2((x0 + x1) * 0.5, (y0 + y1) * 0.5)

			var solid_shape := RectangleShape2D.new()
			solid_shape.size = solid_size
			var solid_col := CollisionShape2D.new()
			solid_col.shape = solid_shape
			solid_col.position = solid_center
			body.add_child(solid_col)

			var area_shape := RectangleShape2D.new()
			area_shape.size = Vector2(maxf(2.0, width * tile_size - 4.0), maxf(2.0, tile_size - 4.0))
			var area_col := CollisionShape2D.new()
			area_col.shape = area_shape
			area_col.position = Vector2((start + width * 0.5) * tile_size, (y + 0.5) * tile_size)
			area.add_child(area_col)
			shape_total += 1
	if shape_total > 0:
		parent.add_child.call_deferred(body)
		parent.add_child.call_deferred(area)

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
			# Rumah MC beratap hijau + dua rumah tetangga di sisi kampung hulu.
			spawn_building(get_parent(), "res://assets/sprites/props/house_mc.png", Vector2(112, 208), Vector2(92, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(272, 208), Vector2(88, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_cream.png", Vector2(112, 448), Vector2(82, 22), 0.5)
			# Pohon dirapikan mengelompok: bingkai tepi kampung barat & rumpun hutan timur (bukan acak di pekarangan).
			_spawn_trees([
				# Bingkai barat & peneduh halaman
				Vector2(36, 128), Vector2(192, 196), Vector2(36, 356), Vector2(40, 488), Vector2(280, 488),
				# Kawasan hutan timur (mengelilingi titik tanam reboisasi & tepi sungai)
				Vector2(616, 72), Vector2(688, 68), Vector2(768, 72), Vector2(848, 72), Vector2(912, 84),
				Vector2(916, 156), Vector2(916, 212),
				Vector2(604, 424), Vector2(604, 488), Vector2(692, 488), Vector2(780, 448), Vector2(860, 488), Vector2(916, 424),
			])
		"desa":
			# Pemukiman padat di sepanjang jalan utama & bantaran Sungai Deli selatan.
			spawn_building(get_parent(), "res://assets/sprites/props/house_cream.png", Vector2(120, 208), Vector2(82, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(480, 208), Vector2(88, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_coastal.png", Vector2(840, 224), Vector2(78, 22), 0.5)
			# Deret rumah bantaran selatan menghadap gang tepi sungai.
			spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(104, 392), Vector2(88, 22), 0.5, Color(0.95, 0.98, 1.0))
			spawn_building(get_parent(), "res://assets/sprites/props/house_brick.png", Vector2(232, 392), Vector2(92, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_cream.png", Vector2(376, 392), Vector2(82, 22), 0.5, Color(0.96, 1.0, 0.96))
			spawn_building(get_parent(), "res://assets/sprites/props/house_coastal.png", Vector2(592, 392), Vector2(78, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(728, 392), Vector2(88, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_modern.png", Vector2(864, 392), Vector2(88, 22), 0.5)
			# Pohon tertata di sudut pekarangan & bingkai tepi peta (tidak menghalangi jalan/kebun).
			_spawn_trees([
				Vector2(40, 128), Vector2(40, 204), Vector2(204, 212), Vector2(396, 212), Vector2(724, 212), Vector2(920, 128),
				Vector2(36, 392), Vector2(168, 392), Vector2(440, 392), Vector2(660, 392), Vector2(924, 392),
				Vector2(48, 520), Vector2(256, 520), Vector2(704, 520), Vector2(912, 520),
			])
		"hilir":
			# Kampung pesisir muara: dua baris rumah utara + rumah sisi timur sungai.
			spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(120, 88), Vector2(88, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_brick.png", Vector2(248, 88), Vector2(92, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(512, 88), Vector2(88, 22), 0.5, Color(0.96, 0.98, 1.0))
			spawn_building(get_parent(), "res://assets/sprites/props/house_coastal.png", Vector2(840, 88), Vector2(78, 22), 0.5, Color(0.96, 1.0, 0.96))
			# Deretan rumah utama di tepi jalan raya pesisir.
			spawn_building(get_parent(), "res://assets/sprites/props/house_coastal.png", Vector2(112, 208), Vector2(78, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_cream.png", Vector2(248, 208), Vector2(82, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(400, 208), Vector2(88, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_modern.png", Vector2(568, 208), Vector2(88, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_cream.png", Vector2(840, 208), Vector2(82, 22), 0.5)
			# Pohon pesisir ditata di celah antar-rumah & batas tepi kampung.
			_spawn_trees([
				Vector2(40, 88), Vector2(392, 88), Vector2(624, 88), Vector2(920, 88),
				Vector2(180, 208), Vector2(308, 208), Vector2(484, 208), Vector2(644, 208), Vector2(920, 208),
				Vector2(48, 352), Vector2(560, 352), Vector2(912, 352),
			])
			for pos in [Vector2(120, 432), Vector2(448, 436), Vector2(520, 432), Vector2(720, 440), Vector2(60, 424)]:
				_spawn_mangrove(pos)

## Memunculkan sprite bangunan berkolisi dari aset 2x/1x agar sejajar di tepi jalan.
static func spawn_building(parent: Node, path: String, pos: Vector2, collision_size: Vector2, sprite_scale: float = 0.5, tint: Color = Color.WHITE) -> void:
	var texture: Texture2D = load(path)
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.modulate = tint
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.position = Vector2(0, -texture.get_height() * 0.5 * sprite_scale)
	body.add_child(sprite)
	# Bangunan 3/4 memblokir seluruh badan + atap mengikuti siluet sprite agar pemain tidak menembus dari belakang/samping.
	var poly := _building_collision_polygon(texture, sprite_scale, collision_size)
	if poly.size() >= 3:
		var col := CollisionPolygon2D.new()
		col.polygon = poly
		body.add_child(col)
	else:
		var solid_size := Vector2(
			maxf(collision_size.x, float(texture.get_width()) * sprite_scale),
			maxf(collision_size.y, float(texture.get_height()) * sprite_scale)
		)
		var shape := RectangleShape2D.new()
		shape.size = solid_size
		var col := CollisionShape2D.new()
		col.shape = shape
		col.position = Vector2(0, -solid_size.y * 0.5)
		body.add_child(col)
	parent.add_child.call_deferred(body)

## Menghasilkan poligon kolisi 3/4 berdasar siluet opak tekstur bangunan (di-cache per aset & skala).
static func _building_collision_polygon(texture: Texture2D, sprite_scale: float, fallback_size: Vector2) -> PackedVector2Array:
	if texture == null:
		return PackedVector2Array()
	var cache_key := "%s:%.3f" % [texture.resource_path, sprite_scale]
	if _building_polygon_cache.has(cache_key):
		return _building_polygon_cache[cache_key]
	var img: Image = texture.get_image()
	if img == null or img.is_empty():
		return PackedVector2Array()
	var w: int = img.get_width()
	var h: int = img.get_height()
	var bands: Array[Dictionary] = []
	for y0 in range(0, h, BUILDING_BAND_SRC_PX):
		var y1: int = mini(h, y0 + BUILDING_BAND_SRC_PX)
		var lx: int = w
		var rx: int = -1
		for y in range(y0, y1):
			for x in range(w):
				if img.get_pixel(x, y).a > 0.2:
					if x < lx:
						lx = x
					if x > rx:
						rx = x
		if rx < lx:
			continue
		var world_w: float = float(rx - lx + 1) * sprite_scale
		# Abaikan puncak cerobong tipis di baris paling atas agar bagian belakang atap tetap rata dan mulus dilewati.
		if bands.is_empty() and world_w < 14.0:
			continue
		# Beri bantalan 1.5px di tepi kiri/kanan agar rambut & bahu karakter (12px) tetap tampak di luar garis tepi dinding.
		bands.append({
			"y0": (float(y0) - float(h)) * sprite_scale,
			"y1": (float(y1) - float(h)) * sprite_scale,
			"lx": (float(lx) - float(w) * 0.5) * sprite_scale - 1.5,
			"rx": (float(rx + 1) - float(w) * 0.5) * sprite_scale + 1.5,
		})
	if bands.is_empty():
		return PackedVector2Array([
			Vector2(-fallback_size.x * 0.5, -fallback_size.y),
			Vector2(-fallback_size.x * 0.5, 0.0),
			Vector2(fallback_size.x * 0.5, 0.0),
			Vector2(fallback_size.x * 0.5, -fallback_size.y),
		])
	# Jaga pangkal depan (-24..0) selebar dinding utama agar pemain tidak masuk celah teras/bay window lalu terpotong Y-sort.
	for i in range(1, bands.size()):
		if bands[i]["y1"] > -24.0:
			bands[i]["lx"] = minf(bands[i]["lx"], bands[i - 1]["lx"])
			bands[i]["rx"] = maxf(bands[i]["rx"], bands[i - 1]["rx"])
	bands[bands.size() - 1]["y1"] = 0.0
	var merged: Array[Dictionary] = []
	for b in bands:
		if not merged.is_empty() and absf(merged[merged.size() - 1]["lx"] - b["lx"]) <= 1.5 and absf(merged[merged.size() - 1]["rx"] - b["rx"]) <= 1.5:
			merged[merged.size() - 1]["lx"] = minf(merged[merged.size() - 1]["lx"], b["lx"])
			merged[merged.size() - 1]["rx"] = maxf(merged[merged.size() - 1]["rx"], b["rx"])
			merged[merged.size() - 1]["y1"] = b["y1"]
		else:
			merged.append(b)
	var pts: Array[Vector2] = []
	var n: int = merged.size()
	for i in range(n):
		pts.append(Vector2(merged[i]["lx"], merged[i]["y0"]))
		if i < n - 1 and absf(merged[i + 1]["lx"] - merged[i]["lx"]) > 4.0:
			pts.append(Vector2(merged[i]["lx"], merged[i]["y1"]))
	pts.append(Vector2(merged[n - 1]["lx"], 0.0))
	pts.append(Vector2(merged[n - 1]["rx"], 0.0))
	for i in range(n - 1, 0, -1):
		if absf(merged[i - 1]["rx"] - merged[i]["rx"]) > 4.0:
			pts.append(Vector2(merged[i]["rx"], merged[i]["y0"]))
			pts.append(Vector2(merged[i - 1]["rx"], merged[i]["y0"]))
		else:
			pts.append(Vector2(merged[i]["rx"], merged[i]["y0"]))
	pts.append(Vector2(merged[0]["rx"], merged[0]["y0"]))
	var poly := PackedVector2Array(pts)
	_building_polygon_cache[cache_key] = poly
	return poly

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
			_spawn_reeds_on_banks(26)

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
