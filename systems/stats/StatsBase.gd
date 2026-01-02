class_name StatsBase
extends Node

#=================================================
@export var level: int = 1
@export var experience: int = 0

@export var cur_hp: float = 100
@export var max_hp: float = 100

@export var cur_mp: float = 50
@export var max_mp: float = 50

@export var cur_sta: float = 100
@export var max_sta: float = 100

@export var base_str: int = 10
@export var base_dex: int = 10
@export var base_int: int = 10
@export var base_agi: int = 10

@export var bonus_str: int = 0
@export var bonus_dex: int = 0
@export var bonus_int: int = 0
@export var bonus_agi: int = 0

@export var base_speed: float = 0.0
@export var bonus_speed: float = 0.0

@export var stun_duration: float = 0.0 # mặc định không gây choáng

#=================================================
signal stats_changed

#=================================================
# Các hàm tính toán tổng chỉ số
func get_str() -> int:
	return base_str + bonus_str

func get_dex() -> int:
	return base_dex + bonus_dex

func get_int() -> int:
	return base_int + bonus_int

func get_agi() -> int:
	return base_agi + bonus_agi

func get_speed() -> float:
	return base_speed + bonus_speed

func get_random_speed(percent: float) -> float:
	var min_speed = get_speed()
	var max_speed = min_speed * (1.0 + percent / 100.0)
	return randf_range(min_speed, max_speed)

#----------------------------------
# Các hàm xử lý máu, mana, stamina
func take_damage(amount: float):
	cur_hp = max(cur_hp - amount, 0)
	emit_signal("stats_changed")

func heal(amount: float):
	cur_hp = min(cur_hp + amount, max_hp)
	emit_signal("stats_changed")

func use_mana(amount: float) -> bool:
	if cur_mp >= amount:
		cur_mp -= amount
		emit_signal("stats_changed")
		return true
	return false

func use_stamina(amount: float) -> bool:
	if cur_sta >= amount:
		cur_sta -= amount
		emit_signal("stats_changed")
		return true
	return false

#----------------------------------
func to_dict() -> Dictionary:
	return {
		"level": level,
		"experience": experience,
		"cur_hp": cur_hp,
		"max_hp": max_hp,
		"cur_mp": cur_mp,
		"max_mp": max_mp,
		"cur_sta": cur_sta,
		"max_sta": max_sta,
		"base_str": base_str,
		"base_dex": base_dex,
		"base_int": base_int,
		"base_agi": base_agi,
		"bonus_str": bonus_str,
		"bonus_dex": bonus_dex,
		"bonus_int": bonus_int,
		"bonus_agi": bonus_agi,
		"base_speed": base_speed,
		"bonus_speed": bonus_speed,
		"stun_duration": stun_duration
	}


func from_dict(data: Dictionary):
	level = data.get("level", level)
	experience = data.get("experience", experience)
	cur_hp = data.get("cur_hp", cur_hp)
	max_hp = data.get("max_hp", max_hp)
	cur_mp = data.get("cur_mp", cur_mp)
	max_mp = data.get("max_mp", max_mp)
	cur_sta = data.get("cur_sta", cur_sta)
	max_sta = data.get("max_sta", max_sta)
	base_str = data.get("base_str", base_str)
	base_dex = data.get("base_dex", base_dex)
	base_int = data.get("base_int", base_int)
	base_agi = data.get("base_agi", base_agi)
	bonus_str = data.get("bonus_str", bonus_str)
	bonus_dex = data.get("bonus_dex", bonus_dex)
	bonus_int = data.get("bonus_int", bonus_int)
	bonus_agi = data.get("bonus_agi", bonus_agi)
	base_speed = data.get("base_speed", base_speed)
	bonus_speed = data.get("bonus_speed", bonus_speed)
	stun_duration = data.get("stun_duration", stun_duration)
	
	emit_signal("stats_changed")
