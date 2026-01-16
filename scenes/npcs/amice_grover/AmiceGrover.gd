class_name AmiceGrover
extends Npc

@onready var stats: NpcStats = $Stats
@onready var detection_area: Area2D = $Perception

func _ready() -> void:
	pass

func _on_perception_area_entered(area: Area2D) -> void:
	if area.get_owner().is_in_group("player"):
		print("Amice detects the player.")
		UiManager.ui_layer.interaction_menu.open(self)

func _on_perception_area_exited(area: Area2D) -> void:
	if area:
		if area.get_owner().is_in_group("player"):
			print("Amice did not detect the player.")
			UiManager.ui_layer.interaction_menu.close()
