extends CharacterBody2D

class_name NPC

@export var npc_name: String = "Unnamed NPC"
@export var dialogue_file: String = "res://templates/npc_template/dialogue.json"

func _ready():
	print("NPC ready:", npc_name)
