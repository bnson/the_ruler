extends Control
class_name ShopUi

@export var slot_scene: PackedScene

@onready var player_item_grid: GridContainer = $Main/Container/HBoxContainer/Panel1/VBoxContainer/GridContainer
@onready var npc_item_grid: GridContainer = $Main/Container/HBoxContainer/Panel2/VBoxContainer/Panel2/VBoxContainer/GridContainer
@onready var item_info_panel: ItemInfoPanel = $Main/Container/HBoxContainer/Panel2/VBoxContainer/Panel3/VBoxContainer/ItemInfoPanel

var current_npc: NPC = null

func _ready():
	#GameState.connect("inventory_changed", Callable(self, "_refresh"))
	#_refresh()
	pass

func open_shop(npc: NPC):
	current_npc = npc
	visible = true
	_refresh()

func _refresh():
	# Dọn sạch UI cũ
	for child in npc_item_grid.get_children():
		child.queue_free()
	for child in player_item_grid.get_children():
		child.queue_free()

	var inventory = GameState.player.inventory
	var shop_max_slots = 10
	var count_item_shop := 0
	var count_item_player := 0
	
	# Load item từ inventory player để bán
	print("Load item from inventory player...")
	for id in inventory.items.keys():
		var slot = slot_scene.instantiate()
		var data = inventory.items[id]
		var item = data["item"]
		var qty = data["quantity"]

		count_item_player += 1
		
		player_item_grid.add_child(slot)
		slot.set_item(item, qty)
		#slot.call_deferred("set_item", item, qty)
		slot.connect("slot_clicked", Callable(self, "_on_sell_item").bind(item))
		
		
		
	# Thêm slot trống cho đủ max_slots
	for i in range(inventory.max_slots - count_item_player):
		var slot = slot_scene.instantiate()
		player_item_grid.add_child(slot)
		slot.set_item(null, 0)

	# Load item NPC đang bán
	print("Load item from inventory NPC...")
	for item in current_npc.sell_items:
		var slot = slot_scene.instantiate()
		npc_item_grid.add_child(slot)
		slot.set_item(item, 1)
		#slot.call_deferred("set_item", item, 1)
		slot.connect("slot_clicked", Callable(self, "_on_buy_item").bind(item))

func _on_buy_item(item: Item):
	print("🛒 Mua item:", item.id)

	# TODO: Check gold, add item to inventory, giảm gold, ...
	GameState.player.inventory.add_item(item, 1)
	GameState.emit_signal("inventory_changed")
	_refresh()

func _on_sell_item(item: Item):
	print("📤 Bán item:", item.id)

	# TODO: Kiểm tra NPC có nhận item không (nếu là gift), tăng gold, xóa item khỏi inventory
	GameState.player.inventory.remove_item(item, 1)
	GameState.emit_signal("inventory_changed")
	_refresh()

func _on_close_button_pressed() -> void:
	visible = false
