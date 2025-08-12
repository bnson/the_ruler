### 📄 Stats.gd 
extends Resource
class_name Stats

signal stats_changed

var level := 1:
	set(value):
		level = value
		emit_signal("stats_changed")

var experience := 0:
	set(value):
		experience = value
		emit_signal("stats_changed")

var hp := 100:
	set(value):
		hp = clamp(value, 0, max_hp)
		emit_signal("stats_changed")

var max_hp := 100:
	set(value):
		max_hp = value
		emit_signal("stats_changed")

var mp := 100:
	set(value):
		mp = clamp(value, 0, max_mp)
		emit_signal("stats_changed")

var max_mp := 100:
	set(value):
		max_mp = value
		emit_signal("stats_changed")

var strength := 10 #str
var dexterity := 5 #dex
var intelligence := 5 #int
var agility := 5 #agi

# EXP logic
func gain_experience(amount: int):
	experience += amount
	while experience >= get_exp_to_next_level(level):
		experience -= get_exp_to_next_level(level)
		_level_up()

func _level_up():
	level += 1
	max_hp += 10
	hp = max_hp
	max_mp += 5
	mp = max_mp

func get_exp_to_next_level(lvl: int) -> int:
	return int(100 * pow(lvl, 1.2))

func to_dict() -> Dictionary:
	return {
		"level": level,
		"experience": experience,
		"hp": hp,
		"max_hp": max_hp,
		"mp": mp,
		"max_mp": max_mp,
		"strength": strength,
		"dexterity": dexterity,
		"intelligence": intelligence,
		"agility": agility
	}

func from_dict(data: Dictionary):
	level = data.get("level", level)
	experience = data.get("experience", experience)
	hp = data.get("hp", hp)
	max_hp = data.get("max_hp", max_hp)
	mp = data.get("mp", mp)
	max_mp = data.get("max_mp", max_mp)
	strength = data.get("strength", strength)
	dexterity = data.get("dexterity", dexterity)
	intelligence = data.get("intelligence", intelligence)
	agility = data.get("agility", agility)
