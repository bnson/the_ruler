class_name AmiceGrover
extends Node

@export var display_name: String
@export_multiline var display_info: String
@export var sell_items: Array[ItemData]
@export var interactions: Array[Dictionary]

@onready var stats: NpcStats = $Stats

@onready var detection_area: Area2D = $Perception

func _ready() -> void:
	pass

func _on_perception_area_entered(area: Area2D) -> void:
	if area.get_owner().is_in_group("player"):
		print("Amice detects the player.")
		UiManager.ui_layer.interaction_menu.open(interactions)

func _on_perception_area_exited(area: Area2D) -> void:
	if area.get_owner().is_in_group("player"):
		print("Amice did not detect the player.")
		UiManager.ui_layer.interaction_menu.close()
