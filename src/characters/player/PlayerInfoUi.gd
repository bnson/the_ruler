### 📄 PlayerInfoUi.gd 
extends Control

@onready var player_name: Label = $Main/Margin/HBoxContainer/Panel1/VBoxContainer/HBoxContainer/PlayerName
@onready var player_level: Label = $Main/Margin/HBoxContainer/Panel1/VBoxContainer/HBoxContainer/PlayerLevel
@onready var player_portrait: TextureRect = $Main/Margin/HBoxContainer/Panel1/VBoxContainer/CenterContainer/PlayerPortrait

@onready var vitals_box_body := $Main/Margin/HBoxContainer/Panel2/VBoxContainer/VitalsContainer/VitalsBox/Body
@onready var hp_progress_bar : ProgressBar = vitals_box_body.get_node("Hp/Progress/Bar")
@onready var mp_progress_bar : ProgressBar = vitals_box_body.get_node("Mp/Progress/Bar")
@onready var sta_progress_bar : ProgressBar = vitals_box_body.get_node("Sta/Progress/Bar")
@onready var exp_progress_bar : ProgressBar = vitals_box_body.get_node("Exp/Progress/Bar")
@onready var hp_progress_value : Label = vitals_box_body.get_node("Hp/Progress/Value")
@onready var mp_progress_value : Label = vitals_box_body.get_node("Mp/Progress/Value")
@onready var sta_progress_value : Label = vitals_box_body.get_node("Sta/Progress/Value")
@onready var exp_progress_value : Label = vitals_box_body.get_node("Exp/Progress/Value")

@onready var attributes_box_body := $Main/Margin/HBoxContainer/Panel2/VBoxContainer/AttributesContainer/AttributesBox/Body
@onready var strength_value : Label = attributes_box_body.get_node("Strength/Value")
@onready var dexterity_value : Label = attributes_box_body.get_node("Dexterity/Value")
@onready var intelligence_value : Label = attributes_box_body.get_node("Intelligence/Value")
@onready var agility_value : Label = attributes_box_body.get_node("Agility/Value")

func _ready():
	var stats = GameState.player.stats
	stats.connect("stats_changed", Callable(self, "_update_all"))
	stats.connect("level_changed", Callable(self, "_on_level_changed"))
	_update_all()

func _update_all():
	var stats = GameState.player.stats
	
	player_name.text = "MALTHERUS"  # bạn có thể lấy từ GameState.player.name nếu có
	player_level.text = "Lv. %d" % stats.level

	# HP
	hp_progress_bar.value = stats.current_hp
	hp_progress_bar.max_value = stats.max_hp
	hp_progress_value.text = "%d / %d" % [stats.current_hp, stats.max_hp]

	# MP
	mp_progress_bar.value = stats.current_mp
	mp_progress_bar.max_value = stats.max_mp
	mp_progress_value.text = "%d / %d" % [stats.current_mp, stats.max_mp]

	# STA
	sta_progress_bar.value = stats.current_sta
	sta_progress_bar.max_value = stats.max_sta
	sta_progress_value.text = "%d / %d" % [stats.current_sta, stats.max_sta]

	# EXP
	var exp_to_next = stats.get_exp_to_next_level(stats.level)
	exp_progress_bar.value = stats.experience
	exp_progress_bar.max_value = exp_to_next
	exp_progress_value.text = "%d / %d" % [stats.experience, exp_to_next]

	# Attributes
	strength_value.text = str(stats.get_strength())
	dexterity_value.text = str(stats.get_dexterity())
	intelligence_value.text = str(stats.get_intelligence())
	agility_value.text = str(stats.get_agility())

func _on_level_changed(new_level):
	# Khi level thay đổi, cập nhật lại EXP bar (vì max_exp mới)
	_update_all()
