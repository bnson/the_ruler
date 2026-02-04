class_name Npc
extends CharacterBody2D

#=============================================================
@export var id: String
@export var first_name: String
@export var last_name: String
@export var level: int
@export_multiline var information: String
@export var sell_items: Array[ItemData]
@export var interactions: Array[Dictionary]
@export var moods: Array[String] = ["happy", "neutral", "tired", "busy", "shy", "annoyed"]
@export var mood_change_interval := 60.0  # đổi mood mỗi 60 giây (có thể sửa)
# --- Cấu hình menu gốc (4 category) — có thể chỉnh theo NPC ---
# Cho phép đổi nhãn và bật/tắt theo từng NPC trong Inspector
@export var root_menu_config := {
	"ask": {"enabled": true,  "label": "Ask"},
	"stay_silent": {"enabled": true, "label": "Stay Silent"},
	"leave": {"enabled": true, "label": "Leave"}
}
# ---
@export_file("*.gd") var ask_bank_script: String = "res://systems/data/AskBank.gd"
@export_file("*.gd") var silence_bank_script: String = "res://systems/data/SilenceBank.gd"
@export var bank_key: StringName = &"default"
# ---
@export var daily_ask_points_cap: float = 9.0  # quota/ngày cho NPC này
@export var daily_silence_points_cap: float = 3.0

#=============================================================
@onready var stats: NpcStats
@onready var state: NpcState

#=============================================================
var current_mood: String = ""
var mood_last_changed := 0.0
var ask_interactions: Array = [] # Danh sách lựa chọn cho category "Ask"



#=============================================================
func _ready() -> void:
	roll_mood()
	load_ask_from_bank()
	# Đăng ký reset theo ngày
	GameClock.day_changed.connect(on_day_changed)
	ensure_daily_reset()

func load_ask_from_bank(use_merge_with_default := true) -> void:
	ask_interactions.clear()
	var scr := load(ask_bank_script)
	if scr == null:
		push_error("Cannot load AskBank: %s" % ask_bank_script)
		return
	
	var data: Array
	if use_merge_with_default:
		data = scr.call("get_merged_for_npc", bank_key, true)
	else:
		data = scr.call("get_pack", bank_key)
	
	if typeof(data) != TYPE_ARRAY:
		push_error("AskBank returned non-array for key: %s" % bank_key)
		return
	
	ask_interactions = data.duplicate(true)

func on_day_changed(new_day: int) -> void:
	if state:
		state.reset_for_new_day(new_day)

func ensure_daily_reset() -> void:
	if not (Engine.has_singleton("GameClock") or "GameClock" in Engine.get_singleton_list()):
		return
	if state:
		state.ensure_daily_sync(GameClock.day)

func roll_mood() -> void:
	if moods.is_empty():
		current_mood = "neutral"
		return
	
	current_mood = moods[randi() % moods.size()]
	mood_last_changed = Time.get_unix_time_from_system()

func get_current_mood() -> String:
	var now := Time.get_unix_time_from_system()
	
	# Nếu mood quá cũ, tự động random lại (tuỳ bạn)
	if now - mood_last_changed >= mood_change_interval:
		roll_mood()
	
	return current_mood

func get_root_menu_items() -> Array[Dictionary]:
	# Trả về danh sách button root dựa theo config: [{id, label}, ...]
	var items: Array[Dictionary] = []
	for id_item in ["ask", "stay_silent", "leave"]:
		var cfg: Dictionary = root_menu_config.get(id_item, {})
		if cfg.get("enabled", false):
			items.append({"id": id_item, "label": String(cfg.get("label", id_item))})
	return items

#=============================================================
# EVALUATE ASK CHOICE
#=============================================================
func evaluate_ask_choice(choice_id: String) -> Dictionary:
	for option in ask_interactions:
		if option.get("id") == choice_id:
			return evaluate_ask(option)
	return {"result": "error", "npc_response": "Not found."}

