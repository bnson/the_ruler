class_name InventoryPanel
extends Control

@export var slot_scene: PackedScene

@onready var general_container: GridContainer = $MainPanel/Margin/VBox/TabContainer/General/HBox/Scroll/GeneralContainer
@onready var special_container: GridContainer = $MainPanel/Margin/VBox/TabContainer/Special/HBox/Scroll/SpecialContainer
@onready var general_item_info_panel: ItemInfoPanel = $MainPanel/Margin/VBox/TabContainer/General/HBox/ItemInfoPanel
@onready var special_item_info_panel: ItemInfoPanel = $MainPanel/Margin/VBox/TabContainer/Special/HBox/ItemInfoPanel

var count_slot_general: int = 0
var count_slot_special: int = 0


func _ready():
	# Kết nối signal từ InventoryManager (Autoload)
	InventoryManager.connect("inventory_changed", Callable(self, "_on_inventory_changed"))
	_on_inventory_changed()  # Hiển thị ban đầu

func _on_inventory_changed():
	clear()
	
	# Lấy danh sách item từ InventoryManager
	var items = InventoryManager.get_all_items()
	for data in items:
		var slot = slot_scene.instantiate()
		var item: ItemData = data["item"]
		
		if item.is_unique:
			special_container.add_child(slot)
			count_slot_special += 1
			slot.set_item(item, data["quantity"])
			slot.connect("slot_clicked", Callable(self, "_on_slot_clicked"))
		else:
			general_container.add_child(slot)
			count_slot_general += 1
			slot.set_item(item, data["quantity"])
			slot.connect("slot_clicked", Callable(self, "_on_slot_clicked"))
	
	# Thêm slot trống cho đủ max_slots
	for i in range(InventoryManager.max_slots - count_slot_general):
		var slot = slot_scene.instantiate()
		general_container.add_child(slot)
		slot.set_item(null, 0)
	
	for i in range(InventoryManager.max_slots - count_slot_special):
		var slot = slot_scene.instantiate()
		special_container.add_child(slot)
		slot.set_item(null, 0)

func _on_slot_clicked(clicked_slot):
	print("Clicked slot:", clicked_slot)
	# Clear cả hai bảng info
	general_item_info_panel.clear()
	special_item_info_panel.clear()
	
	# Highlight slot
	for slot in general_container.get_children():
		if slot.has_method("set_highlight"):
			slot.set_highlight(slot == clicked_slot)
	
	for slot in special_container.get_children():
		if slot.has_method("set_highlight"):
			slot.set_highlight(slot == clicked_slot)
	
	# Hiển thị thông tin item
	var item = clicked_slot.current_item
	if item:
		if item.is_unique:
			special_item_info_panel.show_item(item)
		else:
			general_item_info_panel.show_item(item)

func _on_close_button_pressed() -> void:
	visible = false

func clear() -> void:
	count_slot_general = 0
	count_slot_special = 0
	
	# Clear cả hai bảng info
	general_item_info_panel.clear()
	special_item_info_panel.clear()
	
	# Xoá slot cũ ở cả hai vùng
	for child in general_container.get_children():
		child.queue_free()
		
	for child in special_container.get_children():
		child.queue_free()
