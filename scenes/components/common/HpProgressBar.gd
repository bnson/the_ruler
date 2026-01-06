class_name HpProgressBar
extends Control

@onready var label: Label = $HBox/Label
@onready var bar: ProgressBar = $HBox/Margin/Bar
@onready var value: Label = $HBox/Margin/Value

var player_stats: PlayerStats

func _ready():
	player_stats = PlayerManager.player.stats
	player_stats.connect("stats_changed", Callable(self, "_on_stats_changed"))
	
func _on_stats_changed():
	#print("HP Progress Bar: ", player_stats.cur_hp, " - ", player_stats.max_hp)
	bar.max_value = player_stats.max_hp
	bar.value = player_stats.cur_hp
	value.text = "%d / %d" % [player_stats.cur_hp, player_stats.max_hp]
