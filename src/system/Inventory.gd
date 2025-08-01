extends Resource
class_name Inventory

signal inventory_changed

# Item id → {item: Item, quantity: int}
var items: Dictionary = {}

# Giới hạn slot inventory (nếu cần Grid)
@export var max_slots := 20

func add_item(item: Item, amount := 1):
	if items.has(item.id):
		items[item.id]["quantity"] += amount
	else:
		# Kiểm tra slot còn chỗ không
		if items.size() >= max_slots:
			push_warning("Inventory full!")
			return
		items[item.id] = {"item": item, "quantity": amount}
	emit_signal("inventory_changed")

func remove_item(item_id: String, amount := 1):
	if not items.has(item_id):
		return
	items[item_id]["quantity"] -= amount
	if items[item_id]["quantity"] <= 0:
		items.erase(item_id)
	emit_signal("inventory_changed")

func get_quantity(item_id: String) -> int:
	return items[item_id]["quantity"] if items.has(item_id) else 0

func to_dict() -> Dictionary:
	var data := {}
	for id in items.keys():
		data[id] = items[id]["quantity"]
	return data

func from_dict(data: Dictionary):
	items.clear()
	for id in data.keys():
		var item = ItemDatabase.items.get(id)
		if item:
			items[id] = {"item": item, "quantity": data[id]}
	emit_signal("inventory_changed")
