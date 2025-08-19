### 📄 PlayerState.gd
extends Resource
class_name PlayerState

var stats: PlayerStats = PlayerStats.new()
var inventory: Inventory = Inventory.new()
var quest_log: QuestLog = QuestLog.new()
var gold: int = 0

func to_dict() -> Dictionary:
        return {
                "stats": stats.to_dict(),
                "inventory": inventory.to_dict(),
                "gold": gold,
                "quest": quest_log.to_dict()
        }

func from_dict(data: Dictionary):
        stats.from_dict(data.get("stats", {}))
        inventory.from_dict(data.get("inventory", {}))
        gold = data.get("gold", gold)
        quest_log.from_dict(data.get("quest", {}))
