extends CanvasLayer

@onready var health_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/HealthBar
@onready var mana_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/ManaBar
@onready var exp_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/ExpBar
@onready var level_label: Label = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/LevelLabel
@onready var avatar_tree: AnimationTree = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer1/Avatar/AnimationTree
@onready var time_label: Label = $MainPanel/MainContainer/HBoxContainer2/TimeLabel

var last_displayed_minute := -1
const UPDATE_INTERVAL := 5  # phút

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
		print("✅ Connected to TimeManager.")
	elif not TimeManager:
		print("⚠️ TimeManager not found!")

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

func _on_time_updated(day_name: String, hour: int, minute: int, is_daytime: bool, time_period: String) -> void:
	if minute % UPDATE_INTERVAL != 0 or minute == last_displayed_minute:
		return

	last_displayed_minute = minute
	var icon = "🌞" if is_daytime else "🌙"
	time_label.text = "%s - %02d:00 (%s) %s" % [day_name, hour, time_period, icon]
