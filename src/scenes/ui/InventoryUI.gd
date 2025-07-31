extends Control

@onready var grid: GridContainer = $GridContainer
@export var slot_scene: PackedScene

func _ready():
	GameState.connect("inventory_changed", Callable(self, "_refresh"))
	_refresh()

func _refresh():
	grid.queue_free_children()

	var inventory = GameState.player.inventory
	for id in inventory.items.keys():
		var data = inventory.items[id]
		var slot = slot_scene.instantiate()
		slot.get_node("Icon").texture = data["item"].atlas_texture
		slot.get_node("Quantity").text = str(data["quantity"])
		grid.add_child(slot)

	# Thêm slot trống để đủ max_slots
	for i in range(inventory.max_slots - inventory.items.size()):
		var slot = slot_scene.instantiate()
		slot.get_node("Icon").texture = null
		slot.get_node("Quantity").text = ""
		grid.add_child(slot)
