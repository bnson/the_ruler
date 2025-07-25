class_name EnemyIdleState extends EnemyState

@onready var node_name := get_name()

var idle_timer := 0.0

func enter() -> void:
	Logger.debug_log(node_name, "Enemy idle state enter...", "Enemy")
	var enemy = state_machine.get_parent()
	enemy.velocity = Vector2.ZERO
	state_machine.get_parent().animation_state.travel("IdleState")
	idle_timer = 0.0

func physics_update(delta: float) -> void:
	idle_timer += delta
	if idle_timer >= 2.0:
		state_machine.change_state("PatrolState")
