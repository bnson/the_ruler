# NpcStateManager.gd
extends Node

var npc_states: Dictionary = {}

func register_state(npc_id: String, state: NPCState) -> NPCState:
	if npc_states.has(npc_id):
		return npc_states[npc_id]
	
	state.npc_id = npc_id
	npc_states[npc_id] = state
	
	return state

func get_state(npc_id: String) -> NPCState:
	return npc_states.get(npc_id)

func to_dict() -> Dictionary:
	var data := {}
	for id in npc_states.keys():
		var st: NPCState = npc_states[id]
		var d := st.to_dict()
		d["script"] = st.get_script().resource_path
		data[id] = d
	return data

func from_dict(data: Dictionary) -> void:
	npc_states.clear()
	for id in data.keys():
		var info: Dictionary = data[id]
		var script_path: String = info.get("script", "")
		var st: NPCState = NPCState.new()
		if script_path != "":
			st = load(script_path).new()
		st.npc_id = id
		st.from_dict(info)
		npc_states[id] = st
