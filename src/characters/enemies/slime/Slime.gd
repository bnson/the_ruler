extends CharacterBody2D
class_name Slime

signal slime_died(slime_node: Node)

enum PatrolShape { SQUARE, CIRCLE, TRIANGLE }

@export var speed := 40.0
@export var max_hp := 30
@export var exp_reward := 10
@export var patrol_shape: PatrolShape = PatrolShape.SQUARE
@export var patrol_radius: float = 100.0

var current_hp := max_hp
var patrol_index := 0
var is_attacking := true

var knockback_vector := Vector2.ZERO
var knockback_timer := 0.0
const KNOCKBACK_DURATION := 0.2

@onready var node_name := get_name()
@onready var state_machine = $StateMachine
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var detection_area: Area2D = $DetectionArea
@onready var patrol_positions: Array[Vector2] = generate_patrol_positions(global_position, patrol_shape, patrol_radius)

func _ready() -> void:
	current_hp = max_hp
	animation_tree.active = true
	state_machine.change_state("PatrolState")
	hitbox.hitbox_owner = self

	Logger.debug_log(node_name, "Slime initialized with HP: %d" % max_hp, "Enemy")
	connect_signals()

func connect_signals() -> void:
	Logger.connect_signal_once(hurtbox, "hit_received", Callable(self, "_on_hit_received"), node_name, "Enemy")
	Logger.connect_signal_once(detection_area, "body_entered", Callable(self, "_on_body_entered"), node_name, "Enemy")

func _physics_process(delta: float) -> void:
	var input_vector := Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	if knockback_timer > 0.0:
		velocity = knockback_vector
		knockback_timer -= delta
	else:
		velocity = input_vector * speed

	move_and_slide()

	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/IdleState/blend_position", input_vector)
		animation_tree.set("parameters/WalkState/blend_position", input_vector)

	if state_machine.current_state:
		state_machine.current_state.physics_update(delta)

func get_player() -> Node2D:
	if Global.player:
		return Global.player
	Logger.error(node_name, "Player chưa được khởi tạo trong Global.gd!", "Enemy")
	return null

func take_damage(amount: int) -> void:
	current_hp -= amount
	Logger.debug_log(node_name, "Received damage: %d | Current HP: %d" % [amount, current_hp], "Enemy")

	if current_hp <= 0:
		die()

func die() -> void:
	Logger.debug_log(node_name, "Slime has died.", "Enemy")

	if Global.player and Global.player.has_method("gain_experience"):
		Global.player.gain_experience(exp_reward)
		Logger.debug_log(node_name, "Granted %d EXP to player." % exp_reward, "Enemy")

	emit_signal("slime_died", self)
	queue_free()

func _on_hit_received(damage: int, from_position: Vector2) -> void:
	Logger.debug_log(node_name, "Hit received: %d from position %s" % [damage, str(from_position)], "Enemy")
	knockback_vector = (global_position - from_position).normalized() * 300
	knockback_timer = KNOCKBACK_DURATION
	take_damage(damage)

func generate_patrol_positions(center: Vector2, shape: int, radius: float) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	match shape:
		PatrolShape.SQUARE:
			positions = [
				center + Vector2(-radius, -radius),
				center + Vector2(radius, -radius),
				center + Vector2(radius, radius),
				center + Vector2(-radius, radius)
			]
		PatrolShape.CIRCLE:
			for i in range(4):
				var angle = i * PI / 2
				positions.append(center + Vector2(cos(angle), sin(angle)) * radius)
		PatrolShape.TRIANGLE:
			for i in range(3):
				var angle = i * TAU / 3
				positions.append(center + Vector2(cos(angle), sin(angle)) * radius)
	return positions

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		Logger.debug_log(node_name, "Player entered detection area — switching to WalkState.", "Enemy")
		state_machine.change_state("WalkState")
