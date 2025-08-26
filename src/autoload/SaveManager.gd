### 📄 SaveManager.gd
extends Node

const SAVE_PATH := "user://savegame.json"

var last_autosave_hour := -1

func _ready():
	TimeManager.time_updated.connect(_on_time_updated)
	load_game()
	last_autosave_hour = TimeManager.hour

func _on_time_updated(day_name, hour, minute, is_daytime, time_period):
	if minute == 0 and hour != last_autosave_hour:
		last_autosave_hour = hour
		save_game()

func save_game(path: String = SAVE_PATH):
	var player_state := GameState.player.to_dict()
	var pos : Vector2 = Global.player.global_position if Global.player else Vector2.ZERO
	
        var state := {
                "player": player_state,
                "time": TimeManager.to_dict(),
                "npcs": NpcStateManager.to_dict(),
                "player_position": [pos.x, pos.y],
                "saved_at": Time.get_datetime_string_from_system()
        }
	var file := FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(state))
	file.close()
	Logger.debug_log("Game saved", "SaveManager", "System")

func load_game(path: String = SAVE_PATH) -> bool:
	if not FileAccess.file_exists(path):
		Logger.debug_warn("No save file found", "SaveManager", "System")
		return false
		
	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	
	var state : Variant = JSON.parse_string(content)
	if typeof(state) != TYPE_DICTIONARY:
		Logger.debug_error("Failed to parse save file", "SaveManager", "System")
		return false

        var player_data : Variant = state.get("player", {})
        GameState.player.from_dict(player_data)

        TimeManager.from_dict(state.get("time", {}))
        NpcStateManager.from_dict(state.get("npcs", {}))
	
	var pos = state.get("player_position", null)
	if pos is Array and pos.size() == 2:
		GameState.player_position = Vector2(pos[0], pos[1])
	
	Logger.debug_log("Game loaded", "SaveManager", "System")
	return true

func get_save_timestamp(path: String = SAVE_PATH) -> String:
	if not FileAccess.file_exists(path):
		return ""
	var file := FileAccess.open(path, FileAccess.READ)
	var content := file.get_as_text()
	file.close()
	var state : Variant = JSON.parse_string(content)
	if typeof(state) == TYPE_DICTIONARY:
		return state.get("saved_at", "")
	return ""
