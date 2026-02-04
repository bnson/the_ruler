extends Node

# ===== CONFIG =====
@export var ticks_per_second := 1.0        # 1 tick/giây real
@export var minutes_per_tick := 1          # mỗi tick = 1 phút ingame

@export var minutes_per_hour := 60
@export var hours_per_day := 24

# Thời điểm bắt đầu (ingame)
@export var start_hour := 6
@export var start_day := 1

# ===== STATE =====
var minute: int = 0
var hour: int = 0
var day: int = 1

var paused := false

# Nội bộ
var _accumulator := 0.0
var _tick_interval := 1.0  # sẽ tính từ ticks_per_second

# ===== SIGNALS =====
signal tick(delta_minutes: int)      # tick xảy ra
signal minute_changed(minute: int)
signal hour_changed(hour: int)
signal day_changed(day: int)
signal time_changed(day: int, hour: int, minute: int)

func _ready() -> void:
	_tick_interval = 1.0 / max(ticks_per_second, 0.0001)
	# khởi tạo thời gian bắt đầu
	hour = clampi(start_hour, 0, hours_per_day - 1)
	day = max(1, start_day)

func _process(delta: float) -> void:
	if paused:
		return
	_accumulator += delta
	while _accumulator >= _tick_interval:
		_accumulator -= _tick_interval
		_do_tick()

func _do_tick() -> void:
	# 1 tick = minutes_per_tick phút ingame
	_advance_minutes(minutes_per_tick)
	emit_signal("tick", minutes_per_tick)

func _advance_minutes(delta_minutes: int) -> void:
	var total_minutes := minute + delta_minutes
	while total_minutes >= minutes_per_hour:
		total_minutes -= minutes_per_hour
		_advance_hour()
	minute = total_minutes
	emit_signal("minute_changed", minute)
	emit_signal("time_changed", day, hour, minute)

func _advance_hour() -> void:
	hour += 1
	if hour >= hours_per_day:
		hour = 0
		day += 1
		emit_signal("day_changed", day)
	emit_signal("hour_changed", hour)

# ===== API tiện dụng =====
func set_paused(p: bool) -> void:
	paused = p

func set_speed(new_ticks_per_second: float) -> void:
	ticks_per_second = max(new_ticks_per_second, 0.0001)
	_tick_interval = 1.0 / ticks_per_second

func skip_minutes(m: int) -> void:
	# bỏ qua _process, tiến thời gian ngay (dùng khi ngủ/skip time)
	if m <= 0:
		return
	_advance_minutes(m)

func skip_hours(h: int) -> void:
	if h <= 0:
		return
	for i in h:
		_advance_minutes(minutes_per_hour)

func skip_to(hour_target: int, minute_target: int = 0) -> void:
	# nhảy tới thời điểm trong cùng ngày (nếu đã qua thì sang ngày sau)
	hour_target = clampi(hour_target, 0, hours_per_day - 1)
	minute_target = clampi(minute_target, 0, minutes_per_hour - 1)

	var current_total := hour * minutes_per_hour + minute
	var target_total := hour_target * minutes_per_hour + minute_target
	var delta := target_total - current_total
	if delta < 0:
		delta += hours_per_day * minutes_per_hour  # sang ngày sau
	_advance_minutes(delta)

func get_time_string() -> String:
	return "%02d:%02d" % [hour, minute]

func is_between_hours(from_h: int, to_h: int) -> bool:
	# true nếu giờ hiện tại thuộc [from_h, to_h] (vòng qua 0 nếu to_h < from_h)
	from_h = clampi(from_h, 0, hours_per_day - 1)
	to_h = clampi(to_h, 0, hours_per_day - 1)
	if from_h <= to_h:
		return hour >= from_h and hour <= to_h
	else:
		return (hour >= from_h) or (hour <= to_h)

# ===== SAVE / LOAD =====
func to_dict() -> Dictionary:
	return {
		"minute": minute,
		"hour": hour,
		"day": day,
	}

func from_dict(data: Dictionary) -> void:
	minute = int(data.get("minute", minute))
	hour = int(data.get("hour", hour))
	day = int(data.get("day", day))
