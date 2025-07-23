extends Node

## === Player Stats ===
var level: int = 1
var experience: int = 0
var experience_to_next_level: int = 100

var hp: int = 100
var max_hp: int = 100

var sp: int = 50
var max_sp: int = 50

## === Base Attributes ===
var strength: int = 10
var agility: int = 8
var intelligence: int = 6

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
	reset_stats()
	strength += 2
	agility += 1
	intelligence += 1
	print("Level up! Now level %d" % level)
