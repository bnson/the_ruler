class_name ExpProgressBar
extends Control

@onready var label: Label = $HBox/Label
@onready var bar: ProgressBar = $HBox/Margin/Bar
@onready var value: Label = $HBox/Margin/Value

var player_stats: PlayerStats

func _ready():
	player_stats = PlayerManager.player.stats
	player_stats.connect("stats_changed", Callable(self, "_on_stats_changed"))

func _on_stats_changed():
	#print("EXP Progress Bar: ", player_stats.experience, " - ", player_stats.experience_to_next_level())
	var exp_to_next_level = player_stats.experience_to_next_level()
	bar.max_value = exp_to_next_level
	bar.value = player_stats.experience
	value.text = "%d / %d" % [player_stats.experience, exp_to_next_level]
