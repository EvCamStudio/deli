## TopdownMap — peta top-down prosedural untuk Level 1, 2, dan 4.
## Tema: "hulu" (hutan & mata air), "desa" (sawah & kampung), "hilir" (pesisir & mangrove).
extends Node2D
class_name TopdownMap

const TILE: int = 16
const MAP_W: int = 60
const MAP_H: int = 32
const PATH_ROW: int = 15
const BUILDING_BAND_SRC_PX: int = 8
const BUILDING_ROOF_TUCK_PX: float = 12.0
const BUILDING_SIDE_INSET_PX: float = 2.0
  
const TREE_SPECS: Dictionary = {
	"kelapa": {"path": "res://assets/sprites/props/tree_kelapa.png", "scale": 0.5, "col": Vector2(12, 8)},
	"mangga": {"path": "res://assets/sprites/props/tree_mangga.png", "scale": 0.5, "col": Vector2(14, 8)},
	"pisang": {"path": "res://assets/sprites/props/tree_pisang.png", "scale": 0.5, "col": Vector2(14, 8)},
	"beringin": {"path": "res://assets/sprites/props/tree_beringin.png", "scale": 0.5, "col": Vector2(28, 10)},
	"pepaya": {"path": "res://assets/sprites/props/tree_pepaya.png", "scale": 0.5, "col": Vector2(10, 8)},
	"kamboja": {"path": "res://assets/sprites/props/tree_kamboja.png", "scale": 0.5, "col": Vector2(14, 8)},
	"pinus": {"path": "res://assets/sprites/props/tree_pinus.png", "scale": 0.5, "col": Vector2(14, 8)},
	"spruce_tall": {"path": "res://assets/sprites/props/tree_spruce_tall.png", "scale": 0.5, "col": Vector2(18, 10)},
	"cemara": {"path": "res://assets/sprites/props/tree_cemara.png", "scale": 0.5, "col": Vector2(14, 8)},
	"spruce": {"path": "res://assets/sprites/props/tree_spruce.png", "scale": 0.5, "col": Vector2(16, 8)},
	"rindang": {"path": "res://assets/sprites/props/tree.png", "scale": 0.5, "col": Vector2(16, 8)},
}

# Tile kota / aspal pada Source 2 (city_tileset_32.png)
const T_ASPHALT := [Vector2i(0, 3), Vector2i(1, 3), Vector2i(3, 4)]
const T_DASH_H := Vector2i(2, 3)
const T_DASH_V := Vector2i(3, 3)
const T_WALK := [Vector2i(4, 3), Vector2i(6, 4)]
const T_CURB_DOWN := Vector2i(5, 3)
const T_CURB_UP := Vector2i(4, 4)
const T_CURB_LEFT := Vector2i(0, 5)
const T_CURB_RIGHT := Vector2i(1, 5)
const T_CROSS_H := Vector2i(6, 3)
const T_CROSS_V := Vector2i(7, 3)
const T_PLAZA := [Vector2i(0, 4), Vector2i(1, 4)]
const T_MANHOLE := Vector2i(2, 4)
const T_DRAIN := Vector2i(5, 4)
const T_PLANTER := Vector2i(2, 5)

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
	var shore := ensure_shore_overlay(self, water, bridge)
	autotile_sand_and_shores(ground, water, bridge, shore, MAP_W, MAP_H)
	autotile_dirt_paths(ground, MAP_W, MAP_H, _seed, bridge, water)
	_paint_decor()
	_build_boundaries()
	_build_water_areas()
	_spawn_props()
	_spawn_reeds()

# ─── Tileset ─────────────────────────────────────────────────────────────────

## Membangun TileSet 32x32 (Source 0: atlas utama 8x8, Source 1: 47-blob pasir & tepian air 8x12)
## pada skala 0.5 agar koordinat grid 16px tetap terjaga.
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
	var shore_tex: Texture2D = load("res://assets/tilesets/sand_shore_tileset.png")
	if shore_tex != null:
		var shore_source := TileSetAtlasSource.new()
		shore_source.texture = shore_tex
		shore_source.texture_region_size = Vector2i(32, 32)
		for y in range(12):
			for x in range(8):
				shore_source.create_tile(Vector2i(x, y))
		ts.add_source(shore_source, 1)
	var city_tex: Texture2D = load("res://assets/tilesets/city_tileset_32.png")
	if city_tex != null:
		var city_source := TileSetAtlasSource.new()
		city_source.texture = city_tex
		city_source.texture_region_size = Vector2i(32, 32)
		for y in range(6):
			for x in range(8):
				city_source.create_tile(Vector2i(x, y))
		ts.add_source(city_source, 2)
	for layer in layers:
		if layer is TileMapLayer:
			layer.tile_set = ts
			layer.scale = Vector2(0.5, 0.5)
	return ts

