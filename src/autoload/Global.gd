### 📄 Global.gd
extends Node

var player: Node = null
var player_scene: PackedScene = CharactersManager.get_character("Player")

func ensure_player_exists() -> void:
	if player == null:
		player = player_scene.instantiate()
		player.state = GameState.player  # Gán PlayerState

func detach_player() -> void:
	if player and player.get_parent():
		player.get_parent().remove_child(player)

func attach_player_to(container: Node, spawn_position: Vector2) -> void:
	ensure_player_exists()
	detach_player()
	#container.add_child(player)
	container.call_deferred("add_child", player)
	#player.global_position = spawn_position
	print("attach_player_to...")
	print(GameState.player_position)
	
	if GameState.player_position != Vector2.ZERO:
		player.global_position = GameState.player_position
		GameState.player_position = Vector2.ZERO
	else:
		player.global_position = spawn_position
