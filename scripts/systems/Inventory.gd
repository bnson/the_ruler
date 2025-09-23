extends Resource
class_name Inventory

signal inventory_changed

var items: Dictionary = {}

@export var max_slots: int = 20


### ✅ Thêm item
func add_item(item: Item, amount: int = 1) -> bool:
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
func remove_item(item: Item, amount: int = 1) -> bool:
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
func can_add_item(item: Item) -> bool:
	return items.has(item.id) or items.size() < max_slots


### ✅ Kiểm tra có thể bán item không
func can_sell_item(item: Item, amount: int = 1) -> bool:
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


### ✅ Dùng cho lưu game
func to_dict() -> Dictionary:
	var data := {}
	for id in items.keys():
		data[id] = items[id]["quantity"]
	return data


func from_dict(data: Dictionary):
	items.clear()
	for id in data.keys():
		var item = ItemDatabase.get_item(id)
		if item:
			items[id] = { "item": item, "quantity": int(data[id]) }

	emit_signal("inventory_changed")
