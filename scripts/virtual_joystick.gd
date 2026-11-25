## VirtualJoystick — joystick sentuh 8 arah untuk kontrol top-down.
## Dilengkapi pengaman anti-nyangkut saat dialog otomatis, interaksi tombol aksi,
## cutscene, maupun saat jari terlepas di luar area joystick.
extends Control

@export var deadzone: float = 0.18
@export var max_radius: float = 34.0

@onready var knob: TextureRect = $Knob

var _active: bool = false
var _touch_index: int = -1
var _center: Vector2 = Vector2(50, 50)
var _vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("touch_controls")
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(_on_resized)
	if DialogueManager:
		if not DialogueManager.dialogue_started.is_connected(_on_dialogue_state_changed):
			DialogueManager.dialogue_started.connect(_on_dialogue_state_changed)
		if not DialogueManager.dialogue_finished.is_connected(_on_dialogue_state_changed):
			DialogueManager.dialogue_finished.connect(_on_dialogue_state_changed)
	_recenter()
	call_deferred("_recenter")
	apply_settings()
	call_deferred("apply_settings")

func _on_dialogue_state_changed() -> void:
	_release()

func reset_joystick() -> void:
	_release()

func _notification(what: int) -> void:
	if what in [NOTIFICATION_PAUSED, NOTIFICATION_VISIBILITY_CHANGED, NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_APPLICATION_FOCUS_OUT]:
		if not is_visible_in_tree() or get_tree().paused:
			_release()

func _process(_delta: float) -> void:
	if not _active and _vector == Vector2.ZERO:
		return
	if not is_visible_in_tree() or get_tree().paused:
		_release()
		return
	if DialogueManager and DialogueManager.is_active():
		_release()
		return
	var level := get_tree().get_first_node_in_group("level")
	if level and (bool(level.get("_dialogue_active")) or bool(level.get("_is_cutscene_active"))):
		_release()
		return

func _input(event: InputEvent) -> void:
	if not _active:
		return
	# Tangkap pelepasan sentuhan jari secara global bahkan jika tertutup layer UI Dialog / Tombol Aksi
	if event is InputEventScreenTouch:
		if not event.pressed and (event.index == _touch_index or _touch_index == -1):
			_release()
	elif event is InputEventScreenDrag:
		if event.index == _touch_index:
			var local_pos: Vector2 = get_global_transform_with_canvas().affine_inverse() * event.position
			_update_vector(local_pos)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed and _touch_index == -1:
			_release()

func _on_resized() -> void:
	_recenter()
	pivot_offset = Vector2(0.0, size.y)

func apply_settings() -> void:
	var s: float = SettingsManager.get_touch_scale()
	var joy_scale: float = clampf(s, 0.8, 1.25)
	pivot_offset = Vector2(0.0, size.y)
	scale = Vector2(joy_scale, joy_scale)
	var opacity: float = SettingsManager.get_setting("touch_opacity", 0.7)
	modulate = Color(1, 1, 1, opacity)

func _recenter() -> void:
	_center = size * 0.5
	if not _active:
		_center_knob()

func _gui_input(event: InputEvent) -> void:
	if DialogueManager and DialogueManager.is_active():
		_release()
		return
	if event is InputEventScreenTouch:
		if event.pressed and not _active:
			_active = true
			_touch_index = event.index
			_update_vector(event.position)
		elif not event.pressed and (event.index == _touch_index or _touch_index == -1):
			_release()
	elif event is InputEventScreenDrag:
		if _active and event.index == _touch_index:
			_update_vector(event.position)
	elif not DisplayServer.is_touchscreen_available():
		# Fallback mouse khusus saat dites di PC non-touchscreen
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_active = true
				_touch_index = -1
				_update_vector(event.position)
			else:
				_release()
		elif event is InputEventMouseMotion and _active and _touch_index == -1:
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
	if is_instance_valid(knob):
		_center_knob()
	_set_action("move_left", false)
	_set_action("move_right", false)
	_set_action("move_up", false)
	_set_action("move_down", false)

func _center_knob() -> void:
	knob.position = _center - knob.size * 0.5

func get_direction() -> Vector2:
	return _vector
