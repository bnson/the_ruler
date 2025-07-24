class_name EnemyWalkState extends EnemyState

func enter() -> void:
	print("Enemy walk state enter...")
	state_machine.get_parent().animation_state.travel("WalkState")

func physics_update(_delta: float) -> void:
	var enemy = state_machine.get_parent()
	var player = enemy.get_player()

	if not player:
		state_machine.change_state("PatrolState")
		return

	#var direction = (player.global_position - enemy.global_position).normalized()
	#enemy.velocity = direction * enemy.speed
	enemy.move_and_slide()

	if enemy.global_position.distance_to(player.global_position) < 30:
		state_machine.change_state("AttackState")
	elif enemy.global_position.distance_to(player.global_position) > 200:
		state_machine.change_state("PatrolState")
