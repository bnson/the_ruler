extends Node
class_name ItemDatabase

var items: Dictionary = {}

func _ready():
	load_items()

func load_items():
	var file_path = "res://data/item_database.json"
	if not FileAccess.file_exists(file_path):
		print("❌ Item database file not found:", file_path)
		return

	var file = FileAccess.open(file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	if typeof(data) == TYPE_DICTIONARY:
		for id in data.keys():
			var entry = data[id]
			var item = Item.new()
			item.id = id
			item.name = entry.get("name", "")
			item.description = entry.get("description", "")
			item.type = entry.get("type", "")
			item.value = entry.get("value", 0)

			var atlas = AtlasTexture.new()
			atlas.atlas = load(entry.get("atlas_path", ""))
			atlas.region = Rect2(entry.get("region_x", 0), entry.get("region_y", 0), entry.get("region_w", 32), entry.get("region_h", 32))
			item.atlas_texture = atlas

			items[id] = item
		print("✅ Loaded %d items" % items.size())
	else:
		print("❌ Failed to parse item database")
