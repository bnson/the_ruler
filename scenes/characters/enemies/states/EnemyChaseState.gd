class_name EnemyChaseState extends BaseState


func enter() -> void:
	#print("Enemy Chase state enter...")
	state_machine.get_parent().animation_state.travel("ChaseState")

func physics_update(_delta: float, _input_vector := Vector2.ZERO) -> void:
	var enemy = state_machine.get_parent()
	var player = enemy.get_player()

	if not player:
		state_machine.change_state("PatrolState")
		return

	var distance = enemy.global_position.distance_to(player.global_position)

	if distance < 30:
		state_machine.change_state("AttackState")
	elif distance > 200:
		state_machine.change_state("PatrolState")
	else:
		var direction = (player.global_position - enemy.global_position).normalized()
		enemy.velocity = direction * enemy.speed
		enemy.move_and_slide()
