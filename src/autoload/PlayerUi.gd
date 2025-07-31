extends CanvasLayer

@onready var health_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/HealthBar
@onready var mana_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/ManaBar
@onready var exp_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/ExpBar
@onready var avatar_tree: AnimationTree = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer1/Avatar/AnimationTree
@onready var level_label: Label = $MainPanel/MainContainer/HBoxContainer2/LevelLabel
@onready var time_label: Label = $MainPanel/MainContainer/HBoxContainer2/TimeLabel

var last_displayed_minute := -1

func _ready():
	_connect_time_manager()
	_connect_stats_signals()

	# Update UI ngay khi load
	_update_status_bars()

func _process(_delta: float) -> void:
	_update_avatar_state()

# ----------------------------------
# 🕒 Kết nối TimeManager
# ----------------------------------
func _connect_time_manager():
	if TimeManager:
		if not TimeManager.time_updated.is_connected(Callable(self, "_on_time_updated")):
			TimeManager.time_updated.connect(Callable(self, "_on_time_updated"))
			Logger.debug_log("Connected to TimeManager", "PlayerUi", "UI")
			# Phát signal ngay để UI hiện thời gian lúc start
			TimeManager.emit_time_updated()
	else:
		Logger.debug_warn("TimeManager not found!", "PlayerUi", "UI")

# ----------------------------------
# 🔗 Kết nối Stats signal từ GameState
# ----------------------------------
func _connect_stats_signals():
	if GameState and GameState.player and GameState.player.stats:
		var stats = GameState.player.stats
		if not stats.stats_changed.is_connected(Callable(self, "_update_status_bars")):
			stats.stats_changed.connect(Callable(self, "_update_status_bars"))
	else:
		Logger.debug_warn("GameState or PlayerState not found!", "PlayerUi", "UI")

# ----------------------------------
# 🔄 Cập nhật UI
# ----------------------------------
func _update_status_bars():
	var stats = GameState.player.stats
	health_bar.max_value = stats.max_hp
	health_bar.value = stats.hp

	# Giả sử bạn có SP (Mana) trong Stats (nếu chưa, cần bổ sung)
	if "max_sp" in stats and "sp" in stats:
		mana_bar.max_value = stats.max_sp
		mana_bar.value = stats.sp
	else:
		mana_bar.visible = false

	exp_bar.max_value = stats.get_exp_to_next_level(stats.level)
	exp_bar.value = stats.experience

	level_label.text = "Level: %d" % stats.level

func _update_avatar_state():
	var stats = GameState.player.stats
	var tired_ratio = 1.0 - float(stats.hp) / float(stats.max_hp)
	avatar_tree.set("parameters/EmotionBlend/blend_position", tired_ratio)

# ----------------------------------
# 🕒 Cập nhật Time UI
# ----------------------------------
func _on_time_updated(_day_name: String, _hour: int, minute: int, _is_daytime: bool, _time_period: String) -> void:
	Logger.debug_log("Time updated: %s" % TimeManager.get_time_string(), "PlayerUi", "UI")

	if minute == last_displayed_minute:
		return
	last_displayed_minute = minute

	time_label.text = TimeManager.get_time_string()
