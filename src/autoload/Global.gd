### 📄 Global.gd
extends Node

var player: Player = null
var player_scene: PackedScene = CharactersManager.get_character("Player")

func ensure_player_exists() -> void:
	if player == null:
		player = player_scene.instantiate() as Player
		player.state = GameState.player  # Gán PlayerState

func detach_player() -> void:
	if player and player.get_parent():
		player.get_parent().remove_child(player)

func attach_player_to(container: Node, spawn_position: Vector2) -> void:
	ensure_player_exists()
	detach_player()

	container.call_deferred("add_child", player)

	# Đặt vị trí spawn
	if GameState.player_position != Vector2.ZERO:
		player.global_position = GameState.player_position
		GameState.player_position = Vector2.ZERO
	else:
		player.global_position = spawn_position
		
	# Inject UI components (decoupling)
	if PlayerUi.joystick and PlayerUi.attack_buttons:
		player.joystick = PlayerUi.joystick
		player.attack_buttons = PlayerUi.attack_buttons
	else:
		push_warning("PlayerUi chưa sẵn sàng hoặc thiếu joystick/attack_buttons.")	
