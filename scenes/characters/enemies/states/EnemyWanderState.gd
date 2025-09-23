extends BaseState
class_name EnemyWanderState

var direction := Vector2.ZERO
var change_timer := 0.0

func enter() -> void:
	change_direction()

func physics_update(delta: float, _input_vector := Vector2.ZERO) -> void:
	var enemy = state_machine.get_parent()
	change_timer -= delta
	if change_timer <= 0:
		change_direction()

	enemy.velocity = direction * enemy.speed
	enemy.move_and_slide()

func change_direction():
	direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	change_timer = randf_range(1.0, 3.0)
