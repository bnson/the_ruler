class_name AmiceGrover
extends Npc

@onready var detection_area: Area2D = $Perception

func _ready() -> void:
	super()
	stats = $Stats
	#roll_mood()
	#load_ask_from_bank()
	

func _on_perception_area_entered(area: Area2D) -> void:
	if not is_instance_valid(area):
		return
	
	var area_owner := area.get_owner()
	if not is_instance_valid(area_owner):
		return
	
	if area_owner.is_in_group("player"):
		roll_mood()
		UiManager.ui_layer.interaction_menu.open(self)

func _on_perception_area_exited(area: Area2D) -> void:
	if not is_instance_valid(area):
		return
	
	var area_owner := area.get_owner()
	if not is_instance_valid(area_owner):
		return
	
	if area_owner.is_in_group("player"):
		UiManager.ui_layer.interaction_menu.close()
