class_name AmiceGrover
extends Node

@export var display_name: String
@export_multiline var display_info: String
@export var sell_items: Array[ItemData]

@onready var stats: NpcStats = $Stats

@onready var detection_area: Area2D = $DetectionArea

func _ready() -> void:
	pass

func _on_perception_area_entered(area: Area2D) -> void:
	if area.get_owner().is_in_group("player"):
		pass
	pass # Replace with function body.
