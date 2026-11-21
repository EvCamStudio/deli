extends Node

var total_pass: int = 0
var total_fail: int = 0

func _check(condition: bool, message: String) -> void:
	if condition:
		total_pass += 1
		print("PASS: %s" % message)
	else:
		total_fail += 1
		printerr("FAIL: %s" % message)

func _ready() -> void:
	await get_tree().process_frame
	print("\n=== VERIFYING CHOICE PREFIX & MONEY MECHANIC REMOVAL ===\n")
	
	# 1. Test portrait_dialogue with choice node
	var pd_scene = load("res://scenes/ui/portrait_dialogue.tscn")
	var pd = pd_scene.instantiate()
	get_tree().root.add_child(pd)
	await get_tree().process_frame
	
	pd.show_node({
		"speaker": "Datuk Sampan",
		"teks": "Siapa namamu?",
		"pilihan": [
			{"teks": "Huh? Penjaga sungai ini?"},
			{"teks": "K-kau beneran h-hantu...?"}
		]
	})
	await get_tree().process_frame
	
	pd._open_choice_modal()
	await get_tree().process_frame
	
	var choices_container = pd.choices_container
	var buttons = choices_container.get_children()
	_check(buttons.size() == 2, "Datuk choices has 2 buttons")
	if buttons.size() >= 2:
		var btn0: Button = buttons[0]
		var btn1: Button = buttons[1]
		print("Button 0 text: '%s'" % btn0.text)
		print("Button 1 text: '%s'" % btn1.text)
		_check(not btn0.text.strip_edges().begins_with("A."), "Button 0 does NOT begin with 'A.'")
		_check(not btn0.text.strip_edges().begins_with("[A]"), "Button 0 does NOT begin with '[A]'")
		_check("Huh? Penjaga sungai ini?" in btn0.text, "Button 0 contains clean question")
		_check(not btn1.text.strip_edges().begins_with("B."), "Button 1 does NOT begin with 'B.'")
		_check(not btn1.text.strip_edges().begins_with("[B]"), "Button 1 does NOT begin with '[B]'")
		_check("K-kau beneran h-hantu...?" in btn1.text, "Button 1 contains clean question")
	
	# Test with locked choice & previously tagged [A]
	pd.show_node({
		"speaker": "Pak Darwis",
		"teks": "Mau bagaimana?",
		"choices": [
			{"teks": "[Terkunci] Potong busa kasur", "locked": true},
			{"teks": "Tunggu sebentar ya Pak!", "locked": false}
		]
	})
	await get_tree().process_frame
	pd._open_choice_modal()
	await get_tree().process_frame
	
	var d_buttons = choices_container.get_children()
	if d_buttons.size() >= 2:
		var dbtn0: Button = d_buttons[0]
		var dbtn1: Button = d_buttons[1]
		print("Darwis 0 text: '%s'" % dbtn0.text)
		print("Darwis 1 text: '%s'" % dbtn1.text)
		_check(not dbtn0.text.strip_edges().begins_with("A."), "Darwis 0 does NOT begin with 'A.'")
		_check("[Terkunci]" in dbtn0.text, "Darwis 0 has [Terkunci] tag")
		_check(not dbtn1.text.strip_edges().begins_with("B."), "Darwis 1 does NOT begin with 'B.'")
		_check("Tunggu sebentar ya Pak!" in dbtn1.text, "Darwis 1 has clean text")

	pd.hide_box()
	pd.queue_free()
	
	# 2. Test HUD MoneyCard visibility
	var hud_scene = load("res://scenes/ui/hud.tscn")
	var hud = hud_scene.instantiate()
	get_tree().root.add_child(hud)
	await get_tree().process_frame
	
	var money_card = hud.get_node_or_null("SafeMargin/Root/TopBar/MoneyCard")
	_check(money_card != null, "HUD MoneyCard node exists")
	if money_card:
		_check(not money_card.visible, "HUD MoneyCard is INVISIBLE (money mechanic removed from HUD)")
	
	hud.queue_free()
	
	# 3. Test Pilot HUD MoneyCard visibility
	var pilot_hud_scene = load("res://scenes/ui/pilot_hud.tscn")
	var pilot_hud = pilot_hud_scene.instantiate()
	get_tree().root.add_child(pilot_hud)
	await get_tree().process_frame
	
	var pilot_money_card = pilot_hud.get_node_or_null("SafeMargin/Root/TopBar/MoneyCard")
	_check(pilot_money_card != null, "Pilot HUD MoneyCard node exists")
	if pilot_money_card:
		_check(not pilot_money_card.visible, "Pilot HUD MoneyCard is INVISIBLE")
	
	pilot_hud.queue_free()
	
	# 4. Test Ending screen stats text
	var ending_scene = load("res://scenes/levels/level_5_epilog.tscn")
	var ending = ending_scene.instantiate()
	get_tree().root.add_child(ending)
	await get_tree().process_frame
	var stats_lbl = ending.get_node_or_null("Panel/VBox/StatsLabel")
	if stats_lbl:
		print("Ending stats text:\n%s" % stats_lbl.text)
		_check(not "Rupiah" in stats_lbl.text, "Ending stats does NOT show 'Rupiah'")
		_check(not "Rp " in stats_lbl.text, "Ending stats does NOT show 'Rp '")
	ending.queue_free()
	
	# 5. Test Pilot Journal stats text
	var journal_scene = load("res://scenes/ui/pilot_journal.tscn")
	var journal = journal_scene.instantiate()
	get_tree().root.add_child(journal)
	await get_tree().process_frame
	journal.open()
	await get_tree().process_frame
	var journal_stats = journal.get_node_or_null("Panel/VBox/Stats")
	if journal_stats:
		print("Journal stats text: '%s'" % journal_stats.text)
		_check(not "Rp" in journal_stats.text, "Pilot journal stats does NOT show 'Rp'")
	journal.queue_free()
	
	print("\n=======================================================")
	print("RESULT: %d PASS, %d FAIL" % [total_pass, total_fail])
	print("=======================================================\n")
	
	if total_fail == 0:
		get_tree().quit(0)
	else:
		get_tree().quit(1)
