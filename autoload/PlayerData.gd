extends Node

signal stats_changed

## === Player Stats ===
var level: int = 1:
	set(value):
		level = value
		emit_signal("stats_changed")

var experience: int = 0:
	set(value):
		experience = value
		emit_signal("stats_changed")

var experience_to_next_level: int = 100:
	set(value):
		experience_to_next_level = value
		emit_signal("stats_changed")

var hp: int = 100:
	set(value):
		hp = clamp(value, 0, max_hp)
		emit_signal("stats_changed")

var max_hp: int = 100:
	set(value):
		max_hp = value
		emit_signal("stats_changed")

var sp: int = 50:
	set(value):
		sp = clamp(value, 0, max_sp)
		emit_signal("stats_changed")

var max_sp: int = 50:
	set(value):
		max_sp = value
		emit_signal("stats_changed")

## === Base Attributes ===
var strength: int = 10:
	set(value):
		strength = value
		emit_signal("stats_changed")

var agility: int = 8:
	set(value):
		agility = value
		emit_signal("stats_changed")

var intelligence: int = 6:
	set(value):
		intelligence = value
		emit_signal("stats_changed")

## === Inventory & Skills ===
var inventory: Array = []
var skills: Dictionary = {}

## === Public Methods ===

func gain_experience(amount: int) -> void:
	experience += amount
	while experience >= experience_to_next_level:
		experience -= experience_to_next_level
		_level_up()

func reset_stats() -> void:
	hp = max_hp
	sp = max_sp

## === Private Methods ===

func _level_up() -> void:
	level += 1
	experience_to_next_level += 50
	max_hp += 10
	max_sp += 5
	strength += 2
	agility += 1
	intelligence += 1
	reset_stats()
	print("🎉 Level up! Now level %d" % level)
