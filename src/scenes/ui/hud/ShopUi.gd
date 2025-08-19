extends Control
class_name ShopUi

@export var slot_scene: PackedScene

@onready var player_item_grid: GridContainer = $Main/Container/HBoxContainer/Panel1/VBoxContainer/PlayerItemGrid
@onready var npc_item_grid: GridContainer = $Main/Container/HBoxContainer/Panel2/VBoxContainer2/NpcItemGrid
@onready var item_info_panel: ItemInfoPanel = $Main/Container/HBoxContainer/Panel3/VBoxContainer/ItemInfoPanel

var current_npc: NPC = null

func _ready():
	GameState.inventory_changed.connect(_refresh)
	_refresh()

func open_shop(npc: NPC):
	current_npc = npc
	visible = true
	_refresh()

func _refresh():
	for child in npc_item_grid.get_children():
		child.queue_free()
	for child in player_item_grid.get_children():
		child.queue_free()

	var inventory = GameState.player.inventory
	var shop_max_slots = 10
	var count_item_shop := 0
	var count_item_player := 0

	for data in inventory.get_all_items():
		var item: Item = data["item"]
		var qty: int = data["quantity"]
		count_item_player += 1

		var slot = slot_scene.instantiate()
		player_item_grid.add_child(slot)
		slot.set_item(item, qty)
		slot.connect("slot_clicked", Callable(self, "_on_sell_item"))

	for i in range(inventory.max_slots - count_item_player):
		var slot = slot_scene.instantiate()
		player_item_grid.add_child(slot)
		slot.set_item(null, 0)

	for item in current_npc.sell_items:
		var slot = slot_scene.instantiate()
		npc_item_grid.add_child(slot)
		slot.set_item(item, 1)
		slot.connect("slot_clicked", Callable(self, "_on_buy_item"))
		count_item_shop += 1

	for i in range(shop_max_slots - count_item_shop):
		var slot = slot_scene.instantiate()
		npc_item_grid.add_child(slot)
		slot.set_item(null, 0)

func _on_buy_item(slot):
	var item: Item = slot.current_item
	if not item:
		return
	if GameState.player.gold < item.price:
		push_warning("Not enough gold!")
		return
	if not GameState.player.inventory.can_add_item(item):
		push_warning("Inventory full!")
		return
	GameState.player.gold -= item.price
	GameState.player.inventory.add_item(item, 1)

func _on_sell_item(slot):
	var item: Item = slot.current_item
	if not item:
		return
	if not GameState.player.inventory.can_sell_item(item, 1):
		push_warning("Cannot sell item")
		return
	GameState.player.inventory.remove_item(item, 1)
	GameState.player.gold += item.price

func _on_close_button_pressed() -> void:
	visible = false
