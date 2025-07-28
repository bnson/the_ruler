extends Area2D

const MAX_DISTANCE := 10.0

@onready var handle := $Handle
@onready var background := $Background

var is_touching := false
var raw_vector := Vector2.ZERO

func _process(_delta: float) -> void:
	if is_touching:
		var clamped_vector := raw_vector.limit_length(MAX_DISTANCE)
		handle.global_position = global_position + clamped_vector
	else:
		handle.global_position = global_position
		raw_vector = Vector2.ZERO

# Khi chạm vào vùng joystick
func _input_event(_viewport, event, _shape_idx):
	if event is InputEventScreenTouch and event.pressed:
		is_touching = true
		raw_vector = event.position - global_position
	elif event is InputEventScreenDrag and is_touching:
		raw_vector = event.position - global_position

# Khi thả tay ở bất kỳ đâu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and not event.pressed:
		is_touching = false

func get_direction() -> Vector2:
	if is_touching and raw_vector.length() > 0:
		var direction: Vector2 = raw_vector.normalized()
		var strength: float = clamp(raw_vector.length() / MAX_DISTANCE, 0.0, 1.0)
		var result := direction * strength
		return snap_to_cardinal(result)
	else:
		return Vector2.ZERO

func snap_to_cardinal(vec: Vector2) -> Vector2:
	if vec.length() < 0.1:
		return Vector2.ZERO

	var angle := vec.angle()
	if abs(angle) < deg_to_rad(22.5):
		return Vector2.RIGHT
	elif abs(angle - PI) < deg_to_rad(22.5):
		return Vector2.LEFT
	elif abs(angle - PI / 2) < deg_to_rad(22.5):
		return Vector2.DOWN
	elif abs(angle + PI / 2) < deg_to_rad(22.5):
		return Vector2.UP

	return vec.normalized()
