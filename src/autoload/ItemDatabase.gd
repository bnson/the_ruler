extends Node

var items: Dictionary = {}

func _ready():
	print("Item Database ready....")
	load_items("res://src/resources/items")

func load_items(folder_path: String):
	var dir = DirAccess.open(folder_path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var item_path = folder_path + "/" + file_name
				var item: Item = load(item_path)
				if item:
					items[item.id] = item
			file_name = dir.get_next()
		dir.list_dir_end()
		print("✅ Loaded %d items" % items.size())
	else:
		print("❌ Can't open items folder: ", folder_path)
