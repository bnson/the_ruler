### 📄 GameState.gd
extends Node

@onready var player: PlayerState = PlayerState.new()

var player_position: Vector2 = Vector2.ZERO

signal stats_changed
signal inventory_changed

func _ready():
	print("Game state...")
	print(player_position)
	player.stats.connect("stats_changed", _on_stats_changed)
	player.inventory.connect("inventory_changed", _on_inventory_changed)

func _on_stats_changed():
	emit_signal("stats_changed")

func _on_inventory_changed():
	emit_signal("inventory_changed")
