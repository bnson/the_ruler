### 📄 PlayerUi.gd
extends CanvasLayer

@onready var health_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/HealthBar
@onready var mana_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/ManaBar
@onready var exp_bar: ProgressBar = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer2/ExpBar
@onready var avatar_tree: AnimationTree = $MainPanel/MainContainer/HBoxContainer1/VBoxContainer1/Avatar/AnimationTree
@onready var level_label: Label = $MainPanel/MainContainer/HBoxContainer2/LevelLabel
@onready var time_label: Label = $MainPanel/MainContainer/HBoxContainer2/TimeLabel
@onready var inventory_ui: Control = $CenterContainer3/InventoryUI

var last_displayed_minute := -1
var inventory_visible := false

func _ready():
	_connect_time_manager()
	_connect_stats_signals()
	_connect_player_signals()
	_update_status_bars()

func _process(_delta: float) -> void:
	_update_avatar_state()

func _input(event):
	if event.is_action_pressed("ui_inventory"):
		toggle_inventory()

func _connect_time_manager():
	if TimeManager:
		if not TimeManager.time_updated.is_connected(_on_time_updated):
			TimeManager.time_updated.connect(_on_time_updated)
			TimeManager.emit_time_updated()

func _on_time_updated(_day_name: String, _hour: int, minute: int, _is_daytime: bool, _time_period: String) -> void:
	if minute == last_displayed_minute:
		return
	last_displayed_minute = minute
	time_label.text = TimeManager.get_time_string()

func _connect_stats_signals():
	if GameState.player and GameState.player.stats:
		var stats = GameState.player.stats
		if not stats.stats_changed.is_connected(_update_status_bars):
			stats.stats_changed.connect(_update_status_bars)

func _update_status_bars():
	var stats = GameState.player.stats
	health_bar.max_value = stats.max_hp
	health_bar.value = stats.hp

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

func _connect_player_signals():
	if Global.player:
		if not Global.player.damaged.is_connected(_on_player_damaged):
			Global.player.damaged.connect(_on_player_damaged)
		if not Global.player.gained_exp.is_connected(_on_player_gained_exp):
			Global.player.gained_exp.connect(_on_player_gained_exp)
		if not Global.player.died.is_connected(_on_player_died):
			Global.player.died.connect(_on_player_died)

func _on_player_damaged(amount: int) -> void:
	health_bar.value = GameState.player.stats.hp

func _on_player_gained_exp(amount: int) -> void:
	exp_bar.value = GameState.player.stats.experience

func _on_player_died() -> void:
	# TODO: show Game Over screen
	print("Player has died")

func toggle_inventory():
	inventory_visible = not inventory_visible
	inventory_ui.visible = inventory_visible
