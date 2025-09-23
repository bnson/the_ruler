# NPCInfo.gd
extends Control
class_name NPCInfo

@onready var name_label := $Main/Margin/HBox/LeftPanel/Margin/Container/Header/NameLabel
@onready var info_text := $Main/Margin/HBox/RightPanel/Margin/Container/InfoPanel/InfoText
@onready var level_value := $Main/Margin/HBox/LeftPanel/Margin/Container/Header/LevelValue
@onready var exp_value := $Main/Margin/HBox/LeftPanel/Margin/Container/Footer/ExpValue

@onready var vitals_box_grid := $Main/Margin/HBox/RightPanel/Margin/Container/IndexPanel/VitalStatsBox/Grid
@onready var hp_value : Label = vitals_box_grid.get_node("HpValue")
@onready var mp_value : Label = vitals_box_grid.get_node("MpValue")
@onready var sta_value : Label = vitals_box_grid.get_node("StaValue")
@onready var love_value : Label = vitals_box_grid.get_node("LoveValue")
@onready var trust_value : Label = vitals_box_grid.get_node("TrustValue")
@onready var lust_value : Label = vitals_box_grid.get_node("LustValue")

@onready var attributes_box_grid := $Main/Margin/HBox/RightPanel/Margin/Container/IndexPanel/BaseAttBox/Grid
@onready var str_value : Label = attributes_box_grid.get_node("StrValue")
@onready var dex_value : Label = attributes_box_grid.get_node("DexValue")
@onready var int_value : Label = attributes_box_grid.get_node("IntValue")
@onready var agi_value : Label = attributes_box_grid.get_node("AgiValue")

var current_npc: NPC = null

func _ready():
	#if current_npc and current_npc.state.stats and not current_npc.stats.stats_changed.is_connected(_update_info):
	if current_npc and is_instance_valid(current_npc) and current_npc.state.stats and not current_npc.state.stats.stats_changed.is_connected(_update_info):
		current_npc.stats.stats_changed.connect(_update_info)
		_update_info()

func open(npc: NPC) -> void:
	# Disconnect previous signal if any
	#if current_npc and current_npc.state.stats and current_npc.state.stats.stats_changed.is_connected(_update_info):
	if current_npc and is_instance_valid(current_npc) and current_npc.state.stats and current_npc.state.stats.stats_changed.is_connected(_update_info):
		current_npc.state.stats.stats_changed.disconnect(_update_info)

	# Assign new state
	current_npc = npc

	if current_npc and current_npc.state.stats:
		var stats : NPCStats = current_npc.state.stats
		if not stats.stats_changed.is_connected(_update_info):
			stats.stats_changed.connect(_update_info)
			_update_info()
			visible = true

func close() -> void:
	if current_npc and current_npc.state.stats and current_npc.state.stats.stats_changed.is_connected(_update_info):
		current_npc.state.stats.stats_changed.disconnect(_update_info)
		visible = false

func _update_info() -> void:
	if not current_npc or not is_instance_valid(current_npc):
		return
	
	name_label.text = current_npc.display_name
	info_text.text = current_npc.display_info
	
	var exp_to_next = current_npc.state.stats.get_exp_to_next_level(current_npc.state.stats.level)
	level_value.text = str(current_npc.state.stats.level)
	exp_value.text = "%d / %d" % [current_npc.state.stats.experience, exp_to_next]

	hp_value.text = str(current_npc.state.stats.current_hp)
	mp_value.text = str(current_npc.state.stats.current_mp)
	sta_value.text = str(current_npc.state.stats.current_sta)
	love_value.text = str(current_npc.state.stats.love)
	trust_value.text = str(current_npc.state.stats.trust)
	lust_value.text = str(current_npc.state.stats.lust)
	
	str_value.text = str(current_npc.state.stats.get_strength())
	dex_value.text = str(current_npc.state.stats.get_dexterity())
	int_value.text = str(current_npc.state.stats.get_intelligence())
	agi_value.text = str(current_npc.state.stats.get_agility())

func _on_close_button_pressed() -> void:
	visible = false
