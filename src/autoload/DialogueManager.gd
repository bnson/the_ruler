### 📄 DialogueManager.gd (Autoload)
extends Node

signal dialogue_started(entry: Dictionary)
signal dialogue_advanced(entry: Dictionary)
signal dialogue_options_shown(options: Array)
signal dialogue_ended
signal dialogue_option_selected(option_data: Dictionary)

var current_dialogue: Array = []
var current_index: int = 0
var npc_node: Node = null

func start(dialogue_data: Array, npc: Node):
	current_dialogue = dialogue_data
	current_index = 0
	npc_node = npc
	emit_signal("dialogue_started", current_dialogue[current_index])

func next():
	current_index += 1
	if current_index >= current_dialogue.size():
		emit_signal("dialogue_ended")
		return

	var entry = current_dialogue[current_index]
	if entry.has("options"):
		emit_signal("dialogue_options_shown", entry["options"])
	else:
		emit_signal("dialogue_advanced", entry)

func select_option(option_data: Dictionary):
	if option_data.has("next"):
		var next_id = option_data["next"]
		for i in range(current_dialogue.size()):
			if current_dialogue[i].get("id", "") == next_id:
				current_index = i
				emit_signal("dialogue_advanced", current_dialogue[i])
				return

	if option_data.has("event"):
		emit_signal("dialogue_option_selected", option_data)
		emit_signal("dialogue_ended")
