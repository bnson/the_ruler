extends Resource
class_name QuestLog

var quests: Dictionary = {}  # quest_id -> trạng thái

func to_dict() -> Dictionary:
	return quests.duplicate()

func from_dict(data: Dictionary):
	quests = data.duplicate()
