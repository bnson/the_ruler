class_name MpProgressBar
extends Control

@onready var label: Label = $HBox/Label
@onready var bar: ProgressBar = $HBox/Margin/Bar
@onready var value: Label = $HBox/Margin/Value

var player_stats: PlayerStats

func _ready():
	player_stats = PlayerManager.player.stats
	player_stats.connect("stats_changed", Callable(self, "_on_stats_changed"))
	
func _on_stats_changed():
	#print("MP Progress Bar: ", player_stats.cur_mp, " - ", player_stats.max_mp)
	bar.max_value = player_stats.max_mp
	bar.value = player_stats.cur_mp
	value.text = "%d / %d" % [player_stats.cur_mp, player_stats.max_mp]
