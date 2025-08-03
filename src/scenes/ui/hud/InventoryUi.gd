extends Control

@export var slot_scene: PackedScene

@onready var common_grid: GridContainer = $Panel/TabContainer/Inventory
@onready var special_grid: GridContainer = $Panel/TabContainer/Special

func _ready():
	GameState.connect("inventory_changed", Callable(self, "_refresh"))
	_refresh()

func _refresh():
	# Xoá slot cũ ở cả hai vùng
	for child in common_grid.get_children():
		child.queue_free()
	for child in special_grid.get_children():
		child.queue_free()

	var inventory = GameState.player.inventory
	var count_common := 0
	var count_special := 0

	for id in inventory.items.keys():
		var data = inventory.items[id]
		var slot = slot_scene.instantiate()
		slot.get_node("Icon").texture = data["item"].atlas_texture
		slot.get_node("Quantity").text = str(data["quantity"])

		# Giả sử item có thuộc tính is_unique
		if data["item"].is_unique:
			special_grid.add_child(slot)
			count_special += 1
		else:
			common_grid.add_child(slot)
			count_common += 1

	# Thêm slot trống cho đủ max_slots
	for i in range(inventory.max_slots - count_common):
		var slot = slot_scene.instantiate()
		slot.get_node("Icon").texture = null
		slot.get_node("Quantity").text = ""
		common_grid.add_child(slot)
