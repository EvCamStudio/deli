## Level 2 Desa — Override LevelBase
extends LevelBase

func _ready() -> void:
	level_id = 2
	river_health_target = 55.0
	bgm_key = 2
	super._ready()

func _set_initial_mission() -> void:
	if hud:
		hud.update_mission("Bicara dengan petani dan warga desa!")
