# NpcInteractionManager.gd
# Tự động kết nối tín hiệu của NPC để mở hội thoại khi người chơi tới gần
extends Node

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