func _build_tileset() -> void:
	_tileset = build_curated_tileset([ground, water, bridge, _decor])
	apply_water_visuals(water, theme == "hulu", theme == "hulu", theme == "hilir")

## Menerapkan shader air sungai keruh & animasi arus mengalir pada layer Water.
static func apply_water_visuals(water_layer: TileMapLayer, vertical_flow: bool = false, bend_to_east: bool = false, is_hilir: bool = false) -> void:
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
	mat.set_shader_parameter("bend_to_east", bend_to_east)
	mat.set_shader_parameter("is_hilir", is_hilir)
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

	# Jalan utama kiri–kanan (Desa & Hulu jalan tanah, Hilir diatur tersendiri sebagai aspal & beton).
	var p_row: int = 10 if theme == "hilir" else PATH_ROW
	if theme != "hilir":
		for x in range(MAP_W):
			for y in [p_row - 2, p_row - 1, p_row, p_row + 1]:
				ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)

	match theme:
		"hulu": _paint_hulu_ground()
		"desa": _paint_desa_ground()
		"hilir": _paint_hilir_ground()

	autotile_dirt_paths(ground, MAP_W, MAP_H, _seed)

static func _is_road_dirt_cell(ground_layer: TileMapLayer, cell: Vector2i, map_w: int, map_h: int) -> bool:
	if cell.x < 0 or cell.x >= map_w or cell.y < 0 or cell.y >= map_h:
		return false
	if ground_layer.get_cell_source_id(cell) != 0:
		return false
	var a: Vector2i = ground_layer.get_cell_atlas_coords(cell)
	return (a.y == 0 and a.x in [3, 4, 5]) or (a.y in [4, 5] and (a.y == 4 or a.x <= 5))

static func _is_meadow_grass_cell(ground_layer: TileMapLayer, cell: Vector2i, map_w: int, map_h: int) -> bool:
	if cell.x < 0 or cell.x >= map_w or cell.y < 0 or cell.y >= map_h:
		return false
	if ground_layer.get_cell_source_id(cell) != 0:
		return false
	var a: Vector2i = ground_layer.get_cell_atlas_coords(cell)
	return (a.y == 0 and a.x <= 2) or (a.y == 3)

static func _is_grass_for_sand(ground_layer: TileMapLayer, cell: Vector2i, map_w: int, map_h: int, water_layer: TileMapLayer = null, bridge_layer: TileMapLayer = null) -> bool:
	if cell.x < 0 or cell.x >= map_w or cell.y < 0 or cell.y >= map_h:
		return false
	if water_layer != null and water_layer.get_cell_source_id(cell) != -1:
		return false
	if bridge_layer != null and bridge_layer.get_cell_source_id(cell) != -1:
		return false
	if ground_layer.get_cell_source_id(cell) != 0:
		return false
	var a: Vector2i = ground_layer.get_cell_atlas_coords(cell)
	return (a.y == 0 and a.x <= 2) or (a.y == 3)

static func is_sand_cell(ground_layer: TileMapLayer, cell: Vector2i) -> bool:
	var sid: int = ground_layer.get_cell_source_id(cell)
	var a: Vector2i = ground_layer.get_cell_atlas_coords(cell)
	return (sid == 0 and a.y == 1 and a.x in [4, 5]) or (sid == 1 and a.y < 6)

static func ensure_shore_overlay(map_node: Node, water_layer: TileMapLayer, bridge_layer: TileMapLayer) -> TileMapLayer:
	var shore := map_node.get_node_or_null("ShoreOverlay") as TileMapLayer
	if shore == null:
		shore = TileMapLayer.new()
		shore.name = "ShoreOverlay"
		map_node.add_child(shore)
	shore.z_index = -18
	if bridge_layer != null and bridge_layer.z_index <= shore.z_index:
		bridge_layer.z_index = -17
	if water_layer != null:
		shore.tile_set = water_layer.tile_set
		shore.scale = water_layer.scale
	return shore

static var _blob_lookup_cache: Dictionary = {}

static func _get_blob_lookup() -> Dictionary:
	if not _blob_lookup_cache.is_empty():
		return _blob_lookup_cache
	var masks: Array[int] = []
	var seen: Dictionary = {}
	for raw in range(256):
		var c: int = raw & 15
		if (c & 1) == 0 and (c & 8) == 0 and (raw & 16) != 0:
			c |= 16
		if (c & 1) == 0 and (c & 2) == 0 and (raw & 32) != 0:
			c |= 32
		if (c & 4) == 0 and (c & 2) == 0 and (raw & 64) != 0:
			c |= 64
		if (c & 4) == 0 and (c & 8) == 0 and (raw & 128) != 0:
			c |= 128
		if not seen.has(c):
			seen[c] = true
			masks.append(c)
	masks.sort()
	for i in range(masks.size()):
		_blob_lookup_cache[masks[i]] = Vector2i(i % 8, int(i / 8))
	return _blob_lookup_cache

