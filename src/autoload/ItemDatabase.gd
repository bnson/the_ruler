extends Node

var items: Dictionary = {}
var is_item_data_ready: bool = false

func _ready():
	print("📦 Item Database initializing...")
	load_items()
	is_item_data_ready = true


### ✅ Load tất cả item từ thư mục
func load_items():
	items.clear()

	var dir := DirAccess.open("res://src/resources/items")
	if dir:
		dir.list_dir_begin()
		var file_name := dir.get_next()
		while file_name != "":
			if not dir.current_is_dir() and file_name.ends_with(".tres"):
				var full_path := "res://src/resources/items/" + file_name
				var item := load(full_path)
				if item and item is Item:
					items[item.id] = item
					print("🔹 Loaded item:", item.id)
			file_name = dir.get_next()
	else:
		push_error("❌ Không thể mở thư mục items.")

	print("✅ Loaded %d items." % items.size())


### ✅ Kiểm tra đã load xong
func is_ready() -> bool:
	return is_item_data_ready and items.size() > 0


### ✅ Lấy item theo ID an toàn
func get_item(id: String) -> Item:
	if items.has(id):
		return items[id]
	push_warning("⚠ Item không tồn tại: " + id)
	return null
