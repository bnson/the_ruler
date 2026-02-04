class_name NpcState
extends StateBase

@export var ask_used: float = 0.0
@export var silence_used: float = 0.0
@export var visited_today: bool = false

func reset_for_new_day(new_day: int) -> void:
	super.reset_for_new_day(new_day)
	# Reset các quota/flag trong ngày
	ask_used = 0.0
	silence_used = 0.0
	visited_today = false

func to_dict() -> Dictionary:
	var d := super.to_dict()
	d.merge({
		"ask_used": ask_used,
		"silence_used": silence_used,
		"visited_today": visited_today,
	})
	return d

func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	ask_used = float(data.get("ask_used", ask_used))
	silence_used = float(data.get("silence_used", silence_used))
	visited_today = bool(data.get("visited_today", visited_today))
