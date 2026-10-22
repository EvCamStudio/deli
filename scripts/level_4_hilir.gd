## Level 4 Hilir — Override LevelBase
extends LevelBase

func _ready() -> void:
	level_id = 4
	river_health_target = 85.0
	bgm_key = 4
	super._ready()

func _set_initial_mission() -> void:
	if hud:
		hud.update_mission("Tanam mangrove dan bersihkan pesisir!")