func evaluate_ask(option: Dictionary) -> Dictionary:
	# Neutral priority (giữ nguyên code cũ của bạn)
	if option.has("__is_neutral") and option["__is_neutral"]:
		return {
			"result": "neutral",
			"npc_response": get_random_neutral_response(),
			"effects": {},
			"mood": current_mood
		}
	
	var expected: Array = option.get("expected_moods", [])
	var is_correct := expected.has(current_mood)
	
	var raw_effects: Dictionary = {}
	var response := ""
	
	if is_correct:
		raw_effects = option.get("correct_effects", {})
		var arr = option.get("npc_responses_correct", [])
		response = arr[randi() % arr.size()] if arr.size() > 0 else ""
	else:
		raw_effects = option.get("wrong_effects", {})
		var arr_wrong = option.get("npc_responses_wrong", [])
		response = arr_wrong[randi() % arr_wrong.size()] if arr_wrong.size() > 0 else ""
	
	var applied_effects := apply_effects_with_daily_cap(raw_effects)
	# Thực sự cộng trừ stats theo applied_effects (đã scale hoặc rỗng)
	apply_effects(applied_effects)
	
	# Thêm metadata để UI có thể hiển thị quota
	var cap_total: float = max(daily_ask_points_cap, 0.0)
	#var used: float = clampf(ask_points_used_today, 0.0, cap_total)
	var used: float = clampf(state.ask_used, 0.0, cap_total)
	var remaining: float = max(0.0, cap_total - used)
	var was_capped: float = effects_total_abs(applied_effects) + 1e-6 < effects_total_abs(raw_effects)
	
	return {
		"result": "correct" if is_correct else "wrong",
		"npc_response": response,
		"effects": applied_effects,  # trả về đúng phần đã áp
		"mood": current_mood,
		"daily_cap": {
			"cap": cap_total,
			"used": used,
			"remaining": remaining,
			"was_capped": was_capped
		}
	}

func get_random_neutral_response() -> String:
	var arr = [
		"Hmm… maybe.",
		"Hard to say, honestly.",
		"I'm not sure about that.",
		"Maybe you're right… maybe not.",
		"That’s… possible."
	]
	return arr[randi() % arr.size()]

func apply_effects(effects: Dictionary) -> void:
	if stats == null:
		return
	if effects.has("love"):
		stats.love = clamp(stats.love + float(effects["love"]), 0.0, stats.max_love)
	if effects.has("trust"):
		stats.trust = clamp(stats.trust + float(effects["trust"]), 0.0, stats.max_trust)
	if effects.has("lust"):
		stats.lust = clamp(stats.lust + float(effects["lust"]), 0.0, stats.max_lust)


func effects_total_abs(effects: Dictionary) -> float:
	var total := 0.0
	if effects.has("love"):
		total += absf(float(effects["love"]))
	if effects.has("trust"):
		total += absf(float(effects["trust"]))
	if effects.has("lust"):
		total += absf(float(effects["lust"]))
	return total

func scale_effects(effects: Dictionary, scale_factor: float) -> Dictionary:
	if scale_factor >= 0.999:
		return effects.duplicate(true)
	var out := {}
	if effects.has("love"):
		out["love"] = float(effects["love"]) * scale_factor
	if effects.has("trust"):
		out["trust"] = float(effects["trust"]) * scale_factor
	if effects.has("lust"):
		out["lust"] = float(effects["lust"]) * scale_factor
	return out

func apply_effects_with_daily_cap(effects: Dictionary) -> Dictionary:
	# Reset nếu sang ngày mới
	ensure_daily_reset()

	# Không có hiệu ứng → bỏ qua
	if effects.is_empty():
		return effects

	# Tính quota còn lại
	var cap: float = max(daily_ask_points_cap, 0.0)
	var used: float = state.ask_used
	#var remaining: float = max(0.0, cap - ask_points_used_today)
	var remaining: float = max(0.0, cap - used)
	if remaining <= 0.0:
		# Hết quota -> không áp gì
		return {}

	# Tổng điểm của lần này (|x|+|y|+|z|)
	var total := effects_total_abs(effects)
	if total <= 0.0:
		return {}

	# Nếu còn quota đủ → áp full
	if total <= remaining + 1e-6:
		#ask_points_used_today += total
		state.ask_used = min(cap, used + total)
		return effects.duplicate(true)

	# Nếu vượt quota → scale tỉ lệ
	var scale_factor := remaining / total
	var scaled := scale_effects(effects, scale_factor)
	#ask_points_used_today = cap  # đã dùng hết quota
	state.ask_used = cap # đã dùng hết quota
	return scaled


