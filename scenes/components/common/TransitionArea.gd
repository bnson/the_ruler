extends Area2D
class_name TransitionArea

# Đường dẫn scene cần chuyển tới
@export_file( "*.tscn" ) var target_scene_path = ""
# Trạng thái để tránh chuyển scene nhiều lần
var is_transitioning := false


func _on_body_entered(body: Node2D) -> void:
	if is_transitioning:
		return
	
	if body.is_in_group("player"):
		print("Enter Level Transition Area....")
		change_scene()

func change_scene():
	if target_scene_path != "":
		is_transitioning = true
		await get_tree().process_frame
		#SceneManager.change_scene(target_scene_path)
		SceneManager.change_level_with_fade(target_scene_path)
	else:
		push_error("TransitionArea chưa có target_scene_path!")