static func _is_channel_cell(water_layer: TileMapLayer, bridge_layer: TileMapLayer, cell: Vector2i, map_w: int, map_h: int) -> bool:
	if cell.x < 0 or cell.x >= map_w or cell.y < 0 or cell.y >= map_h:
		return true
	if water_layer.get_cell_source_id(cell) != -1:
		return true
	return bridge_layer != null and bridge_layer.get_cell_source_id(cell) != -1

static func _neighbor_blob_mask(c: Vector2i, is_outer: Callable) -> int:
	var n: bool = is_outer.call(c + Vector2i(0, -1))
	var e: bool = is_outer.call(c + Vector2i(1, 0))
	var s: bool = is_outer.call(c + Vector2i(0, 1))
	var w: bool = is_outer.call(c + Vector2i(-1, 0))
	var mask: int = (1 if n else 0) | (2 if e else 0) | (4 if s else 0) | (8 if w else 0)
	if not n and not w and is_outer.call(c + Vector2i(-1, -1)):
		mask |= 16
	if not n and not e and is_outer.call(c + Vector2i(1, -1)):
		mask |= 32
	if not s and not e and is_outer.call(c + Vector2i(1, 1)):
		mask |= 64
	if not s and not w and is_outer.call(c + Vector2i(-1, 1)):
		mask |= 128
	return mask

## Menerapkan autotile 47-blob halus untuk transisi Rumput↔Pasir serta lengkung tepian Air↔Pasir basah.
static func autotile_sand_and_shores(ground_layer: TileMapLayer, water_layer: TileMapLayer, bridge_layer: TileMapLayer, shore_layer: TileMapLayer, map_w: int, map_h: int) -> void:
	if ground_layer == null or ground_layer.tile_set == null or not ground_layer.tile_set.has_source(1):
		return
	var lookup: Dictionary = _get_blob_lookup()
	var grass_pred := func(cell: Vector2i) -> bool:
		return _is_grass_for_sand(ground_layer, cell, map_w, map_h, water_layer, bridge_layer)

	# 1) Pass Pasir → Rumput (snapshot dulu agar ubahan tidak memengaruhi tetangga).
	var sand_cells: Array[Vector2i] = []
	var sand_masks: Array[int] = []
	for y in range(map_h):
		for x in range(map_w):
			var c := Vector2i(x, y)
			if not is_sand_cell(ground_layer, c):
				continue
			var mask: int = _neighbor_blob_mask(c, grass_pred)
			if mask != 0:
				sand_cells.append(c)
				sand_masks.append(mask)
	for i in range(sand_cells.size()):
		var coord: Vector2i = lookup.get(sand_masks[i], Vector2i.ZERO)
		ground_layer.set_cell(sand_cells[i], 1, coord, 0)

	# 2) Pass Tepian Air ↔ Pasir Basah di atas layer Water (tanpa menimpa jembatan/dermaga).
	if shore_layer == null or water_layer == null:
		return
	var land_pred := func(cell: Vector2i) -> bool:
		return not _is_channel_cell(water_layer, bridge_layer, cell, map_w, map_h)
	for y in range(map_h):
		for x in range(map_w):
			var c := Vector2i(x, y)
			var has_open_water: bool = water_layer.get_cell_source_id(c) != -1 and (bridge_layer == null or bridge_layer.get_cell_source_id(c) == -1)
			if not has_open_water:
				shore_layer.erase_cell(c)
				continue
			var mask: int = _neighbor_blob_mask(c, land_pred)
			if mask == 0:
				shore_layer.erase_cell(c)
			else:
				var coord: Vector2i = lookup.get(mask, Vector2i.ZERO)
				shore_layer.set_cell(c, 1, Vector2i(coord.x, coord.y + 6), 0)

