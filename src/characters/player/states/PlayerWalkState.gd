class_name PlayerWalkState extends PlayerState

func enter() -> void:
	#print("Enter player walk")
	state_machine.get_parent().animation_state.travel("WalkState")

func physics_update(_delta: float, input_vector: Vector2) -> void:
	#var input_vector = Vector2(
	#	Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
	#	Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	#)

	if input_vector.length() == 0:
		state_machine.change_state("IdleState")
	elif Input.is_action_just_pressed("attack"):
		state_machine.change_state("AttackState")
