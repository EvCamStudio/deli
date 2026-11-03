## Level 1 Hulu — Override LevelBase
# Misi: tanam 5 pohon, puzzle sambungkan aliran air.
extends LevelBase

var _trees_target: int = 5

func _ready() -> void:
	level_id = 1
	river_health_target = 40.0
	bgm_key = 1
	super._ready()

func _set_initial_mission() -> void:
	if hud:
		hud.update_mission("Tanam pohon di titik yang tersedia!")

func _process(delta: float) -> void:
	super._process(delta)
	# Update misi teks saat pohon ditanam
	if hud:
		var trees: int = GameState.trees_planted
		if trees >= _trees_target:
			hud.update_mission("Pohon selesai! Menuju gerbang →")
		else:
			hud.update_mission("Tanam pohon: %d/%d" % [trees, _trees_target])
