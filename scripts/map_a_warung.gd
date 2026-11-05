## Map A: Warung dan Jalan Depan (Hub Utama)
## Tempat warung kopi Bu Mira & Pak Hendra, kasur tidur MC,
## lapak gorengan Kak Rina, dan lapak pengepul sampah.
extends MapBase

@onready var bang_ucok: Node2D = get_node_or_null("BangUcok") as Node2D
@onready var bu_mira: Node2D = get_node_or_null("BuMira") as Node2D

func _ready() -> void:
	map_name = "Warung"
	super._ready()

	# Bang Ucok hanya muncul di sore Hari 7
	if bang_ucok:
		bang_ucok.visible = (GameState.hari == 7)
		var col := bang_ucok.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col:
			col.disabled = not (GameState.hari == 7)

	_update_bu_mira_indicator()
	GameState.h1_fase_changed.connect(func(_f): _update_bu_mira_indicator())

func _update_bu_mira_indicator() -> void:
	if not bu_mira:
		return
	if GameState.hari == 1:
		var exclaim := bu_mira.get_node_or_null("ExclaimLabel") as Label
		if exclaim:
			# Bu Mira hanya punya tanda seru '!' jika pemain sudah mendapat arahan dari Datuk (Fase 3)
			exclaim.visible = (GameState.h1_fase == 3)
