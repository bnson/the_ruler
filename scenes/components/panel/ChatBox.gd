class_name ChatBox
extends Control

var npc_interaction: Npc


func handle_interaction(npc: Npc) -> void:
	npc_interaction = npc
	show()

func _on_close_button_pressed() -> void:
	hide()
