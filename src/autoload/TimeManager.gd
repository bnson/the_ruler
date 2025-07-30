extends Node

signal time_updated(day_name: String, hour: int, minute: int, is_daytime: bool, time_period: String)

@export var day_names: Array[String] = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
@export var time_speed_levels: Array[float] = [1.0, 1.5, 2.0, 3.0, 6.0]

const SAVE_PATH := "user://time_data.json"

var current_day_index := 0
var hour := 6
var minute := 0

var time_speed: float = 60.0
var current_speed_index := 0
var is_paused := false

@onready var timer: Timer = Timer.new()
var last_saved_hour := hour

func _ready():
	timer.wait_time = 1.0 / time_speed
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	Logger.debug_log("TimeManager ready", "TimeManager", "System")

func _on_timer_timeout():
	if is_paused:
		return
	Logger.debug_log("Tick", "TimeManager", "System")
	advance_time()

# -------------------------------
# ⏱️ Cập nhật thời gian
# -------------------------------

func advance_time():
	minute += 1
	if minute >= 60:
		minute = 0
		advance_hour()
	emit_time_updated()

func advance_hour():
	hour += 1
	if hour >= 24:
		hour = 0
		advance_day()

	# ⏳ Tự động lưu mỗi 1 giờ
	if hour != last_saved_hour:
		last_saved_hour = hour
		save_time()

func advance_day():
	current_day_index = (current_day_index + 1) % day_names.size()

func emit_time_updated():
	emit_signal("time_updated", get_day_name(), hour, minute, is_daytime(), get_time_period())

# -------------------------------
# 📌 Điều khiển thời gian
# -------------------------------

func increase_time_speed():
	current_speed_index = (current_speed_index + 1) % time_speed_levels.size()
	set_time_speed(time_speed_levels[current_speed_index])

func decrease_time_speed():
	current_speed_index = (current_speed_index - 1 + time_speed_levels.size()) % time_speed_levels.size()
	set_time_speed(time_speed_levels[current_speed_index])

func pause_time():
	is_paused = true
	Logger.debug_log("Time paused", "TimeManager", "System")

func resume_time():
	is_paused = false
	Logger.debug_log("Time resumed", "TimeManager", "System")

func set_time_speed(new_speed: float):
	time_speed = new_speed
	timer.wait_time = 1.0 / time_speed
	Logger.debug_log("Time speed set to: %.1f" % time_speed, "TimeManager", "System")

# -------------------------------
# 💾 Lưu và khôi phục thời gian
# -------------------------------

func save_time(path: String = SAVE_PATH):
	var state = {
		"day_index": current_day_index,
		"hour": hour,
		"minute": minute
	}
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(state))
	file.close()
	Logger.debug_log("Time saved to file", "TimeManager", "System")

func load_time(path: String = SAVE_PATH):
	if not FileAccess.file_exists(path):
		Logger.debug_warn("No time save file found", "TimeManager", "System")
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var state = JSON.parse_string(content)
	if typeof(state) == TYPE_DICTIONARY:
		current_day_index = state.get("day_index", 0)
		hour = state.get("hour", 6)
		minute = state.get("minute", 0)
		last_saved_hour = hour
		emit_time_updated()
		Logger.debug_log("Time loaded from file", "TimeManager", "System")
	else:
		Logger.debug_error("Failed to parse time save file", "TimeManager", "System")

# -------------------------------
# 🕒 Thông tin thời gian
# -------------------------------

func get_day_name() -> String:
	return day_names[current_day_index]

func is_daytime() -> bool:
	return hour >= 6 and hour < 18

func get_time_period() -> String:
	if hour >= 5 and hour < 11:
		return "☀️ Morning"
	elif hour >= 11 and hour < 13:
		return "🌞 Noon"
	elif hour >= 13 and hour < 18:
		return "🌇 Afternoon"
	else:
		return "🌙 Night"

func get_time_progress_ratio() -> float:
	var total_minutes = hour * 60 + minute
	return float(total_minutes) / 1440.0

func get_time_string() -> String:
	return "%s %02d:%02d (day %d)" % [get_day_name(), hour, minute, current_day_index + 1]
