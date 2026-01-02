# PlayerManager.gd
extends Node

const PLAYER_SCENE: PackedScene = preload("res://scenes/player/Player.tscn")

var player: Player

func _ready() -> void:
	# Khởi tạo player nếu chưa có
	if player == null:
		player = PLAYER_SCENE.instantiate() as Player
		if player == null:
			push_error("Không thể khởi tạo player từ PLAYER_SCENE.")
			return
	
	# Đảm bảo player không thuộc node khác
	var parent := player.get_parent()
	if parent:
		parent.remove_child(player)

	# Thêm player vào scene
	add_child(player)

func set_player_position(position: Vector2) -> void:
	if !player:
		push_error("Player chưa được khởi tạo. Không thể đặt position.")
	player.global_position = position

func get_player_position() -> Vector2:
	if !player:
		push_error("Player chưa được khởi tạo. Không thể lấy position.")
		return Vector2.ZERO
	return player.global_position

func to_dict() -> Dictionary:
	if !player:
		push_error("Player chưa được khởi tạo. Không thể lấy dictionary.")
		return {}
	#--
	return {
		"stats": player.stats.to_dict(),
		"position": [player.global_position.x, player.global_position.y]
	}

func from_dict(data: Dictionary) -> void:
	if !player:
		push_error("Player chưa được khởi tạo. Không thể áp dụng dictionary.")
	#--
	if data.has("stats"):
		player.stats.from_dict(data["stats"])
	if data.has("position"):
		var pos_array = data["position"]
		if pos_array is Array and pos_array.size() == 2:
			$Player.global_position = Vector2(pos_array[0], pos_array[1])
