## Level 3 — Kota Medan (Bantaran) Script
# Vertical slice prioritas. Mengelola:
# - Puzzle drainase (tuas)
# - Mini-game pantun
# - 4 NPC dialog bercabang
# - Penyelesaian level
extends LevelBase

# ─── Puzzle Drainase ──────────────────────────────────────────────────────────
var _lever_sequence: Array[int] = [1, 3, 2]  # Urutan tuas yang benar
var _lever_pressed: Array[int] = []

## Dipanggil oleh script tuas saat ditekan.
func lever_pressed(lever_id: int) -> void:
	_lever_pressed.append(lever_id)

	# Cek kecocokan urutan
	for i in range(_lever_pressed.size()):
		if _lever_pressed[i] != _lever_sequence[i]:
			# Salah urutan: reset
			_lever_pressed = []
			GameState.add_river_health(-3.0)
			AudioManager.play_sfx("wrong")
			if hud:
				hud.update_mission("Urutan tuas salah! Coba lagi.")
			return

	if _lever_pressed.size() == _lever_sequence.size():
		# Berhasil: buka pintu air
		_open_drainage()

func _open_drainage() -> void:
	GameState.add_river_health(10.0)
	GameState.unlock_card("card_drainase_01")
	AudioManager.play_sfx("correct")
	if hud:
		hud.update_mission("Drainase terbuka! Banjir surut.")
	# Aktifkan animasi pintu air di scene
	var gates := get_tree().get_nodes_in_group("drainage_gate")
	for gate in gates:
		if gate.has_method("open"):
			gate.open()

# ─── Mini-Game Pantun ─────────────────────────────────────────────────────────
# Dikelola oleh PantunMinigame.gd (objek terpisah)

## Dipanggil oleh PantunMinigame saat berhasil.
func on_pantun_completed() -> void:
	GameState.unlock_card("card_pantun_01")
	GameState.add_river_health(8.0)
	if hud:
		hud.update_mission("Pantun selesai! Gerbang terbuka.")

# ─── Override ─────────────────────────────────────────────────────────────────

func _ready() -> void:
	level_id = 3
	river_health_target = 70.0
	bgm_key = 3
	super._ready()

func _set_initial_mission() -> void:
	if hud:
		hud.update_mission("Bersihkan bantaran dan perbaiki drainase!")
