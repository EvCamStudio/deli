## Titik tanam top-down untuk pohon hulu dan mangrove pesisir.
## Sebelum ditanam hanya lingkaran tanah yang terlihat. Saat pemain menanam,
## yang muncul hanya bibit; pohon tumbuh mengikuti siklus hari, bukan hitungan
## detik, jadi tidak ada pohon yang langsung jadi di tempat.
extends Area2D
class_name TreeSpotTopDown

enum Stage { SEEDLING, SAPLING, MATURE }

## Berapa hari setelah tanam bibit berubah jadi pohon muda / pohon dewasa.
const DAYS_TO_SAPLING: int = 1
const DAYS_TO_MATURE: int = 2
const SAPLING_SCALE: float = 0.38

@export var kind: String = "tree"  # "tree" atau "mangrove"
@export var spot_id: String = ""

@onready var marker: Sprite2D = $Marker
@onready var seedling_sprite: Sprite2D = $Seedling
@onready var planted_sprite: Sprite2D = $Planted
@onready var blocker_col: CollisionShape2D = $Blocker/CollisionShape2D

var _planted: bool = false
var _blocker_active: bool = false
var _stage: int = Stage.SEEDLING
var _target_scale := Vector2.ONE
var _tree_height: float = 1.0

func _ready() -> void:
	add_to_group("tree_spot")
	marker.texture = load("res://assets/sprites/props/tree_spot_ring.png")
	marker.scale = Vector2.ONE

	var is_mangrove := kind == "mangrove"
	var tree_path: String = "res://assets/sprites/props/mangrove.png" if is_mangrove else "res://assets/sprites/props/tree_mangga.png"
	var seedling_path: String = "res://assets/sprites/props/seedling_mangrove.png" if is_mangrove else "res://assets/sprites/props/seedling_tree.png"
	_target_scale = Vector2.ONE if is_mangrove else Vector2(0.5, 0.5)
	planted_sprite.texture = load(tree_path)
	_tree_height = float(planted_sprite.texture.get_height())
	_apply_tree_scale(1.0)

	seedling_sprite.texture = load(seedling_path)
	seedling_sprite.hide()

	GameState.day_changed.connect(_on_day_changed)

	if not spot_id.is_empty() and spot_id in GameState.planted_spots:
		mark_planted()
	else:
		_show_unplanted()

## Skala pohon selalu berpangkal di titik tanam (bukan di tengah sprite).
func _apply_tree_scale(factor: float) -> void:
	var s := _target_scale * factor
	planted_sprite.scale = s
	planted_sprite.position = Vector2(0, -_tree_height * 0.5 * s.y)

func _update_blocker() -> void:
	if is_instance_valid(blocker_col):
		blocker_col.set_deferred("disabled", not (_planted and _blocker_active))

func _show_unplanted() -> void:
	_planted = false
	_blocker_active = false
	_stage = Stage.SEEDLING
	marker.show()
	seedling_sprite.hide()
	planted_sprite.hide()
	_update_blocker()

func get_action_label() -> String:
	if _planted:
		return ""
	return "Tanam Bibit Mangrove" if kind == "mangrove" else "Tanam Bibit Pohon"

func is_planted() -> bool:
	return _planted

## Hari saat titik ini ditanam (0 kalau tidak tercatat, mis. save lama).
func planted_day() -> int:
	return int(GameState.planted_days.get(spot_id, 0))

## Tahap tumbuh berdasarkan selisih hari, bukan stopwatch.
func current_stage() -> int:
	var day_planted := planted_day()
	if day_planted <= 0:
		# Save lama tidak mencatat hari tanam: anggap pohonnya sudah dewasa.
		return Stage.MATURE
	var elapsed: int = GameState.hari - day_planted
	if elapsed >= DAYS_TO_MATURE:
		return Stage.MATURE
	if elapsed >= DAYS_TO_SAPLING:
		return Stage.SAPLING
	return Stage.SEEDLING

## Tandai sudah ditanam tanpa memicu hadiah (dipakai saat memuat save).
func mark_planted() -> void:
	if _planted:
		return
	_planted = true
	marker.hide()
	_apply_stage(current_stage(), false)

func _required_quest() -> String:
	return "tanam_mangrove" if kind == "mangrove" else "tanam_pohon_hulu"

func _show_locked_message() -> void:
	var guide: String = "Nelayan" if kind == "mangrove" else "Penjaga Hutan"
	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("toast"):
		level.toast("Bicara dulu dengan %s." % guide, false)

func interact() -> void:
	if _planted:
		return
	if not GameState.has_quest(_required_quest()):
		_show_locked_message()
		return

	_planted = true
	marker.hide()
	planted_sprite.hide()

	if not spot_id.is_empty():
		GameState.planted_days[spot_id] = GameState.hari
		if spot_id not in GameState.planted_spots:
			GameState.planted_spots.append(spot_id)

	# Yang muncul saat menanam hanya bibit; pohon menyusul di hari berikutnya.
	_apply_stage(Stage.SEEDLING, true)

	if kind == "mangrove":
		GameState.plant_mangrove()
		GameState.add_river_health(5.0)
		GameState.rupiah += 2000
	else:
		GameState.plant_tree()
		GameState.add_river_health(4.0)
		GameState.rupiah += 500

	AudioManager.play_sfx("plant")
	SettingsManager.vibrate(30)

	var level := get_tree().get_first_node_in_group("level")
	if level and level.has_method("on_tree_planted"):
		level.on_tree_planted(kind)
	GameState.save_game()

## Terapkan tampilan sesuai tahap. Animasi hanya dipakai saat pemain menanam
## atau saat hari berganti, bukan timer pertumbuhan di latar belakang.
func _apply_stage(stage: int, animate: bool) -> void:
	var grew: bool = stage > _stage
	_stage = stage
	match stage:
		Stage.SEEDLING:
			_blocker_active = false
			_show_seedling(animate)
		Stage.SAPLING:
			_blocker_active = true
			_show_tree(SAPLING_SCALE, animate and grew)
		_:
			_blocker_active = true
			_show_tree(1.0, animate and grew)
	_update_blocker()

## Bibit muncul dengan animasi "pop" kecil dan tetap jadi bibit hari itu.
func _show_seedling(animate: bool) -> void:
	planted_sprite.hide()
	seedling_sprite.show()
	seedling_sprite.modulate.a = 1.0
	if not animate:
		seedling_sprite.scale = Vector2.ONE
		return
	seedling_sprite.scale = Vector2(0.35, 0.35)
	var tween := create_tween()
	tween.tween_property(seedling_sprite, "scale", Vector2.ONE, 0.35) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _show_tree(scale_factor: float, animate: bool) -> void:
	seedling_sprite.hide()
	seedling_sprite.scale = Vector2.ONE
	planted_sprite.show()
	planted_sprite.modulate.a = 1.0
	_apply_tree_scale(scale_factor)
	if not animate:
		return
	# Sedikit "tarik napas" supaya perubahan hari terasa hidup.
	var from := scale_factor * 0.88
	_apply_tree_scale(from)
	var tween := create_tween()
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(planted_sprite, "scale", _target_scale * scale_factor, 0.45)
	tween.parallel().tween_property(
		planted_sprite,
		"position",
		Vector2(0, -_tree_height * 0.5 * _target_scale.y * scale_factor),
		0.45
	)

## Saat pemain tidur / hari maju, bibit yang sudah cukup umur ikut tumbuh.
func _on_day_changed(_new_day: int) -> void:
	if _planted:
		_apply_stage(current_stage(), true)
