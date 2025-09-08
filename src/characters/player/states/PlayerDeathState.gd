extends BaseState
class_name PlayerDeathState

func enter() -> void:
	var player = state_machine.get_parent()
	player.emit_signal("died")
	SystemDialogs.show_message("You have died")
	player.respawn()
