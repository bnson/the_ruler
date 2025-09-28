extends Node

const DATA_PATH := "res://src/data/npc_chat_keywords.json"

var _npc_data: Dictionary = {}

func _ready() -> void:
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file:
		var parsed = JSON.parse_string(file.get_as_text())
		if typeof(parsed) == TYPE_DICTIONARY:
			_npc_data = parsed
		file.close()

func process_chat(npc: NPC, text: String) -> Dictionary:	
	if npc == null or text.is_empty():
		return {"love": 0, "reply": ""}

	var npc_id := npc.state.npc_id
	var cfg = _npc_data.get(npc_id, null)	
	if cfg == null:
		return {"love": 0, "reply": ""}

	text = text.to_lower()
	var love_gain : float = 0
	var reply : String = ""
	var keywords : Dictionary = cfg.get("keywords", {})

	for k in keywords.keys():
		if text.find(k) != -1:
			var val = keywords[k]
			if typeof(val) == TYPE_DICTIONARY:
				love_gain += float(val.get("love", 0))
				if reply == "":
					reply = String(val.get("reply", ""))
			else:
				love_gain += float(val)
	
	if love_gain > 0:
		var today := _get_today_key()
		var today_date = today.split("T")[0]
		var last_date = npc.state.last_chat_day.split("T")[0]
		if last_date != today_date:
			love_gain += float(cfg.get("daily_bonus", 0))
			npc.state.last_chat_day = today
	
	if reply == "":
		reply = String(cfg.get("default_reply", ""))
	
	return {"love": love_gain, "reply": reply}

func _get_today_key() -> String:
	return Time.get_datetime_string_from_system().split(" ")[0]
