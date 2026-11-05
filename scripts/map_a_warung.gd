## Map A: Warung dan Jalan Depan (Hub Utama)
## Tempat warung kopi Bu Mira & Pak Hendra, kasur tidur MC,
## lapak gorengan Kak Rina, dan lapak pengepul sampah.
extends MapBase

@onready var bang_ucok: Node2D = get_node_or_null("BangUcok") as Node2D
@onready var bu_mira: Node2D = get_node_or_null("BuMira") as Node2D

var _exclaim_tween: Tween = null

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
	var exclaim := bu_mira.get_node_or_null("ExclaimLabel") as Label
	if exclaim:
		if _exclaim_tween:
			_exclaim_tween.kill()
		if GameState.hari == 1:
			exclaim.visible = (GameState.h1_fase == 3)
			if exclaim.visible:
				exclaim.text = "!"
				var start_y := exclaim.position.y
				_exclaim_tween = create_tween().set_loops()
				_exclaim_tween.tween_property(exclaim, "position:y", start_y - 4.0, 0.45).set_trans(Tween.TRANS_SINE)
				_exclaim_tween.tween_property(exclaim, "position:y", start_y, 0.45).set_trans(Tween.TRANS_SINE)
		else:
			exclaim.visible = false
