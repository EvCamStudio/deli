## Map B: Tepi Sungai Deli
## Tempat memungut sampah, menanam pohon di tebing,
## bertemu Datuk Sampan di tepi air, dan mengobrol dengan Pak Darwis di bale bambu.
extends MapBase

@onready var datuk_sampan: Node2D = get_node_or_null("DatukSampan") as Node2D

func _ready() -> void:
	map_name = "Sungai"
	super._ready()

	# Hari 1: Begitu MC tiba di tepi sungai, misi aktif untuk mengutip sampah
	if GameState.hari == 1 and GameState.h1_fase == 0:
		GameState.h1_fase = 1
		GameState.h1_fase_changed.emit(1)
		var hud := get_tree().get_first_node_in_group("hud")
		if hud and hud.has_method("show_toast"):
			hud.show_toast("Misi Diperbarui: Kutip 3 sampah di sekitar sungai!")

	_update_datuk_indicator()
	GameState.h1_fase_changed.connect(func(_f): _update_datuk_indicator())

func _update_datuk_indicator() -> void:
	if not is_instance_valid(datuk_sampan):
		return
	if GameState.hari == 1:
		var exclaim := datuk_sampan.get_node_or_null("ExclaimLabel") as Label
		if exclaim:
			# Datuk hanya memiliki tanda seru '!' jika 3 sampah sudah dikutip (Fase 2)
			exclaim.visible = (GameState.h1_fase == 2)
