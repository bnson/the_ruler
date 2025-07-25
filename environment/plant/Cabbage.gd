extends Node2D
class_name Cabbage

@export var max_hp := 1
@export var exp_reward := 5

var current_hp := max_hp
var is_alive := true

@onready var node_name := get_name()
@onready var hurtbox := $Hurtbox

func _ready() -> void:
	current_hp = max_hp
	is_alive = true

	Logger.debug_log(node_name, "Cabbage is now active.", "Enemy")
	connect_signals()

func connect_signals() -> void:
	Logger.connect_signal_once(hurtbox, "hit_received", Callable(self, "_on_hit_received"), node_name, "Enemy")

func _on_hit_received(damage: int, _from_position: Vector2) -> void:
	take_damage(damage)

func take_damage(amount: int) -> void:
	if not is_alive:
		return

	current_hp -= amount
	Logger.debug_log(node_name, "Received damage: %d | Current HP: %d" % [amount, current_hp], "Enemy")

	if current_hp <= 0:
		die()

func die() -> void:
	is_alive = false
	Logger.debug_log(node_name, "Cabbage has died.", "Enemy")

	if Global.player and Global.player.has_method("add_exp"):
		Global.player.add_exp(exp_reward)
		Logger.debug_log(node_name, "Granted %d EXP to player." % exp_reward, "Enemy")

	$StaticBody2D.queue_free()
	queue_free()
