class_name Slime extends CharacterBody2D


signal slime_died(slime_node: Node)

enum PatrolShape { SQUARE, CIRCLE, TRIANGLE }

const STATE_IDLE := "IdleState"
const STATE_CHASE := "ChaseState"
const STATE_ATTACK := "AttackState"
const STATE_PATROL := "PatrolState"
const STATE_STUN := "StunState"
const STATE_DESTROY := "DestroyState"
const KNOCKBACK_DURATION: float = 0.2

#––––––––––
# Exported
#––––––––––
@export var speed: float = 40.0
@export var max_hp: int = 300
@export var exp_reward: int = 1
@export var patrol_shape: PatrolShape = PatrolShape.SQUARE
@export var patrol_radius: float = 100.0
@export var dropped_item_scene: PackedScene

# Drop table: item_id : tỉ lệ (trọng số)
@export var drop_table := {
	"potion": 0.5,
	"apple": 0.3,
	"key": 0.2
}

@export var min_drop_count := 1
@export var max_drop_count: int = 3

# Chế độ loot: 
# - true = auto loot trực tiếp vào Inventory.
# - false = spawn item ra map
@export var auto_loot := false

#–––––––––––––
# Cached nodes
#–––––––––––––
@onready var node_name := get_name()
@onready var state_machine = $StateMachine
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_state: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var detection_area: Area2D = $DetectionArea
@onready var patrol_positions: Array[Vector2] = generate_patrol_positions(global_position, patrol_shape, patrol_radius)

#–––––––––––––––
# Internal state
#–––––––––––––––
var current_hp: int = max_hp
var patrol_index: int = 0
var is_attacking: bool = true
var knockback_vector: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0
var look_direction: Vector2 = Vector2.RIGHT  # mặc định nhìn phải

#––––––
# Ready
#––––––
func _ready() -> void:
	current_hp = max_hp
	animation_tree.active = true
	hitbox.hitbox_owner = self
	state_machine.change_state(STATE_PATROL)
	Logger.debug_log(node_name, "Slime initialized with HP: %d" % max_hp, "Enemy")
	connect_signals()

func connect_signals() -> void:
	Logger.connect_signal_once(hurtbox, "hit_received", Callable(self, "_on_hit_received"), node_name, "Enemy")
	Logger.connect_signal_once(detection_area, "body_entered", Callable(self, "_on_body_entered"), node_name, "Enemy")

#––––––
# Logic
#––––––
func _update_animation() -> void:
	var move_dir: Vector2 = velocity.normalized()
	if move_dir == Vector2.ZERO:
		return

	if abs(move_dir.x) > abs(move_dir.y):
		look_direction = Vector2(sign(move_dir.x), 0)
	else:
		look_direction = Vector2(0, sign(move_dir.y))

	animation_tree.set("parameters/IdleState/blend_position", look_direction)
	animation_tree.set("parameters/ChaseState/blend_position", look_direction)
	animation_tree.set("parameters/StunState/blend_position", look_direction)

func _state_update(delta: float) -> void:
	if state_machine.current_state:
		state_machine.current_state.physics_update(delta)

func _physics_process(delta: float) -> void:
	_update_animation()
	_state_update(delta)

#–––––––––––––––
# Combat & Death
#–––––––––––––––
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

	state_machine.change_state(STATE_DESTROY)
	await animation_tree.animation_finished

	# Thêm EXP vào player
	GameState.player.stats.gain_experience(exp_reward)

	# Drop item (spawn hoặc auto loot)
	drop_item(auto_loot)

	emit_signal("slime_died", self)
	queue_free()

func _on_hit_received(damage: int, from_position: Vector2) -> void:
	Logger.debug_log(node_name, "Hit received: %d from position %s" % [damage, str(from_position)], "Enemy")
	state_machine.change_state(STATE_STUN)
	knockback_vector = (global_position - from_position).normalized() * 300
	knockback_timer = KNOCKBACK_DURATION
	take_damage(damage)

#––––––––––––––––––
# Patrol positions
#––––––––––––––––––
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
		Logger.debug_log(node_name, "Player entered detection area — switching to ChaseState.", "Enemy")
		state_machine.change_state(STATE_CHASE)

#–––––––––––––
# Loot system
#–––––––––––––
func drop_item(_auto_loot := false):
	var drop_count = randi_range(min_drop_count, max_drop_count)
	for i in range(drop_count):
		var id = choose_random_item()
		if id != "":
			var item = ItemDatabase.get_item(id)
			if item:
				var amount = 1
				#var amount = randi_range(1, 3)  # mỗi item drop từ 1-3 stack
				if auto_loot:
					GameState.player.inventory.add_item(item, amount)
				else:
					spawn_item(item, amount)

# Weighted random chọn item từ drop_table
func choose_random_item() -> String:
	var total_weight := 0.0
	for chance in drop_table.values():
		total_weight += chance

	var rnd = randf() * total_weight
	var running_sum := 0.0
	for id in drop_table.keys():
		running_sum += drop_table[id]
		if rnd <= running_sum:
			return id
	return ""

# Spawn item ra map với lực văng ngẫu nhiên
func spawn_item(item: Item, amount := 1):
	print("📦 SPAWN", item.id, "x", amount, "at", global_position)
	if not dropped_item_scene:
		push_error("❌ dropped_item_scene chưa được set trong Inspector")
		return

	var drop: DroppedItem = dropped_item_scene.instantiate()

	# Offset vị trí + random lực văng
	var offset = Vector2(randf_range(-8, 8), randf_range(-8, 8))
	drop.global_position = global_position + offset
	var angle = randf() * TAU
	var force = randf_range(60, 120)
	drop.linear_velocity = Vector2.RIGHT.rotated(angle) * force

	# ✅ Add vào SceneTree trước để @onready var sprite khởi tạo
	if get_tree().current_scene:
		get_tree().current_scene.call_deferred("add_child", drop)
	else:
		push_error("⚠️ current_scene null, không thể add_child")

	# ✅ Sau khi add vào tree mới set_item
	# Dùng call_deferred để đảm bảo sprite đã tồn tại
	drop.call_deferred("set_item", item, amount)
