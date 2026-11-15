extends Node

func _ready() -> void:
	print("--- STARTING V2 MECHANICS TEST SUITE ---")
	call_deferred("_run_tests")

func _check(condition: bool, msg: String) -> void:
	if condition:
		print("PASS: " + msg)
	else:
		push_error("FAIL: " + msg)
		print("FAIL: " + msg)
		get_tree().quit(1)

func _run_tests() -> void:
	# 1. Test Dialog JSON Loading
	var files_to_check: Array[String] = [
		"h1_warung", "h1_narasi_2hari", "h1_warung_kasur", "h1_jembatan_suara",
		"h1_datuk", "h1_selesai_sungai", "h1_penjaga_hutan", "h1_penjaga_hutan_selesai",
		"h1_toko_jaya", "h6_darwis", "h4_rina", "h2_pemuka_desa", "h5_rina",
		"h2_jali", "h3_pak_rt", "h3_jali", "h3_ibu_rumah", "h3_budi",
		"h7_penjaga_sungai", "h7_pantun", "h7_nelayan", "h7_nelayan_selesai", "h7_epilog",
		"ending_a", "ending_b", "ending_c", "ending_d", "h1_datuk_dejavu"
	]

	for fname in files_to_check:
		var path := "res://data/dialog/%s.json" % fname
		_check(FileAccess.file_exists(path), "File exists: " + path)
		var file := FileAccess.open(path, FileAccess.READ)
		var json := JSON.new()
		var err := json.parse(file.get_as_text())
		_check(err == OK, "Valid JSON: " + path)

	# 2. Test Choice Locking & Dynamic Logic
	GameState.reset()
	_check(not bool(GameState.choices.get("has_jeriken_and_info", false)), "has_jeriken_and_info initially false")
	_check(not bool(GameState.choices.get("has_rt_cart_approval", false)), "has_rt_cart_approval initially false")

	# Test Pak Darwis Choices
	GameState.record_choice("darwis_peduli", true)
	_check(GameState.get_sikap("darwis") == GameState.SIKAP_PEDULI, "Darwis sikap Peduli when darwis_peduli=true")

	GameState.record_choice("darwis_peduli", false)
	_check(GameState.get_sikap("darwis") == GameState.SIKAP_MENOLAK, "Darwis sikap Menolak when darwis_peduli=false")

	# Test Kak Rina Choices
	GameState.record_choice("rina_peduli", true)
	_check(GameState.get_sikap("rina") == GameState.SIKAP_PEDULI, "Rina sikap Peduli when rina_peduli=true")

	# Test Bang Jali Choices
	GameState.record_choice("jali_peduli", true)
	_check(GameState.get_sikap("jali") == GameState.SIKAP_PEDULI, "Jali sikap Peduli when jali_peduli=true")

	# 3. Test 4 Ending Calculation
	# Ending A requirements: Meter <= 20, 3 warga peduli, 5 trees + 8 mangroves
	GameState.meter_bencana = 15.0
	GameState.set_sikap("darwis", GameState.SIKAP_PEDULI)
	GameState.set_sikap("rina", GameState.SIKAP_PEDULI)
	GameState.set_sikap("jali", GameState.SIKAP_PEDULI)
	GameState.add_zone_stat("hulu", "trees", 5)
	GameState.add_zone_stat("hilir", "mangroves", 8)
	var ending := GameState.hitung_kode_ending()
	_check(ending == "A", "Ending A correctly determined when all criteria met (got: %s)" % ending)

	# Ending B requirements: Meter <= 40, minimal 2 warga peduli
	GameState.meter_bencana = 35.0
	GameState.set_sikap("darwis", GameState.SIKAP_MENOLAK)
	ending = GameState.hitung_kode_ending()
	_check(ending == "B", "Ending B correctly determined when 2 peduli and meter <= 40 (got: %s)" % ending)

	# Ending C requirements: Meter <= 60, minimal 1 warga peduli
	GameState.meter_bencana = 55.0
	GameState.set_sikap("rina", GameState.SIKAP_MENOLAK)
	ending = GameState.hitung_kode_ending()
	_check(ending == "C", "Ending C correctly determined when 1 peduli and meter <= 60 (got: %s)" % ending)

	# Ending D requirements: Meter > 60
	GameState.meter_bencana = 70.0
	ending = GameState.hitung_kode_ending()
	_check(ending == "D", "Ending D correctly determined when meter > 60 (got: %s)" % ending)

	# 4. Test Rewind Functionality
	GameState.rewind()
	_check(bool(GameState.choices.get("is_rewound", false)) == true, "Rewind correctly flags is_rewound=true")
	_check(GameState.choices.has("last_fail_reason"), "Rewind records last_fail_reason")

	print("\n=================================")
	print("ALL V2 MECHANICS TESTS PASSED!")
	print("=================================")
	get_tree().quit(0)
