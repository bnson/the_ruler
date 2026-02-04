class_name StateBase
extends Node

@export var last_day_checked: int = -1

func reset_for_new_day(new_day: int) -> void:
	last_day_checked = new_day

func ensure_daily_sync(current_day: int) -> void:
	if last_day_checked != current_day:
		reset_for_new_day(current_day)

func to_dict() -> Dictionary:
	return {
		"last_day_checked": last_day_checked,
	}

func from_dict(data: Dictionary) -> void:
	last_day_checked = int(data.get("last_day_checked", last_day_checked))
