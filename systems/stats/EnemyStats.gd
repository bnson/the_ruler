class_name EnemyStats
extends StatsBase

func get_damage() -> int:
	return get_str() * 2  # Mỗi STR tăng 2 damage

func get_reward_exp() -> int:
	return level * experience