## Mengubah tepi dan sudut jalan tanah menjadi ubin transisi rumput-tanah secara otomatis.
static func autotile_dirt_paths(ground_layer: TileMapLayer, map_w: int, map_h: int, seed_value: int = 0, bridge_layer: TileMapLayer = null, water_layer: TileMapLayer = null) -> void:
	var grass_or_edge := func(cell: Vector2i) -> bool:
		if bridge_layer != null and bridge_layer.get_cell_source_id(cell) != -1:
			return false
		if water_layer != null and water_layer.get_cell_source_id(cell) != -1:
			return false
		return _is_meadow_grass_cell(ground_layer, cell, map_w, map_h)
	var targets: Array[Vector2i] = []
	for y in range(map_h):
		for x in range(map_w):
			var c := Vector2i(x, y)
			if _is_road_dirt_cell(ground_layer, c, map_w, map_h):
				targets.append(c)
	for c in targets:
		var n: bool = grass_or_edge.call(c + Vector2i(0, -1))
		var s: bool = grass_or_edge.call(c + Vector2i(0, 1))
		var w: bool = grass_or_edge.call(c + Vector2i(-1, 0))
		var e: bool = grass_or_edge.call(c + Vector2i(1, 0))
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
			if grass_or_edge.call(c + Vector2i(-1, -1)):
				atlas = Vector2i(0, 5)
			elif grass_or_edge.call(c + Vector2i(1, -1)):
				atlas = Vector2i(1, 5)
			elif grass_or_edge.call(c + Vector2i(-1, 1)):
				atlas = Vector2i(2, 5)
			elif grass_or_edge.call(c + Vector2i(1, 1)):
				atlas = Vector2i(3, 5)
		ground_layer.set_cell(c, 0, atlas, 0)

func _paint_hulu_ground() -> void:
	# Jalur jalan setapak rapi dari pintu rumah Ibu & rumah tetangga ke jalan utama (lebar 2 petak)
	_paint_door_path(6, 7, 11, 13)
	_paint_door_path(16, 17, 11, 13)

func _paint_desa_ground() -> void:
	# Jalur jalan setapak rapi dari pintu deret rumah utara ke jalan utama (lebar 2 petak, Gambar 7).
	_paint_door_path(11, 12, 11, 13) # warung_toko_jaya (x=180)
	_paint_door_path(21, 22, 11, 13) # house_cottage_orange (x=340)
	_paint_door_path(31, 32, 11, 13) # house_seng_gate (x=500)
	_paint_door_path(41, 42, 11, 13) # house_cabin_blue (x=660)
	_paint_door_path(51, 52, 11, 13) # house_seng_motor (x=820)
	# Gang vertikal rapi penghubung jalan utama utara ke jalan bantaran sungai selatan (lebar 2 petak)
	# Melewati celah antar-bangunan selatan yang luas (x=352 / col 22, x=544 / col 34),
	# tidak membelah badan rumah warga (house_brick di col 16/17 bersih berpekarangan rumput).
	for col in [22, 34]:
		for y in range(16, 24):
			for x in range(col, col + 2):
				ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)
	# Jalan kampung bantaran sungai menyusuri deretan rumah selatan (y=24..25).
	for x in range(4, 56):
		ground.set_cell(Vector2i(x, 24), 0, Vector2i(4 + _hash(x, 24) % 2, 0), 0)
		ground.set_cell(Vector2i(x, 25), 0, Vector2i(4 + _hash(x, 25) % 2, 0), 0)

