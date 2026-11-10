## Panah guidance kuning yang melayang di atas objek tujuan.
## Target diatur oleh world_sungai_deli.get_guidance_target().
extends Node2D

var _target: Node2D = null
var _label: Label = null
var _time: float = 0.0

func _ready() -> void:
	_label = Label.new()
	_label.text = "▼"
	_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	_label.size = Vector2(18, 18)
	_label.position = Vector2(-9, -18)
	_label.add_theme_font_override("font", load("res://assets/fonts/PixelifySans.ttf"))
	_label.add_theme_font_size_override("font_size", 18)
	_label.add_theme_color_override("font_color", Color(1.0, 0.82, 0.18, 1.0))
	_label.add_theme_color_override("font_outline_color", Color(0.24, 0.16, 0.09, 1.0))
	_label.add_theme_constant_override("outline_size", 4)
	add_child(_label)
	visible = false

func set_target(target: Node2D) -> void:
	_target = target
	visible = target != null and is_instance_valid(target)

func _process(delta: float) -> void:
	if _target == null or not is_instance_valid(_target):
		visible = false
		return
	if not _target.is_visible_in_tree():
		visible = false
		return
	_time += delta
	global_position = _target.global_position + Vector2(0, -34.0 + sin(_time * 3.2) * 3.0)
	visible = true
