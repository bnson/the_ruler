class_name PlayerDeathState extends BaseState


func enter() -> void:
	var player = state_machine.get_parent()
	player.animation_state.travel("DeathState")
	await player.animation_tree.animation_finished
	await get_tree().create_timer(5.0).timeout
	player.emit_signal("died")
	SystemDialogs.show_message("You have died")
	player.respawn()
	state_machine.change_state("IdleState")
