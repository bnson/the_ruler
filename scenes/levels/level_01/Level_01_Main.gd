extends Node

@export var slime_scene: PackedScene
@export var min_slimes: int = 3
@export var max_slimes: int = 6
@export var spawn_area: Rect2 = Rect2(Vector2(100, 100), Vector2(800, 400))
@export var max_spawn_attempts: int = 10

@export var use_random_respawn_time: bool = false
@export var respawn_time_fixed: float = 1.0
@export var respawn_time_min: float = 5.0
@export var respawn_time_max: float = 12.0

func _ready():
	if $PlayerSpawn and $SceneContainer:
		Global.attach_player_to($SceneContainer, $PlayerSpawn.global_position)
	else:
		push_error("PlayerSpawn hoặc SceneContainer chưa sẵn sàng!")

	PlayerUi.visible = true
	DayNightController.visible = false

	if is_valid_packed_scene(slime_scene):
		print("Load random slime...")
		spawn_slimes()
	else:
		push_error("PackedScene slime_scene không hợp lệ!")

func spawn_slimes():
	var slime_count = randi_range(min_slimes, max_slimes)
	for i in range(slime_count):
		spawn_single_slime()

func spawn_single_slime():
	var slime = slime_scene.instantiate()
	if slime == null:
		print("Không thể tạo slime từ PackedScene!")
		return

	var spawn_position: Vector2
	var attempts := 0
	while attempts < max_spawn_attempts:
		spawn_position = get_random_position_in_area(spawn_area)
		if is_position_valid(spawn_position):
			break
		attempts += 1

	if attempts == max_spawn_attempts:
		print("Không tìm được vị trí spawn hợp lệ!")
		return

	slime.global_position = spawn_position
	slime.patrol_shape = randi_range(0, 2)
	slime.connect("slime_died", Callable(self, "_on_slime_died"))
	$SceneContainer.add_child(slime)

func _on_slime_died(_slime_node: Node):
	var respawn_time: float
	if use_random_respawn_time:
		respawn_time = randf_range(respawn_time_min, respawn_time_max)
	else:
		respawn_time = respawn_time_fixed

	await get_tree().create_timer(respawn_time).timeout
	spawn_single_slime()


func get_random_position_in_area(area: Rect2) -> Vector2:
	var x = randf_range(area.position.x, area.position.x + area.size.x)
	var y = randf_range(area.position.y, area.position.y + area.size.y)
	return Vector2(x, y)

func is_position_valid(position: Vector2, radius: float = 16.0) -> bool:
	var space_state = get_viewport().get_world_2d().direct_space_state

	var shape = CircleShape2D.new()
	shape.radius = radius

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, position)
	query.collide_with_areas = true
	query.collide_with_bodies = true

	var result = space_state.intersect_shape(query)
	return result.is_empty()

func is_valid_packed_scene(scene: PackedScene) -> bool:
	return scene != null and scene.can_instantiate()
