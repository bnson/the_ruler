### 📄 DialogueManager.gd (Autoload)
extends Node

signal dialogue_started(speaker: String, text: String, options: Array[Dictionary])
signal dialogue_ended
signal dialogue_option_selected(option: Dictionary)

var dialogue_resource: DialogueResource
var npc_node: Node = null
var current_node_id: String = ""
var active := false

func start(resource: DialogueResource, npc: Node, start_id: String = "start") -> void:
	dialogue_resource = resource
	npc_node = npc
	current_node_id = start_id
	active = true
	_show_current_node()

func _show_current_node():
	var node := dialogue_resource.get_node_by_id(current_node_id)
	if node.is_empty():
		end()
		return
	emit_signal("dialogue_started", node.get("speaker", ""), node.get("text", ""), node.get("options", []))

func select_option(option: Dictionary):
	if not active:
		return
	
	emit_signal("dialogue_option_selected", option)

	var event : String = option.get("event", "")
	if npc_node and event != "":
		npc_node._on_option_selected(option)

	var next_id : String = option.get("next", "")
	if next_id != "":
		current_node_id = next_id
		_show_current_node()
	else:
		end()

func end():
	active = false
	emit_signal("dialogue_ended")
	dialogue_resource = null
	npc_node = null
	current_node_id = ""
