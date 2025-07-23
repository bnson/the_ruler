extends CharacterBody2D

@export var speed := 40.0
@export var max_hp := 30
@export var exp_reward := 10
@export var patrol_positions: Array[Vector2] = [
	Vector2(100, 200),
	Vector2(400, 200)
]

var current_hp := max_hp
var patrol_index := 0
var is_attacking: bool = true

var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
const KNOCKBACK_DURATION: float = 0.2

@onready var state_machine = $StateMachine
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox


func _ready() -> void:
	#print("Slime HP khi khởi tạo: ", max_hp)
	current_hp = max_hp
	
	animation_tree.active = true
	#state_machine.change_state("WalkState")
	state_machine.change_state("PatrolState")
	
	hitbox.hitbox_owner = self
	
	if hurtbox.has_signal("hit_received"):
		hurtbox.connect("hit_received", Callable(self, "_on_hit_received"))

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	
	# Nếu đang bị knockback
	if knockback_timer > 0:
		velocity = knockback_vector
		knockback_timer -= delta
	else:
		velocity = input_vector * speed
	
	move_and_slide()
	
	# Cập nhập hướng cho BlendSpace2d
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/IdleState/blend_position", input_vector)
		animation_tree.set("parameters/WalkState/blend_position", input_vector)
	
	if state_machine.current_state:
		state_machine.current_state.physics_update(delta)
	

func get_player() -> Node2D:
	if Global.player:
		return Global.player
	else:
		push_error("Player chưa được khởi tạo trong Global.gd!")
		return null

func take_damage(amount: int) -> void:
	current_hp -= amount
	print("Slime current HP: ", current_hp)
	if current_hp <= 0:
		die()

func die() -> void:
	print("Cabbage die.")
	if Global.player and Global.player.has_method("gain_experience"):
		Global.player.gain_experience(exp_reward)
	queue_free()
	
func _on_hit_received(damage: int, from_position: Vector2) -> void:
	print("Slime nhận tín hiệu sát thương: ", damage, " - vị trí: ", from_position)
	# Tính hướng knockback
	knockback_vector = (global_position - from_position).normalized() * 300
	knockback_timer = KNOCKBACK_DURATION
	# TODO: Trừ máu, hiệu ứng, v.v.
	take_damage(damage)
