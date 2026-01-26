# NpcManager.gd
extends Node

var npcs: Dictionary = {}
var registry: Dictionary = {}

# --- API runtime ---
func register(npc: Npc) -> void:
	var id: String = npc.id
	registry[id] = npc
	if npcs.has(id):
		apply_to_npc(npc, npcs[id])

func apply_loaded_state() -> void:
	for id in npcs.keys():
		var npc: Npc = registry.get(id)
		if is_instance_valid(npc):
			apply_to_npc(npc, npcs[id])

func apply_to_npc(npc: Npc, data: Dictionary) -> void:
	if npc.has_method("load_save_data"):
		npc.load_save_data(data)
		return
	if npc.has_variable("stats") and npc.stats and npc.stats.has_method("from_dict"):
		npc.stats.from_dict(data)

func unregister(npc: Npc) -> void:
	if not npc:
		return
	if registry.get(npc.id) == npc:
		registry.erase(npc.id)

func get_npc(id: String) -> Node:
	return registry.get(id)

func clear_runtime() -> void:
	registry.clear()

func collect_for_save() -> void:
	for id in registry.keys():
		var npc: Node = registry[id]
		if not is_instance_valid(npc):
			continue
		var data := extract_from_npc(npc)
		if not data.is_empty():
			npcs[id] = data

func to_dict() -> Dictionary:
	collect_for_save()
	return npcs.duplicate(true)

func from_dict(data: Dictionary) -> void:
	if typeof(data) == TYPE_DICTIONARY:
		npcs = data.duplicate(true)
	else:
		npcs.clear()
	apply_loaded_state()

func extract_from_npc(npc: Node) -> Dictionary:
	if npc.has_method("to_save_data"):
		return npc.to_save_data()
	if npc.has_variable("stats") and npc.stats and npc.stats.has_method("to_dict"):
		return npc.stats.to_dict()
	return {}
