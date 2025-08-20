### 📄 InventoryUi.gd
extends Control
class_name InventoryUi

@export var slot_scene: PackedScene

@onready var general_grid: GridContainer = $Main/Margin/VBoxContainer/Panel2/TabContainer/General/MarginContainer/HBoxContainer/GridContainer
@onready var special_grid: GridContainer = $Main/Margin/VBoxContainer/Panel2/TabContainer/Special/MarginContainer/HBoxContainer/GridContainer
@onready var general_info_panel: ItemInfoPanel = $Main/Margin/VBoxContainer/Panel2/TabContainer/General/MarginContainer/HBoxContainer/ItemInfoPanel
@onready var special_info_panel: ItemInfoPanel = $Main/Margin/VBoxContainer/Panel2/TabContainer/Special/MarginContainer/HBoxContainer/ItemInfoPanel
@onready var gold_label: Label = $Main/Margin/VBoxContainer/Panel/HBoxContainer/GoldLabel


func _ready():
	GameState.connect("inventory_changed", Callable(self, "_refresh"))
	_refresh()

func _refresh():
	var inventory = GameState.player.inventory
	var count_general := 0
	var count_special := 0
	
	gold_label.text = str(GameState.player.gold)
	
	# Xoá slot cũ ở cả hai vùng
	for child in general_grid.get_children():
		child.queue_free()
		
	for child in special_grid.get_children():
		child.queue_free()

	for data in inventory.get_all_items():
		var item: Item = data["item"]
		var slot = slot_scene.instantiate()

		if item.is_unique:
			special_grid.add_child(slot)
			count_special += 1
		else:
			general_grid.add_child(slot)
			count_general += 1

		slot.set_item(item, data["quantity"])
		slot.connect("slot_clicked", Callable(self, "_on_slot_clicked"))

	# Thêm slot trống cho đủ max_slots
	for i in range(inventory.max_slots - count_general):
		var slot = slot_scene.instantiate()
		general_grid.add_child(slot)
		slot.set_item(null, 0)

	for i in range(inventory.max_slots - count_special):
		var slot = slot_scene.instantiate()
		special_grid.add_child(slot)
		slot.set_item(null, 0)

func _on_slot_clicked(clicked_slot):
	# Clear cả hai bảng info
	general_info_panel.clear()
	special_info_panel.clear()

	# Highlight slot
	for slot in general_grid.get_children():
		if slot.has_method("set_selected"):
			slot.set_selected(slot == clicked_slot)

	for slot in special_grid.get_children():
		if slot.has_method("set_selected"):
			slot.set_selected(slot == clicked_slot)

	# Hiển thị thông tin item
	var item = clicked_slot.current_item
	if item:
		if item.is_unique:
			special_info_panel.show_item(item)
		else:
			general_info_panel.show_item(item)

func _on_button_pressed() -> void:
	visible = false
