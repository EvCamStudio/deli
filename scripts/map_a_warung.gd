## Map A: Warung dan Jalan Depan (Hub Utama)
## Tempat warung kopi Bu Mira & Pak Hendra, kasur tidur MC,
## lapak gorengan Kak Rina, dan lapak pengepul sampah.
extends MapBase

@onready var bang_ucok: Node2D = get_node_or_null("BangUcok") as Node2D

func _ready() -> void:
	map_name = "Warung"
	super._ready()

	# Dialog pembuka Hari 1 di warung jika belum pernah bicara
	if GameState.hari == 1 and not GameState.choices.has("h1_warung_done"):
		get_tree().create_timer(0.6).timeout.connect(func():
			DialogueManager.mulai("h1_warung")
			GameState.choices["h1_warung_done"] = true
		)

	# Bang Ucok hanya muncul di sore Hari 7
	if bang_ucok:
		bang_ucok.visible = (GameState.hari == 7)
		var col := bang_ucok.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if col:
			col.disabled = not (GameState.hari == 7)

