extends Control
class_name ShopUi

@export var slot_scene: PackedScene

@onready var player_item_grid: GridContainer = $Main/Container/VBoxContainer/HBoxContainer/Panel1/MarginContainer/VBoxContainer/ScrollContainer/PlayerItemGrid
@onready var npc_item_grid: GridContainer = $Main/Container/VBoxContainer/HBoxContainer/Panel2/MarginContainer/VBoxContainer2/ScrollContainer/NpcItemGrid
@onready var item_info_panel: ItemInfoPanel = $Main/Container/VBoxContainer/HBoxContainer/Panel3/VBoxContainer/ItemInfoPanel
@onready var gold_value: Label = $Main/Container/VBoxContainer/HBoxContainer/Panel1/MarginContainer/VBoxContainer/Header/GoldValue
@onready var message_label: Label = $Main/Container/VBoxContainer/HBoxContainer/Panel3/VBoxContainer/Panel/MesssageLabel

const SHOP_MAX_SLOTS := 10

var current_npc: NPC
var _selected_item_id: String = ""
enum Source { NONE, SHOP, PLAYER }
var _selected_source: int = Source.NONE

func _ready() -> void:
	GameState.inventory_changed.connect(_refresh)
	_refresh()

func open_shop(npc: NPC) -> void:
	current_npc = npc
	visible = true
	_clear_selection()
	item_info_panel.clear()
	_refresh()

func _refresh() -> void:
	# Clear grids
	for c in npc_item_grid.get_children(): c.queue_free()
	for c in player_item_grid.get_children(): c.queue_free()

	# Update gold
	gold_value.text = str(GameState.player.gold)

	if current_npc == null:
		return

	# Build Player inventory slots
	var inv := GameState.player.inventory
	var count_player := 0
	for data in inv.get_all_items():
		var item: Item = data["item"]
		var qty: int = data["quantity"]
		count_player += 1
		_add_slot(player_item_grid, item, qty, Source.PLAYER)

	# Fill empty player slots
	for i in inv.max_slots - count_player:
		_add_slot(player_item_grid, null, 0, Source.PLAYER)

	# Build Shop slots
	var count_shop := 0
	for item in current_npc.sell_items:
		count_shop += 1
		_add_slot(npc_item_grid, item, 1, Source.SHOP)

	# Fill empty shop slots
	for i in SHOP_MAX_SLOTS - count_shop:
		_add_slot(npc_item_grid, null, 0, Source.SHOP)

	# Re-apply selection highlight if còn hợp lệ
	_apply_selection_highlight()

	# Nếu item đã bị bán hết (không còn slot phù hợp), tự clear panel
	_validate_info_panel_target()

func _add_slot(grid: GridContainer, item: Item, qty: int, src: int) -> void:
	var slot = slot_scene.instantiate()
	grid.add_child(slot)
	slot.set_item(item, qty)
	# Kỳ vọng Slot có signal: signal slot_clicked(slot)
	slot.disconnect("slot_clicked", Callable()) if slot.is_connected("slot_clicked", Callable(self, "_on_slot_clicked")) else null
	slot.connect("slot_clicked", Callable(self, "_on_slot_clicked").bind(src))

func _on_slot_clicked(slot, src: int) -> void:
	message_label.text = ""
	if slot.current_item == null:
		# Click vào ô trống => bỏ chọn toàn bộ bên tương ứng + clear panel
		if src == Source.SHOP and _selected_source == Source.SHOP: _clear_selection()
		elif src == Source.PLAYER and _selected_source == Source.PLAYER: _clear_selection()
		_apply_selection_highlight()
		item_info_panel.clear()
		return

	# Cập nhật selection: chỉ một phía được chọn tại một thời điểm
	_selected_item_id = slot.current_item.id
	_selected_source = src
	_apply_selection_highlight()
	
	# Hiển thị giá theo nguồn: SHOP => gấp đôi, PLAYER => giá gốc
	var item: Item = slot.current_item
	var display_price := (item.price * 2) if src == Source.SHOP else item.price
	item_info_panel.show_item(slot.current_item, display_price)

