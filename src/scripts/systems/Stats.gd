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

var strength := 10
var defense := 5

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

func get_exp_to_next_level(lvl: int) -> int:
	return int(100 * pow(lvl, 1.2))

func to_dict() -> Dictionary:
	return {
		"level": level,
		"experience": experience,
		"hp": hp,
		"max_hp": max_hp,
		"strength": strength,
		"defense": defense
	}

func from_dict(data: Dictionary):
	level = data.get("level", level)
	experience = data.get("experience", experience)
	hp = data.get("hp", hp)
	max_hp = data.get("max_hp", max_hp)
	strength = data.get("strength", strength)
	defense = data.get("defense", defense)
