extends Node

signal time_updated(day_name: String, hour: int, minute: int, is_daytime: bool, time_period: String)

enum TimePeriod { Morning, Noon, Afternoon, Evening }

@export var day_names: Array[String] = ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
@export var time_speed_levels: Array[int] = [3, 6, 12, 30, 60]

var current_day_index := 0
var hour := 6
var minute := 0

var time_speed := 60
var current_speed_index := 0
var is_paused := false

@onready var timer: Timer = Timer.new()

func _ready():
	print("TimeManager ready")
	timer.wait_time = 1.0 / time_speed
	timer.autostart = true
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func _on_timer_timeout():
	if is_paused:
		return
	#print("⏱️ Time tick: ", hour, minute)
	advance_time()

func advance_time():
	minute += 1
	if minute >= 60:
		minute = 0
		hour += 1
		if hour >= 24:
			hour = 0
			current_day_index = (current_day_index + 1) % day_names.size()

	emit_time_updated()

func emit_time_updated():
	emit_signal("time_updated", get_day_name(), hour, minute, is_daytime(), get_time_period())
	#print("Time mager send signal time updated")

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
	print("⏸️ Time paused.")

func resume_time():
	is_paused = false
	print("▶️ Time resumed.")

func set_time_speed(new_speed: float):
	time_speed = new_speed
	timer.wait_time = 1.0 / time_speed
	print("⏩ Time speed set to:", time_speed)

# -------------------------------
# 💾 Lưu và khôi phục thời gian
# -------------------------------

func save_time_state() -> Dictionary:
	return {
		"day_index": current_day_index,
		"hour": hour,
		"minute": minute
	}

func load_time_state(state: Dictionary):
	current_day_index = state.get("day_index", 0)
	hour = state.get("hour", 6)
	minute = state.get("minute", 0)
	emit_time_updated()
	print("🔄 Time state loaded:", get_day_name(), hour, minute)

# -------------------------------
# 🕒 Thông tin thời gian
# -------------------------------

func get_day_name() -> String:
	return day_names[current_day_index]

func is_daytime() -> bool:
	return hour >= 6 and hour < 18

func get_time_period() -> String:
	if hour >= 5 and hour < 11:
		return "Morning"
	elif hour >= 11 and hour < 13:
		return "Noon"
	elif hour >= 13 and hour < 18:
		return "Afternoon"
	else:
		return "Evening"  # Bao gồm 0–5 và 18–23

func get_time_progress_ratio() -> float:
	var total_minutes = hour * 60 + minute
	return float(total_minutes) / 1440.0
