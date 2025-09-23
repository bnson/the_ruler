extends Area2D

@export var damage: int = 10
@export var active_time: float = 0.2  # thời gian tồn tại hitbox

var hitbox_owner: Node = null

var timer := 0.0
var already_hit := []

func _ready():
	#monitoring = false
	#visible = false
	add_to_group("hitbox")
	connect("area_entered", Callable(self, "_on_area_entered"))

func activate():
	monitoring = true
	visible = true
	timer = active_time
	already_hit.clear()  # reset danh sách đã đánh trúng

func deactivate():
	monitoring = false
	visible = false

func _process(delta: float) -> void:
	if monitoring:
		timer -= delta
		if timer <= 0:
			deactivate()

func _on_area_entered(area: Area2D) -> void:
	# Tránh đánh trúng nhiều lần cùng một đối tượng trong một lần kích hoạt
	if area in already_hit:
		return

	if area.is_in_group("hurtbox"):
		if area.has_method("receive_hit"):
			area.receive_hit(damage)
		elif area.has_signal("hit_received"):
			var from_position = area.global_position
			if from_position:
				area.emit_signal("hit_received", damage, from_position)

		already_hit.append(area)

func get_damage() -> int:
	return damage


func get_attacker() -> Node:
	return hitbox_owner
