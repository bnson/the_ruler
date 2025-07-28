extends CharacterBody2D
class_name Player

@export var speed: float = 200.0

@onready var node_name := get_name()
@onready var state_machine: Node = $StateMachine
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var attack_effect_animation_tree: AnimationTree = $Sprite2D/AttackEffectSprite/AttackEffectAnimationTree
@onready var attack_effect_animation_state: AnimationNodeStateMachinePlayback = attack_effect_animation_tree.get("parameters/playback")
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var joystick := PlayerUi.get_node_or_null("Joystick")


var is_attacking: bool = false
var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
const KNOCKBACK_DURATION: float = 0.2

var look_direction: Vector2 = Vector2.RIGHT  # mặc định nhìn phải

func _ready() -> void:
	Logger.debug_log(node_name, "Player ready...", "Player")
	animation_tree.active = true
	state_machine.change_state("IdleState")
	hitbox.hitbox_owner = self
	connect_signals()

func connect_signals() -> void:
	Logger.connect_signal_once(hurtbox, "hit_received", Callable(self, "_on_hit_received"), node_name, "Player")

func _physics_process(delta: float) -> void:
	#var input_vector: Vector2 = Vector2(
	#	Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
	#	Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	#).normalized()
	
	var input_vector : Vector2 = joystick.get_direction()
	#print(input_vector)


	# Di chuyển
	if knockback_timer > 0:
		velocity = knockback_vector
		knockback_timer -= delta
	else:
		velocity = input_vector * speed

	move_and_slide()

	# Cập nhật hướng nhìn
	var blend_vector: Vector2 = input_vector

	if input_vector.x != 0 and input_vector.y != 0:
		# Nếu đang đi chéo → giữ hướng trái/phải
		look_direction = Vector2(input_vector.x, 0)
		blend_vector = look_direction
	elif input_vector != Vector2.ZERO:
		# Nếu chỉ đi theo 1 hướng → dùng hướng thật
		look_direction = input_vector
		blend_vector = input_vector

	# Cập nhật animation và hitbox
	if input_vector != Vector2.ZERO:
		update_blend_positions(blend_vector)
		update_hitbox_rotation(blend_vector)

	# Gọi cập nhật từ state machine
	if state_machine.current_state:
		#print(state_machine.current_state)
		state_machine.current_state.physics_update(delta, input_vector)

func update_blend_positions(input_vector: Vector2) -> void:
	animation_tree.set("parameters/IdleState/blend_position", input_vector)
	animation_tree.set("parameters/WalkState/blend_position", input_vector)
	animation_tree.set("parameters/AttackState/blend_position", input_vector)
	attack_effect_animation_tree.set("parameters/AttackEffect/blend_position", input_vector)

func update_hitbox_rotation(input_vector: Vector2) -> void:
	if input_vector == Vector2.ZERO:
		return

	if abs(input_vector.x) > abs(input_vector.y):
		hitbox.rotation_degrees = -90 if input_vector.x > 0 else 90
	else:
		hitbox.rotation_degrees = 0 if input_vector.y > 0 else -180

func take_damage(amount: int) -> void:
	PlayerData.hp -= amount
	PlayerUi.health_bar.value = PlayerData.hp
	Logger.debug_log(node_name, "Received damage: %d | Current HP: %d" % [amount, PlayerData.hp], "Player")

	if PlayerData.hp <= 0:
		die()

func die() -> void:
	Logger.debug_log(node_name, "Player has died.", "Player")

func _on_hit_received(damage: int, from_position: Vector2) -> void:
	knockback_vector = (global_position - from_position).normalized() * 300
	knockback_timer = KNOCKBACK_DURATION
	take_damage(damage)
