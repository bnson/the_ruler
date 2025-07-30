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

	if PlayerData and not PlayerData.stats_changed.is_connected(_update_status_bars):
		PlayerData.stats_changed.connect(_update_status_bars)

func _process(_delta: float) -> void:
	if PlayerData:
		_update_avatar_state()

func _connect_time_manager():
	if TimeManager and not TimeManager.time_updated.is_connected(_on_time_updated):
		TimeManager.time_updated.connect(_on_time_updated)
		Logger.debug_log("Connected to TimeManager", "PlayerUi", "UI")
		TimeManager.emit_time_updated()  
	elif not TimeManager:
		Logger.debug_warn("TimeManager not found!", "PlayerUi", "UI")

# -------------------------------
# 🔄 Cập nhật UI
# -------------------------------

func _update_status_bars():
	health_bar.max_value = PlayerData.max_hp
	health_bar.value = PlayerData.hp

	mana_bar.max_value = PlayerData.max_sp
	mana_bar.value = PlayerData.sp

	exp_bar.max_value = PlayerData.experience_to_next_level
	exp_bar.value = PlayerData.experience

	level_label.text = "Level: %d" % PlayerData.level

func _update_avatar_state():
	var tired_ratio = 1.0 - float(PlayerData.hp) / float(PlayerData.max_hp)
	avatar_tree.set("parameters/EmotionBlend/blend_position", tired_ratio)

func _on_time_updated(_day_name: String, _hour: int, minute: int, _is_daytime: bool, _time_period: String) -> void:
	Logger.debug_log("Time updated: %s" % TimeManager.get_time_string(), "PlayerUi", "UI")
	if minute == last_displayed_minute:
		return

	last_displayed_minute = minute
	time_label.text = TimeManager.get_time_string()
