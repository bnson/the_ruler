# AmiceGroverScene1.gd (Godot 4.x)
extends Node

signal action_changed(new_action: String)
signal tap_feedback(meter: float, count: int, tps: float)
signal round_resolved(player_won: bool, unwinnable: bool) # thông báo round kết thúc

@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var info_label : Label = get_node_or_null("InfoLabel")
@onready var love_bar : ProgressBar = get_node_or_null("Panel/Margin/HBoxContainer/Panel1/VBoxContainer/LoveBar")
@onready var tension_bar : ProgressBar = get_node_or_null("Panel/Margin/HBoxContainer/Panel1/VBoxContainer/TensionBar")
@onready var message_box : Panel = get_node_or_null("Panel/Margin/MessageBox")
@onready var message_text : Label = get_node_or_null("Panel/Margin/MessageBox/MarginContainer/VBoxContainer/MessageText")

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
@export var result_show_sec := 1.5          # thời gian hiển thị kết quả thắng/thua

var tap_meter := 0.0
var tap_count := 0
var taps: Array[float] = []

# Gameplay stats ---------------------------------------------------------
# NPC stats được truyền từ nơi khác (ví dụ hệ thống hội thoại)
var current_npc_lust : float = 0.0
var current_npc_power_score : float = 0.0
var current_npc_love : float = 0.0

# Player stats
var player_power_score : float = 0.0
var player_stamina : float = 0.0 # ĐÃ ĐỔI TÊN từ player_stamina_player -> player_stamina

# Runtime meters dùng cho mini-game LOVE/TENSION
var love := 0.0
var tension := 0.0
var overheated_threshold := 90.0

# Timer tạm để xóa thông báo thắng/thua
var _result_timer: SceneTreeTimer = null


func _ready():
	PlayerUi.visible = false
	DayNightController.visible = false

	_validate_setup()
	_switch_action(action_names[0])
	sprite.play()

	# Initialise UI meters
	if love_bar:
		love_bar.value = love
	if tension_bar:
		tension_bar.value = tension
		
	# Ẩn message box lúc đầu
	if message_box:
		message_box.visible = false


func _process(delta: float) -> void:
	# Giảm meter & cập nhật speed
	tap_meter = max(0.0, tap_meter - decay * delta)
	var t = clamp(tap_meter / 5.0, 0.0, 1.0)
	sprite.speed_scale = lerp(speed_min, speed_max, t)

	# Update LOVE/TENSION mini-game meters
	_update_meters(delta)

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
		_apply_tap_effects()


# ---------- LOVE/TENSION mini-game logic ----------
func _apply_tap_effects() -> void:
	var lust_bonus := 1.0 + current_npc_lust * 0.1
	var stamina_reduction := 1.0 - player_stamina * 0.05
	var tension_gain := 5.0 * stamina_reduction * (1.0 - current_npc_lust * 0.05)
	var love_gain := 5.0 * lust_bonus
	if _is_unwinnable_round():
		tension_gain *= 2.0
		love_gain *= 0.5
	tension += tension_gain
	love += love_gain
	_clamp_and_update_bars()


func _update_meters(delta: float) -> void:
	# Passive love gain khi tension ở vùng thoải mái
	var comfort_width := 20.0 + current_npc_lust * 5.0
	var lower := 50.0 - comfort_width / 2.0
	var upper := 50.0 + comfort_width / 2.0
	if tension >= lower and tension <= upper:
		love += (2.0 * (1.0 + current_npc_lust * 0.2)) * delta

	# Tension giảm dần theo thời gian (trừ khi quá nóng)
	if tension < overheated_threshold:
		tension = max(0.0, tension - (3.0 * (1.0 + player_stamina * 0.2)) * delta)

	_clamp_and_update_bars()

	var unwinnable := _is_unwinnable_round()
	var love_max := love_bar.max_value if love_bar else 100.0
	var tension_max := tension_bar.max_value if tension_bar else 100.0
	if love >= love_max:
		_resolve_round(true, unwinnable)
	elif tension >= tension_max:
		_resolve_round(false, unwinnable)


func _resolve_round(player_won: bool, unwinnable: bool) -> void:
	if unwinnable:
		player_won = false

	# CLAMP các chỉ số NPC để tránh tràn
	if player_won:
		current_npc_love = clamp(current_npc_love + 1.0, 0.0, 100.0)
		current_npc_lust = clamp(current_npc_lust + 1.0, 0.0, 100.0)
	else:
		current_npc_love = clamp(current_npc_love - 1.0, 0.0, 100.0)
		current_npc_lust = clamp(current_npc_lust - 1.0, 0.0, 100.0)

	# Thông báo kết quả (label + signal)
	_show_result_message(player_won, unwinnable)
	emit_signal("round_resolved", player_won, unwinnable)

	_reset_round()


func _reset_round() -> void:
	love = 0.0
	tension = 0.0
	tap_count = 0
	taps.clear()
	tap_meter = 0.0
	# Reset tốc độ animation về mức tối thiểu cho vòng mới
	sprite.speed_scale = speed_min
	_clamp_and_update_bars()


func _clamp_and_update_bars() -> void:
	var love_max := love_bar.max_value if love_bar else 100.0
	var tension_max := tension_bar.max_value if tension_bar else 100.0
	love = clamp(love, 0.0, love_max)
	tension = clamp(tension, 0.0, tension_max)
	if love_bar:
		love_bar.value = love
	if tension_bar:
		tension_bar.value = tension


func _is_unwinnable_round() -> bool:
	if player_power_score <= 0.0:
		return true
	var epr : float = current_npc_power_score / max(player_power_score, 0.001)
	return epr >= 2.0


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


# --- CHỈNH: dùng mili-giây để đo TPS chính xác ---
func _push_tap_time() -> void:
	var now := Time.get_ticks_msec() / 1000.0
	taps.append(now)
	while taps.size() > 0 and now - taps[0] > tempo_window_sec:
		taps.pop_front()


func _current_tps() -> float:
	if taps.is_empty():
		return 0.0
	var now := Time.get_ticks_msec() / 1000.0
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


# ---------- Thông báo kết quả ----------
func _show_result_message(player_won: bool, unwinnable: bool) -> void:
	var txt := ""
	if unwinnable:
		txt = "[Unwinnable] Lost!"
	elif player_won:
		txt = "Win!"
	else:
		txt = "Lost!"
	
	_show_message(txt, result_show_sec)

func _show_message(txt: String, seconds: float) -> void:
	# Hủy timer cũ nếu đang chờ (để không đè nhau)
	if _result_timer:
		_result_timer = null
	
	message_text.text = txt
	message_box.visible = true
