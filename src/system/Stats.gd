### 📄 Stats.gd 
extends Resource
class_name Stats

signal stats_changed
signal current_hp_changed(new_value)
signal current_mp_changed(new_value)
signal current_sta_changed(new_value)
signal level_changed(new_level)

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
var experience := 0

# HP
var _current_hp : float = 100
var _max_hp : float = 100

# MP
var _current_mp : float = 100
var _max_mp : float = 100

# STA (Stamina)
var _current_sta : float = 100
var _max_sta : float = 100

### GETTERS / SETTERS ###
var level:
	get: return _level
	set(value):
		_level = value
		emit_signal("level_changed", value)
		emit_signal("stats_changed")

var current_hp:
	get: return _current_hp
	set(value):
		_current_hp = clamp(value, 0, max_hp)
		emit_signal("current_hp_changed", _current_hp)
		emit_signal("stats_changed")

var max_hp:
	get: return _max_hp
	set(value):
		_max_hp = value
		emit_signal("stats_changed")

var current_mp:
	get: return _current_mp
	set(value):
		_current_mp = clamp(value, 0, max_mp)
		emit_signal("current_mp_changed", _current_mp)
		emit_signal("stats_changed")

var max_mp:
	get: return _max_mp
	set(value):
		_max_mp = value
		emit_signal("stats_changed")

var current_sta:
	get: return _current_sta
	set(value):
		_current_sta = clamp(value, 0, max_sta)
		emit_signal("current_sta_changed", _current_sta)
		emit_signal("stats_changed")

var max_sta:
	get: return _max_sta
	set(value):
		_max_sta = value
		emit_signal("stats_changed")

### FINAL ATTRIBUTES ###
func get_strength() -> int:
	return base_strength + bonus_strength

func get_dexterity() -> int:
	return base_dexterity + bonus_dexterity

func get_intelligence() -> int:
	return base_intelligence + bonus_intelligence

func get_agility() -> int:
	return base_agility + bonus_agility

### LEVELING ###
func gain_experience(amount: int):
	experience += amount
	while experience >= get_exp_to_next_level(level):
		experience -= get_exp_to_next_level(level)
		_level_up()

func _level_up():
	level += 1
	max_hp += 10
	current_hp = max_hp
	max_mp += 5
	current_mp = max_mp
	max_sta += 8
	current_sta = max_sta

func get_exp_to_next_level(lvl: int) -> int:
	return int(100 * pow(lvl, 1.2))

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

func from_dict(data: Dictionary):
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
