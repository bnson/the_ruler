### 📄 Player.gd
extends CharacterBody2D
class_name Player

signal damaged(amount: int)
signal healed(amount: int)
signal gained_exp(amount: int)
signal died()

@export var speed: float = 200.0

# State machines
@onready var state_machine: Node = $StateMachine
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var attack_effect_animation_tree: AnimationTree = $Sprite2D/AttackEffectSprite/AttackEffectAnimationTree
@onready var attack_effect_animation_state: AnimationNodeStateMachinePlayback = attack_effect_animation_tree.get("parameters/playback")

# Collision
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox

# UI controls (sẽ được gán từ Global)
var joystick: Joystick = null
var attack_buttons: AttackButtons = null

# Gameplay state
var state: PlayerState
var is_attacking := false
var knockback_vector := Vector2.ZERO
var knockback_timer := 0.0
const KNOCKBACK_DURATION := 0.2
var attack_requested := false
var look_direction: Vector2 = Vector2.RIGHT
var spawn_position: Vector2 = Vector2.ZERO


func _ready() -> void:
	animation_tree.active = true
	state_machine.change_state("IdleState")
	hitbox.hitbox_owner = self
	connect_signals()

func connect_signals() -> void:
	if attack_buttons:
		attack_buttons.attack_triggered.connect(_on_attack_triggered)
	else:
		push_warning("Attack buttons chưa được gán vào Player.")
	
	hurtbox.connect("hit_received", _on_hit_received)

func _physics_process(delta: float) -> void:
	var input_vector: Vector2 = joystick.get_direction() if joystick else Vector2.ZERO

	if knockback_timer > 0:
		velocity = knockback_vector
		knockback_timer -= delta
	else:
		velocity = input_vector * speed

	move_and_slide()

	if input_vector != Vector2.ZERO:
		var blend_vector = _update_look_direction(input_vector)
		update_blend_positions(blend_vector)
		update_hitbox_rotation(blend_vector)

	if state_machine.current_state:
		state_machine.current_state.physics_update(delta, input_vector)

func _update_look_direction(input: Vector2) -> Vector2:
	if input.x != 0 and input.y != 0:
		look_direction = Vector2(input.x, 0)
	elif input != Vector2.ZERO:
		look_direction = input
	return look_direction

func update_blend_positions(input: Vector2) -> void:
	for state in ["IdleState", "WalkState", "AttackState"]:
		animation_tree.set("parameters/%s/blend_position" % state, input)
	attack_effect_animation_tree.set("parameters/AttackEffect/blend_position", input)

func update_hitbox_rotation(input: Vector2) -> void:
	if input == Vector2.ZERO: return
	if abs(input.x) > abs(input.y):
		hitbox.rotation_degrees = -90 if input.x > 0 else 90
	else:
		hitbox.rotation_degrees = 0 if input.y > 0 else -180

func take_damage(amount: int) -> void:
	state.stats.current_hp = max(0, state.stats.current_hp - amount)
	emit_signal("damaged", amount)
	if state.stats.current_hp <= 0:
		die()

func gain_experience(amount: int) -> void:
	#state.gain_experience(amount)
	state.stats.gain_experience(amount)
	emit_signal("gained_exp", amount)

func die() -> void:
	state_machine.change_state("DeathState")
	
func respawn() -> void:
	global_position = spawn_position
	state.stats.current_hp = state.stats.max_hp
	velocity = Vector2.ZERO
	attack_requested = false
	knockback_timer = 0.0
	state_machine.change_state("IdleState")	

func _on_hit_received(damage: int, from_position: Vector2) -> void:
	knockback_vector = (global_position - from_position).normalized() * 300
	knockback_timer = KNOCKBACK_DURATION
	take_damage(damage)

func _on_attack_triggered() -> void:
	attack_requested = true

func add_item_to_inventory(item: Item, amount := 1):
	state.inventory.add_item(item, amount)
