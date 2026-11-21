extends Node

func _ready() -> void:
	await get_tree().process_frame
	print("\n=== TESTING RESTORED CHOICE MODAL BEHAVIOR & BUG FIX ===\n")
	
	var pd_scene = load("res://scenes/ui/portrait_dialogue.tscn")
	var pd = pd_scene.instantiate()
	get_tree().root.add_child(pd)
	await get_tree().process_frame

	# Test 1: First choice node
	pd.show_node({
		"speaker": "Penjaga Hutan",
		"portrait": "penjaga_hutan",
		"teks": "Akar pohon itu semacam spons raksasa, nak.",
		"choices": [
			{"teks": "Baiklah Pak, biar saya bantu menanam bibitnya."},
			{"teks": "Yah, daripada rumahku kerendam lumpur lagi, sini saya bantu, Pak."}
		]
	})
	pd._finish_typewriter()
	await get_tree().process_frame

	# Before tapping: dialogue_frame is VISIBLE
	_check(pd.dialogue_frame.visible, "dialogue_frame is VISIBLE during dialogue text")
	_check(pd.speaker_label.text == "Penjaga Hutan", "speaker_label shows 'Penjaga Hutan'")
	_check(not pd.choice_modal.visible, "choice_modal is NOT YET visible while reading")

	# Tap to transition to choices
	pd._on_tap()
	await get_tree().process_frame
	await get_tree().process_frame

	# After tapping: dialogue_frame is HIDDEN, choice_modal is VISIBLE at bottom
	_check(not pd.dialogue_frame.visible, "dialogue_frame is HIDDEN when choice modal opens")
	_check(pd.choice_modal.visible, "choice_modal is VISIBLE at bottom")

	var title = pd.choice_modal.get_node_or_null("ChoicePanel/VBox/Title")
	var sep = pd.choice_modal.get_node_or_null("ChoicePanel/VBox/Sep")
	_check(title != null and title.visible, "Title '— PILIH RESPON —' is VISIBLE")
	_check(sep != null and sep.visible, "Sep HSeparator is VISIBLE")

	var h1 = absf(pd.choice_modal.offset_top - pd.choice_modal.offset_bottom)
	print("ChoiceModal height on 1st opening: %s px (top=%s, bot=%s)" % [h1, pd.choice_modal.offset_top, pd.choice_modal.offset_bottom])
	_check(h1 <= 140.0, "ChoiceModal height is compact (not huge/bloated)")
	_check(pd.choice_modal.offset_bottom == -4.0, "ChoiceModal offset_bottom is -4.0")

	# Test 2: Repeat with a second choice node (testing memory accumulation bug!)
	pd.show_node({
		"speaker": "Mamak",
		"portrait": "ibu",
		"teks": "Bisa bantu Mamak, nak?",
		"choices": [
			{"teks": "Bisa, Mak."},
			{"teks": "Tempatnya di mana ya, Mak?"}
		]
	})
	pd._finish_typewriter()
	pd._on_tap()
	await get_tree().process_frame
	await get_tree().process_frame

	var h2 = absf(pd.choice_modal.offset_top - pd.choice_modal.offset_bottom)
	print("ChoiceModal height on 2nd opening: %s px (top=%s, bot=%s)" % [h2, pd.choice_modal.offset_top, pd.choice_modal.offset_bottom])
	_check(h2 <= 140.0, "ChoiceModal height remains compact on repeated choices (BUG FIXED!)")
	_check(absf(h2 - h1) < 2.0, "ChoiceModal height did NOT grow/accumulate between dialogues")

	# Check button text formatting
	var buttons = pd.choices_container.get_children()
	_check(buttons.size() == 2, "2 choice buttons present")
	if buttons.size() >= 2:
		print("Btn 0: '%s'" % buttons[0].text)
		print("Btn 1: '%s'" % buttons[1].text)
		_check(not buttons[0].text.strip_edges().begins_with("A."), "Btn 0 has no 'A.' prefix")
		_check(not buttons[1].text.strip_edges().begins_with("B."), "Btn 1 has no 'B.' prefix")

	# Clean up
	pd.hide_box()
	pd.queue_free()

	print("\n=======================================================")
	print("TEST RESULT: %d PASSED, %d FAILED" % [_passed, _failed])
	print("=======================================================\n")
	if _failed > 0:
		get_tree().quit(1)
	else:
		get_tree().quit(0)

var _passed: int = 0
var _failed: int = 0

func _check(condition: bool, msg: String) -> void:
	if condition:
		print("  [PASS] %s" % msg)
		_passed += 1
	else:
		print("  [FAIL] %s" % msg)
		_failed += 1
