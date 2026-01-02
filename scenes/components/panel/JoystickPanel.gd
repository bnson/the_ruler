class_name JoystickPanel
extends Control

#========================================================
# Nodes
@onready var base: TextureRect = $Base
@onready var knob: TextureRect = $Knob

#========================================================
# Config
const MAX_DISTANCE := 15.0 # bán kính joystick (pixel)
var is_touching := false
var touch_index := -1
var raw_vector := Vector2.ZERO

#========================================================
# Update loop
func _process(_delta: float) -> void:
	var center := base.position + base.size * 0.5

	if is_touching:
		var clamped := raw_vector.limit_length(MAX_DISTANCE)
		knob.position = center + clamped - knob.size * 0.5
	else:
		# reset knob về giữa
		knob.position = center - knob.size * 0.5
		raw_vector = Vector2.ZERO

#========================================================
# Input handling (touch + mouse)
func _unhandled_input(event: InputEvent) -> void:
	var global_center := base.get_global_transform().origin + base.size * 0.5
	
	# --- Touch begin / end ---
	if event is InputEventScreenTouch:
		if event.pressed and touch_index == -1:
			var local_pos = base.get_global_transform().affine_inverse() * event.position
			if local_pos.distance_to(base.size * 0.5) <= MAX_DISTANCE:
				touch_index = event.index
				is_touching = true
				raw_vector = event.position - global_center
		elif not event.pressed and event.index == touch_index:
			is_touching = false
			touch_index = -1
			raw_vector = Vector2.ZERO
	
	# --- Touch drag ---
	elif event is InputEventScreenDrag and is_touching and event.index == touch_index:
		raw_vector = event.position - global_center

#========================================================
# Trả về hướng normalized (-1 → 1)
func get_direction() -> Vector2:
	if is_touching and raw_vector.length() > 0:
		var direction := raw_vector.normalized()
		var strength : float = clamp(raw_vector.length() / MAX_DISTANCE, 0.0, 1.0)
		return direction * strength
	
	return Vector2.ZERO
