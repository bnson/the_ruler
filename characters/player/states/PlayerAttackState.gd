class_name PlayerAttackState extends PlayerState

func enter() -> void:
	#print("Enter Attack")
	# Chuyển trạng thái animation chính
	var player = state_machine.get_parent();
	player.is_attacking = true
	player.animation_state.travel("AttackState")
	player.attack_effect_animation_tree.active = true
	player.attack_effect_animation_state.travel("AttackEffect")

	if player.has_node("Hitbox"):
		#print("AttackState: Hitbox activate")
		player.get_node("Hitbox").activate()


func physics_update(_delta: float) -> void:
	# Kiểm tra nếu animation đã kết thúc
	var player = state_machine.get_parent()
	var current_anim = player.animation_state.get_current_node()
	#print("current_anim: " + current_anim)

	if current_anim == "IdleState" or current_anim == "WalkState":
		player.attack_effect_animation_tree.active = false
		
		# Tắt hitbox khi kết thúc animation
		if player.has_node("Hitbox"):
			#print("AttackState: Hitbox deactivate")
			player.get_node("Hitbox").deactivate()
			player.is_attacking = false
		
		state_machine.change_state(current_anim)


func get_attack_vector() -> Vector2:
	#return state_machine.get_parent().animation_tree.get("parameters/Move/blend_position")
	return state_machine.get_parent().animation_tree.get("parameters/WalkState/blend_position")

func get_attack_direction() -> String:
	#var blend_pos = state_machine.get_parent().animation_tree.get("parameters/Move/blend_position")
	var blend_pos = state_machine.get_parent().animation_tree.get("parameters/WalkState/blend_position")
	if abs(blend_pos.x) > abs(blend_pos.y):
		return "right" if blend_pos.x > 0 else "left"
	else:
		return "down" if blend_pos.y > 0 else "up"
