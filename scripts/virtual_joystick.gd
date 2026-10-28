## VirtualJoystick — joystick sentuh 8 arah untuk kontrol top-down.
extends Control

@export var deadzone: float = 0.18
@export var max_radius: float = 34.0

@onready var knob: TextureRect = $Knob

var _active: bool = false
var _touch_index: int = -1
var _center: Vector2 = Vector2(50, 50)
var _vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("touch_controls")
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_on_resized)
	_recenter()
	call_deferred("_recenter")

func _on_resized() -> void:
	_recenter()

func _recenter() -> void:
	_center = size * 0.5
	if not _active:
		_center_knob()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed and not _active:
			_active = true
			_touch_index = event.index
			_update_vector(event.position)
		elif not event.pressed and event.index == _touch_index:
			_release()
	elif event is InputEventScreenDrag:
		if _active and event.index == _touch_index:
			_update_vector(event.position)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_active = true
			_update_vector(event.position)
		else:
			_release()
	elif event is InputEventMouseMotion and _active:
		_update_vector(event.position)

func _update_vector(local_position: Vector2) -> void:
	var delta: Vector2 = local_position - _center
	var distance: float = min(delta.length(), max_radius)
	_vector = Vector2.ZERO if distance < max_radius * deadzone else delta.normalized() * (distance / max_radius)
	knob.position = _center + _vector * max_radius - knob.size * 0.5
	_apply_actions()

func _apply_actions() -> void:
	_set_action("move_left", _vector.x < -0.25)
	_set_action("move_right", _vector.x > 0.25)
	_set_action("move_up", _vector.y < -0.25)
	_set_action("move_down", _vector.y > 0.25)

func _set_action(action: StringName, pressed: bool) -> void:
	if pressed and not Input.is_action_pressed(action):
		Input.action_press(action)
	elif not pressed and Input.is_action_pressed(action):
		Input.action_release(action)

func _release() -> void:
	_active = false
	_touch_index = -1
	_vector = Vector2.ZERO
	_center_knob()
	_set_action("move_left", false)
	_set_action("move_right", false)
	_set_action("move_up", false)
	_set_action("move_down", false)

func _center_knob() -> void:
	knob.position = _center - knob.size * 0.5

func get_direction() -> Vector2:
	return _vector

func apply_settings() -> void:
	modulate.a = SettingsManager.get_setting("touch_opacity", 0.7)
