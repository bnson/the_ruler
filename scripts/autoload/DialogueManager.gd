### 📄 DialogueManager.gd (Autoload)
extends Node

signal dialogue_started(speaker: String, text: String, options: Array[Dictionary])
signal dialogue_ended
#signal dialogue_option_selected(option: Dictionary)
# Phát tín hiệu kèm NPC để hệ thống ngoài xử lý event tùy ý
signal dialogue_option_selected(npc: Node, option: Dictionary)

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

func show_next() -> void:
	if not active:
		return

	var node := dialogue_resource.get_node_by_id(current_node_id)
	var next_id : String = node.get("next", "")

	if next_id != "":
		current_node_id = next_id
		await get_tree().process_frame
		_show_current_node()
	else:
		end()

func select_option(option: Dictionary):
	if not active:
		return
	# Thông báo cho các hệ thống khác biết NPC và option vừa được chọn
	emit_signal("dialogue_option_selected", npc_node, option)
	var next_id : String = option.get("next", "")
	if next_id != "":
		current_node_id = next_id
		await get_tree().process_frame # ⏳ chờ 1 frame để DialogueUi xử lý UI cũ
		_show_current_node()
	else:
		end()

func end():
	active = false
	emit_signal("dialogue_ended")
	dialogue_resource = null
	npc_node = null
	current_node_id = ""
