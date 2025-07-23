extends CharacterBody2D

@export var speed: float = 200.0

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
	print("Player ready...")
	animation_tree.active = true
	state_machine.change_state("IdleState")
	
	hitbox.hitbox_owner = self

	if hurtbox.has_signal("hit_received"):
		print("Player hit received...")
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
		animation_tree.set("parameters/AttackState/blend_position", input_vector)
		
		attack_effect_animation_tree.set("parameters/AttackEffect/blend_position", input_vector)

	if state_machine.current_state:
		state_machine.current_state.physics_update(delta)

	if input_vector != Vector2.ZERO:
		if input_vector == Vector2(0, -1):  # lên
			hitbox.rotation_degrees = -180
		elif input_vector == Vector2(0, 1):  # xuống
			hitbox.rotation_degrees = 0
		elif input_vector == Vector2(-1, 0):  # trái
			hitbox.rotation_degrees = 90
		elif input_vector == Vector2(1, 0):  # phải
			hitbox.rotation_degrees = -90

func take_damage(amount: int) -> void:
	PlayerData.hp -= amount
	PlayerUi.health_bar.value = PlayerData.hp
	print("Player bị trúng đòn! Mất ", amount, " máu, còn lại ", PlayerData.hp, " máu")
	if PlayerData.hp <= 0:
		die()

func die() -> void:
	print("Player die...")

func _on_hit_received(damage: int, from_position: Vector2) -> void:
	# Tính hướng knockback
	knockback_vector = (global_position - from_position).normalized() * 300
	knockback_timer = KNOCKBACK_DURATION
	# TODO: Trừ máu, hiệu ứng, v.v.
	take_damage(damage)
