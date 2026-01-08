class_name ShopUi
extends Control

@export var slot_scene: PackedScene

@onready var player_container: GridContainer = $Main/Margin/VBox/HBoxCenter/PanelLeft/Margin/VBox/Scroll/PlayerContainer
@onready var shop_container: GridContainer = $Main/Margin/VBox/HBoxCenter/PanelCenter/Margin/VBox/Scroll/ShopContainer
@onready var item_info_panel: ItemInfoPanel = $Main/Margin/VBox/HBoxCenter/PanelRight/Margin/ItemInfoPanel

var count_slot_player: int = 0
var count_slot_shop: int = 0


func _ready():
	# Kết nối signal từ InventoryManager (Autoload)
	InventoryManager.connect("inventory_changed", Callable(self, "on_inventory_changed"))
	on_inventory_changed()

func on_inventory_changed():
	clear()
	
	# Lấy danh sách item từ InventoryManager
	var items = InventoryManager.get_all_items()
	for data in items:
		var slot = slot_scene.instantiate()
		var item: ItemData = data["item"]
		
		if !item.is_unique:
			player_container.add_child(slot)
			count_slot_player += 1
			slot.set_item(item, data["quantity"])
			slot.connect("slot_clicked", Callable(self, "_on_slot_clicked"))
	# Thêm slot trống cho đủ max_slots
	for i in range(InventoryManager.max_slots - count_slot_player):
		var slot = slot_scene.instantiate()
		player_container.add_child(slot)
		slot.set_item(null, 0)
	
	for i in range(InventoryManager.max_slots - count_slot_shop):
		var slot = slot_scene.instantiate()
		shop_container.add_child(slot)
		slot.set_item(null, 0)

func _on_slot_clicked(clicked_slot):
	item_info_panel.clear()
	
	# Highlight slot
	for slot in player_container.get_children():
		if slot.has_method("set_highlight"):
			slot.set_highlight(slot == clicked_slot)
	
	for slot in shop_container.get_children():
		if slot.has_method("set_highlight"):
			slot.set_highlight(slot == clicked_slot)
	
	# Hiển thị thông tin item
	var item = clicked_slot.current_item
	if item:
		if item.is_unique:
			item_info_panel.show_item(item)
		else:
			item_info_panel.show_item(item)

func clear() -> void:
	count_slot_player = 0
	count_slot_shop = 0
	
	item_info_panel.clear()
	
	for child in player_container.get_children():
		child.queue_free()
		
	for child in shop_container.get_children():
		child.queue_free()
