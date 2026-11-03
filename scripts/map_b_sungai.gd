## Map B: Tepi Sungai Deli
## Tempat memungut sampah, menanam pohon di tebing,
## bertemu Datuk Sampan di tepi air, dan mengobrol dengan Pak Darwis di bale bambu.
extends MapBase

func _ready() -> void:
	map_name = "Sungai"
	super._ready()

	# Malam hari 1: jika MC pertama kali datang ke sungai, picu kemunculan Datuk Sampan
	if GameState.hari == 1 and not GameState.choices.has("h1_datuk_done"):
		get_tree().create_timer(1.0).timeout.connect(func():
			DialogueManager.mulai("h1_datuk")
			GameState.choices["h1_datuk_done"] = true
		)

