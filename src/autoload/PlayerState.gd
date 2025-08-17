### 📄 PlayerState.gd
extends Resource
class_name PlayerState

var stats: PlayerStats = PlayerStats.new()
var inventory: Inventory = Inventory.new()
var quest_log: QuestLog = QuestLog.new()

func to_dict() -> Dictionary:
	return {
		"stats": stats.to_dict(),
		"inventory": inventory.to_dict(),
		"quest": quest_log.to_dict()
	}

func from_dict(data: Dictionary):
	stats.from_dict(data.get("stats", {}))
	inventory.from_dict(data.get("inventory", {}))
	quest_log.from_dict(data.get("quest", {}))
