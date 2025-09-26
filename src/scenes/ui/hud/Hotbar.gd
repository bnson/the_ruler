class_name Hotbar extends Control

@export var slot_scene: PackedScene

@onready var item_container : GridContainer = $Panel/ItemContainer

func _ready():
	GameState.inventory_changed.connect(refresh)
	refresh()
	
func refresh():
	var inventory = GameState.player.inventory
	var count_items := 0
	var max_slots := 6
	
	for item in item_container.get_children():
		item.queue_free()
		
	for data in inventory.get_all_items():
		var item: Item = data["item"]
	
		if item.effects.size() > 0:
			var slot = slot_scene.instantiate()
			item_container.add_child(slot)
			slot.set_item(item, data["quantity"])
			slot.connect("slot_clicked", Callable(self, "on_slot_clicked"))
			count_items += 1
		
	# Thêm slot trống cho đủ max_slots
	for i in range(max_slots - count_items):
		var slot = slot_scene.instantiate()
		item_container.add_child(slot)
		slot.set_item(null, 0)
		
func on_slot_clicked(clicked_slot):
	for slot in item_container.get_children():
		if slot.has_method("set_selected"):
			slot.set_selected(slot == clicked_slot)
			
	var item = clicked_slot.current_item
	if item:
		if item.effects.size() > 0:
			if item.use():
				GameState.player.inventory.remove_item(item, 1)
				refresh()
	
