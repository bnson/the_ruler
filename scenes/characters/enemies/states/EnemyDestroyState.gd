class_name EnemyDestroyState extends BaseState

func enter() -> void:
	print("Enemy destroy state enter...")
	state_machine.get_parent().animation_state.travel("DestroyState")

func physics_update(_delta: float, _input_vector := Vector2.ZERO) -> void:
	pass
