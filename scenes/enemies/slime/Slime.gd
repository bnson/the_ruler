class_name Slime
extends Enemy

#======================================================================
@export var item_pickup_scene: PackedScene

# Drop items: item_id : tỉ lệ (trọng số)
@export var drop_items := {
	"health_potion": 0.5,
	"apple": 0.5,
	"grocery_store_key": 0.5,
}

@export var min_drop_count := 10
@export var max_drop_count: int = 30

# Chế độ loot: 
# - true = auto loot trực tiếp vào Inventory.
# - false = spawn item ra map
@export var auto_loot := false

#======================================================================
func _ready() -> void:
	super._ready()
	#--
	hitbox.owner = self
	hitbox.active_time = 0.0
	hitbox.damage = stats.get_damage()
	hitbox.activate()
	#--
	hurtbox.owner = self
	#--
	state = State.PATROLLING

func _physics_process(delta: float) -> void:
	# Xử lý stunned
	if is_stunned():
		move_and_slide()
		return
		
	# Xử lý die
	if stats.cur_hp <= 0:
		if state != State.DEAD:
			#print("---------------: ", state)
			state = State.DEAD
			set_dead_state()
			# Drop item (spawn hoặc auto loot)
			drop_item(auto_loot)
			move_and_slide()
			
		return
	
	# Xử lý action dựa trên current state
	match state:
		State.IDLE:
			velocity = Vector2.ZERO
		State.PATROLLING:
			patrol(delta)
		State.CHASING:
			chase_player(delta)
		State.STUNNED:
			pass
		State.DEAD:
			pass
	
	# Cập nhật direction
	if direction != Vector2.ZERO:
		update_animation_direction()
		update_hitbox_direction()
	
	move_and_slide()

#======================================================================
func update_animation_direction() -> void:
	for anim_state in ["IdleState", "WalkState", "StunState", "DieState"]:
		animation_tree.set("parameters/%s/blend_position" % anim_state, direction)

func update_hitbox_direction():
	if direction == Vector2.ZERO:
		return
	
	if abs(direction.x) > abs(direction.y):
		hitbox.rotation_degrees = -90 if direction.x > 0 else 90
	else:
		hitbox.rotation_degrees = 0 if direction.y > 0 else -180

#======================================================================
func _on_perception_area_entered(area: Area2D) -> void:
	handle_player_detected(area)

#======================================================================
# Loot system
#======================================================================
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
					PlayerManager.player.inventory.add_item(item, amount)
				else:
					spawn_item(item, amount)

# Weighted random chọn item từ drop_items
func choose_random_item() -> String:
	var total_weight := 0.0
	for chance in drop_items.values():
		total_weight += chance

	var rnd = randf() * total_weight
	var running_sum := 0.0
	for id in drop_items.keys():
		running_sum += drop_items[id]
		if rnd <= running_sum:
			return id
	return ""

# Spawn item ra map với lực văng ngẫu nhiên
func spawn_item(item: ItemData, amount := 1):
	print("📦 SPAWN", item.id, "x", amount, "at", global_position)
	if not item_pickup_scene:
		push_error("❌ item_pickup_scene chưa được set trong Inspector")
		return

	var drop: ItemPickup = item_pickup_scene.instantiate()

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
