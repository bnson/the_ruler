class_name Npc
extends CharacterBody2D

@export var first_name: String
@export var last_name: String
@export var level: int
@export_multiline var information: String
@export var sell_items: Array[ItemData]
@export var interactions: Array[Dictionary]
@export var moods: Array[String] = ["happy", "neutral", "tired", "busy", "shy", "annoyed"]

var current_mood: String = ""
var mood_last_changed := 0.0
var mood_change_interval := 60.0  # đổi mood mỗi 60 giây (có thể sửa)

func _ready() -> void:
	roll_mood()  # chọn mood ngẫu nhiên lúc spawn

func roll_mood() -> void:
	if moods.is_empty():
		current_mood = "neutral"
		return
	
	current_mood = moods[randi() % moods.size()]
	mood_last_changed = Time.get_unix_time_from_system()

func get_current_mood() -> String:
	var now := Time.get_unix_time_from_system()
	
	# Nếu mood quá cũ, tự động random lại (tuỳ bạn)
	if now - mood_last_changed >= mood_change_interval:
		roll_mood()
	
	return current_mood
