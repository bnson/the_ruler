extends NPC
class_name AmiceGrover

@onready var node_name := get_name()

func _ready():
	super()
	display_name = "Amice Grover"

	# ✅ Chỉ gán nếu ItemDatabase đã sẵn sàng
	if ItemDatabase.is_ready():
		sell_items = [
			ItemDatabase.get_item("apple")
		]
	else:
		push_warning("⚠ ItemDatabase chưa sẵn sàng khi AmiceGrover khởi tạo.")
