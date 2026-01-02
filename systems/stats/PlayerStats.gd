class_name PlayerStats
extends StatsBase

#=================================================
func get_damage() -> int:
	return get_str() * 2  # Mỗi STR tăng 2 damage

#=================================================
# Cấp độ và kinh nghiệm (cơ bản)
func add_experience(amount: int):
	experience += amount
	if experience >= experience_to_next_level():
		level_up()
	emit_signal("stats_changed")

func experience_to_next_level() -> int:
	return 100 * level  # công thức ví dụ

func level_up():
	experience -= experience_to_next_level()
	level += 1
	max_hp += 10
	max_mp += 5
	max_sta += 5
	cur_hp = max_hp
	cur_mp = max_mp
	cur_sta = max_sta
	emit_signal("stats_changed")
