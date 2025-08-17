### 📄 BaseStats.gd
extends Resource
class_name BaseStats

# Base attributes
var base_strength := 10
var base_dexterity := 5
var base_intelligence := 5
var base_agility := 5

# Bonus attributes
var bonus_strength := 0
var bonus_dexterity := 0
var bonus_intelligence := 0
var bonus_agility := 0

# Level and EXP
var _level := 1
var _experience := 0

# HP
var _current_hp: float = 100
var _max_hp: float = 100

# MP
var _current_mp: float = 100
var _max_mp: float = 100

# STA (Stamina)
var _current_sta: float = 100
var _max_sta: float = 100

func _on_stat_updated(_stat_name: String) -> void:
    pass

var level:
    get: return _level
    set(value):
        _level = value
        _on_stat_updated("level")

var experience:
    get: return _experience
    set(value):
        _experience = value
        _on_stat_updated("experience")

var current_hp:
    get: return _current_hp
    set(value):
        _current_hp = clamp(value, 0, max_hp)
        _on_stat_updated("current_hp")

var max_hp:
    get: return _max_hp
    set(value):
        _max_hp = value
        if current_hp > _max_hp:
            current_hp = _max_hp
        _on_stat_updated("max_hp")

var current_mp:
    get: return _current_mp
    set(value):
        _current_mp = clamp(value, 0, max_mp)
        _on_stat_updated("current_mp")

var max_mp:
    get: return _max_mp
    set(value):
        _max_mp = value
        if current_mp > _max_mp:
            current_mp = _max_mp
        _on_stat_updated("max_mp")

var current_sta:
    get: return _current_sta
    set(value):
        _current_sta = clamp(value, 0, max_sta)
        _on_stat_updated("current_sta")

var max_sta:
    get: return _max_sta
    set(value):
        _max_sta = value
        if current_sta > _max_sta:
            current_sta = _max_sta
        _on_stat_updated("max_sta")

### FINAL ATTRIBUTES ###
func get_strength() -> int:
    return base_strength + bonus_strength

func get_dexterity() -> int:
    return base_dexterity + bonus_dexterity

func get_intelligence() -> int:
    return base_intelligence + bonus_intelligence

func get_agility() -> int:
    return base_agility + bonus_agility

### SERIALIZATION ###
func to_dict() -> Dictionary:
    return {
        "level": level,
        "experience": experience,
        "current_hp": current_hp,
        "max_hp": max_hp,
        "current_mp": current_mp,
        "max_mp": max_mp,
        "current_sta": current_sta,
        "max_sta": max_sta,
        "base_strength": base_strength,
        "base_dexterity": base_dexterity,
        "base_intelligence": base_intelligence,
        "base_agility": base_agility,
        "bonus_strength": bonus_strength,
        "bonus_dexterity": bonus_dexterity,
        "bonus_intelligence": bonus_intelligence,
        "bonus_agility": bonus_agility
    }

func from_dict(data: Dictionary) -> void:
    level = data.get("level", level)
    experience = data.get("experience", experience)

    current_hp = data.get("current_hp", current_hp)
    max_hp = data.get("max_hp", max_hp)

    current_mp = data.get("current_mp", current_mp)
    max_mp = data.get("max_mp", max_mp)

    current_sta = data.get("current_sta", current_sta)
    max_sta = data.get("max_sta", max_sta)

    base_strength = data.get("base_strength", base_strength)
    base_dexterity = data.get("base_dexterity", base_dexterity)
    base_intelligence = data.get("base_intelligence", base_intelligence)
    base_agility = data.get("base_agility", base_agility)

    bonus_strength = data.get("bonus_strength", bonus_strength)
    bonus_dexterity = data.get("bonus_dexterity", bonus_dexterity)
    bonus_intelligence = data.get("bonus_intelligence", bonus_intelligence)
    bonus_agility = data.get("bonus_agility", bonus_agility)

### AGGREGATED STATS ###
func get_all_stats() -> Dictionary:
    return {
        "level": level,
        "experience": experience,
        "current_hp": current_hp,
        "max_hp": max_hp,
        "current_mp": current_mp,
        "max_mp": max_mp,
        "current_sta": current_sta,
        "max_sta": max_sta,
        "strength": get_strength(),
        "dexterity": get_dexterity(),
        "intelligence": get_intelligence(),
        "agility": get_agility()
    }

func has_stat(key: String) -> bool:
    return get_all_stats().has(key)

func get_stat_value(key: String) -> float:
    var d := get_all_stats()
    return d.get(key, 0.0)

func set_stat_value(key: String, value: float) -> void:
    match key:
        "level": level = int(value)
        "experience": experience = int(value)
        "current_hp": current_hp = value
        "max_hp": max_hp = value
        "current_mp": current_mp = value
        "max_mp": max_mp = value
        "current_sta": current_sta = value
        "max_sta": max_sta = value
        "base_strength":
            base_strength = int(value)
            _on_stat_updated("base_strength")
        "base_dexterity":
            base_dexterity = int(value)
            _on_stat_updated("base_dexterity")
        "base_intelligence":
            base_intelligence = int(value)
            _on_stat_updated("base_intelligence")
        "base_agility":
            base_agility = int(value)
            _on_stat_updated("base_agility")
        "bonus_strength":
            bonus_strength = int(value)
            _on_stat_updated("bonus_strength")
        "bonus_dexterity":
            bonus_dexterity = int(value)
            _on_stat_updated("bonus_dexterity")
        "bonus_intelligence":
            bonus_intelligence = int(value)
            _on_stat_updated("bonus_intelligence")
        "bonus_agility":
            bonus_agility = int(value)
            _on_stat_updated("bonus_agility")
        _:
            push_warning("Unknown stat key: %s" % key)

func add_stat_value(key: String, delta: float) -> void:
    set_stat_value(key, get_stat_value(key) + delta)

# (Optional) Sức mạnh tổng hợp để so sánh nhanh “yếu hơn/mạnh hơn”
func get_power_score() -> float:
    return level * 10 + get_strength() * 2 + get_agility() + current_hp / 10.0

func get_exp_to_next_level(lvl: int) -> int:
    return int(100 * pow(lvl, 1.2))
