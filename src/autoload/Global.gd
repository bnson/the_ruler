extends Node

var player: Node = null
#var player_scene: PackedScene = preload("res://characters/player/Player.tscn")
var player_scene: PackedScene = CharactersManager.get_character("Player")

# Đảm bảo Player đã được tạo
func ensure_player_exists() -> void:
	if player == null:
		player = player_scene.instantiate()

# Gỡ Player khỏi scene cũ (nếu có)
func detach_player() -> void:
	if player and player.get_parent():
		player.get_parent().remove_child(player)

# Gắn Player vào scene mới tại vị trí spawn
func attach_player_to(container: Node, spawn_position: Vector2) -> void:
	ensure_player_exists()
	detach_player()
	container.add_child(player)
	player.global_position = spawn_position
