extends NPC
class_name AmiceGrover

@onready var node_name := get_name()

func _ready():
	super()
	display_name = "Amice Grover"
	sell_items = [ItemDatabase.items["apple"], ItemDatabase.items["potion"]]
	accept_gift_item_ids = ["apple"]
