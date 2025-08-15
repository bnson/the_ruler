extends Node

@onready var vitals_box := $Main/Container/HBox1/VitalsBox
@onready var hp_bar: ProgressBar = vitals_box.get_node("HpBar")
@onready var mp_bar: ProgressBar = vitals_box.get_node("MpBar")
@onready var sta_bar: ProgressBar = vitals_box.get_node("StaBar")
@onready var exp_bar: ProgressBar = vitals_box.get_node("ExpBar")

@onready var avatar_tree: AnimationTree = $Main/Container/HBox1/PortraitBox/Avatar/AnimationTree
@onready var level_label: Label = $Main/Container/HBox2/Level
@onready var time_label: Label = $Main/Container/HBox2/Time

var last_displayed_minute := -1

func _ready() -> void:
	_connect_time_manager()
	_connect_stats_signals()
	_connect_player_signals()
	_update_status_bars()

func _process(_delta: float) -> void:
	_update_avatar_state()

func _connect_stats_signals():
	if GameState.player and GameState.player.stats:
		var stats = GameState.player.stats
		if not stats.stats_changed.is_connected(_update_status_bars):
			stats.stats_changed.connect(_update_status_bars)

func _connect_player_signals():
	if Global.player:
		if not Global.player.damaged.is_connected(_on_player_damaged):
			Global.player.damaged.connect(_on_player_damaged)
		if not Global.player.gained_exp.is_connected(_on_player_gained_exp):
			Global.player.gained_exp.connect(_on_player_gained_exp)
		if not Global.player.died.is_connected(_on_player_died):
			Global.player.died.connect(_on_player_died)


func _on_player_died() -> void:
	# TODO: show Game Over screen
	print("Player has died")


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

func _on_player_damaged(amount: int) -> void:
	hp_bar.value = GameState.player.stats.current_hp

func _on_player_gained_exp(amount: int) -> void:
	exp_bar.value = GameState.player.stats.experience


func _update_status_bars():
	var stats = GameState.player.stats
	
	hp_bar.max_value = stats.max_hp
	hp_bar.value = stats.current_hp

	mp_bar.max_value = stats.max_mp
	mp_bar.value = stats.current_mp
	
	sta_bar.max_value = stats.max_sta
	sta_bar.value = stats.current_sta

	exp_bar.max_value = stats.get_exp_to_next_level(stats.level)
	exp_bar.value = stats.experience
	
	level_label.text = "Level: %d" % stats.level

func _update_avatar_state():
	var stats = GameState.player.stats
	var tired_ratio = 1.0 - float(stats.current_hp) / float(stats.max_hp)
	avatar_tree.set("parameters/EmotionBlend/blend_position", tired_ratio)
