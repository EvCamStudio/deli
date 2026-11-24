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
const BUILDING_WALL_BOTTOM_TUCK_PX: float = 6.0
const BUILDING_SIDE_INSET_PX: float = 2.0

const TREE_SPECS: Dictionary = {
	"kelapa": {"path": "res://assets/sprites/props/tree_tall_kelapa.png", "scale": 0.5, "col": Vector2(14, 8)},
	"palem": {"path": "res://assets/sprites/props/tree_tall_palem.png", "scale": 0.5, "col": Vector2(14, 8)},
	"mangga": {"path": "res://assets/sprites/props/tree_tall_broadleaf.png", "scale": 0.5, "col": Vector2(16, 8)},
	"pisang": {"path": "res://assets/sprites/props/tree_tall_palem.png", "scale": 0.5, "col": Vector2(14, 8)},
	"pepaya": {"path": "res://assets/sprites/props/tree_tall_palem.png", "scale": 0.5, "col": Vector2(14, 8)},
	"kamboja": {"path": "res://assets/sprites/props/tree_tall_forest.png", "scale": 0.5, "col": Vector2(16, 8)},
	"beringin": {"path": "res://assets/sprites/props/tree_tall_beringin.png", "scale": 0.5, "col": Vector2(26, 10)},
	"willow": {"path": "res://assets/sprites/props/tree_tall_willow.png", "scale": 0.5, "col": Vector2(20, 10)},
	"forest": {"path": "res://assets/sprites/props/tree_tall_forest.png", "scale": 0.5, "col": Vector2(16, 8)},
	"leafy": {"path": "res://assets/sprites/props/tree_tall_leafy.png", "scale": 0.5, "col": Vector2(16, 8)},
	"broadleaf": {"path": "res://assets/sprites/props/tree_tall_broadleaf.png", "scale": 0.5, "col": Vector2(16, 8)},
	"pinus": {"path": "res://assets/sprites/props/tree_tall_pinus.png", "scale": 0.5, "col": Vector2(14, 8)},
	"cemara": {"path": "res://assets/sprites/props/tree_tall_cemara.png", "scale": 0.5, "col": Vector2(14, 8)},
	"spruce_tall": {"path": "res://assets/sprites/props/tree_tall_pinus.png", "scale": 0.5, "col": Vector2(16, 8)},
	"spruce": {"path": "res://assets/sprites/props/tree_tall_cemara.png", "scale": 0.5, "col": Vector2(14, 8)},
	"rindang": {"path": "res://assets/sprites/props/tree_tall_rindang.png", "scale": 0.5, "col": Vector2(16, 8)},
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
	var mud_tex: Texture2D = load("res://assets/tilesets/hilir_mud_tileset.png")
	if mud_tex != null:
		var mud_source := TileSetAtlasSource.new()
		mud_source.texture = mud_tex
		mud_source.texture_region_size = Vector2i(32, 32)
		for y in range(8):
			for x in range(8):
				mud_source.create_tile(Vector2i(x, y))
		ts.add_source(mud_source, 3)
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
			if theme == "hulu" and x >= 38 and x <= 55 and y >= 5 and y <= 12:
				atlas = Vector2i(_hash(x, y) % 3, 0)  # Padang rumput hijau murni tanpa bercak bunga liar di kawasan reboisasi bukit
			elif roll < 95:
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
	_paint_door_path(41, 42, 11, 13) # house_cozy_red (x=660)
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

	# Hamparan tanah berlumpur alami kawasan mangrove muara (y=18..27, habitat asli pohon bakau pesisir diperluas).
	# Menggantikan rumput hijau & pasir dengan ubin lumpur organik mulus dari hilir_mud_tileset (Source 3) sampai tempat MC berdiri.
	for y in range(18, 28):
		for x in range(MAP_W):
			if x in [20, 21, 22]:
				# Jalur dari jembatan ke pantai selatan (tanah & papan kayu pantai).
				ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)
			else:
				var roll: int = _hash(x, y, 17)
				var mud_atlas: Vector2i
				if roll < 700:
					mud_atlas = Vector2i(_hash(x, y) % 8, 1)  # lumpur pasang surut bertekstur mulus
				elif roll < 840:
					mud_atlas = Vector2i(_hash(x, y) % 8, 4)  # tanah lumpur lempung basah
				elif roll < 930:
					mud_atlas = Vector2i(_hash(x, y) % 8, 6)  # variasi lumpur pesisir
				else:
					mud_atlas = Vector2i(_hash(x, y) % 8, 2)  # genangan becek & kerikil kecil alami
				ground.set_cell(Vector2i(x, y), 3, mud_atlas, 0)

	# Garis tepi perbatasan pantai pasir (y=28)
	for x in range(MAP_W):
		_paint_sand_cell(x, 28)
	# Sisa pantai berpasir pesisir selatan (y=28 sampai ujung bawah peta, disisakan sedikit sesuai instruksi user).
	for x in range(MAP_W):
		for y in range(28, MAP_H):
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
	var pond_center := Vector2(30.0, 5.0)
	var pond_radius := Vector2(5.0, 4.0)
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
				if n.y in [8, 9, 10, 11] or (n.y >= 18 and n.y <= 22):
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
		if theme == "hulu" and x >= 38 and x <= 55 and y >= 5 and y <= 13:
			continue  # Bebaskan kawasan bukit reboisasi dari semua semak, bunga, pakis, dan batu agar bersih & rapi
		var mod: int = i % 6
		var atlas: Vector2i
		if mod <= 1:
			atlas = Vector2i(6, 5)  # semanggi & bunga kecil transparan
		elif mod == 2:
			atlas = Vector2i(7, 5)  # pakis rimba hulu/desa
		elif mod == 3 or mod == 4:
			atlas = Vector2i(6, 2)  # semak rimbun
		else:
			atlas = Vector2i(7, 2)  # batu berlumut
		# Jika ada batu di cell ini, pastikan tidak tertimpa decor semak lain di cell yang sama
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
			# Rumah MC beratap hijau + rumah warga berpagar kayu di sisi kampung hulu.
			spawn_building(get_parent(), "res://assets/sprites/props/house_mc.png", Vector2(112, 160), Vector2(92, 22), 0.5)
			# Pagar teras kayu rumah MC (sisi kiri teras x=78.5..110.0):
			# MC dilarang menembus pagar teras kayu (Gambar 1).
			# Kolisi diposisikan presisi di bibir teras agar MC berhenti pas di depan pagar tanpa jarak kosong terlalu jauh.
			# Pintu masuk di sisi kanan teras (x=110..130) tetap terbuka sehingga MC bisa menapak teras sampai depan pintu tanpa tembus dinding (Gambar 2).
			_add_collision(Vector2(94.25, 154.5), Vector2(31.5, 9.0))
			spawn_building(get_parent(), "res://assets/sprites/props/house_cabin_blue.png", Vector2(272, 160), Vector2(104, 22), 0.45)

			# Pegangan jembatan kayu Hulu (sisi atas dan sisi bawah jembatan, Gambar 5)
			_spawn_bridge_rail(Vector2(29.0 * TILE, 12.5 * TILE), true)
			_spawn_bridge_rail(Vector2(29.0 * TILE, 17.0 * TILE), false)

			# Batas rintangan alam (pemain hanya bisa berjalan di pekarangan rumah & jalur jelajah, tidak bisa menerobos hutan utara & rimba selatan)
			_add_collision(Vector2(165, 95), Vector2(330, 20))       # Tembok hutan utara di belakang rumah MC & tetangga (x=0..330)
			_add_collision(Vector2(335, 60), Vector2(10, 120))       # Sekat batas kanan hutan utara dari jalur tepian sungai (Gambar 1)
			_add_collision(Vector2(165, 20), Vector2(330, 20))       # Sekat batas atas rimba utara agar MC tidak menerobos masuk kanopi dari atas (Gambar 6)
			_add_collision(Vector2(188, 95), Vector2(48, 20))        # Sekat celah belakang antar-rumah (semak & rumput depan bebas dijelajahi sampai menyentuh flora, Gambar 3)
			_add_collision(Vector2(25, 110), Vector2(50, 20))        # Sisi barat rumah MC ditutup vegetasi lebat
			_add_collision(Vector2(170, 355), Vector2(340, 20))      # Tembok hutan selatan di padang rumput barat (x=0..340)
			_add_collision(Vector2(342, 430), Vector2(10, 160))      # Sekat batas rimba selatan dari jalur tepian sungai barat (Gambar 5)
			# Batas utara kawasan reboisasi timur (Gambar 1 user: batas depan kanopi pohon y=25)
			_add_collision(Vector2(760, 35), Vector2(400, 24))
			# Dinding transparan batas kanan kawasan reboisasi timur dekat pohon kelapa (Gambar 2 user: batas x=932..934)
			_add_collision(Vector2(924, 115), Vector2(16, 170))
			_add_collision(Vector2(760, 355), Vector2(400, 20))      # Batas rimba selatan timur

			# Pohon Hulu: hutan rimbun berlapis multi-kedalaman tanpa area kosong gundul
			# (Koridor pinggiran sungai barat x=345..395 dibuat bersih & leluasa dijelajahi pemain sepanjang tepi air)
			_spawn_typed_trees([
				# ─── Hutan Utara Lebat (Lapis Latar Belakang & Peneduh Belakang Rumah) ───
				# Baris 1: Latar kanopi rimba utara terdalam (y=20..25)
				[Vector2(20, 22), "pinus"], [Vector2(55, 20), "rindang"], [Vector2(95, 18), "forest"],
				[Vector2(135, 22), "beringin"], [Vector2(175, 18), "cemara"], [Vector2(215, 22), "leafy"],
				[Vector2(255, 18), "rindang"], [Vector2(295, 22), "willow"], [Vector2(325, 22), "cemara"],

				# Baris 2: Lapis tengah rimba utara (y=42..48)
				[Vector2(35, 45), "beringin"], [Vector2(75, 42), "willow"], [Vector2(115, 45), "rindang"],
				[Vector2(155, 42), "forest"], [Vector2(195, 45), "broadleaf"], [Vector2(235, 42), "leafy"],
				[Vector2(275, 45), "pinus"], [Vector2(315, 42), "rindang"], [Vector2(320, 45), "willow"],

				# Baris 3: Tepian hutan di belakang & sela rumah warga (y=65..85)
				[Vector2(30, 80), "rindang"], [Vector2(70, 70), "forest"],
				[Vector2(112, 65), "beringin"], # Menjulang megah di belakang atap rumah MC
				[Vector2(150, 72), "pinus"],
				[Vector2(188, 75), "willow"],   # Mengisi penuh celah tengah antar-rumah
				[Vector2(192, 105), "palem"],   # Menutup celah tengah dengan daun palem rindang
				[Vector2(235, 72), "leafy"],
				[Vector2(272, 65), "rindang"],  # Menjulang megah di belakang atap rumah merah tetangga
				[Vector2(315, 72), "cemara"],
				[Vector2(325, 75), "beringin"], # Menjulang di sudut kanan belakang rumah merah
				[Vector2(30, 120), "broadleaf"],# Sudut pekarangan kiri barat rumah MC

				# ─── Hutan Selatan Hulu (Pemandangan Pohon Ditebang di Belakang/Selatan Rumah MC, Gambar 2 User) ───
				# Baris 1: Sebagian besar ditebang, disisakan sedikit pohon berdiri alami di tepi
				[Vector2(25, 350), "cemara"], [Vector2(185, 350), "willow"], [Vector2(325, 350), "kelapa"],

				# Baris 2: Lapis dalam hutan selatan (sebagian ditebang menyisakan tunggul & kayu)
				[Vector2(35, 410), "rindang"], [Vector2(165, 415), "forest"], [Vector2(300, 410), "cemara"],

				# Baris 3: Lapis lebat bawah hutan selatan (y=455..460)
				[Vector2(20, 455), "broadleaf"], [Vector2(60, 460), "cemara"], [Vector2(100, 455), "forest"],
				[Vector2(145, 460), "beringin"], [Vector2(190, 455), "willow"], [Vector2(235, 460), "rindang"],
				[Vector2(280, 455), "palem"], [Vector2(325, 460), "leafy"],

				# Baris 4: Lapis batas bawah peta selatan (y=495)
				[Vector2(40, 495), "pinus"], [Vector2(85, 495), "rindang"], [Vector2(130, 495), "cemara"],
				[Vector2(175, 495), "forest"], [Vector2(220, 495), "beringin"], [Vector2(265, 495), "willow"],
				[Vector2(310, 495), "broadleaf"], [Vector2(325, 495), "palem"],

				# ─── Kawasan Hutan Timur (Reboisasi Bukit & Hutan Tenggara) ───
				# Latar belakang utara kawasan reboisasi (y=20..30 & y=48..55)
				[Vector2(600, 25), "pinus"], [Vector2(640, 25), "broadleaf"], [Vector2(680, 20), "forest"],
				[Vector2(720, 25), "beringin"], [Vector2(760, 20), "cemara"], [Vector2(800, 25), "leafy"],
				[Vector2(840, 20), "rindang"], [Vector2(880, 25), "pinus"], [Vector2(920, 25), "cemara"],
				[Vector2(616, 50), "pinus"], [Vector2(650, 48), "broadleaf"], [Vector2(688, 48), "beringin"],
				[Vector2(768, 50), "forest"], [Vector2(848, 50), "cemara"], [Vector2(912, 60), "kelapa"],
				[Vector2(916, 110), "palem"], [Vector2(916, 150), "leafy"], [Vector2(600, 200), "kelapa"],
				[Vector2(880, 200), "beringin"],

				# Rimba tenggara hulu (y=350..480)
				[Vector2(580, 350), "kelapa"], [Vector2(630, 360), "rindang"], [Vector2(680, 350), "forest"],
				[Vector2(730, 360), "beringin"], [Vector2(780, 350), "cemara"], [Vector2(830, 360), "pinus"],
				[Vector2(880, 350), "kelapa"], [Vector2(930, 360), "palem"],
				[Vector2(600, 415), "broadleaf"], [Vector2(650, 420), "willow"], [Vector2(700, 415), "rindang"],
				[Vector2(750, 420), "forest"], [Vector2(800, 415), "leafy"], [Vector2(850, 420), "palem"],
				[Vector2(900, 415), "cemara"],
				[Vector2(580, 475), "cemara"], [Vector2(640, 480), "pinus"], [Vector2(700, 475), "beringin"],
				[Vector2(780, 480), "rindang"], [Vector2(840, 475), "willow"], [Vector2(900, 480), "kelapa"],
			])
			# Semak, tanaman liar, dan kayu rimba alami (rapat, rimbun, dan estetis)
			_spawn_flora_entries([
				# Semak di pekarangan & penutup sela rumah (koridor tepian sungai x=335..395 STERIL dari semak pemblokir)
				[Vector2(35, 140), "bush_large_green.png", 0.35],
				[Vector2(65, 185), "bush_small_flower.png", 0.35],
				[Vector2(175, 126), "bush_round_green.png", 0.35],
				[Vector2(188, 124), "bush_large_green.png", 0.35],
				[Vector2(202, 126), "bush_small_green.png", 0.35],
				[Vector2(195, 185), "bush_flowering_white.png", 0.35],

				# ─── Pemandangan Pohon Ditebang di Hutan Selatan MC (Tunggul, Kayu Gelondongan, Ranting, Gambar 2 User) ───
				[Vector2(65, 355), "prop_stump_tree.png", 0.38],
				[Vector2(95, 365), "prop_log_wood.png", 0.35],
				[Vector2(105, 350), "prop_stump_tree.png", 0.38],
				[Vector2(145, 365), "prop_stump_tree.png", 0.38],
				[Vector2(205, 365), "prop_log_wood.png", 0.35],
				[Vector2(225, 355), "prop_stump_tree.png", 0.38],
				[Vector2(265, 350), "prop_stump_tree.png", 0.38],
				[Vector2(285, 365), "prop_fallen_branches.png", 0.38],
				[Vector2(305, 360), "prop_stump_tree.png", 0.38],
				[Vector2(75, 415), "prop_stump_tree.png", 0.38],
				[Vector2(120, 415), "prop_log_wood.png", 0.35],
				[Vector2(210, 415), "prop_fallen_branches.png", 0.38],
				[Vector2(255, 415), "prop_stump_tree.png", 0.38],
				[Vector2(320, 415), "prop_log_wood.png", 0.35],
				[Vector2(85, 345), "flora_flower_yellow.png", 0.30],
				[Vector2(150, 365), "flora_flower_red.png", 0.30],
				[Vector2(225, 340), "flora_flower_purple.png", 0.30],
				[Vector2(300, 355), "flora_flower_white.png", 0.30],
				[Vector2(110, 380), "flora_grass_medium.png", 0.35],
				[Vector2(50, 430), "prop_stump_tree.png", 0.38],
				[Vector2(140, 435), "prop_log_wood.png", 0.35],
				[Vector2(230, 425), "prop_fallen_branches.png", 0.38],
				[Vector2(310, 430), "flora_grass_dense.png", 0.35],
				[Vector2(80, 475), "bush_large_green.png", 0.35],
				[Vector2(170, 470), "flora_grass_tall.png", 0.35],
				[Vector2(260, 475), "bush_round_green.png", 0.35],
				[Vector2(310, 470), "prop_log_wood.png", 0.35],

				# Kawasan bukit timur / reboisasi (pemandangan pohon ditebang: tunggul, kayu gelondongan & ranting di tepi plot)
				[Vector2(675, 80), "prop_stump_tree.png", 0.38],
				[Vector2(710, 75), "prop_log_wood.png", 0.35],
				[Vector2(750, 85), "prop_fallen_branches.png", 0.38],
				[Vector2(790, 80), "prop_stump_tree.png", 0.38],
				[Vector2(835, 75), "prop_log_wood.png", 0.35],
				[Vector2(870, 95), "prop_stump_tree.png", 0.38],
				[Vector2(860, 140), "prop_fallen_branches.png", 0.38],
				[Vector2(635, 135), "prop_log_wood.png", 0.35],
				[Vector2(845, 150), "prop_stump_tree.png", 0.38],
				[Vector2(880, 150), "prop_log_wood.png", 0.35],
				[Vector2(930, 90), "flora_grass_dense.png", 0.35],
				[Vector2(590, 215), "flora_grass_tall.png", 0.35],
				[Vector2(650, 210), "prop_stump_tree.png", 0.38],
				[Vector2(715, 205), "prop_fallen_branches.png", 0.38],
				[Vector2(750, 210), "flora_flower_red.png", 0.30],
				[Vector2(840, 215), "prop_log_wood.png", 0.35],
				[Vector2(885, 200), "prop_stump_tree.png", 0.38],

				# Padang rumput selatan hulu di bawah jalan / bawah map (pohon-pohon ditebang, Gambar 3 user)
				[Vector2(590, 295), "prop_stump_tree.png", 0.38],
				[Vector2(640, 310), "prop_log_wood.png", 0.35],
				[Vector2(695, 290), "prop_stump_tree.png", 0.38],
				[Vector2(745, 315), "prop_fallen_branches.png", 0.38],
				[Vector2(790, 295), "prop_stump_tree.png", 0.38],
				[Vector2(845, 310), "prop_log_wood.png", 0.35],
				[Vector2(670, 345), "prop_log_wood.png", 0.35],
				[Vector2(735, 350), "prop_stump_tree.png", 0.38],
				[Vector2(810, 350), "prop_fallen_branches.png", 0.38],

				# Rimba tenggara
				[Vector2(630, 430), "prop_stump_tree.png", 0.38],
				[Vector2(720, 435), "prop_log_wood.png", 0.35],
				[Vector2(810, 430), "bush_large_green.png", 0.35],
				[Vector2(890, 435), "flora_grass_dense.png", 0.35],
				[Vector2(660, 480), "flora_grass_tall.png", 0.35],
				[Vector2(750, 475), "prop_fallen_branches.png", 0.38],
				[Vector2(840, 480), "bush_round_green.png", 0.35],
			])

			# Lumpur becek di jalan bekas banjir di dekat rumah MC (Visual pasca-banjir, Gambar 1 steril dari tumpukan):
			# 1. Becek lumpur di jalan depan halaman rumah MC (tanpa kolisi, z_index -1 agar diinjak alami)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_mud_puddle_becek.png", Vector2(112, 235), 0.24, false, Vector2.ZERO, Vector2.ZERO, -1)
			# 2. Becek lumpur di jalan utama menuju jembatan timur
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_dirt_patch_becek.png", Vector2(185, 248), 0.24, false, Vector2.ZERO, Vector2.ZERO, -1)
			# 3. Becek di jalan barat
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_mud_puddle_becek.png", Vector2(65, 245), 0.20, false, Vector2.ZERO, Vector2.ZERO, -1)

			# Hamparan lumpur organik alami (aset lumpur tanam mangrove) di sela-sela pohon ditebang di Hulu (Gambar 3 User):
			# z_index = -1 & has_collision = false agar MC menginjak di atas tanah/lumpur secara alami (tidak tenggelam).
			# 1. Padang rumput selatan hulu (Gambar 3 User: menggantikan 2 gundukan tanah dengan lumpur tanam mangrove)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/soil_patch_spot_0.png", Vector2(610, 270), 0.40, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/soil_patch_decor_1.png", Vector2(705, 340), 0.35, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/soil_patch_spot_1.png", Vector2(825, 275), 0.40, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/soil_patch_decor_2.png", Vector2(880, 335), 0.35, false, Vector2.ZERO, Vector2.ZERO, -1)

			# 2. Kawasan bukit reboisasi atas (tempat MC menanam pohon, di dekat pohon-pohon yang sudah ditebang)
			# Tersebar di sekitar tunggul dan batang kayu tepi plot tanpa menimpa 15 titik tanam bibit pohon
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/soil_patch_decor_0.png", Vector2(690, 92), 0.32, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/soil_patch_spot_2.png", Vector2(815, 88), 0.38, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/soil_patch_decor_3.png", Vector2(865, 120), 0.32, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/soil_patch_spot_3.png", Vector2(640, 155), 0.38, false, Vector2.ZERO, Vector2.ZERO, -1)

			# 3. Sampah plastik & kantong sampah di Hulu (Gambar 2 User: Kantong Sampah Hitam & Biru/Putih):
			# Sampah di dekat pekarangan MC (45, 175), dekat jembatan/papan pantun (290, 235), dan dekat gundukan tanah (635, 290) dihapus sesuai gambar user.
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_trash_bags_blue_white.png", Vector2(765, 345), 0.25, true, Vector2(34, 10), Vector2(0, -5))
		"desa":
			# Deret utara: Toko Jaya Pak Darwis dan deretan rumah warga berjarak lega (tidak mepet)
			spawn_building(get_parent(), "res://assets/sprites/props/warung_toko_jaya.png", Vector2(180, 160), Vector2(96, 22), 0.4)
			spawn_building(get_parent(), "res://assets/sprites/props/house_cottage_orange.png", Vector2(340, 160), Vector2(104, 22), 0.45)
			spawn_building(get_parent(), "res://assets/sprites/props/building_kantor_desa.png", Vector2(500, 160), Vector2(110, 22), 0.42)
			spawn_building(get_parent(), "res://assets/sprites/props/house_cozy_red.png", Vector2(660, 160), Vector2(104, 22), 0.44)
			spawn_building(get_parent(), "res://assets/sprites/props/building_mesjid_desa.png", Vector2(820, 160), Vector2(110, 22), 0.40)

			# Tembok transparan pembatas hutan utara Desa (tepat di belakang gedung, y <= 72):
			# Dimundurkan ke belakang gedung (y <= 72), sehingga MC bebas berjalan di samping gedung,
			# dan batasnya tepat berada di belakang gedung agar MC tidak bisa masuk ke daerah pepohonan hutan.
			_add_collision(Vector2(480, 36), Vector2(960, 72))

			# Deret selatan: warung dan rumah menghadap jalan utama & sungai selatan
			spawn_building(get_parent(), "res://assets/sprites/props/warung_madura.png", Vector2(110, 368), Vector2(92, 22), 0.4)
			spawn_building(get_parent(), "res://assets/sprites/props/house_brick.png", Vector2(270, 368), Vector2(92, 22), 0.5)
			spawn_building(get_parent(), "res://assets/sprites/props/warung_sayur_fresh.png", Vector2(460, 364), Vector2(100, 22), 0.42)
			spawn_building(get_parent(), "res://assets/sprites/props/warung_bu_sri.png", Vector2(650, 368), Vector2(100, 22), 0.36)
			spawn_building(get_parent(), "res://assets/sprites/props/house_modern_2story.png", Vector2(850, 368), Vector2(110, 22), 0.42)

			# Pohon Desa: Sedikit pohon peneduh yang tersisa di latar belakang & sela-sela atap rumah
			_spawn_typed_trees([
				# ─── Baris 1: Pohon latar belakang atas yang tersisa (y=18..22) ───
				[Vector2(30, 22), "pinus"],
				[Vector2(140, 20), "beringin"],
				[Vector2(260, 22), "rindang"],
				[Vector2(380, 18), "cemara"],
				[Vector2(500, 22), "forest"],
				[Vector2(620, 18), "broadleaf"],
				[Vector2(750, 22), "pinus"],
				[Vector2(880, 20), "willow"],

				# ─── Baris 2: Pohon lapis tengah yang tersisa (y=44..48) ───
				[Vector2(85, 45), "willow"],
				[Vector2(320, 46), "leafy"],
				[Vector2(570, 44), "rindang"],
				[Vector2(820, 48), "cemara"],

				# ─── Baris 3: Peneduh atap & celah antar-rumah warga Desa (y=70..80) ───
				[Vector2(35, 75), "beringin"],
				[Vector2(265, 80), "pinus"],
				[Vector2(425, 78), "cemara"],
				[Vector2(585, 80), "rindang"],
				[Vector2(745, 80), "beringin"],
				[Vector2(930, 78), "pinus"],

				# Pekarangan selatan: celah luas antar-bangunan
				[Vector2(26, 360), "kelapa"],
				[Vector2(745, 360), "beringin"],
				[Vector2(935, 360), "kelapa"],
			])
			# Flora Desa: Pemandangan hutan ditebang di belakang rumah warga (tunggul, kayu gelondongan, ranting, rumput liar) & taman pekarangan
			_spawn_flora_entries([
				# ─── Pemandangan Pohon Ditebang di Hutan Utara Desa (Tunggul, Kayu Gelondongan, Ranting Patah) ───
				# Area Barat (belakang Toko Jaya & pekarangan barat)
				[Vector2(60, 32), "prop_stump_tree.png", 0.38],
				[Vector2(95, 24), "prop_log_wood.png", 0.35],
				[Vector2(110, 58), "prop_fallen_branches.png", 0.38],
				[Vector2(175, 42), "prop_stump_tree.png", 0.38],
				[Vector2(215, 34), "prop_log_wood.png", 0.35],
				[Vector2(245, 62), "prop_stump_tree.png", 0.38],
				[Vector2(160, 82), "flora_grass_tall.png", 0.35],

				# Area Tengah (belakang Cottage, Kantor Desa & Cozy Red)
				[Vector2(300, 34), "prop_log_wood.png", 0.35],
				[Vector2(340, 48), "prop_stump_tree.png", 0.38],
				[Vector2(370, 72), "prop_fallen_branches.png", 0.38],
				[Vector2(440, 32), "prop_stump_tree.png", 0.38],
				[Vector2(470, 52), "prop_log_wood.png", 0.35],
				[Vector2(515, 72), "prop_stump_tree.png", 0.38],
				[Vector2(550, 38), "prop_fallen_branches.png", 0.38],
				[Vector2(600, 58), "prop_stump_tree.png", 0.38],
				[Vector2(645, 36), "prop_log_wood.png", 0.35],
				[Vector2(675, 68), "prop_stump_tree.png", 0.38],
				[Vector2(480, 82), "flora_grass_dense.png", 0.35],
				[Vector2(630, 82), "flora_grass_tall.png", 0.35],

				# Area Timur (belakang & sudut samping Mesjid)
				[Vector2(715, 38), "prop_log_wood.png", 0.35],
				[Vector2(770, 52), "prop_stump_tree.png", 0.38],
				[Vector2(805, 72), "prop_fallen_branches.png", 0.38],
				[Vector2(845, 36), "prop_stump_tree.png", 0.38],
				[Vector2(865, 62), "prop_log_wood.png", 0.35],
				[Vector2(895, 42), "prop_stump_tree.png", 0.38],
				[Vector2(935, 38), "prop_log_wood.png", 0.35],
				[Vector2(940, 72), "prop_stump_tree.png", 0.38],
				[Vector2(865, 92), "prop_fallen_branches.png", 0.38],
				[Vector2(915, 88), "flora_grass_tall.png", 0.35],

				# ─── Pekarangan Warga Depan Rumah ───
				# Pekarangan utara
				[Vector2(75, 185), "bush_flowering_pink.png", 0.35],
				[Vector2(265, 185), "flora_grass_medium.png", 0.35],
				[Vector2(290, 185), "flora_flower_pink.png", 0.30],
				[Vector2(415, 185), "bush_small_flower.png", 0.35],
				[Vector2(580, 185), "flora_flower_white.png", 0.30],
				[Vector2(740, 185), "bush_round_green.png", 0.35],
				[Vector2(915, 185), "flora_flower_yellow.png", 0.30],
				# Pekarangan selatan (di sela-sela rumput luas antar-toko & pekarangan seimbang Warung Sayur Fresh)
				[Vector2(40, 375), "flora_grass_dense.png", 0.35],
				[Vector2(150, 360), "bush_small_green.png", 0.35],
				[Vector2(395, 364), "bush_small_flower.png", 0.35], # Sisi kiri pekarangan seimbang Warung Sayur
				[Vector2(525, 364), "bush_flowering_pink.png", 0.35], # Sisi kanan pekarangan Warung Sayur (di rumput, bukan di jalan)
				[Vector2(775, 360), "flora_grass_medium.png", 0.35],
				[Vector2(945, 375), "bush_small_flower.png", 0.35],
			])

			# Gundukan tanah di sekitar hutan yang ditebang di belakang rumah warga Desa (z_idx = -1):
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_dirt_mound_forest.png", Vector2(140, 50), 0.26, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_dirt_mound_soil.png", Vector2(395, 45), 0.26, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_dirt_mound_forest.png", Vector2(620, 50), 0.26, false, Vector2.ZERO, Vector2.ZERO, -1)
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_dirt_mound_soil.png", Vector2(790, 42), 0.26, false, Vector2.ZERO, Vector2.ZERO, -1)

			# Sampah lingkungan Desa di pekarangan barat dan lorong utara:
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_trash_pile_box.png", Vector2(50, 370), 0.25, true, Vector2(32, 10), Vector2(0, -5))
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_trash_bags_blue_white.png", Vector2(115, 175), 0.25, true, Vector2(34, 10), Vector2(0, -5))
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_trash_pile_box.png", Vector2(585, 165), 0.25, true, Vector2(32, 10), Vector2(0, -5))
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
			# Pohon pesisir ditata rapi di celah antar-rumah utara & padang rumput pesisir selatan
			_spawn_typed_trees([
				[Vector2(40, 50), "kelapa"], [Vector2(178, 56), "kelapa"], [Vector2(336, 50), "pisang"],
				[Vector2(496, 50), "pepaya"], [Vector2(945, 50), "kelapa"],
				# Pohon kelapa pesisir selatan dimajukan ke sisa pantai pasir selatan (Gambar 11 User)
				[Vector2(100, 470), "kelapa"], [Vector2(280, 475), "kelapa"],
				[Vector2(620, 470), "kelapa"], [Vector2(880, 475), "kelapa"],
			])
			# Rumput pesisir & bunga diatur rapi di luar kawasan pembibitan mangrove
			_spawn_flora_entries([
				# Pekarangan rumput utara
				[Vector2(60, 95), "bush_small_green.png", 0.35],
				[Vector2(925, 95), "bush_round_green.png", 0.35],
				# Vegetasi pesisir (posisi rapi di luar area pembibitan)
				[Vector2(160, 325), "flora_grass_tall.png", 0.35],
				[Vector2(650, 325), "flora_grass_dense.png", 0.35],
				[Vector2(820, 335), "flora_plant_leafy.png", 0.35],
				# Sisa pantai pasir selatan (kayu terdampar / driftwood alami pantai)
				[Vector2(220, 480), "prop_log_wood.png", 0.35],
				[Vector2(640, 480), "prop_fallen_branches.png", 0.35],
			])
			# Rumpun pohon bakau alami mengitari kawasan pembibitan & diperluas ke selatan hingga tempat MC (Gambar 11 User):
			# Sisi Barat muara:
			_spawn_mangrove(Vector2(60, 350), "mature")
			_spawn_mangrove(Vector2(110, 355), "young")
			_spawn_mangrove(Vector2(145, 335), "sprout")
			_spawn_mangrove(Vector2(180, 350), "mature")
			_spawn_mangrove(Vector2(215, 345), "young")
			_spawn_mangrove(Vector2(80, 405), "young")
			_spawn_mangrove(Vector2(135, 420), "sprout")
			_spawn_mangrove(Vector2(180, 410), "mature")
			_spawn_mangrove(Vector2(235, 420), "young")

			# Sisi Tengah selatan (perluasan lumpur coklat di sekitar tempat MC berdiri, lorong jalan kayu steril dari pohon):
			_spawn_mangrove(Vector2(420, 425), "sprout")
			_spawn_mangrove(Vector2(500, 420), "young")
			_spawn_mangrove(Vector2(575, 425), "sprout")

			# Sisi Timur muara:
			_spawn_mangrove(Vector2(680, 350), "mature")
			_spawn_mangrove(Vector2(735, 345), "young")
			_spawn_mangrove(Vector2(775, 335), "sprout")
			_spawn_mangrove(Vector2(830, 350), "mature")
			_spawn_mangrove(Vector2(880, 345), "young")
			_spawn_mangrove(Vector2(665, 410), "young")
			_spawn_mangrove(Vector2(725, 420), "sprout")
			_spawn_mangrove(Vector2(790, 415), "mature")
			_spawn_mangrove(Vector2(850, 420), "young")
			_spawn_mangrove(Vector2(910, 410), "young")

			# Hamparan tanah lumpur alami pesisir mangrove (Gambar 4 & Gambar 11 User)
			var soil_decor_list: Array = [
				[Vector2(80, 355), "res://assets/sprites/props/soil_patch_decor_0.png", 0.35],
				[Vector2(140, 360), "res://assets/sprites/props/soil_patch_decor_1.png", 0.38],
				[Vector2(200, 355), "res://assets/sprites/props/soil_patch_decor_2.png", 0.35],
				[Vector2(670, 355), "res://assets/sprites/props/soil_patch_decor_3.png", 0.38],
				[Vector2(750, 360), "res://assets/sprites/props/soil_patch_decor_4.png", 0.38],
				[Vector2(110, 420), "res://assets/sprites/props/soil_patch_decor_0.png", 0.35],
				[Vector2(540, 420), "res://assets/sprites/props/soil_patch_decor_2.png", 0.35],
				[Vector2(760, 425), "res://assets/sprites/props/soil_patch_decor_3.png", 0.38],
				[Vector2(880, 420), "res://assets/sprites/props/soil_patch_decor_4.png", 0.38],
			]
			for sd in soil_decor_list:
				spawn_environment_prop(get_parent(), sd[1], sd[0], sd[2], false, Vector2.ZERO, Vector2.ZERO, -1)

			# Lampu jalan aspal pesisir, hidran, dan bangku (berkolisi solid di pangkalnya, Gambar 9)
			for lx in [80, 320, 500, 720]:
				_spawn_city_prop("lamp.png", Vector2(lx, 114))
			for lx in [140, 440, 680]:
				_spawn_city_prop("lamp.png", Vector2(lx, 194))
			_spawn_city_prop("hydrant.png", Vector2(340, 194))
			_spawn_city_prop("bench.png", Vector2(640, 208))

			# ─── Sampah Lingkungan Pesisir Hilir Muara (Gambar 4 User: Tumpukan Kantong Sampah Hitam & Biru/Putih) ───
			# 1. Lorong perkampungan nelayan & Pasar Ikan (aman & berjarak lega > 120px dari tong sampah pilah):
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_trash_bags_blue_white.png", Vector2(345, 95), 0.25, true, Vector2(34, 10), Vector2(0, -5))
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_trash_pile_box.png", Vector2(500, 95), 0.25, true, Vector2(32, 10), Vector2(0, -5))
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_trash_pile_box.png", Vector2(655, 95), 0.25, true, Vector2(32, 10), Vector2(0, -5))

			# 2. Tepi jalan & trotoar pesisir (jauh dari tong sampah):
			spawn_environment_prop(get_parent(), "res://assets/sprites/props/prop_trash_bags_blue_white.png", Vector2(680, 205), 0.25, true, Vector2(34, 10), Vector2(0, -5))

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
	# Pivot Y-sort dinaikkan ke garis dasar dinding (bukan di ujung bawah teras/tangga depan),
	# sehingga pemain yang menapak teras digambar di depan teras secara realistis (Gambar 2 & 4).
	var ysort_lift: float = BUILDING_WALL_BOTTOM_TUCK_PX
	body.position = Vector2(pos.x, pos.y - ysort_lift)
	body.collision_layer = 1
	body.collision_mask = 0
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.modulate = tint
	sprite.scale = Vector2(sprite_scale, sprite_scale)
	sprite.position = Vector2(0, -texture.get_height() * 0.5 * sprite_scale + ysort_lift)
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
			"y0": (float(y0) - float(h)) * sprite_scale + BUILDING_WALL_BOTTOM_TUCK_PX,
			"y1": (float(y1) - float(h)) * sprite_scale + BUILDING_WALL_BOTTOM_TUCK_PX,
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
	# Pangkas band yang melewati dasar dinding (0.0) agar lantai teras/tangga depan di bawah dinding
	# tidak memblokir pemain (pemain bisa menapak teras realistis sampai batas dinding, Gambar 2 & 4).
	var trimmed_bands: Array[Dictionary] = []
	for b in bands:
		if b["y0"] < 0.0:
			b["y1"] = minf(b["y1"], 0.0)
			trimmed_bands.append(b)
	if not trimmed_bands.is_empty():
		bands = trimmed_bands
	bands[bands.size() - 1]["y1"] = 0.0

	# Jaga pangkal depan selebar dinding utama agar pemain tidak masuk celah sempit
	for i in range(1, bands.size()):
		if bands[i]["y1"] > -14.0:
			bands[i]["lx"] = minf(bands[i]["lx"], bands[i - 1]["lx"])
			bands[i]["rx"] = maxf(bands[i]["rx"], bands[i - 1]["rx"])
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