func _paint_hilir_ground() -> void:
	# Jalan raya pesisir utama (horizontal, 4 lajur aspal lebar + garis putus putih tengah, Gambar 6).
	for x in range(MAP_W):
		for y in [8, 9, 10, 11]:
			ground.set_cell(Vector2i(x, y), 2, T_ASPHALT[_hash(x, y, 2) % 3], 0)
		ground.set_cell(Vector2i(x, 9), 2, T_DASH_H, 0)

	# Kanstin trotoar beton pada tepi atas (y=7) dan bawah (y=12) jalan raya.
	for x in range(MAP_W):
		ground.set_cell(Vector2i(x, 7), 2, T_CURB_DOWN, 0)
		if not (x in [20, 21, 22]):
			ground.set_cell(Vector2i(x, 12), 2, T_CURB_UP, 0)

	# Zebra cross penyeberangan di depan gang pemukiman dan akses jembatan pesisir.
	for cx in [20, 36]:
		for x in [cx, cx + 1, cx + 2]:
			for y in [8, 9, 10, 11]:
				ground.set_cell(Vector2i(x, y), 2, T_CROSS_V, 0)

	# Trotoar pejalan kaki lebar & mulus di sepanjang sisi utara jalan raya (y=6).
	for x in range(MAP_W):
		ground.set_cell(Vector2i(x, 6), 2, T_WALK[_hash(x, 6) % T_WALK.size()], 0)

	# Akses jalan / trotoar beton dari pintu deret rumah utara ke trotoar jalan raya (y=4..5), lebar 4 petak seukuran rumah (Gambar 8).
	for col in [6, 15, 25, 36, 45, 54]:
		for y in range(4, 6):
			ground.set_cell(Vector2i(col - 1, y), 2, T_CURB_RIGHT, 0)
			ground.set_cell(Vector2i(col, y), 2, T_WALK[_hash(col, y) % T_WALK.size()], 0)
			ground.set_cell(Vector2i(col + 1, y), 2, T_WALK[_hash(col + 1, y, 5) % T_WALK.size()], 0)
			ground.set_cell(Vector2i(col + 2, y), 2, T_CURB_LEFT, 0)

	# Jalur beton dari jalan raya menuju jembatan kayu pesisir (x=20..22, y=12..13).
	for y in range(12, 14):
		for x in [20, 21, 22]:
			ground.set_cell(Vector2i(x, y), 2, T_WALK[_hash(x, y) % T_WALK.size()], 0)

	# Got dan manhole di sepanjang tepi jalan pesisir.
	for p in [Vector2i(12, 12), Vector2i(28, 12), Vector2i(45, 12)]:
		ground.set_cell(p, 2, T_DRAIN, 0)
	for p in [Vector2i(23, 9), Vector2i(52, 10)]:
		ground.set_cell(p, 2, T_MANHOLE, 0)

	# Jalur dari jembatan ke pantai selatan (tanah & papan kayu pantai).
	for y in range(18, 23):
		for x in [20, 21, 22]:
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)

	# Jalan setapak di sepanjang pantai mangrove (y=24)
	for x in range(4, 42):
		ground.set_cell(Vector2i(x, 24), 0, Vector2i(4 + _hash(x, 24) % 2, 0), 0)
	for x in range(50, 56):
		ground.set_cell(Vector2i(x, 24), 0, Vector2i(4 + _hash(x, 24) % 2, 0), 0)

	# Garis tepi rumput-pasir organik di perbatasan pantai (ditangani 47-blob autotile pasir).
	for x in range(MAP_W):
		_paint_sand_cell(x, 23)
	# Pantai berpasir pesisir selatan (y=24 sampai ujung bawah peta, bersih tanpa potongan air laut).
	for x in range(MAP_W):
		for y in range(24, MAP_H):
			var roll: int = _hash(x, y, 29)
			var atlas := Vector2i(4 + _hash(x, y) % 2, 1)
			if (y % 5 == 0) and roll < 75:
				atlas = Vector2i(4, 7)  # lumpur pasang surut
			elif (y % 6 == 0) and roll >= 935:
				atlas = Vector2i(5, 7)  # tanah retak kering
			ground.set_cell(Vector2i(x, y), 0, atlas, 0)

func _paint_door_path(x_left: int, x_right: int, y_top: int, y_bottom: int = 13) -> void:
	for y in range(y_top, y_bottom + 1):
		for x in range(x_left, x_right + 1):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)

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
	var water_cells: Dictionary = {}

	# Aliran sungai hulu diperlebar (x=25..33, 9 petak = 144px, Gambar 1/4)
	for y in range(0, 20):
		for x in range(25, 34):
			water_cells[Vector2i(x, y)] = true

	# Belokan sungai ke timur di sisi selatan (rows 25..29) menyambung utuh dengan Desa!
	var bend_rows: Dictionary = {
		20: Vector2i(25, 36),
		21: Vector2i(26, 40),
		22: Vector2i(27, 46),
		23: Vector2i(28, 54),
		24: Vector2i(28, MAP_W),
		25: Vector2i(27, MAP_W),
		26: Vector2i(26, MAP_W),
		27: Vector2i(26, MAP_W),
		28: Vector2i(26, MAP_W),
		29: Vector2i(26, MAP_W),
	}
	for y in bend_rows.keys():
		var span: Vector2i = bend_rows[y]
		for x in range(span.x, span.y):
			water_cells[Vector2i(x, y)] = true

	# Mata air: kolam lonjong di hulu, menyatu dengan aliran sungai lebar.
	var pond_center := Vector2(29.0, 5.0)
	var pond_radius := Vector2(7.5, 4.0)
	for y in range(0, 10):
		for x in range(20, 38):
			var dx: float = float(x) + 0.5 - pond_center.x
			var dy: float = float(y) + 0.5 - pond_center.y
			var nx: float = dx / pond_radius.x
			var ny: float = dy / pond_radius.y
			var angle: float = atan2(ny, nx)
			var wobble: float = 1.0 + 0.10 * sin(angle * 3.0 + 0.9) + 0.06 * sin(angle * 5.0 - 1.3)
			if nx * nx + ny * ny <= wobble * wobble:
				water_cells[Vector2i(x, y)] = true

	# Air sungai + jembatan kayu lebar 4 lajur (rows 13..16, columns 24..34) di jalan utama.
	for cell: Vector2i in water_cells.keys():
		if cell.y >= PATH_ROW - 2 and cell.y <= PATH_ROW + 1:
			_paint_bridge_cell(cell.x, cell.y)
		else:
			_paint_water_cell(cell.x, cell.y)

	# Ujung jembatan menapak daratan di sisi barat (x=24) dan timur (x=34)
	for y in range(PATH_ROW - 2, PATH_ROW + 2):
		_paint_bridge_cell(24, y)
		_paint_bridge_cell(34, y)

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
				if n.y >= PATH_ROW - 2 and n.y <= PATH_ROW + 1:
					continue
				_paint_sand_cell(n.x, n.y)

