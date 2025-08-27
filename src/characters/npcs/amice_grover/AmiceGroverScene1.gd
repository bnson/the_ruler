# AmiceGroverScene1.gd (Godot 4.x)
extends Node

signal action_changed(new_action: String)
signal tap_feedback(meter: float, count: int, tps: float)

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var info_label : Label = get_node_or_null("InfoLabel")
@onready var love_bar : ProgressBar = get_node_or_null("LoveBar")
@onready var tension_bar : ProgressBar = get_node_or_null("TensionBar")

@export var action_names := ["action_1", "action_2", "action_3"]

# Điều khiển tốc độ
@export var decay := 1.0
@export var tap_boost := 0.3
@export_range(0.1, 10.0) var speed_min := 1.0
@export_range(0.1, 10.0) var speed_max := 9.0

# Chế độ chuyển cấp
@export var use_tempo_based := false
@export var threshold_action_2 := 20
@export var threshold_action_3 := 50
@export var tempo_window_sec := 1.2
@export var tps_to_action_2 := 2.0
@export var tps_to_action_3 := 4.0

# Input
@export var tap_action_name := "amice_tap"

# UI
@export var show_info := false              # ẩn/hiện bảng thông tin
@export var info_position := Vector2(12, 12)

var tap_meter := 0.0
var tap_count := 0
var taps: Array[float] = []
#--
var current_npc_lust : float = 0
var current_npc_power_score : float = 0
#--
var player_power_score : float = 0
var player_stamina_player : float = 0


func _ready():
	PlayerUi.visible = false
	DayNightController.visible = false	
	
	_validate_setup()
	_switch_action(action_names[0])
	sprite.play()

	# Tạo label nếu chưa có
	if show_info and info_label == null:
		info_label = Label.new()
		info_label.name = "InfoLabel"
		info_label.position = info_position
		info_label.autowrap_mode = TextServer.AUTOWRAP_WORD
		add_child(info_label)

func _process(delta: float) -> void:
	# Giảm meter & cập nhật speed
	tap_meter = max(0.0, tap_meter - decay * delta)
	var t = clamp(tap_meter / 5.0, 0.0, 1.0)
	sprite.speed_scale = lerp(speed_min, speed_max, t)

	# Quyết định action
	var tps := _current_tps()
	if use_tempo_based:
		_apply_action_by_tps(tps)
	else:
		_apply_action_by_total()

	# Emit feedback
	emit_signal("tap_feedback", tap_meter, tap_count, tps)

	# Cập nhật thông tin hiển thị
	if show_info and info_label:
		var base_fps := _get_current_anim_fps()
		var eff_fps := base_fps * sprite.speed_scale
		var cur_anim := sprite.animation
		var cur_frame := sprite.frame
		var total_frames := _get_current_anim_frame_count()

		info_label.text = "Action: %s\nFPS: %.2f  (eff: %.2f)\nSpeedScale: %.2f\nTPS: %.2f\nMeter: %.2f\nTaps: %d\nFrame: %d / %d" % [
			cur_anim,
			base_fps, eff_fps,
			sprite.speed_scale,
			tps,
			tap_meter,
			tap_count,
			cur_frame + 1, total_frames
		]

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(tap_action_name):
		tap_meter += tap_boost
		tap_count += 1
		_push_tap_time()

# ---------- Helpers ----------
func _apply_action_by_total() -> void:
	var a1 = action_names[0]
	var a2 = action_names[1] if action_names.size() > 1 else a1
	var a3 = action_names[2] if action_names.size() > 2 else a2

	if tap_count >= threshold_action_3:
		_switch_action(a3)
	elif tap_count >= threshold_action_2:
		_switch_action(a2)
	else:
		_switch_action(a1)

func _apply_action_by_tps(tps: float) -> void:
	var a1 = action_names[0]
	var a2 = action_names[1] if action_names.size() > 1 else a1
	var a3 = action_names[2] if action_names.size() > 2 else a2

	if tps >= tps_to_action_3:
		_switch_action(a3)
	elif tps >= tps_to_action_2:
		_switch_action(a2)
	else:
		_switch_action(a1)

func _switch_action(name: String) -> void:
	if sprite.animation == name:
		return
	var sf := sprite.sprite_frames
	if sf == null or not sf.has_animation(name):
		push_warning("Animation '%s' không tồn tại trong SpriteFrames." % name)
		return
	sprite.animation = name
	sprite.frame = 0
	sprite.play()
	emit_signal("action_changed", name)

func _push_tap_time() -> void:
	var now := Time.get_unix_time_from_system()
	taps.append(now)
	while taps.size() > 0 and now - taps[0] > tempo_window_sec:
		taps.pop_front()

func _current_tps() -> float:
	if taps.is_empty():
		return 0.0
	var now := Time.get_unix_time_from_system()
	while taps.size() > 0 and now - taps[0] > tempo_window_sec:
		taps.pop_front()
	return float(taps.size()) / max(tempo_window_sec, 0.001)

func _get_current_anim_fps() -> float:
	var sf := sprite.sprite_frames
	if sf == null or not sf.has_animation(sprite.animation):
		return 0.0
	return sf.get_animation_speed(sprite.animation)

func _get_current_anim_frame_count() -> int:
	var sf := sprite.sprite_frames
	if sf == null or not sf.has_animation(sprite.animation):
		return 0
	return sf.get_frame_count(sprite.animation)

func _validate_setup() -> void:
	if sprite == null:
		push_error("Không tìm thấy AnimatedSprite2D.")
		return
	if sprite.sprite_frames == null:
		push_error("AnimatedSprite2D chưa gán SpriteFrames (Inspector -> sprite_frames).")
		return
	for n in action_names:
		if not sprite.sprite_frames.has_animation(n):
			push_warning("Thiếu animation: %s trong SpriteFrames." % n)