func _spawn_flora_entries(entries: Array) -> void:
	for entry in entries:
		var pos: Vector2 = entry[0]
		var prop_name: String = str(entry[1])
		var prop_scale: float = float(entry[2]) if entry.size() > 2 else 0.35
		if is_in_water(pos):
			continue
		spawn_flora(get_parent(), pos, prop_name, prop_scale)

## Memunculkan tanaman kecil / semak / rumput / bunga berkolisi solid di daratan (tidak bisa diinjak/dilewati).
static func spawn_flora(parent: Node, pos: Vector2, prop_name: String, scale_factor: float = 0.35) -> void:
	if parent == null:
		return
	var path := "res://assets/sprites/props/" + prop_name
	var texture: Texture2D = load(path)
	if texture == null:
		return
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(scale_factor, scale_factor)
	sprite.position = Vector2(0, -texture.get_height() * 0.5 * scale_factor)
	body.add_child(sprite)

	var tex_w: float = texture.get_width() * scale_factor
	var tex_h: float = texture.get_height() * scale_factor

	# Tentukan ukuran kolisi padat di pangkal tanaman / semak
	var col_w: float
	var col_h: float
	if prop_name.begins_with("bush_"):
		col_w = clampf(tex_w * 0.65, 14.0, 24.0)
		col_h = clampf(tex_h * 0.40, 8.0, 12.0)
	elif prop_name.begins_with("prop_"):
		col_w = clampf(tex_w * 0.65, 14.0, 26.0)
		col_h = clampf(tex_h * 0.40, 7.0, 10.0)
	else:
		# flora_ / grass / flower
		col_w = clampf(tex_w * 0.55, 8.0, 14.0)
		col_h = clampf(tex_h * 0.35, 6.0, 9.0)

	var shape := RectangleShape2D.new()
	shape.size = Vector2(col_w, col_h)
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = Vector2(0, -col_h * 0.5)
	body.add_child(col)

	parent.add_child.call_deferred(body)

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

