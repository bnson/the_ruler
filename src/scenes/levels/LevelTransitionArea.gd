extends Area2D

## Đường dẫn đến scene level tiếp theo
@export_file("*.tscn") var next_level_path: String

## Node chứa hiệu ứng fade (CanvasLayer)
@export_node_path("CanvasLayer") var fade_layer_path: NodePath

## Thời gian chờ trước khi gọi chuyển scene (giây)
@export_range(0.0, 5.0, 0.1) var delay: float = 0.2

## Tên node của player để kiểm tra
@export var player_node_name: String = "Player"

## Trạng thái để tránh chuyển scene nhiều lần
var is_transitioning := false

func _on_body_entered(body: Node) -> void:
	print("Enter Level Transition Area")
	
	if is_transitioning:
		return

	if body.name == player_node_name:
		is_transitioning = true
		await get_tree().create_timer(delay).timeout
		var fade_layer = get_node_or_null(fade_layer_path)
		if fade_layer and next_level_path:
			SceneManager.change_scene_with_fade(next_level_path, fade_layer)
		else:
			push_error("Không tìm thấy fade_layer hoặc đường dẫn scene không hợp lệ.")
