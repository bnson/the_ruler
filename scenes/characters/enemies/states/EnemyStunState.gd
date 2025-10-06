class_name EnemyStunState extends BaseState

func enter() -> void:
	var enemy = state_machine.get_parent()
	enemy.animation_state.travel("StunState")
	print("Enemy stun state enter...")

func physics_update(delta: float, _input_vector := Vector2.ZERO) -> void:
	var enemy = state_machine.get_parent()
	var player = enemy.get_player()

	if enemy.knockback_timer > 0.0:
		enemy.velocity = enemy.knockback_vector
		enemy.knockback_timer = max(enemy.knockback_timer - delta, 0.0)
		enemy.move_and_slide()
		return
	enemy.velocity = Vector2.ZERO

	if not player:
		state_machine.change_state("PatrolState")
		return

	var distance = enemy.global_position.distance_to(player.global_position)

	if distance < 10:
		state_machine.change_state("AttackState")
	elif distance > 200:
		state_machine.change_state("PatrolState")
	else:
		state_machine.change_state("WalkState")
