class_name EnemyAttackState extends EnemyState


func enter() -> void:
	print("Enemy attack state enter...")
	var enemy = state_machine.get_parent()
	enemy.is_attacking = true
	enemy.animation_state.travel("AttackState")
	
	if enemy.has_node("Hitbox"):
		enemy.get_node("Hitbox").activate()

func physics_update(_delta: float) -> void:
	var enemy = state_machine.get_parent()
	var current_anim = enemy.animation_state.get_current_node()

	if current_anim != "Attack":
		if enemy.has_node("Hitbox"):
			enemy.get_node("Hitbox").deactivate()
			enemy.is_attacking = false

		state_machine.change_state("IdleState")