func _spawn_mangrove(pos: Vector2, variant_type: String = "auto") -> void:
	if is_in_water(pos):
		return
	var tree_idx: int = abs(int(pos.x * 73 + pos.y * 37)) % 5
	var texture: Texture2D = null
	var tree_scale: float = 0.32
	var col_size := Vector2(24, 10)
	var col_offset := Vector2(0, -5)
	var has_soil_base: bool = true

	match variant_type:
		"mature":
			texture = load("res://assets/sprites/props/mangrove_tree_mature_%d.png" % tree_idx)
			tree_scale = 0.32
			col_size = Vector2(24, 10)
			col_offset = Vector2(0, -5)
		"young":
			var young_sprites := [
				"res://assets/sprites/props/mangrove_tree_young_0.png",
				"res://assets/sprites/props/mangrove_tree_young_1.png",
				"res://assets/sprites/props/mangrove_tree_adolescent_0.png",
			]
			texture = load(young_sprites[tree_idx % young_sprites.size()])
			tree_scale = 0.44
			col_size = Vector2(14, 8)
			col_offset = Vector2(0, -4)
		"sprout":
			var sprout_sprites := [
				"res://assets/sprites/props/mangrove_tree_sprout_0.png",
				"res://assets/sprites/props/mangrove_tree_sapling_tall.png",
			]
			texture = load(sprout_sprites[tree_idx % sprout_sprites.size()])
			tree_scale = 0.44
			col_size = Vector2(8, 4)
			col_offset = Vector2(0, -2)
			has_soil_base = false
		_:
			texture = load("res://assets/sprites/props/mangrove_tree_mature_%d.png" % tree_idx)
			tree_scale = 0.32
			col_size = Vector2(24, 10)
			col_offset = Vector2(0, -5)

	if texture == null:
		texture = load("res://assets/sprites/props/mangrove.png")
	var body := StaticBody2D.new()
	body.position = pos
	body.collision_layer = 1
	body.collision_mask = 0

	# Alas tanah lumpur alami untuk rumpun akar mangrove dari Gambar 4
	if has_soil_base:
		var soil_sprite := Sprite2D.new()
		soil_sprite.texture = load("res://assets/sprites/props/soil_patch_tree_%d.png" % (tree_idx % 4))
		soil_sprite.scale = Vector2(0.32, 0.28) if variant_type != "young" else Vector2(0.24, 0.20)
		soil_sprite.position = Vector2(0, -6)
		soil_sprite.z_index = -1
		body.add_child(soil_sprite)

	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.scale = Vector2(tree_scale, tree_scale)
	sprite.position = Vector2(0, -texture.get_height() * 0.5 * tree_scale)
	body.add_child(sprite)
	var shape := RectangleShape2D.new()
	shape.size = col_size
	var col := CollisionShape2D.new()
	col.shape = shape
	col.position = col_offset
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

