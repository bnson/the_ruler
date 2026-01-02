class_name Hitbox
extends Area2D

#=====================================================================
signal hit_detected(area : Area2D, damage : float) 

var timer : float = 0.0
var active_time : float = 0.0 # Thời gian tồn tại hitbox
var damage : float = 0.0


#=====================================================================
func _ready():
	add_to_group("hitboxes")
	connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta: float) -> void:
	if monitoring and active_time > 0:
		timer -= delta
		if timer <= 0:
			deactivate()

func _on_area_entered(area : Area2D):
	if area.is_in_group("hurtboxes") and area.get_owner() != self.get_owner():
		if area.has_method("receive_hit"):
			# Gọi hàm xử lý va chạm
			area.receive_hit(self, damage)
			emit_signal("hit_detected", area, damage)

func activate():
	monitoring = true
	visible = true
	timer = active_time

func deactivate():
	monitoring = false
	visible = false
