## Titik investigasi tepi sungai Hulu yang memicu suara misterius sebelum kemunculan Datuk Sampan.
extends Area2D
class_name RiverbankSpot

signal investigated

var _active: bool = false
var _triggered: bool = false
var _ripple: Sprite2D = null
var _label: Label = null
var _pulse_time: float = 0.0

func _ready() -> void:
	collision_layer = 2
	collision_mask = 1
	var shape := CircleShape2D.new()
	shape.radius = 24.0
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)

	_ripple = Sprite2D.new()
	_ripple.texture = _build_ripple_texture()
	_ripple.z_index = -1
	add_child(_ripple)

	_label = Label.new()
	_label.z_index = 5
	_label.text = "?"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.position = Vector2(-12, -26)
	_label.size = Vector2(24, 16)
	_label.add_theme_color_override("font_color", Color(1.0, 0.88, 0.42))
	_label.add_theme_color_override("font_outline_color", Color(0.227, 0.165, 0.118))
	_label.add_theme_constant_override("outline_size", 3)
	_label.add_theme_font_size_override("font_size", 11)
	add_child(_label)

	body_entered.connect(_on_body_entered)
	set_active(false)

func _process(delta: float) -> void:
	if not _active or _ripple == null:
		return
	_pulse_time += delta * 3.2
	var s: float = 0.92 + sin(_pulse_time) * 0.12
	_ripple.scale = Vector2(s, s)
	if _label:
		_label.position.y = -26.0 + sin(_pulse_time * 1.3) * 2.0

func set_active(state: bool) -> void:
	_active = state and not _triggered
	visible = _active
	set_deferred("monitoring", _active)
	set_deferred("monitorable", _active)

func is_investigated() -> bool:
	return _triggered

func mark_done() -> void:
	_triggered = true
	set_active(false)

func get_action_label() -> String:
	return "Selidiki Tepian" if _active else ""

func interact() -> void:
	if not _active or _triggered:
		return
	_triggered = true
	set_active(false)
	investigated.emit()

func _on_body_entered(body: Node) -> void:
	if not _active or _triggered:
		return
	if body.is_in_group("player") and not DialogueManager.is_active():
		interact()

func _build_ripple_texture() -> ImageTexture:
	var size: int = 24
	var img := Image.create(size, size, false, Image.FORMAT_RGBA8)
	var center := Vector2(size * 0.5 - 0.5, size * 0.5 - 0.5)
	for y in range(size):
		for x in range(size):
			var d: float = Vector2(x, y).distance_to(center)
			if d >= 8.5 and d <= 10.5:
				img.set_pixel(x, y, Color(0.85, 0.96, 1.0, 0.85))
			elif d >= 4.0 and d <= 5.5:
				img.set_pixel(x, y, Color(0.65, 0.88, 1.0, 0.65))
	return ImageTexture.create_from_image(img)