func _water_desa() -> void:
	# Sungai lebar di sisi selatan desa (rows 26..29, 4 petak = 64px lebar air).
	for x in range(MAP_W):
		for y in range(26, 30):
			_paint_water_cell(x, y)
		_paint_sand_cell(x, 25)
		_paint_sand_cell(x, 30)

func _water_hilir() -> void:
	var water_cells: Dictionary = {}

	# Aliran sungai masuk dari Kota Medan melintasi Hilir dari barat ke timur (rows 14..17)
	for x in range(MAP_W):
		var top: int = int(round(14.0 + sin(float(x) * 0.12) * 0.5))
		var bot: int = top + 3
		for y in range(top, bot + 1):
			water_cells[Vector2i(x, y)] = true

	# Jembatan kayu di x=20..22, rows 14..18 menghubungkan desa utara ke pantai selatan
	for cell: Vector2i in water_cells.keys():
		if cell.x in [20, 21, 22] and cell.y >= 14 and cell.y <= 18:
			_paint_bridge_cell(cell.x, cell.y)
		else:
			_paint_water_cell(cell.x, cell.y)

	# Tepi pasir mengikuti kontur sungai tanpa menimpa jalan (y=8..11)
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
				if n.y in [8, 9, 10, 11]:
					continue
				_paint_sand_cell(n.x, n.y)

# ─── Decorations ─────────────────────────────────────────────────────────────

