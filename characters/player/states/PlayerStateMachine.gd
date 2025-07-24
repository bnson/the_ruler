class_name PlayerStateMachine extends Node

var states: Dictionary = {}
var current_state: Node = null

func _ready() -> void:
	for child in get_children():
		states[child.name] = child
		child.state_machine = self
		child.set_process(false)
		child.set_physics_process(false)

func change_state(state_name: String) -> void:
	if current_state:
		current_state.exit()
		current_state.set_process(false)
		current_state.set_physics_process(false)

	current_state = states.get(state_name)
	if current_state:
		current_state.set_process(true)
		current_state.set_physics_process(true)
		current_state.enter()
	else:
		push_error("State not found: " + state_name)
