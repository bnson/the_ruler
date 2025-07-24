extends Node2D

@export var max_hp := 1
@export var exp_reward := 5

var current_hp := max_hp
var is_alive := true

@onready var hurtbox = $Hurtbox


func _ready() -> void:
	print("Cabbage ready")
	
	if hurtbox.has_signal("hit_received"):
		print("Cabbage hit received")
		hurtbox.connect("hit_received", Callable(self, "_on_hit_received"))

func _on_hit_received(damage: int, _from_position: Vector2) -> void:
	take_damage(damage)

func take_damage(amount: int) -> void:
	if not is_alive:
		return

	current_hp -= amount
	print("Cabbage bị đánh trúng với sát thương:", amount)

	if current_hp <= 0:
		die()

func die() -> void:
	is_alive = false
	print("Cabbage biến mất.")

	if Global.player and Global.player.has_method("add_exp"):
		Global.player.add_exp(exp_reward)

	$StaticBody2D.queue_free()
	queue_free()
