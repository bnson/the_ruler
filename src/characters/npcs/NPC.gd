# NPC.gd
extends CharacterBody2D
class_name NPC

## NPC scene chỉ chịu trách nhiệm:
## - Phát hiện Player, phát tín hiệu "yêu cầu" (request_dialogue/shop/tooltip...)
## - Gọi các hàm trong NPCState (nhận quà, trừ máu...) khi cần
## - KHÔNG gọi trực tiếp UI hay DialogueManager → giảm coupling

# ---- Signals để hệ thống ngoài lắng nghe ----
signal player_entered(npc: NPC)
signal player_exited(npc: NPC)
signal request_dialogue(npc: NPC, res: DialogueResource, start_node_id: String)
signal request_shop(npc: NPC)

# ---- Config/UI/Dialogue ----
@export var display_name: String = "Unnamed NPC"
@export var dialogue_resource: DialogueResource
@export var start_node_id: String = "start"
@export var sell_items: Array[Item] = [] # nếu có shop

# ---- State (ôm Stats) ----
@export var state: NPCState = NPCState.new()

# ---- Nodes ----
@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	# Bảo vệ
	if state == null:
		state = NPCState.new()
	if state.npc_id.is_empty():
		state.npc_id = name
	
	state = NpcStateManager.register_state(state.npc_id, state)
	state.setup_signals_once()

	# Kết nối detection
	if detection_area:
		if not detection_area.body_entered.is_connected(_on_body_entered):
			detection_area.body_entered.connect(_on_body_entered)
		if not detection_area.body_exited.is_connected(_on_body_exited):
			detection_area.body_exited.connect(_on_body_exited)
	else:
		push_warning("NPC '%s' missing DetectionArea." % display_name)

	# (tuỳ chọn) group để World/Controller tự động connect
	if not is_in_group("NPCs"):
		add_to_group("NPCs")

	# Debug nhẹ
	print("🟢 NPC Ready:", display_name)

# ---------- Detection ----------
func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_entered.emit(self)

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_exited.emit(self)

# ---------- Public API cho hệ thống ngoài gọi ----------
func interact_open_dialogue() -> void:
	if dialogue_resource:
		request_dialogue.emit(self, dialogue_resource, start_node_id)
	else:
		push_warning("NPC '%s' chưa gán dialogue_resource." % display_name)

func interact_open_shop() -> void:
	request_shop.emit(self)

# ---------- Helpers (tiện UI/logic) ----------
func get_stat(key: String) -> float:
	return state.stats.get_stat_value(key)

func set_stat(key: String, value: float) -> void:
	state.stats.set_stat_value(key, value)

func add_stat(key: String, delta: float) -> void:
	state.stats.add_stat_value(key, delta)

func hp_ratio() -> float:
	var cur : float = get_stat("current_hp")
	var mx : float = max(1.0, get_stat("max_hp"))
	return cur / mx

func love_ratio() -> float:
	var cur : float = get_stat("love")
	var mx : float = max(1.0, get_stat("max_love"))
	return cur / mx

func power_score() -> float:
	return state.stats.get_power_score()
