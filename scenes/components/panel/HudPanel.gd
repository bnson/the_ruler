class_name HudPanel
extends Control

#=============================================
@onready var vitals_panel = $MainPanel/PlayerPanel/VitalsPanel
@onready var hp_bar: ProgressBar = vitals_panel.get_node("HpBar")
@onready var mp_bar: ProgressBar = vitals_panel.get_node("MpBar")
@onready var st_bar: ProgressBar = vitals_panel.get_node("StBar")
@onready var ex_bar: ProgressBar = vitals_panel.get_node("ExBar")

@onready var info_panel = $MainPanel/InfoPanel
@onready var level_label: Label = info_panel.get_node("Level")
@onready var time_label: Label = info_panel.get_node("Time")

#=============================================
var player_stats: PlayerStats

#=============================================
func _ready() -> void:
	time_label.text = "%s (Day %d)" % [GameClock.get_time_string(), GameClock.day]
	GameClock.time_changed.connect(on_time_changed)

func on_time_changed(day: int, hour: int, minute: int) -> void:
	time_label.text = "%02d:%02d (Day %d)" % [hour, minute, day]

func set_player_stats(stats: PlayerStats):
	if player_stats:
		# Tránh kết nối trùng
		player_stats.disconnect("stats_changed", Callable(self, "_on_stats_changed"))
	player_stats = stats
	player_stats.connect("stats_changed", Callable(self, "_on_stats_changed"))
	_on_stats_changed()

func _on_stats_changed():
	if player_stats == null:
		return

	hp_bar.value = player_stats.cur_hp
	hp_bar.max_value = player_stats.max_hp

	mp_bar.value = player_stats.cur_mp
	mp_bar.max_value = player_stats.max_mp

	st_bar.value = player_stats.cur_sta
	st_bar.max_value = player_stats.max_sta

	ex_bar.value = player_stats.experience
	ex_bar.max_value = player_stats.experience_to_next_level()

	level_label.text = "Lv. %d" % player_stats.level
