# InventoryManager.gd
extends Node

signal inventory_changed

var max_slots: int = 99
var items: Dictionary = {}
var gold: int = 0
var gold_cap: int = 9999999  # Giới hạn tối đa

### ✅ Thêm item
func add_item(item: ItemData, amount: int = 1) -> bool:
	if items.has(item.id):
		items[item.id]["quantity"] += amount
	else:
		# Kiểm tra slot nếu là item mới
		if items.size() >= max_slots:
			push_warning("Inventory full! Không thể thêm: " + item.id)
			return false
		items[item.id] = { "item": item, "quantity": amount }

	emit_signal("inventory_changed")
	return true


### ✅ Xoá item bằng Item
func remove_item(item: ItemData, amount: int = 1) -> bool:
	if not items.has(item.id):
		return false

	items[item.id]["quantity"] -= amount

	if items[item.id]["quantity"] <= 0:
		items.erase(item.id)

	emit_signal("inventory_changed")
	return true

### ✅ Lấy số lượng của một item
func get_quantity(item_id: String) -> int:
	return items[item_id]["quantity"] if items.has(item_id) else 0


### ✅ Kiểm tra có thể thêm item hay không (UI hoặc Loot dùng)
func can_add_item(item: ItemData) -> bool:
	return items.has(item.id) or items.size() < max_slots


### ✅ Kiểm tra có thể bán item không
func can_sell_item(item: ItemData, amount: int = 1) -> bool:
	return get_quantity(item.id) >= amount


### ✅ Lấy toàn bộ item để hiển thị UI, shop, v.v.
func get_all_items() -> Array[Dictionary]:
	var result : Array[Dictionary] = []
	for id in items.keys():
		result.append({
			"item": items[id]["item"],
			"quantity": items[id]["quantity"]
		})
	return result


# ----------------------------
# 🟡 GOLD 
# ----------------------------
func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	var before := gold
	gold = min(gold_cap, gold + amount)
	if gold != before:
		emit_signal("inventory_changed")

func can_spend_gold(amount: int) -> bool:
	return amount >= 0 and gold >= amount

func spend_gold(amount: int) -> bool:
	if not can_spend_gold(amount):
		return false
	gold -= amount
	emit_signal("inventory_changed")
	return true

func get_gold() -> int:
	return gold

# ----------------------------
### ✅ Dùng cho lưu game
func to_dict() -> Dictionary:
	var data := {}
	
	for id in items.keys():
		data[id] = items[id]["quantity"]
	
	return {
		"gold": gold,
		"items": data
	}

func from_dict(data: Dictionary) -> void:
	items.clear()
	gold = int(data.get("gold", 0))
	
	var saved_items = data.get("items", {})
	if typeof(saved_items) == TYPE_DICTIONARY:
		for id in saved_items.keys():
			var item = ItemDatabase.get_item(id)
			if item:
				items[id] = { "item": item, "quantity": int(saved_items[id]) }
	
	emit_signal("inventory_changed")
