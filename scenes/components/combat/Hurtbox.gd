class_name Hurtbox
extends Area2D

#=================================================
signal hit_received(area: Area2D, damage: float)


#=================================================
func _ready():
	add_to_group("hurtboxes")
	connect("area_entered", Callable(self, "_on_area_entered"))
	
func _on_area_entered(_area : Area2D):
	pass
	
func receive_hit(area : Area2D, damage: float):
	if area.is_in_group("hitboxes") and area.get_owner() != self.get_owner():
		emit_signal("hit_received", area, damage)
