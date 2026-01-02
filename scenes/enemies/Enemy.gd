class_name Enemy
extends CharacterBody2D

@onready var animation_tree: AnimationTree = get_node_or_null("AnimationTree")
@onready var animation_player: AnimationPlayer = get_node_or_null("AnimationPlayer")
@onready var hitbox: Hitbox = get_node_or_null("Hitbox")
@onready var hurtbox: Hurtbox = get_node_or_null("Hurtbox")
@onready var stats: EnemyStats = get_node_or_null("Stats")
@onready var raycast: RayCast2D = get_node_or_null("RayCast2D")
@onready var timer: Timer = get_node_or_null("Timer")
@onready var detection_area: Area2D = get_node("DetectionArea")
@onready var health_bar: ProgressBar = get_node_or_null("HealthBar/ProgressBar")

# Enum state
enum State { IDLE, PATROLLING, CHASING, ATTACKING, STUNNED, DEAD }
enum PatrolMode { CIRCLE, RANDOM, WANDER }

# Trạng thái & cách thức tuần tra
var state: State = State.PATROLLING
var patrol_mode: PatrolMode = PatrolMode.CIRCLE

# Di chuyển
var direction: Vector2 = Vector2.ZERO
var knockback_direction: Vector2 = Vector2.ZERO
var knockback_force: float = 150.0

# Tuần tra
var patrol_points: Array[Vector2] = []
var patrol_index: int = 0
var patrol_speed: float = 0
var patrol_radius: float = 100.0
var auto_generate_patrol: bool = true
var patrol_point_count: int = 5
var wait_time_at_point: float = 0.3

#=============================================================
func _ready() -> void:
	add_to_group("enemies")
	
	# Hit and hurt box
	hitbox.hit_detected.connect(on_hit_detected)
	hurtbox.hit_received.connect(on_hit_received)
	
	# Connect timeout
	timer.timeout.connect(time_out)
	
	# Random tốc độ tuần tra
	patrol_speed = stats.get_random_speed(10)
	
	# Random chế độ tuần tra
	var modes = [PatrolMode.CIRCLE, PatrolMode.RANDOM, PatrolMode.WANDER]
	patrol_mode = modes[randi() % modes.size()]
	
	# Tạo điểm tuần tra nếu chưa có
	if auto_generate_patrol and patrol_points.is_empty():
		generate_patrol_points()
		
	# Thiết lập thanh máu
	if health_bar:
		health_bar.max_value = stats.max_hp
		health_bar.value = stats.cur_hp
		health_bar.visible = false
	
#=============================================================
func generate_patrol_points():
	patrol_points.clear()
	var center = global_position
	
	match patrol_mode:
		PatrolMode.CIRCLE:
			for i in range(patrol_point_count):
				var angle = deg_to_rad(360.0 / patrol_point_count * i + randf_range(-15, 15))
				var radius = patrol_radius + randf_range(-20, 20)
				var offset = Vector2(cos(angle), sin(angle)) * radius
				patrol_points.append(center + offset)
		PatrolMode.RANDOM:
			for i in range(patrol_point_count):
				var offset = Vector2(randf_range(-patrol_radius, patrol_radius), randf_range(-patrol_radius, patrol_radius))
				patrol_points.append(center + offset)
		PatrolMode.WANDER:
			# Wander không cần điểm cố định
			pass

func patrol(delta: float) -> void:
	if is_dead():
		return
	
	if state != State.PATROLLING:
		return
	
	match patrol_mode:
		PatrolMode.CIRCLE, PatrolMode.RANDOM:
			if patrol_points.is_empty():
				return
			
			var target = patrol_points[patrol_index]
			
			if wait_time_at_point > 0.0:
				wait_time_at_point -= delta
				velocity = Vector2.ZERO
				return
			
			direction = (target - global_position).normalized()
			direction = check_obstacle_and_adjust(direction)
			velocity = direction * patrol_speed
			
			if global_position.distance_to(target) < 4.0:
				wait_time_at_point = randf_range(0.5, 2.0) # nghỉ ngẫu nhiên
				patrol_index = (patrol_index + 1) % patrol_points.size()
	
		PatrolMode.WANDER:
			if direction == Vector2.ZERO or randf() < 0.01:
				direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
			
			direction = check_obstacle_and_adjust(direction)
			velocity = direction * patrol_speed

#=============================================================
func chase_player(_delta: float):
	if is_dead():
		return
		
	var distance = global_position.distance_to(PlayerManager.get_player_position())
	
	if distance > 200:
		state = State.PATROLLING
	else:
		state = State.CHASING
		direction = (PlayerManager.get_player_position() - global_position).normalized()
		direction = check_obstacle_and_adjust(direction)
		velocity = direction * stats.get_speed()

func attack_player(_delta: float):
	pass

#=============================================================
func on_hit_detected(_area : Area2D, _damage : float):
	#print(self, " hit ", area.get_owner(), " for ", damage)
	pass

func on_hit_received(area : Area2D, damage: float):
	#print(self, " took ", damage, " from ", area.get_owner())
	
	# Xử ly die
	if is_dead():
		return
	
	# Xử lý khi area là player
	if area.get_owner().is_in_group("player"):
		# Trừ máu
		stats.take_damage(damage)
		update_health_bar()
	
		# Các hiệu ứng khác
		state = State.STUNNED
		knockback_direction = (global_position - area.global_position).normalized()
		velocity = knockback_direction * knockback_force
	
		# Xử lý timer
		timer.stop()
		timer.wait_time = PlayerManager.player.stats.stun_duration
		timer.one_shot = true
		timer.start()

#======================================================================
func handle_player_detected(area : Area2D):
	if is_dead():
		return
	
	if area.get_owner().is_in_group("player"):
		state = State.CHASING

#======================================================================
func update_health_bar():
	if health_bar:
		health_bar.value = stats.cur_hp
		health_bar.visible = stats.cur_hp < stats.max_hp

func set_dead_state():
	state = State.DEAD
	velocity = Vector2.ZERO
	PlayerManager.player.stats.add_experience(stats.get_reward_exp())
	
	if health_bar:
		health_bar.visible = false
	
	await animation_tree.animation_finished
	queue_free()

#======================================================================
func is_idle() -> bool:
	return state == State.IDLE

func is_walking() -> bool:
	return state == State.PATROLLING or state == State.CHASING

func is_stunned() -> bool:
	return state == State.STUNNED

func is_dead() -> bool:
	return state == State.DEAD

#======================================================================
func check_obstacle_and_adjust(i_direction: Vector2) -> Vector2:
	if is_dead():
		return Vector2.ZERO

	if raycast:
		raycast.target_position = i_direction * 32 # khoảng cách kiểm tra
		if raycast.is_colliding():
			var collider = raycast.get_collider()
			# Nếu collider là player thì giữ nguyên hướng
			if collider is Player:
				return i_direction
			# Ngược lại đổi hướng ngẫu nhiên
			return Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	return i_direction

func time_out():
	if is_dead():
		return
	
	if state == State.STUNNED:
		state = State.PATROLLING
