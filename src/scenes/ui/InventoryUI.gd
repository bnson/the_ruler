extends Control
class_name InventoryUI

@onready var grid_container: GridContainer = $GridContainer

func update_inventory(item_list: Array[Item]):
	grid_container.clear()
	for item in item_list:
		var icon = TextureRect.new()
		icon.texture = item.atlas_texture
		icon.tooltip_text = "%s\n%s" % [item.name, item.description]
		icon.custom_minimum_size = Vector2(48, 48)
		grid_container.add_child(icon)
