# NpcInteractionManager.gd
# Tự động kết nối tín hiệu của NPC để mở hội thoại khi người chơi tới gần
extends Node

# NPC đang ở love scene (lưu bằng npc_id)
var love_scene_npc_id: String = ""
# scene trước khi chuyển sang love scene
var _previous_scene_path: String = ""
var _previous_player_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Kết nối các NPC đã có trong scene
	for npc in get_tree().get_nodes_in_group("NPCs"):
		_setup_npc(npc)
	# Lắng nghe NPC được thêm mới
	get_tree().node_added.connect(_on_node_added)
	# Lắng nghe lựa chọn option trong hội thoại để xử lý shop
	DialogueManager.dialogue_option_selected.connect(_on_dialogue_option_selected)

func _on_node_added(node: Node) -> void:
	if node.is_in_group("NPCs"):
		_setup_npc(node)

func _setup_npc(npc: NPC) -> void:
	if not npc.player_entered.is_connected(_on_player_entered):
		npc.player_entered.connect(_on_player_entered)
	if not npc.player_exited.is_connected(_on_player_exited):
		npc.player_exited.connect(_on_player_exited)
	if not npc.request_dialogue.is_connected(_on_request_dialogue):
		npc.request_dialogue.connect(_on_request_dialogue)
	if not npc.request_shop.is_connected(_on_request_shop):
		npc.request_shop.connect(_on_request_shop)

func _on_player_entered(npc: NPC) -> void:
	npc.interact_open_dialogue()

func _on_player_exited(npc: NPC) -> void:
	if DialogueManager.active and DialogueManager.npc_node == npc:
		DialogueManager.end()

func _on_request_dialogue(npc: NPC, res: DialogueResource, start_node_id: String) -> void:
	DialogueManager.start(res, npc, start_node_id)

func _on_request_shop(npc: NPC) -> void:
	PlayerUi.show_shop(npc)

func _on_dialogue_option_selected(npc: NPC, option: Dictionary) -> void:
	var event_name = option.get("event", "")
	if event_name == "buy_sell":
		npc.interact_open_shop()
	elif event_name == "info":
		PlayerUi.show_npc_info(npc)
	elif event_name == "talk":
		PlayerUi.show_npc_chat(npc)
	elif event_name == "love":
		_start_love_scene(npc)

# Bắt đầu love scene với NPC
func _start_love_scene(npc: NPC) -> void:
	love_scene_npc_id = npc.state.npc_id
	_previous_scene_path = get_tree().current_scene.scene_file_path if get_tree().current_scene else ""
	_previous_player_position = Global.player.global_position if Global.player else Vector2.ZERO
	GameState.player_position = _previous_player_position
	
	if DialogueManager.active:
		DialogueManager.end()
	
	var folder := npc.state.npc_id.to_snake_case()
	var scene_path := "res://scenes/characters/npcs/%s/%sScene1.tscn" % [folder, npc.state.npc_id]
	
	if ResourceLoader.exists(scene_path):
		SceneManager.change_scene(scene_path)
	else:
		push_warning("Love scene not found for %s" % npc.state.npc_id)

# Quay lại scene trước đó
func return_to_previous_scene() -> void:
	love_scene_npc_id = ""
	if _previous_scene_path != "":
		GameState.player_position = _previous_player_position
		SceneManager.change_scene(_previous_scene_path)
		_previous_scene_path = ""
