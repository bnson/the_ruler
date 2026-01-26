# SaveManager.gd
extends Node

const SAVE_PATH := "user://savegame.json"
var auto_save_timer: Timer
var game_data: Dictionary = {}

func _ready() -> void:
	# Tạo Timer cho Auto-Save.
	auto_save_timer = Timer.new()
	# 10s Save một lần.
	auto_save_timer.wait_time = 10.0
	auto_save_timer.one_shot = false
	auto_save_timer.autostart = false
	add_child(auto_save_timer)
	auto_save_timer.timeout.connect(on_auto_save_timeout)
	
func save_game() -> void:
	var data := {
		"player": PlayerManager.to_dict(),
		"inventory": InventoryManager.to_dict(),
		"npcs": NpcManager.to_dict(),
		"level": SceneManager.to_dict(),
	}
	
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	
	print("Save completed.")

func load_game(scene_container: Node, fade_layer: Node):
	if not FileAccess.file_exists(SAVE_PATH):
		push_error("File not found: ", SAVE_PATH)
		return

	var content = FileAccess.get_file_as_string(SAVE_PATH)
	game_data = JSON.parse_string(content)
	if typeof(game_data) != TYPE_DICTIONARY:
		push_error("JSON format error: ", SAVE_PATH)
		return
	
	SceneManager.from_dict(game_data.get("level", ""), scene_container, fade_layer)
	PlayerManager.from_dict(game_data.get("player", {})) 
	InventoryManager.from_dict(game_data.get("inventory", {}))
	NpcManager.from_dict(game_data.get("npcs", {}))

# Auto-save
func auto_save_start():
	auto_save_timer.start()
	print("Auto-save started.")

func auto_save_stop():
	auto_save_timer.stop()
	print("Auto-save stopped.")
	
func on_auto_save_timeout():
	save_game()
	print("Auto-save completed.")
	
