class_name PlayerProfile
extends Control

@onready var base_attr_container := $MainPanel/Margin/HBox/PanelRight/VBox/Vitals/VBox/BaseAttrContainer
@onready var str_value: Label = base_attr_container.get_node("StrValue")
@onready var dex_value: Label = base_attr_container.get_node("DexValue")
@onready var int_value: Label = base_attr_container.get_node("IntValue")
@onready var agi_value: Label = base_attr_container.get_node("AgiValue")

var player_stats: PlayerStats


func _ready():
	player_stats = PlayerManager.player.stats
	player_stats.connect("stats_changed", Callable(self, "_on_stats_changed"))
	
func _on_stats_changed():
	str_value.text = "%d" % [player_stats.max_hp]
	str_value.text = "%d" % [player_stats.base_str]
	dex_value.text = "%d" % [player_stats.base_str]
	int_value.text = "%d" % [player_stats.base_str]
	agi_value.text = "%d" % [player_stats.base_str]

func _on_close_button_pressed() -> void:
	visible = false
