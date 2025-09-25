class_name Hotbar extends Control

@export var slot_scene: PackedScene

@onready var item_container : GridContainer = $Panel/ItemContainer

func _ready():
	GameState.connect("inventory_changed", Callable(self, "refresh"))
	refresh()
	
func refresh():
	var inventory = GameState.player.inventory
	var count_items := 0
	
	for item in item_container.get_children():
		item.queue_free()
		
	for data in inventory.get_all_items():
		var item: Item = data["item"]
		var slot = slot_scene.instantiate()
	
		if item.is_unique:
			item_container.add_child(slot)
			count_items += 1

		slot.set_item(item, data["quantity"])
		slot.connect("slot_clicked", Callable(self, "on_slot_clicked"))
		
	# Thêm slot trống cho đủ max_slots
	for i in range(inventory.max_slots - count_items):
		var slot = slot_scene.instantiate()
		item_container.add_child(slot)
		slot.set_item(null, 0)
		
func on_slot_clicked(clicked_slot):
	pass
