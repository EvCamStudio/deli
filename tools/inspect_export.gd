@tool
extends EditorScript

func _run() -> void:
	print("Inspecting Android export preset...")
	# Let's inspect EditorExport
	for i in range(EditorInterface.get_export_preset_count() if EditorInterface.has_method("get_export_preset_count") else 0):
		pass

