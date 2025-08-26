### 📄 NPCChatUi.gd 
extends Control

@export var slot_scene: PackedScene

@onready var npc_name: Label = $Panel/Margin/HBox/NpcPanel/Margin/Container/Header/NameValue
@onready var npc_level: Label = $Panel/Margin/HBox/NpcPanel/Margin/Container/Header/LevelValue
@onready var npc_portrait: TextureRect = $Panel/Margin/HBox/NpcPanel/Margin/Container/Body/Portrait

@onready var vitals_container := $Panel/Margin/HBox/NpcPanel/Margin/Container/Footer
@onready var love_progress_bar : ProgressBar = vitals_container.get_node("Love/Progress/Bar")
@onready var trust_progress_bar : ProgressBar = vitals_container.get_node("Trust/Progress/Bar")
@onready var lust_progress_bar : ProgressBar = vitals_container.get_node("Lust/Progress/Bar")
@onready var love_progress_value : Label = vitals_container.get_node("Love/Progress/Value")
@onready var trust_progress_value : Label = vitals_container.get_node("Trust/Progress/Value")
@onready var lust_progress_value : Label = vitals_container.get_node("Lust/Progress/Value")

@onready var gift_item_grid: GridContainer = $Panel/Margin/HBox/VBox/GiftPanel/VBoxContainer/Panel/MarginContainer/ScrollContainer/GridContainer

const GIFT_MAX_SLOTS := 10

var current_npc: NPC


func _on_close_button_pressed() -> void:
	visible = false
