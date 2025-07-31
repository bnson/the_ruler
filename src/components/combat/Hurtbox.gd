extends Area2D

signal hit_received(damage: int, from_position: Vector2)

func _ready():
	# Thêm vào nhóm hurtbox để dễ quản lý
	add_to_group("hurtbox")
	# Kết nối tín hiệu khi có vùng khác đi vào
	connect("area_entered", Callable(self, "_on_area_entered"))

func _on_area_entered(area: Area2D) -> void:
	#print("Va chạm với:", area.name, " - ", area.monitoring)

	# Kiểm tra nếu area là hitbox, có phương thức get_damage và đang hoạt động
	#if area.is_in_group("hitbox") and area.has_method("get_damage") and area.monitoring:
	if area.is_in_group("hitbox") and area.has_method("get_damage"):
		var damage = area.get_damage()
		var from_position = area.global_position
		var attacker = area.get_attacker() if area.has_method("get_attacker") else null

		if attacker and "is_attacking" in attacker and attacker.is_attacking:
			#print("Bị tấn công bởi: ", attacker.name)
			emit_signal("hit_received", damage, from_position)
		else:
			#print("Va chạm nhưng không phải tấn công, có thể bị phản công.")
			return
