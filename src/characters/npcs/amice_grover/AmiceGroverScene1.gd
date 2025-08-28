# AmiceGroverScene1.gd (Godot 4.x)
extends Node

# -------------------- Signals --------------------
signal action_changed(new_action: String)
signal tap_feedback(meter: float, count: int, tps: float)
signal round_resolved(player_won: bool, unwinnable: bool)  # kết thúc một lượt (round)
signal session_resolved(player_won: bool, total_rounds: int, wins: int, losses: int)  # kết thúc một phiên (session)

# -------------------- Node refs --------------------
@onready var sprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var info_label : Label = get_node_or_null("InfoLabel")
@onready var love_bar : ProgressBar = get_node_or_null("Panel/Margin/HBoxContainer/Panel1/VBoxContainer/LoveBar")
@onready var tension_bar : ProgressBar = get_node_or_null("Panel/Margin/HBoxContainer/Panel1/VBoxContainer/TensionBar")
@onready var message_box : Panel = get_node_or_null("Panel/Margin/MessageBox")
@onready var message_text : Label = get_node_or_null("Panel/Margin/MessageBox/MarginContainer/VBoxContainer/MessageText")

# -------------------- Config: Animation switching --------------------
@export var action_names := ["action_1", "action_2", "action_3"]
@export var use_tempo_based := false
@export var threshold_action_2 := 20
@export var threshold_action_3 := 50
@export var tempo_window_sec := 1.2
@export var tps_to_action_2 := 2.0
@export var tps_to_action_3 := 4.0

# -------------------- Config: Tap speed feel --------------------
@export var decay := 1.0
@export var tap_boost := 0.3
@export_range(0.1, 10.0) var speed_min := 1.0
@export_range(0.1, 10.0) var speed_max := 9.0

# -------------------- Config: Difficulty by power ratio r = NPC/Player --------------------
@export var ratio_unwinnable := 2.0     # r >= 2.0  -> thua chắc
@export var ratio_hard := 1.25          # 1.25 <= r < 2.0 -> khó
@export var ratio_medium_low := 0.85    # 0.85 <= r < 1.25 -> trung bình; r < 0.85 -> dễ

@export var base_tension_per_tap := 5.0
@export var base_love_per_tap := 5.0
@export var tension_min_per_tap := 0.4
@export var tension_max_per_tap := 15.0

# -------------------- Config: UI & flow --------------------
@export var tap_action_name := "amice_tap"
@export var show_info := false
@export var info_position := Vector2(12, 12)
@export var result_show_sec := 1.5

# Stamina theo lượt (giữ cơ chế nhiều lượt trong 1 phiên)
@export var stamina_cost_per_round := 50.0
@export var win_first_bonus := 10       # thắng lượt đầu phiên: +10 LOVE & +10 LUST
@export var win_chain_bonus := 2        # thắng mỗi lượt tiếp theo: +2

# -------------------- Runtime: tap meter & tempo --------------------
var tap_meter := 0.0
var tap_count := 0
var taps: Array[float] = []

# -------------------- Gameplay stats --------------------
# NPC stats (nhận từ hệ thống khác)
var current_npc_lust : float = 0.0
var current_npc_power_score : float = 0.0
var current_npc_love : float = 0.0

# Player stats (đọc từ GameState)
var player_power_score : float = 0.0
var player_stamina : float = 0.0  # vẫn dùng cho tiêu hao mỗi lượt, KHÔNG ảnh hưởng tension_gain

# LOVE/TENSION meters
var love := 0.0
var tension := 0.0
var overheated_threshold := 90.0

# Ngưỡng mục tiêu (đồng bộ từ progress bars nếu có)
var love_target := 100.0
var tension_target := 100.0

# Session nhiều lượt
var _session_active := false
var _session_wins := 0
var _session_losses := 0
var _session_any_loss := false

var npc_state : NPCState = null

# =========================================================
#                       LIFECYCLE
# =========================================================
func _ready():
	PlayerUi.visible = false
	DayNightController.visible = false

	npc_state = NpcStateManager.get_state(NpcInteractionManager.love_scene_npc_id)
	if npc_state:
		var stats = npc_state.stats
		current_npc_lust = stats.lust
		current_npc_power_score = stats.get_power_score()
		current_npc_love = stats.love

	var player_stats = GameState.player.stats
	player_power_score = player_stats.get_power_score()
	player_stamina = player_stats.current_sta

	print("Player power: %s, NPC power: %s" % [str(player_power_score), str(current_npc_power_score)])

	_validate_setup()
	_switch_action(action_names[0])
	sprite.play()

	if love_bar:
		love_bar.value = love
		love_target = love_bar.max_value
	if tension_bar:
		tension_bar.value = tension
		tension_target = tension_bar.max_value

	if message_box:
		message_box.visible = false

	_start_new_session()


