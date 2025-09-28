extends Control
class_name Joystick

const MAX_DISTANCE := 15.0  # Bán kính joystick

@onready var stick: TextureRect = $Stick
@onready var base: TextureRect = $Base

var is_touching := false
var raw_vector := Vector2.ZERO
var touch_index := -1  # ID của ngón tay đang điều khiển joystick

func _process(_delta: float) -> void:
	var center := base.position + base.size / 2
	if is_touching:
		var clamped := raw_vector.limit_length(MAX_DISTANCE)
		stick.position = center + clamped - stick.size / 2
	else:
		stick.position = center - stick.size / 2
		raw_vector = Vector2.ZERO

func _unhandled_input(event: InputEvent) -> void:
	var global_center := base.get_global_transform().origin + base.size / 2

	if event is InputEventScreenTouch:
		if event.pressed and event.index == 0:
			if touch_index == -1:
				var local_pos : Vector2 = base.get_global_transform().affine_inverse() * event.position
				if local_pos.distance_to(base.size / 2) <= MAX_DISTANCE:
					touch_index = event.index
					is_touching = true
					raw_vector = event.position - global_center
		else:
			if event.index == touch_index:
				is_touching = false
				touch_index = -1
				raw_vector = Vector2.ZERO

	elif event is InputEventScreenDrag:
		if is_touching and event.index == touch_index:
			raw_vector = event.position - global_center

func get_direction() -> Vector2:
	if is_touching and raw_vector.length() > 0:
		var direction: Vector2 = raw_vector.normalized()
		var strength: float = clamp(raw_vector.length() / MAX_DISTANCE, 0.0, 1.0)
		var result := direction * strength
		result = snap_to_cardinal(result)
		return result
	else:
		return Vector2(
			Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
			Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
		).normalized()

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