func _apply_selection_highlight() -> void:
	# SHOP side
	for s in npc_item_grid.get_children():
		if s.has_method("set_selected"):
			var on_shop : bool = (_selected_source == Source.SHOP) and s.current_item and s.current_item.id == _selected_item_id
			s.set_selected(on_shop)
	# PLAYER side
	for s in player_item_grid.get_children():
		if s.has_method("set_selected"):
			var on_player : bool = (_selected_source == Source.PLAYER) and s.current_item and s.current_item.id == _selected_item_id
			s.set_selected(on_player)

func _validate_info_panel_target() -> void:
	if _selected_source == Source.NONE or _selected_item_id == "":
		return
	var still_exists := false
	var grid := npc_item_grid if _selected_source == Source.SHOP else player_item_grid

	for s in grid.get_children():
		if s.current_item and s.current_item.id == _selected_item_id:
			still_exists = true
			break
	if not still_exists:
		_clear_selection()
		item_info_panel.clear()
		_apply_selection_highlight()

func _clear_selection() -> void:
	_selected_item_id = ""
	_selected_source = Source.NONE

# --------------------
# Buy / Sell actions
# --------------------

func _on_buy_item(slot) -> void:
	# Chuyển qua chế độ chọn SHOP cho đúng logic single-selection
	_selected_source = Source.SHOP
	
	if slot.current_item:
		_selected_item_id = slot.current_item.id
	else:
		_selected_item_id = ""
	
	_apply_selection_highlight()
	message_label.text = ""
	if slot.current_item == null:
		return

	var item: Item = slot.current_item
	var buy_price := item.price * 2
	item_info_panel.show_item(item, buy_price)

	if GameState.player.gold < buy_price:
		message_label.text = "Not enough gold!"
		push_warning(message_label.text)
		return
	if not GameState.player.inventory.can_add_item(item):
		message_label.text = "Inventory full!"
		push_warning(message_label.text)
		return

	GameState.player.gold -= buy_price
	GameState.player.inventory.add_item(item, 1)
	# ==
	current_npc.state.stats.trust += 1
	# Refresh nhưng giữ nguyên lựa chọn ở SHOP để tiếp tục mua
	_refresh()

func _on_sell_item(slot) -> void:
	_selected_source = Source.PLAYER

	if slot.current_item:
		_selected_item_id = slot.current_item.id
	else:
		_selected_item_id = ""

	_apply_selection_highlight()
	message_label.text = ""
	if slot.current_item == null:
		return

	var item: Item = slot.current_item
	item_info_panel.show_item(item, item.price)

	if not GameState.player.inventory.can_sell_item(item, 1):
		push_warning("Cannot sell item")
		return

	GameState.player.inventory.remove_item(item, 1)
	GameState.player.gold += item.price
	# Nếu sau khi bán hết stack thì panel/selection sẽ tự clear ở _refresh()
	_refresh()

func _on_close_button_pressed() -> void:
	visible = false
	_clear_selection()
	item_info_panel.clear()


func _on_buy_button_pressed() -> void:
	if _selected_source != Source.SHOP or _selected_item_id == "":
		message_label.text = "No item selected to buy!"
		return

	# tìm slot hiện tại trong shop
	var target_slot = null
	for s in npc_item_grid.get_children():
		if s.current_item and s.current_item.id == _selected_item_id:
			target_slot = s
			break
	if target_slot == null:
		message_label.text = "Item not available!"
		_clear_selection()
		item_info_panel.clear()
		_apply_selection_highlight()
		return

	_on_buy_item(target_slot)


func _on_sell_button_pressed() -> void:
	if _selected_source != Source.PLAYER or _selected_item_id == "":
		message_label.text = "No item selected to sell!"
		return

	# tìm slot hiện tại trong player inventory
	var target_slot = null
	for s in player_item_grid.get_children():
		if s.current_item and s.current_item.id == _selected_item_id:
			target_slot = s
			break
	if target_slot == null:
		message_label.text = "Item not available!"
		_clear_selection()
		item_info_panel.clear()
		_apply_selection_highlight()
		return

	_on_sell_item(target_slot)