func apply_silence_with_daily_cap(effects: Dictionary) -> Dictionary:
	ensure_daily_reset()
	
	if effects.is_empty():
		return effects

	var cap: float = max(daily_silence_points_cap, 0.0)
	var used := state.silence_used
	#var remaining: float = max(0.0, cap - silence_points_used_today)
	var remaining: float = max(0.0, cap - used)
	
	if remaining <= 0.0:
		return {}

	var total_pos := effects_total_abs(effects)
	if total_pos <= 0.0:
		return effects

	if total_pos <= remaining + 1e-6:
		#silence_points_used_today += total_pos
		state.silence_used = min(cap, used + total_pos)
		return effects.duplicate(true)

	var scale_factor := remaining / total_pos
	var scaled := scale_effects(effects, scale_factor)
	#silence_points_used_today = cap
	state.silence_used = cap
	return scaled


#=============================================================
# NEW ASK CHOICES (1 correct – 2 wrong – 1 neutral)
#=============================================================
func get_ask_correct_pool() -> Array[Dictionary]:
	var arr: Array[Dictionary] = []
	for opt in ask_interactions:
		if opt.get("expected_moods", []).has(current_mood):
			arr.append(opt)
	return arr

func get_ask_wrong_pool() -> Array[Dictionary]:
	var arr: Array[Dictionary] = []
	for opt in ask_interactions:
		if not opt.get("expected_moods", []).has(current_mood):
			arr.append(opt)
	return arr


func get_ask_choices_mixed() -> Array[Dictionary]:
	var correct_pool := get_ask_correct_pool()
	var wrong_pool := get_ask_wrong_pool()

	if correct_pool.is_empty():
		return []

	correct_pool.shuffle()
	wrong_pool.shuffle()

	# 1 correct
	var selected_correct: Array[Dictionary] = [correct_pool[0]]

	# 2 wrong
	var selected_wrong: Array[Dictionary] = wrong_pool.slice(0, min(2, wrong_pool.size()))

	# 1 neutral
	var neutral: Dictionary
	if wrong_pool.size() > 2:
		neutral = wrong_pool[2].duplicate(true)
	else:
		neutral = wrong_pool[0].duplicate(true)
	neutral["__is_neutral"] = true

	var result: Array[Dictionary] = []
	result.append_array(selected_correct)
	result.append_array(selected_wrong)
	result.append(neutral)

	result.shuffle()
	return result

#=============================================================
func evaluate_stay_silent() -> Dictionary:
	# Lấy 1 entry ngẫu nhiên từ bank theo npc_key (bank_key bạn đang dùng cho Ask có thể tái dụng)
	var scr := load(silence_bank_script)
	if scr == null:
		# fallback cực đơn giản
		var fallback := {"text": "You stay by quietly.", "effects": {}}
		return apply_silence_entry(fallback)

	var entry: Dictionary = scr.call("pick", bank_key, current_mood)
	# Nếu bạn muốn chỉ cộng điểm khi mood tiêu cực, thì có thể kẹp lại ở đây:
	var negative_moods := ["tired", "annoyed", "busy", "shy"]
	if not negative_moods.has(current_mood):
		# xoá effects nếu mood không tiêu cực
		entry = entry.duplicate(true)
		entry["effects"] = {}

	return apply_silence_entry(entry)


func apply_silence_entry(entry: Dictionary) -> Dictionary:
	var text := String(entry.get("text", "You remain silent."))
	var effects: Dictionary = entry.get("effects", {})

	# Áp cap theo ngày cho Stay Silent (tối đa 3 điểm dương/ngày)
	var applied_effects := apply_silence_with_daily_cap(effects)
	apply_effects(applied_effects)

	return {
		"result": "stay_silent",
		"npc_response": text,
		"effects": applied_effects,
		"mood": current_mood,
		"silence_cap": {
			"cap": daily_silence_points_cap,
			"used": state.silence_used,
			"remaining": max(0.0, daily_silence_points_cap - state.silence_used)
		}
	}
