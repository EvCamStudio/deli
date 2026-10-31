## TEMP TEST SCRIPT — hapus setelah verifikasi visual.
extends "res://scripts/intro/intro_dramatic.gd"

func _ready() -> void:
	var target_stage: int = 2
	var name_arg: String = "Budi"
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("stage="):
			target_stage = int(arg.substr(6))
		elif arg.begins_with("name="):
			name_arg = arg.substr(5)
	GameState.player_name = name_arg
	stage = target_stage
	super._ready()
