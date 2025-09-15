extends BaseState
class_name PlayerDeathState

func enter() -> void:
	#var player = state_machine.get_parent()
	#player.emit_signal("died")
	#SystemDialogs.show_message("You have died xxx")
	#player.respawn()
	var player = state_machine.get_parent()
	player.animation_state.travel("DeathState")
	player.emit_signal("died")
	await player.animation_tree.animation_finished
	SystemDialogs.show_message("You have died")
	player.respawn()
	state_machine.change_state("IdleState")
