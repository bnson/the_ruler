extends CharacterBody2D

class_name Enemy

@export var enemy_name: String = "Unnamed Enemy"
@export var stats: Resource

func _ready():
	print("Enemy ready:", enemy_name)
