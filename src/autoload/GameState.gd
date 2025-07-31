extends Node

@onready var player: PlayerState = PlayerState.new()

signal stats_changed
signal inventory_changed

func _ready():
	# Gắn signals từ PlayerState đến GameState
	player.stats.connect("stats_changed", func(): _on_stats_changed())
	player.inventory.connect("inventory_changed", func(): _on_inventory_changed())

func _on_stats_changed():
	emit_signal("stats_changed")

func _on_inventory_changed():
	emit_signal("inventory_changed")
