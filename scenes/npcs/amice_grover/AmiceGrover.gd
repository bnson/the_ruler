class_name AmiceGrover
extends Npc

@onready var detection_area: Area2D = $Perception


func _ready() -> void:
	super()
	stats = $Stats
	NpcManager.register(self)
	
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

func exit_tree() -> void:
	NpcManager.unregister(self)

func to_save_data() -> Dictionary:
	return stats.to_dict()

func load_save_data(data: Dictionary) -> void:
	stats.from_dict(data)
