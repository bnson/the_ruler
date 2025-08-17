# NPCStats.gd
extends Resource
class_name NPCStats

signal stats_changed
signal affection_changed(love, trust, lust)

# Level/EXP (nếu NPC cũng có)
var level := 1
var experience := 0

# Combat
var current_hp: float = 100
var max_hp: float = 100
var current_mp: float = 0
var max_mp: float = 0
var current_sta: float = 100
var max_sta: float = 100

# Social
var love: float = 0
var max_love: float = 100
var trust: float = 0
var max_trust: float = 100
var lust: float = 0
var max_lust: float = 100

# (Tuỳ chọn) Thuộc tính cơ bản nếu bạn cần so sánh “power”
var base_strength := 6
var base_dexterity := 5
var base_intelligence := 5
var base_agility := 5
var bonus_strength := 0
var bonus_dexterity := 0
var bonus_intelligence := 0
var bonus_agility := 0

### Helpers phát signal + clamp
func _set_and_emit(prop: String, v: float, minv: float, maxv: float) -> void:
	var nv = clamp(v, minv, maxv)
	set(prop, nv)
	if prop in ["love","trust","lust"]:
		affection_changed.emit(love, trust, lust)
	stats_changed.emit()

### Bridge API (đồng bộ với Player)
func has_stat(key: String) -> bool:
	return get_all_stats().has(key)

func get_stat_value(key: String) -> float:
	var d := get_all_stats()
	return d.get(key, 0.0)

func set_stat_value(key: String, value: float) -> void:
	match key:
		"level": level = int(value)
		"experience": experience = int(value)
		"current_hp": _set_and_emit("current_hp", value, 0, max_hp)
		"max_hp":
			max_hp = value
			current_hp = min(current_hp, max_hp)
			stats_changed.emit()
		"current_mp": _set_and_emit("current_mp", value, 0, max_mp)
		"max_mp":
			max_mp = value
			current_mp = min(current_mp, max_mp)
			stats_changed.emit()
		"current_sta": _set_and_emit("current_sta", value, 0, max_sta)
		"max_sta":
			max_sta = value
			current_sta = min(current_sta, max_sta)
			stats_changed.emit()
		"love": _set_and_emit("love", value, 0, max_love)
		"max_love":
			max_love = value
			love = min(love, max_love); stats_changed.emit()
		"trust": _set_and_emit("trust", value, 0, max_trust)
		"max_trust":
			max_trust = value
			trust = min(trust, max_trust); stats_changed.emit()
		"lust": _set_and_emit("lust", value, 0, max_lust)
		"max_lust":
			max_lust = value
			lust = min(lust, max_lust); stats_changed.emit()
		"base_strength": base_strength = int(value); stats_changed.emit()
		"base_dexterity": base_dexterity = int(value); stats_changed.emit()
		"base_intelligence": base_intelligence = int(value); stats_changed.emit()
		"base_agility": base_agility = int(value); stats_changed.emit()
		"bonus_strength": bonus_strength = int(value); stats_changed.emit()
		"bonus_dexterity": bonus_dexterity = int(value); stats_changed.emit()
		"bonus_intelligence": bonus_intelligence = int(value); stats_changed.emit()
		"bonus_agility": bonus_agility = int(value); stats_changed.emit()
		_:
			push_warning("Unknown stat key: %s" % key)

func add_stat_value(key: String, delta: float) -> void:
	set_stat_value(key, get_stat_value(key) + delta)

### Tổng hợp cho Requirement/Effect/UI
func get_strength() -> int:
	return base_strength + bonus_strength
func get_dexterity() -> int:
	return base_dexterity + bonus_dexterity
func get_intelligence() -> int:
	return base_intelligence + bonus_intelligence
func get_agility() -> int:
	return base_agility + bonus_agility

func get_all_stats() -> Dictionary:
	return {
		"level": level, "experience": experience,
		"current_hp": current_hp, "max_hp": max_hp,
		"current_mp": current_mp, "max_mp": max_mp,
		"current_sta": current_sta, "max_sta": max_sta,
		"love": love, "max_love": max_love,
		"trust": trust, "max_trust": max_trust,
		"lust": lust, "max_lust": max_lust,
		"strength": get_strength(),
		"dexterity": get_dexterity(),
		"intelligence": get_intelligence(),
		"agility": get_agility()
	}

# (Tuỳ chọn) So sánh sức mạnh nhanh
func get_power_score() -> float:
	return level * 10 + get_strength() * 2 + get_agility() + current_hp / 10.0
