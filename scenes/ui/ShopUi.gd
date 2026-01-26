class_name ShopUi
extends Control

#=============================================
@export var slot_scene: PackedScene

#=============================================
@onready var player_container: GridContainer = $Main/Margin/VBox/HBoxCenter/PanelLeft/Margin/VBox/Scroll/PlayerContainer
@onready var shop_container: GridContainer = $Main/Margin/VBox/HBoxCenter/PanelCenter/Margin/VBox/Scroll/ShopContainer
@onready var item_info_panel: ItemInfoPanel = $Main/Margin/VBox/HBoxCenter/PanelRight/Margin/ItemInfoPanel
@onready var message_label: Label = $Main/Margin/VBox/HBoxBottom/Panel/MessageLabel

#=============================================
const BUY_PRICE_MULTIPLIER := 2

var npc_interaction: Npc
var selected_item_buy: ItemData
var selected_item_sell: ItemData

#=============================================
func _ready():
	# Kết nối signal từ InventoryManager (Autoload)
	InventoryManager.connect("inventory_changed", Callable(self, "on_inventory_changed"))
	on_inventory_changed()
	#--
	message_label.text = ""

func on_inventory_changed():
	if npc_interaction == null:
		return
	#--
	clear()
	populate_slots(player_container, InventoryManager.get_all_items())
	populate_slots(shop_container, npc_interaction.sell_items)

func populate_slots(container: GridContainer, items: Array):
	for data in items:
		var item: ItemData
		var event: String
		var quantity: int
		var selected_item: ItemData
		
		if typeof(data) == TYPE_DICTIONARY:
			item = data["item"]
			quantity= data["quantity"]
			event = "on_player_inventory_slot_clicked"
			selected_item = selected_item_sell
		else:
			item = data
			quantity = 1
			event = "on_shop_inventory_slot_clicked"
			selected_item = selected_item_buy
		
		if !item.is_unique:
			var slot: InventorySlot = slot_scene.instantiate()
			container.add_child(slot)
			slot.set_item(item, quantity)
			slot.connect("slot_clicked", Callable(self, event))
			slot.set_highlight(false)
			
			if selected_item:
				if slot.item.id == selected_item.id:
					slot.set_highlight(true)
					item_info_panel.show_item(selected_item)
	
	# Thêm slot trống cho đủ max_slots
	for i in range(InventoryManager.max_slots - container.get_child_count()):
		var slot = slot_scene.instantiate()
		container.add_child(slot)
		slot.set_item(null, 0)

func on_player_inventory_slot_clicked(clicked_slot: InventorySlot):
	selected_item_buy = null
	selected_item_sell = clicked_slot.item
	item_info_panel.clear()
	item_info_panel.show_item(selected_item_sell)
	on_inventory_slot_clicked(clicked_slot)
	
func on_shop_inventory_slot_clicked(clicked_slot):
	selected_item_buy = clicked_slot.item
	selected_item_sell = null
	var buy_price := selected_item_buy.price * 2
	item_info_panel.clear()
	item_info_panel.show_item(selected_item_buy, buy_price)
	on_inventory_slot_clicked(clicked_slot)

func on_inventory_slot_clicked(clicked_slot):
	# Highlight slot in player container
	for slot in player_container.get_children():
		if slot.has_method("set_highlight"):
			slot.set_highlight(slot == clicked_slot)
	# Highlight slot in shop container
	for slot in shop_container.get_children():
		if slot.has_method("set_highlight"):
			slot.set_highlight(slot == clicked_slot)

func clear() -> void:
	item_info_panel.clear()
	# Clear child in container
	for child in player_container.get_children(): child.free()
	for child in shop_container.get_children(): child.free()
	
func handle_interaction(npc: Npc) -> void:
	npc_interaction = npc
	on_inventory_changed()
	show()

func _on_sell_button_pressed() -> void:
	if selected_item_sell:
		if InventoryManager.can_sell_item(selected_item_sell, 1):
			InventoryManager.remove_item(selected_item_sell, 1)
			InventoryManager.add_gold(selected_item_sell.price)
			message_label.text = ""
		else:
			message_label.text = "Message: No items for sale!"

func _on_buy_button_pressed() -> void:
	if selected_item_buy:
		var buy_price := selected_item_buy.price * BUY_PRICE_MULTIPLIER
		if InventoryManager.can_spend_gold(buy_price):
			InventoryManager.add_item(selected_item_buy, 1)
			InventoryManager.spend_gold(buy_price)
			message_label.text = ""
			#--
			npc_interaction.stats.trust += 0.001
			print(npc_interaction.stats.trust)
		else:
			message_label.text = "Message: Not enough gold!"

func _on_close_button_pressed() -> void:
	selected_item_buy = null
	selected_item_sell = null
	clear()
	hide()
