# AmiceGrover.gd
extends NPC

func _ready():
	display_name = "Amice Grover"
	dialogue_data = preload("res://dialogues/amice_dialogue_data.gd")
	sell_items = [ItemDatabase.items["apple"], ItemDatabase.items["potion"]]
	accept_gift_item_ids = ["apple"]
