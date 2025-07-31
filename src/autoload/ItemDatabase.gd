extends Node

var items: Dictionary = {}

func _ready():
	print("📦 Item Database ready....")
	load_items()

func load_items():
	items.clear()

	# ✅ Danh sách tất cả item preload để chắc chắn export sang Android
	var all_items: Array[Item] = [
		preload("res://src/resources/items/potion.tres"),
		preload("res://src/resources/items/apple.tres"),
		preload("res://src/resources/items/key.tres"),
	]

	for item in all_items:
		if item:
			items[item.id] = item
			print("🔹 Loaded item:", item.id, "->", item.atlas_texture)

	print("✅ Loaded %d items" % items.size())
