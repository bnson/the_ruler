class_name NpcStats
extends StatsBase

# Social stats
@export var love: float = 0
@export var max_love: float = 999
@export var trust: float = 0
@export var max_trust: float = 999
@export var lust: float = 0
@export var max_lust: float = 999


func from_dict(data: Dictionary) -> void:
	super.from_dict(data)
	love = data.get("love", love)
	max_love = data.get("max_love", max_love)
	trust = data.get("trust", trust)
	max_trust = data.get("max_trust", max_trust)
	lust = data.get("lust", lust)
	max_lust = data.get("max_lust", max_lust)

func to_dict() -> Dictionary:
	var d := super.to_dict()
	d.merge({
		"love": love, "max_love": max_love,
		"trust": trust, "max_trust": max_trust,
		"lust": lust, "max_lust": max_lust,
	})
	return d
