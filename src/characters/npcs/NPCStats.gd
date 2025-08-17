# NPCStats.gd
extends BaseStats
class_name NPCStats

signal stats_changed
signal affection_changed(love, trust, lust)

# Social stats
var _love: float = 0
var _max_love: float = 100
var _trust: float = 0
var _max_trust: float = 100
var _lust: float = 0
var _max_lust: float = 100

var love:
	get: return _love
	set(value):
		_love = clamp(value, 0, max_love)
		affection_changed.emit(_love, _trust, _lust)
		stats_changed.emit()

var max_love:
	get: return _max_love
	set(value):
		_max_love = value
		_love = min(_love, _max_love)
		stats_changed.emit()

var trust:
	get: return _trust
	set(value):
		_trust = clamp(value, 0, max_trust)
		affection_changed.emit(_love, _trust, _lust)
		stats_changed.emit()

var max_trust:
	get: return _max_trust
	set(value):
		_max_trust = value
		_trust = min(_trust, _max_trust)
		stats_changed.emit()

var lust:
	get: return _lust
	set(value):
		_lust = clamp(value, 0, max_lust)
		affection_changed.emit(_love, _trust, _lust)
		stats_changed.emit()

var max_lust:
	get: return _max_lust
	set(value):
		_max_lust = value
		_lust = min(_lust, _max_lust)
		stats_changed.emit()

func _on_stat_updated(_stat_name: String) -> void:
	stats_changed.emit()

func set_stat_value(key: String, value: float) -> void:
	match key:
		"love": love = value
		"max_love": max_love = value
		"trust": trust = value
		"max_trust": max_trust = value
		"lust": lust = value
		"max_lust": max_lust = value
		_:
			super.set_stat_value(key, value)

func get_all_stats() -> Dictionary:
	var d = super.get_all_stats()
	d.merge({
		"love": love, "max_love": max_love,
		"trust": trust, "max_trust": max_trust,
		"lust": lust, "max_lust": max_lust,
	})
	return d
