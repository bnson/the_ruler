extends Node

#============================================================
var scene_container: Node = null
var fade_layer: Node = null
var current_scene: Node = null
var current_scene_file_path: String
var default_scene_file_path: String = "res://scenes/levels/level_01/Level01.tscn"

#============================================================
# Thiết lập container để chứa scene
func setup(container: Node, layer: Node) -> void:
	scene_container = container
	fade_layer = layer
	change_scene(current_scene_file_path)

# Chuyển màn
func change_scene(path: String) -> void:
	if scene_container == null:
		push_error("SceneManager chưa được setup!")
		return
	
	# Xóa màn cũ
	if current_scene:
		current_scene.queue_free()
	
	# Load màn mới
	if path.is_empty():
		current_scene_file_path = default_scene_file_path
	else:
		current_scene_file_path = path
	
	var new_scene = load(current_scene_file_path).instantiate()
	scene_container.add_child(new_scene)
	current_scene = new_scene
	print("[SceneManager] Changed level to: ", current_scene.scene_file_path)

# Chuyển màn với fade-in/out
func change_level_with_fade(path: String) -> void:
	var color_rect = fade_layer.get_node_or_null("ColorRect")

	if color_rect == null:
		change_scene(path)
		return
	
	# Fade-in: từ trong suốt -> đen
	color_rect.modulate.a = 0.0
	color_rect.show()
	
	var t_in := color_rect.create_tween()
	t_in.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t_in.tween_property(color_rect, "modulate:a", 1.0, 0.4)
	await t_in.finished
	
	# Chuyển màn
	change_scene(path)
	
	# Fade-out: từ đen -> trong suốt
	var t_out := color_rect.create_tween()
	t_out.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t_out.tween_property(color_rect, "modulate:a", 0.0, 0.35)
	await t_out.finished

	color_rect.hide()

func to_dict() -> String:
	if !current_scene:
		push_error("Current scene chưa được khởi tạo.")
		return ""
	#--
	return current_scene_file_path

func from_dict(data: String, container: Node, layer: Node) -> void:
	current_scene_file_path = data
	setup(container, layer)
