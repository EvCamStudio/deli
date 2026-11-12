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
	_tileset = TopdownMap.build_curated_tileset([ground, water, bridge])
	TopdownMap.apply_water_visuals(water, false)

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

	# jalur vertikal ke jembatan dan permukiman bantaran selatan
	for y in range(8, 16):
		ground.set_cell(Vector2i(20, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(21, y), 0, Vector2i(5, 0), 0)
		ground.set_cell(Vector2i(44, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(45, y), 0, Vector2i(5, 0), 0)
	for y in range(22, 31):
		ground.set_cell(Vector2i(20, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(21, y), 0, Vector2i(5, 0), 0)
		ground.set_cell(Vector2i(44, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(45, y), 0, Vector2i(5, 0), 0)

	# jalan pemukiman bantaran selatan kota
	for x in range(5, 55):
		for y in [29, 30]:
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)

	# alun-alun batu di timur
	for x in range(48, 58):
		for y in range(12, 16):
			ground.set_cell(Vector2i(x, y), 0, Vector2i(6 + _hash(x, y) % 2, 0), 0)

	# jalur menuju gerbang
	for x in range(57, 60):
		for y in [10, 11]:
			ground.set_cell(Vector2i(x, y), 0, Vector2i(4 + _hash(x, y) % 2, 0), 0)

	# jalur ke warung, rumah, ruko jalan utama (utara)
	for y in range(8, 11):
		for col in [8, 15, 30, 37]:
			ground.set_cell(Vector2i(col, y), 0, Vector2i(4, 0), 0)
			ground.set_cell(Vector2i(col + 1, y), 0, Vector2i(5, 0), 0)
	for y in range(9, 13):
		ground.set_cell(Vector2i(52, y), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(53, y), 0, Vector2i(5, 0), 0)

	# jalur pintu rumah bantaran selatan menuju jalan selatan
	for col in [7, 14, 27, 36, 52]:
		ground.set_cell(Vector2i(col, 28), 0, Vector2i(4, 0), 0)
		ground.set_cell(Vector2i(col + 1, 28), 0, Vector2i(5, 0), 0)

	# bunga liar
	for i in range(95):
		var x: int = 2 + _hash(i, 4, 2) % (MAP_W - 4)
		var y: int = 2 + _hash(i, 8, 3) % (MAP_H - 4)
		if y >= 15 and y <= 22:
			continue
		if ground.get_cell_source_id(Vector2i(x, y)) == 0:
			var atlas: Vector2i = ground.get_cell_atlas_coords(Vector2i(x, y))
			if atlas.y == 0 and atlas.x <= 2:
				ground.set_cell(Vector2i(x, y), 0, Vector2i(i % 3, 3), 0)

	TopdownMap.autotile_dirt_paths(ground, MAP_W, MAP_H)

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
	# Menggunakan pembangun kolisi & area per tile air supaya kelokan sungai kota akurat dan jembatan tetap bisa dilalui.
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
	# Deret permukiman jalan utara kota
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_brick.png", Vector2(128, 132), Vector2(92, 22), 0.5)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(244, 132), Vector2(88, 22), 0.5)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_modern.png", Vector2(480, 132), Vector2(90, 22), 0.5)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_coastal.png", Vector2(604, 132), Vector2(78, 22), 0.5)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_cream.png", Vector2(840, 148), Vector2(82, 22), 0.5)
	# Deret pemukiman padat bantaran Sungai Deli selatan (menghadap jalan selatan)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_cream.png", Vector2(112, 448), Vector2(82, 22), 0.5, Color(0.96, 0.98, 1.0))
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_coastal.png", Vector2(232, 448), Vector2(78, 22), 0.5)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_courtyard.png", Vector2(440, 448), Vector2(88, 22), 0.5)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_brick.png", Vector2(584, 448), Vector2(92, 22), 0.5)
	TopdownMap.spawn_building(get_parent(), "res://assets/sprites/props/house_modern.png", Vector2(832, 448), Vector2(90, 22), 0.5, Color(0.96, 1.0, 0.96))

func _spawn_trees() -> void:
	# Pohon dirapikan di bingkai tepi peta & sudut celah rumah (tidak acak di tengah jalan/taman).
	var positions: Array[Vector2] = [
		Vector2(44, 112), Vector2(372, 116), Vector2(676, 116), Vector2(920, 112),
		Vector2(48, 436), Vector2(172, 436), Vector2(360, 436), Vector2(512, 436), Vector2(652, 436), Vector2(760, 436), Vector2(912, 436),
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
