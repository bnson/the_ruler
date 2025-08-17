# NPCState.gd
extends Resource
class_name NPCState

## Trạng thái động của NPC (save/load)
## - Ôm toàn bộ chỉ số (combat + social) qua NPCStats
## - Lưu lịch sử quà tặng, re-emit signal khi stat đổi

signal affection_changed(npc_id: String, love: float, trust: float, lust: float)
signal combat_changed(npc_id: String, hp: float, mp: float, sta: float)
signal stats_changed(npc_id: String) # tổng quát, tiện cho UI refresh

@export var npc_id: String = ""
@export var stats: NPCStats = NPCStats.new()
@export var favorite_gifts: Array[String] = []   # quà ưa thích (ID/Name tuỳ bạn)
@export var given_gifts: Array[String] = []      # lịch sử quà đã tặng

func _init() -> void:
	# Đảm bảo Stats có giá trị mặc định hợp lý (nếu cần)
	if stats == null:
		stats = NPCStats.new()

func setup_signals_once() -> void:
	# Gọi hàm này sau khi gán stats (ví dụ từ save) để đảm bảo connect 1 lần
	if not stats.is_connected("stats_changed", _on_stats_changed):
		stats.stats_changed.connect(_on_stats_changed)
	if not stats.is_connected("affection_changed", _on_affection_changed):
		stats.affection_changed.connect(_on_affection_changed)

func receive_gift(item_id: String) -> void:
	# Logic quà → tăng chỉ số social
	var love_delta : float = 5.0 if item_id in favorite_gifts else 1.0
	var trust_delta : float = 3.0 if item_id in favorite_gifts else 1.0
	stats.add_stat_value("love", love_delta)
	stats.add_stat_value("trust", trust_delta)
	given_gifts.append(item_id)
	# (signals đã phát từ NPCStats → _on_affection_changed sẽ re-emit)

func take_damage(amount: float) -> void:
	var cur := stats.get_stat_value("current_hp")
	stats.set_stat_value("current_hp", max(0.0, cur - amount))
	# (stats_changed sẽ được phát tự động)

func heal(amount: float) -> void:
	var cur := stats.get_stat_value("current_hp")
	var max_hp := stats.get_stat_value("max_hp")
	stats.set_stat_value("current_hp", min(max_hp, cur + amount))

func spend_mp(cost: float) -> bool:
	var cur := stats.get_stat_value("current_mp")
	if cur >= cost:
		stats.set_stat_value("current_mp", cur - cost)
		return true
	return false

func spend_sta(cost: float) -> bool:
	var cur := stats.get_stat_value("current_sta")
	if cur >= cost:
		stats.set_stat_value("current_sta", cur - cost)
		return true
	return false

# ---------- Save/Load ----------
func to_dict() -> Dictionary:
		return {
				"npc_id": npc_id,
				"stats": stats.to_dict(),
				"favorite_gifts": favorite_gifts.duplicate(),
				"given_gifts": given_gifts.duplicate()
		}

func from_dict(d: Dictionary) -> void:
		npc_id = d.get("npc_id", npc_id)
		if d.has("stats"):
				stats.from_dict(d["stats"])
		favorite_gifts = d.get("favorite_gifts", favorite_gifts)
		given_gifts = d.get("given_gifts", given_gifts)
		# đảm bảo signal đã nối
		setup_signals_once()

# ---------- Re-emit nội bộ ----------
func _on_stats_changed() -> void:
	stats_changed.emit(npc_id)
	# tách nhanh 2 nhóm hay dùng:
	combat_changed.emit(
		npc_id,
		stats.get_stat_value("current_hp"),
		stats.get_stat_value("current_mp"),
		stats.get_stat_value("current_sta")
	)

func _on_affection_changed(love: float, trust: float, lust: float) -> void:
	affection_changed.emit(npc_id, love, trust, lust)
