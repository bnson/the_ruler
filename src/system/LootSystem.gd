extends Node
class_name LootSystem

@export var loot_table: Array[Dictionary] = []

func drop_loot() -> Array[Item]:
	var dropped_items: Array[Item] = []
	for entry in loot_table:
		var item_id = entry.get("id", "")
		var chance = entry.get("chance", 0.0)
		if randf() < chance:
                        var item = ItemDatabase.get_item(item_id)
                        if item:
                                dropped_items.append(item)
	return dropped_items
