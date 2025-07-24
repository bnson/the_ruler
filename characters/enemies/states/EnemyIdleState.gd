class_name EnemyIdleState extends EnemyState

var idle_timer := 0.0

func enter() -> void:
	print("Enemy idle state enter...")
	var enemy = state_machine.get_parent()
	enemy.velocity = Vector2.ZERO
	state_machine.get_parent().animation_state.travel("IdleState")
	idle_timer = 0.0

func physics_update(delta: float) -> void:
	idle_timer += delta
	if idle_timer >= 2.0:
		state_machine.change_state("PatrolState")
