extends Node

# Chuyển scene trực tiếp
func change_scene(path: String) -> void:
	if not ResourceLoader.exists(path):
		push_error("Scene không tồn tại: " + path)
		return

	var error = get_tree().change_scene_to_file(path)
	if error != OK:
		push_error("Không thể chuyển scene: " + path)

# Chuyển scene có hiệu ứng fade (CanvasLayer chứa FadeRect)
func change_scene_with_fade(path: String, fade_layer: CanvasLayer) -> void:
	if not ResourceLoader.exists(path):
		push_error("Scene không tồn tại: " + path)
		return

	var fade_rect = fade_layer.get_node("FadeRect") if fade_layer.has_node("FadeRect") else null
	if fade_rect:
		fade_rect.modulate.a = 0.0
		fade_rect.show()
		var tween = fade_rect.create_tween()
		tween.tween_property(fade_rect, "modulate:a", 1.0, 0.5)
		tween.finished.connect(func ():
			get_tree().change_scene_to_file(path)
		)
	else:
		change_scene(path)
