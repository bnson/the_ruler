extends CanvasModulate

@export var gradient_texture: GradientTexture1D

const MINUTES_PER_DAY := 1440

func _ready():
	if TimeManager and not TimeManager.time_updated.is_connected(_on_time_updated):
		TimeManager.time_updated.connect(_on_time_updated)

	# Cập nhật ánh sáng ngay khi bắt đầu
	_on_time_updated(
		TimeManager.get_day_name(),
		TimeManager.hour,
		TimeManager.minute,
		TimeManager.is_daytime(),
		TimeManager.get_time_period()
	)

func _on_time_updated(_day_name: String, hour: int, minute: int, _is_daytime: bool, _time_period: String):
	var total_minutes := hour * 60 + minute
	var value := float(total_minutes) / MINUTES_PER_DAY
	self.color = gradient_texture.gradient.sample(value)
