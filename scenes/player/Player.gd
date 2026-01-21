class_name Player
extends CharacterBody2D

#=========================================================================
@export var first_name: String
@export var last_name: String

#=========================================================================
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Hitbox = $Hitbox
@onready var hurtbox: Hurtbox = $Hurtbox
@onready var stats: PlayerStats = $Stats
@onready var timer: Timer = $Timer

const SPEED: float = 200

# Enum state
enum State { IDLE, WALKING, ATTACKING, STUNNED, DEAD }

# Trạng thái
var state: State = State.IDLE
var direction: Vector2 = Vector2.ZERO
var knockback_direction: Vector2 = Vector2.ZERO
var knockback_force: float = 300.0

#=========================================================================
func _ready() -> void:
	await get_tree().process_frame
	add_to_group("player")
	
	animation_tree.active = true
	# Gán stats cho HudPanel thông qua UiManager
	UiManager.set_player_stats(stats)
	
	# Hitbox / Hurtbox setup
	hitbox.owner = self
	hitbox.active_time = 0.1
	hitbox.deactivate()
	#--
	hurtbox.owner = self
	hitbox.hit_detected.connect(on_hit_detected)
	hurtbox.hit_received.connect(on_hit_received)
	
	# Connect timeout
	timer.timeout.connect(time_out)

func _process(_delta: float) -> void:
	pass

func _physics_process(_delta: float) -> void:
	# Xử lý stunned
	if is_stunned():
		move_and_slide()
		return
	
	# Xử lý die
	if is_dead() or stats.cur_hp <= 0:
		set_dead_state()
		move_and_slide()
		return
	
	# Xử lý di chuyển đầu vào từ joystick hoặc keyboard
	var input_vector : Vector2 = UiManager.get_joystick_vector()
	if input_vector == Vector2.ZERO:
		input_vector = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down").normalized()
	
	# Xứ lý tấn cồng đầu vào từ phím ảo và keyboard
	if Input.is_action_just_pressed("ui_attack") or UiManager.btn_attack_is_just_pressed():
		state = State.ATTACKING
	elif input_vector.length() > 0:
		state = State.WALKING
	else:
		state = State.IDLE
	
	# Xử lý action dự trên current state
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.WALKING:
			# Cập nhật hướng & vận tốc
			velocity = input_vector * SPEED
			direction = velocity.normalized()
			# Xử lý lỗi blend bị méo hoặc mất hình khi đi chéo (blend type là continuous).
			if direction.x != 0 and direction.y != 0:
				direction = Vector2(direction.x, 0).normalized()
		State.ATTACKING:
			hitbox.damage = stats.get_damage()
			hitbox.activate()
	
	# Update direction
	if direction != Vector2.ZERO:
		update_animation_direction()
		update_hitbox_direction()
	
	move_and_slide()

#=========================================================================
func update_animation_direction() -> void:
	for anim_state in ["IdleState", "WalkState", "AttackState", "StunState", "DieState"]:
		animation_tree.set("parameters/%s/blend_position" % anim_state, direction)

func update_hitbox_direction():
	if direction == Vector2.ZERO:
		return
	
	if abs(direction.x) > abs(direction.y):
		hitbox.rotation_degrees = -90 if direction.x > 0 else 90
	else:
		hitbox.rotation_degrees = 0 if direction.y > 0 else -180

#=========================================================================
func on_hit_detected(area : Area2D, _damage : float):
	print(self, " hit ", area.get_owner(), " for ", _damage, " damage.")
	#if area.get_owner().is_in_group("enemies"):
	#	var enemy: Enemy = area.get_owner()


func on_hit_received(area : Area2D, damage : float):
	#print(self, " took ", damage, " from ", area.get_owner())
	var stun_duration: float = 0.0
	
	# Trừ máu
	stats.take_damage(damage)
	
	# Các hiệu ứng khác
	state = State.STUNNED
	knockback_direction = (global_position - area.global_position).normalized()
	velocity = knockback_direction * knockback_force
	
	# Xử lý khi area là enmy
	if area.get_owner().is_in_group("enemies"):
		var enemy: Enemy = area.get_owner()
		stun_duration = enemy.stats.stun_duration
	
	# Xử lý timer
	timer.stop()
	timer.wait_time = stun_duration
	timer.one_shot = true
	timer.start()

func time_out():
	if state == State.STUNNED:
		state = State.IDLE

func set_dead_state():
	state = State.DEAD
	velocity = Vector2.ZERO

#======================================================================
func is_idle() -> bool:
	return state == State.IDLE

func is_walking() -> bool:
	return state == State.WALKING

func is_attacking() -> bool:
	return state == State.ATTACKING

func is_stunned() -> bool:
	return state == State.STUNNED

func is_dead() -> bool:
	return state == State.DEAD
