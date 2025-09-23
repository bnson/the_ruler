extends Node
class_name BaseState

var state_machine: StateMachine = null

func enter() -> void:
	pass

func exit() -> void:
	pass

func physics_update(_delta: float, _input_vector := Vector2.ZERO) -> void:
	pass
