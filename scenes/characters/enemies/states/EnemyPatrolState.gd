class_name EnemyPatrolState extends BaseState


var patrol_index := 0
var patrol_points := []

func enter() -> void:
	#print("Enemy patrol state enter...")
	var enemy = state_machine.get_parent()
	enemy.animation_state.travel("WalkState")

	# Lấy danh sách điểm tuần tra từ enemy
	if enemy.patrol_positions.is_empty():
		push_warning("Enemy has no patrol positions!")
		return

	# Đảm bảo index không vượt quá giới hạn
	#patrol_index = patrol_index % patrol_points.size()

func physics_update(_delta: float, _input_vector := Vector2.ZERO) -> void:
	var enemy = state_machine.get_parent()
	var positions = enemy.patrol_positions
	
	if positions.is_empty():
		return

	var index = enemy.patrol_index  # lấy từ enemy
	var target = positions[index]
	var direction = (target - enemy.global_position).normalized()
	enemy.velocity = direction * enemy.speed
	enemy.move_and_slide()
	
	#print("Moving to point ", index, ": ", target)
	#print("Enemy pos:", enemy.global_position, "Target:", target, "Distance:", enemy.global_position.distance_to(target))

	if enemy.global_position.distance_to(target) < 10:
		#print("Moving to point ", index, ": ", target)
		enemy.patrol_index = (index + 1) % positions.size()  # cập nhật lại vào enemy
		state_machine.change_state("IdleState")