func _process(delta: float) -> void:
	# Tap meter & animation speed
	tap_meter = max(0.0, tap_meter - decay * delta)
	var t : float = clamp(tap_meter / 5.0, 0.0, 1.0)
	sprite.speed_scale = lerp(speed_min, speed_max, t)

	# Update LOVE/TENSION
	_update_meters(delta)

	# Decide animation by TPS or total taps
	var tps := _current_tps()
	if use_tempo_based:
		_apply_action_by_tps(tps)
	else:
		_apply_action_by_total()

	emit_signal("tap_feedback", tap_meter, tap_count, tps)

	# Debug info
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


# =========================================================
#                      SESSION LOGIC
# =========================================================
func _start_new_session() -> void:
	_session_active = true
	_session_wins = 0
	_session_losses = 0
	_session_any_loss = false
	_reset_round()


func _end_session(apply_result: bool = true) -> void:
	_session_active = false

	# Kết quả phiên:
	# - Có bất kỳ lượt thua -> thua phiên: -20 LOVE/LUST
	# - Không có lượt thua, có ít nhất 1 lượt thắng -> thắng phiên:
	#     +10 cho lượt đầu + 2 cho mỗi lượt thắng tiếp theo
	var player_won_session := (not _session_any_loss) and (_session_wins > 0)

	if apply_result:
		if player_won_session:
			var gain : float = win_first_bonus + max(0, _session_wins - 1) * win_chain_bonus
			_apply_npc_delta(+gain)
			_show_result_message(true, _is_unwinnable_round())
		else:
			_apply_npc_delta(-20)
			_show_result_message(false, _is_unwinnable_round())

	emit_signal("session_resolved", player_won_session, _session_wins + _session_losses, _session_wins, _session_losses)


func _apply_npc_delta(delta: int) -> void:
	if npc_state:
		NpcStateManager.add_affection(npc_state.npc_id, delta, delta)
		current_npc_love = npc_state.stats.love
		current_npc_lust = npc_state.stats.lust
	else:
		current_npc_love = clamp(current_npc_love + delta, 0.0, 100.0)
		current_npc_lust = clamp(current_npc_lust + delta, 0.0, 100.0)


# =========================================================
#           LOVE/TENSION MINI-GAME (ratio-based)
# =========================================================
func _apply_tap_effects() -> void:
	if not _session_active:
		return

	var p = _difficulty_params()  # profile theo r = NPC/Player

	var t_gain : float = base_tension_per_tap * p.tension_mult
	var l_gain : float = base_love_per_tap * p.love_mult

	# đảm bảo không bằng 0 và không vượt trần
	t_gain = clamp(t_gain, tension_min_per_tap, tension_max_per_tap)

	# Nếu unwinnable: vẫn cho chạy để người chơi "cảm" độ khó, nhưng sẽ không thể thắng thật sự
	if _is_unwinnable_round():
		t_gain *= 2.0
		l_gain *= 0.5

	tension += t_gain
	love += l_gain

	_clamp_and_update_bars()


func _update_meters(delta: float) -> void:
	if not _session_active:
		return

	var p = _difficulty_params()

	# LOVE thụ động khi TENSION ở vùng dễ chịu quanh 50
	var lower : float = 50.0 - p.comfort_width * 0.5
	var upper : float = 50.0 + p.comfort_width * 0.5
	if tension >= lower and tension <= upper:
		love += (2.0 * p.love_mult) * delta

	# TENSION hồi/ phạt
	if tension < overheated_threshold:
		tension = max(0.0, tension - (p.tension_cool_rate) * delta)
	else:
		tension += p.overheat_penalty * delta

	_clamp_and_update_bars()

	# Kết thúc 1 lượt
	if love >= love_target:
		_on_round_win()
	elif tension >= tension_target:
		_on_round_loss()


func _on_round_win() -> void:
	# Unwinnable: cưỡng thua
	if _is_unwinnable_round():
		_on_round_loss()
		return

	_session_wins += 1
	emit_signal("round_resolved", true, false)

	# Trừ stamina theo lượt; nếu còn đủ để chơi lượt tiếp theo thì tiếp tục
	if _try_consume_stamina_and_continue():
		_reset_round()
	else:
		# Hết stamina -> chốt phiên (nếu không có lượt thua => thắng phiên)
		_end_session(true)