func _is_open_grass(x: int, y: int) -> bool:
	if x < 1 or x >= MAP_W - 1 or y < 1 or y >= MAP_H - 1:
		return false
	var p_row: int = 10 if theme == "hilir" else PATH_ROW
	if y >= p_row - 3 and y <= p_row + 2:
		return false
	# Jangan menaruh semak/batu di atas air atau jembatan.
	if water.get_cell_source_id(Vector2i(x, y)) != -1:
		return false
	if bridge.get_cell_source_id(Vector2i(x, y)) != -1:
		return false
	if ground.get_cell_source_id(Vector2i(x, y)) != 0:
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
	if theme == "hilir":
		for i in range(18):
			var x: int = 2 + _hash(i, 19, 7) % (MAP_W - 4)
			var y: int = 24 + _hash(i, 23, 11) % 3
			var c := Vector2i(x, y)
			if water.get_cell_source_id(c) == -1 and is_sand_cell(ground, c):
				_decor.set_cell(c, 0, Vector2i(6, 7), 0)  # kerikil & kerang pantai

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
			# Rumah MC beratap hijau + rumah teras pot bunga warga di sisi kampung hulu.
			spawn_building(get_parent(), "res://assets/sprites/props/house_mc.png", Vector2(112, 160), Vector2(92, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_terrace_pots.png", Vector2(272, 160), Vector2(104, 22), 0.44)

			# Pegangan jembatan kayu Hulu (sisi atas dan sisi bawah jembatan, Gambar 5)
			_spawn_bridge_rail(Vector2(29.0 * TILE, 12.5 * TILE), true)
			_spawn_bridge_rail(Vector2(29.0 * TILE, 17.0 * TILE), false)

			# Pohon dirapikan mengelompok: ragam pohon alami (pohon mangga dikurangi drastis agar tidak berulang)
			_spawn_typed_trees([
				# Bingkai barat & peneduh halaman utara (jauh dari jalan)
				[Vector2(40, 80), "beringin"], [Vector2(36, 130), "pisang"], [Vector2(192, 140), "pisang"],
				# Padang rumput selatan kampung barat (aman di daratan padat, jauh dari sungai)
				[Vector2(40, 360), "pepaya"], [Vector2(180, 360), "kamboja"],
				[Vector2(260, 370), "beringin"], [Vector2(120, 390), "rindang"], [Vector2(320, 390), "kelapa"],
				# Kawasan hutan timur (mengelilingi titik tanam reboisasi & tepi sungai utara)
				[Vector2(616, 50), "pinus"], [Vector2(688, 48), "beringin"], [Vector2(768, 50), "kamboja"],
				[Vector2(848, 50), "cemara"], [Vector2(912, 60), "kelapa"],
				[Vector2(916, 110), "pisang"], [Vector2(916, 150), "kamboja"],
				[Vector2(600, 200), "kelapa"], [Vector2(680, 210), "mangga"], [Vector2(880, 200), "beringin"],
			])
		"desa":
			# Deret utara: Toko Jaya Pak Darwis dan deretan rumah warga berjarak lega (tidak mepet)
			spawn_building(get_parent(), "res://assets/sprites/props/warung_toko_jaya.png", Vector2(180, 160), Vector2(96, 22), 0.4)
			spawn_building(get_parent(), "res://assets/sprites/props/house_cottage_orange.png", Vector2(340, 160), Vector2(104, 22), 0.45)
			spawn_building(get_parent(), "res://assets/sprites/props/house_seng_gate.png", Vector2(500, 160), Vector2(102, 22), 0.42)
			spawn_building(get_parent(), "res://assets/sprites/props/house_cabin_blue.png", Vector2(660, 160), Vector2(104, 22), 0.45)
			spawn_building(get_parent(), "res://assets/sprites/props/house_seng_motor.png", Vector2(820, 160), Vector2(104, 22), 0.44)

			# Deret selatan: warung dan rumah menghadap jalan utama & sungai selatan
			spawn_building(get_parent(), "res://assets/sprites/props/warung_madura.png", Vector2(110, 368), Vector2(92, 22), 0.4)
			spawn_building(get_parent(), "res://assets/sprites/props/house_brick.png", Vector2(270, 368), Vector2(92, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/warung_kios_snack.png", Vector2(430, 368), Vector2(98, 22), 0.42)
			spawn_building(get_parent(), "res://assets/sprites/props/warung_bu_sri.png", Vector2(650, 368), Vector2(100, 22), 0.36)
			spawn_building(get_parent(), "res://assets/sprites/props/house_modern_garage.png", Vector2(850, 368), Vector2(110, 22), 0.44)

			# Pohon di sekitar rumah utara & sudut pekarangan (diatur di celah antar-rumah yang luas)
			_spawn_typed_trees([
				# Di pintu masuk kampung barat & celah antar-rumah utara yang lega
				[Vector2(60, 95), "beringin"],
				[Vector2(260, 105), "pinus"],
				[Vector2(420, 105), "spruce_tall"],
				[Vector2(580, 105), "cemara"],
				[Vector2(740, 110), "spruce"],
				# Bingkai sudut pekarangan timur
				[Vector2(900, 105), "cemara"],
				# Tepian sungai selatan (pohon di samping pekarangan rumput bersih)
				[Vector2(48, 410), "kelapa"], [Vector2(325, 368), "rindang"], [Vector2(704, 410), "beringin"], [Vector2(912, 410), "kelapa"],
			])
		"hilir":
			# Kampung pesisir muara
			spawn_building(get_parent(), "res://assets/sprites/props/house_coastal.png", Vector2(112, 64), Vector2(78, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_suburban_blue.png", Vector2(256, 64), Vector2(108, 22), 0.4)
			spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(416, 64), Vector2(88, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/house_suburban_lshape.png", Vector2(576, 64), Vector2(108, 22), 0.4)
			spawn_building(get_parent(), "res://assets/sprites/props/market_ikan.png", Vector2(736, 68), Vector2(110, 22), 0.42)
			spawn_building(get_parent(), "res://assets/sprites/props/house_suburban_canopy.png", Vector2(880, 64), Vector2(104, 22), 0.4)
			# Pagar pengaman jembatan kayu pesisir (sisi kiri dan kanan, melintasi sungai rows 14..18)
			_spawn_wood_bridge_rail_vertical(Vector2(318, 264), true)
			_spawn_wood_bridge_rail_vertical(Vector2(369, 264), false)
			# Pohon pesisir ditata di celah antar-rumah & pekarangan selatan (bebas tumpang tindih)
			_spawn_typed_trees([
				[Vector2(40, 50), "kelapa"], [Vector2(178, 56), "kelapa"], [Vector2(336, 50), "pisang"],
				[Vector2(496, 50), "pepaya"], [Vector2(945, 50), "kelapa"],
				[Vector2(96, 260), "kelapa"], [Vector2(288, 260), "kelapa"],
				[Vector2(560, 260), "kelapa"], [Vector2(904, 260), "kelapa"],
			])
			for pos in [Vector2(120, 360), Vector2(480, 360), Vector2(720, 360), Vector2(60, 350)]:
				_spawn_mangrove(pos)

			# Lampu jalan aspal pesisir, hidran, dan bangku (berkolisi solid di pangkalnya, Gambar 9)
			for lx in [80, 320, 500, 720]:
				_spawn_city_prop("lamp.png", Vector2(lx, 114))
			for lx in [140, 440, 680]:
				_spawn_city_prop("lamp.png", Vector2(lx, 194))
			_spawn_city_prop("hydrant.png", Vector2(340, 194))
			_spawn_city_prop("bench.png", Vector2(640, 194))

func _spawn_wood_bridge_rail_vertical(pos: Vector2, is_left: bool) -> void:
	var tex_path := "res://assets/sprites/props/bridge_rail_wood_left.png" if is_left else "res://assets/sprites/props/bridge_rail_wood_right.png"
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

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(6, 80)
	col.shape = shape
	col.position = Vector2(0, 0)
	body.add_child(col)

	get_parent().add_child.call_deferred(body)

func _spawn_bridge_rail(pos: Vector2, _is_top: bool) -> void:
	var texture: Texture2D = load("res://assets/sprites/props/bridge_rail_wood.png")
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

	var col := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = Vector2(10 * TILE, 6)
	col.shape = shape
	col.position = Vector2(0, 0)
	body.add_child(col)

	get_parent().add_child.call_deferred(body)

func _spawn_city_prop(prop: String, pos: Vector2) -> void:
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
		"rail.png":
			shape.size = Vector2(6, 60)
			col.position = Vector2(0, -30)
		_:
			shape.size = Vector2(8, 6)
			col.position = Vector2(0, -3)
	col.shape = shape
	body.add_child(col)

	get_parent().add_child.call_deferred(body)

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
	var tuck_src: int = int(round(BUILDING_ROOF_TUCK_PX / sprite_scale))
	var min_wall_src: int = maxi(0, h - int(round(24.0 / sprite_scale)))
	# Beri ruang 3/4 di bagian atas atap agar kaki/bawah baju bisa masuk tipis di balik atap secara natural.
	var col_solid_top: Array[int] = []
	col_solid_top.resize(w)
	for x in range(w):
		var top_y: int = -1
		for y in range(h):
			if img.get_pixel(x, y).a > 0.2:
				top_y = y
				break
		col_solid_top[x] = mini(top_y + tuck_src, min_wall_src) if top_y >= 0 else h

	var bands: Array[Dictionary] = []
	for y0 in range(0, h, BUILDING_BAND_SRC_PX):
		var y1: int = mini(h, y0 + BUILDING_BAND_SRC_PX)
		var lx: int = w
		var rx: int = -1
		for y in range(y0, y1):
			for x in range(w):
				if y >= col_solid_top[x] and img.get_pixel(x, y).a > 0.2:
					if x < lx:
						lx = x
					if x > rx:
						rx = x
		if rx < lx:
			continue
		var world_w: float = float(rx - lx + 1) * sprite_scale
		# Abaikan puncak cerobong tipis di baris paling atas agar bagian belakang atap tetap rata dan mulus dilewati.
		if bands.is_empty() and world_w < 18.0:
			continue
		var side_lx: float = (float(lx) - float(w) * 0.5) * sprite_scale + BUILDING_SIDE_INSET_PX
		var side_rx: float = (float(rx + 1) - float(w) * 0.5) * sprite_scale - BUILDING_SIDE_INSET_PX
		if side_rx - side_lx < 8.0:
			continue
		bands.append({
			"y0": (float(y0) - float(h)) * sprite_scale,
			"y1": (float(y1) - float(h)) * sprite_scale,
			"lx": side_lx,
			"rx": side_rx,
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

func _spawn_typed_trees(entries: Array) -> void:
	for entry in entries:
		var pos: Vector2 = entry[0]
		var kind: String = str(entry[1])
		var hw: float = 40.0 if kind == "beringin" else 18.0
		# Pastikan tidak ada akar kiri, batang tengah, atau akar kanan yang menjuntai ke air sungai
		var touches_water := false
		for check_x in [pos.x - hw, pos.x, pos.x + hw]:
			for check_y in [pos.y - 12.0, pos.y, pos.y + 4.0]:
				if is_in_water(Vector2(check_x, check_y)):
					touches_water = true
					break
			if touches_water:
				break
		if touches_water:
			continue
		spawn_tree(get_parent(), pos, kind)

## Memunculkan sprite pohon bervariasi (kelapa, mangga, pisang, beringin, pepaya, kamboja) dengan kolisi batang di pangkal.
static func spawn_tree(parent: Node, pos: Vector2, kind: String = "rindang") -> void:
	if parent == null:
		return
	var spec: Dictionary = TREE_SPECS.get(kind, TREE_SPECS["rindang"])
	var texture: Texture2D = load(str(spec["path"]))
	var sprite_scale: float = float(spec["scale"])
	var col_size: Vector2 = spec["col"]
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.position = Vector2(0, -texture.get_height() * 0.5 * sprite_scale)
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = col_size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -col_size.y * 0.5)
	body.add_child(col)
	parent.add_child.call_deferred(body)

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
			if not is_sand_cell(ground, cell):
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
