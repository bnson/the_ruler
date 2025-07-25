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

var is_attacking: bool = false
var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
const KNOCKBACK_DURATION: float = 0.2

func _ready() -> void:
	Logger.debug_log(node_name, "Player ready...", "Player")
	animation_tree.active = true
	state_machine.change_state("IdleState")
	hitbox.hitbox_owner = self

	connect_signals()

func connect_signals() -> void:
	Logger.connect_signal_once(hurtbox, "hit_received", Callable(self, "_on_hit_received"), node_name, "Player")

func _physics_process(delta: float) -> void:
	var input_vector = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	if knockback_timer > 0:
		velocity = knockback_vector
		knockback_timer -= delta
	else:
		velocity = input_vector * speed

	move_and_slide()

	if input_vector != Vector2.ZERO:
		update_blend_positions(input_vector)
		update_hitbox_rotation(input_vector)

	if state_machine.current_state:
		state_machine.current_state.physics_update(delta)

func update_blend_positions(input_vector: Vector2) -> void:
	animation_tree.set("parameters/IdleState/blend_position", input_vector)
	animation_tree.set("parameters/WalkState/blend_position", input_vector)
	animation_tree.set("parameters/AttackState/blend_position", input_vector)
	attack_effect_animation_tree.set("parameters/AttackEffect/blend_position", input_vector)

func update_hitbox_rotation(input_vector: Vector2) -> void:
	match input_vector:
		Vector2(0, -1): hitbox.rotation_degrees = -180  # lên
		Vector2(0, 1): hitbox.rotation_degrees = 0      # xuống
		Vector2(-1, 0): hitbox.rotation_degrees = 90    # trái
		Vector2(1, 0): hitbox.rotation_degrees = -90    # phải

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