func _on_round_loss() -> void:
	_session_losses += 1
	_session_any_loss = true
	emit_signal("round_resolved", false, _is_unwinnable_round())
	# Chỉ cần 1 lượt thua -> thua cả phiên
	_end_session(true)


func _try_consume_stamina_and_continue() -> bool:
	# Trừ stamina cho lượt vừa hoàn tất; nếu còn đủ cho lượt tiếp theo thì tiếp tục
	var sta : float = GameState.player.stats.current_sta
	sta = max(0.0, sta - stamina_cost_per_round)
	GameState.player.stats.current_sta = sta
	player_stamina = sta
	return sta >= stamina_cost_per_round


# =========================================================
#                    HELPERS & UI
# =========================================================
func _reset_round() -> void:
	love = 0.0
	tension = 0.0
	tap_count = 0
	taps.clear()
	tap_meter = 0.0
	sprite.speed_scale = speed_min
	_clamp_and_update_bars()


func _clamp_and_update_bars() -> void:
	var love_max := love_bar.max_value if love_bar else 100.0
	var tension_max := tension_bar.max_value if tension_bar else 100.0

	love_target = love_max
	tension_target = tension_max

	love = clamp(love, 0.0, love_max)
	tension = clamp(tension, 0.0, tension_max)

	if love_bar:
		love_bar.value = love
	if tension_bar:
		tension_bar.value = tension


func _is_unwinnable_round() -> bool:
	var r := _power_ratio()
	return r >= ratio_unwinnable


func _power_ratio() -> float:
	if player_power_score <= 0.0:
		return 9999.0
	return current_npc_power_score / max(player_power_score, 0.001)


# Trả về profile độ khó theo r = NPC/Player
# Bạn có thể tinh chỉnh các hệ số để đạt "feel" mong muốn.
func _difficulty_params():
	var r := _power_ratio()

	# Mặc định: trung bình
	var params = {
		"tension_mult": 1.0,      # nhân vào base_tension_per_tap
		"love_mult": 1.0,         # nhân vào base_love_per_tap
		"comfort_width": 20.0,    # vùng dễ chịu quanh 50
		"tension_cool_rate": 3.0, # hồi Tension khi chưa quá nhiệt
		"overheat_penalty": 1.5   # phạt/giây khi >= overheated_threshold
	}

	if r >= ratio_unwinnable:
		# thua chắc (vẫn cho cảm giác cực khó)
		params.tension_mult = 2.0
		params.love_mult = 0.5
		params.comfort_width = 12.0
		params.tension_cool_rate = 2.0
		params.overheat_penalty = 2.5
		return params

	if r >= ratio_hard:
		# khó (tăng dần theo r)
		var t : float = (r - ratio_hard) / max(ratio_unwinnable - ratio_hard, 0.0001)
		params.tension_mult = lerp(1.4, 1.8, clamp(t, 0.0, 1.0))
		params.love_mult = 0.8
		params.comfort_width = 14.0
		params.tension_cool_rate = 2.5
		params.overheat_penalty = 2.0
		return params

	if r >= ratio_medium_low:
		# trung bình
		return params

	# dễ (player mạnh hơn rõ rệt)
	var ease : float = clamp((ratio_medium_low - r) / ratio_medium_low, 0.0, 1.0)
	params.tension_mult = lerp(0.8, 0.5, ease)
	params.love_mult = lerp(1.2, 1.6, ease)
	params.comfort_width = lerp(24.0, 32.0, ease)
	params.tension_cool_rate = lerp(3.5, 4.5, ease)
	params.overheat_penalty = lerp(1.2, 0.8, ease)
	return params


# -------------------- Animation switching --------------------
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


# -------------------- Tempo & taps --------------------
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


# -------------------- SpriteFrames helpers --------------------
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


# -------------------- Result messaging --------------------
func _show_result_message(player_won: bool, unwinnable: bool) -> void:
	var txt := ""
	if unwinnable and not player_won:
		txt = "[Unwinnable] Lost!"
	elif player_won:
		txt = "Win!"
	else:
		txt = "Lost!"
	_show_message(txt, result_show_sec)


func _show_message(txt: String, seconds: float) -> void:
	message_text.text = txt
	message_box.visible = true


func _on_ok_button_pressed() -> void:
	NpcInteractionManager.return_to_previous_scene()