## Memunculkan prop lingkungan/polusi/sungai dengan skala proporsional & opsi kolisi dasar
static func spawn_environment_prop(parent: Node, path: String, pos: Vector2, scale_factor: float = 0.3, has_collision: bool = false, col_size: Vector2 = Vector2.ZERO, col_offset: Vector2 = Vector2.ZERO, z_idx: int = 0) -> void:
	var texture: Texture2D = null
	if ResourceLoader.exists(path):
		texture = load(path) as Texture2D
	if texture == null:
		var global_path := ProjectSettings.globalize_path(path)
		var img := Image.load_from_file(global_path)
		if img != null:
			texture = ImageTexture.create_from_image(img)
			texture.resource_path = path
	if texture == null:
		return
	if has_collision:
		var body := StaticBody2D.new()
		body.position = pos
		body.collision_layer = 1
		body.collision_mask = 0
		body.z_index = z_idx

		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2(scale_factor, scale_factor)
		sprite.position = Vector2(0, -texture.get_height() * scale_factor * 0.5)
		body.add_child(sprite)

		var col := CollisionShape2D.new()
		var shape := RectangleShape2D.new()
		shape.size = col_size
		col.shape = shape
		col.position = col_offset
		body.add_child(col)
		parent.add_child.call_deferred(body)
	else:
		var sprite := Sprite2D.new()
		sprite.texture = texture
		sprite.scale = Vector2(scale_factor, scale_factor)
		sprite.position = Vector2(pos.x, pos.y - texture.get_height() * scale_factor * 0.5)
		sprite.z_index = z_idx
		parent.add_child.call_deferred(sprite)
