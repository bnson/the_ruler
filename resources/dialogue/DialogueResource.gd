# DialogueResource.gd
extends Resource
class_name DialogueResource

@export var nodes: Array[Dictionary] = []

func get_node_by_id(id: String) -> Dictionary:
	for node in nodes:
		if node.get("id", "") == id:
			return node
	return {}
