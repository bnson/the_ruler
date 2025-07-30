extends Node

signal stats_changed

@onready var logger = Logger

# === Internal storage ===
var _level: int = 1
var _experience: int = 0
var _experience_to_next_level: int = get_exp_to_next_level(1)

var _hp: int = 100
var _max_hp: int = 100
var _sp: int = 50
var _max_sp: int = 50

var _strength: int = 10
var _defense: int = 12
var _agility: int = 8
var _intelligence: int = 6

# === Inventory & Skills ===
var inventory: Array = []
var skills: Dictionary = {}

# === Properties ===
var level: int:
	get: return _level
	set(value):
		_level = value
		emit_signal("stats_changed")

var experience: int:
	get: return _experience
	set(value):
		_experience = value
		emit_signal("stats_changed")

var experience_to_next_level: int:
	get: return _experience_to_next_level
	set(value):
		_experience_to_next_level = value
		emit_signal("stats_changed")

var hp: int:
	get: return _hp
	set(value):
		_hp = clamp(value, 0, max_hp)
		emit_signal("stats_changed")

var max_hp: int:
	get: return _max_hp
	set(value):
		_max_hp = value
		emit_signal("stats_changed")

var sp: int:
	get: return _sp
	set(value):
		_sp = clamp(value, 0, max_sp)
		emit_signal("stats_changed")

var max_sp: int:
	get: return _max_sp
	set(value):
		_max_sp = value
		emit_signal("stats_changed")

var strength: int:
	get: return _strength
	set(value):
		_strength = value
		emit_signal("stats_changed")

var defense: int:
	get: return _defense
	set(value):
		_defense = value
		emit_signal("stats_changed")

var agility: int:
	get: return _agility
	set(value):
		_agility = value
		emit_signal("stats_changed")

var intelligence: int:
	get: return _intelligence
	set(value):
		_intelligence = value
		emit_signal("stats_changed")

func _ready():
	load_player_data()

# === EXP & Leveling ===
func gain_experience(amount: int) -> void:
	experience += amount
	while experience >= experience_to_next_level:
		experience -= experience_to_next_level
		_level_up()

func _level_up() -> void:
	level += 1
	experience_to_next_level = get_exp_to_next_level(level)
	max_hp += 10
	max_sp += 5
	strength += 2
	defense += 2
	agility += 1
	intelligence += 1
	reset_stats()
	logger.debug_log("🎉 Level up! Now level %d" % level, "PlayerData", "Player")
	save_player_data()

func reset_stats() -> void:
	hp = max_hp
	sp = max_sp

func get_exp_to_next_level(lvl: int) -> int:
	return int(100 * pow(lvl, 1.2))

# === Save & Load ===
func save_player_data():
	var data = {
		"level": level,
		"experience": experience,
		"experience_to_next_level": experience_to_next_level,
		"hp": hp,
		"max_hp": max_hp,
		"sp": sp,
		"max_sp": max_sp,
		"strength": strength,
		"agility": agility,
		"intelligence": intelligence,
		"defense": defense
	}

	var path = "user://player_data.json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()

	logger.debug_log("✅ Player data saved to %s" % ProjectSettings.globalize_path(path), "PlayerData", "Player")
	TimeManager.save_time_to_file()

func load_player_data():
	if not FileAccess.file_exists("user://player_data.json"):
		logger.debug_warn("⚠️ No player data file found", "PlayerData", "Player")
		return

	var file = FileAccess.open("user://player_data.json", FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	if typeof(data) == TYPE_DICTIONARY:
		level = data.get("level", level)
		experience = data.get("experience", experience)
		experience_to_next_level = data.get("experience_to_next_level", experience_to_next_level)
		hp = data.get("hp", hp)
		max_hp = data.get("max_hp", max_hp)
		sp = data.get("sp", sp)
		max_sp = data.get("max_sp", max_sp)
		strength = data.get("strength", strength)
		agility = data.get("agility", agility)
		intelligence = data.get("intelligence", intelligence)
		defense = data.get("defense", defense)

		logger.debug_log("📥 Player data loaded successfully", "PlayerData", "Player")
	else:
		logger.debug_error("❌ Failed to parse player data", "PlayerData", "Player")

# === Load when player chooses "Continue" ===
func load_if_continue_game(should_continue: bool):
	if should_continue:
		load_player_data()
		TimeManager.load_time()
