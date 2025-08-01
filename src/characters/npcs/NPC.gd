# NPC.gd
extends Area2D

class_name NPC

@export var display_name: String = "Unnamed NPC"
@export var dialogue_data: Array = []
@export var sell_items: Array[Item] = []
@export var accept_gift_item_ids: Array[String] = []

var love: int = 0
var trust: int = 0

signal player_entered()
signal player_exited()

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body):
	if body.name == "Player":
		emit_signal("player_entered")

func _on_body_exited(body):
	if body.name == "Player":
		emit_signal("player_exited")
