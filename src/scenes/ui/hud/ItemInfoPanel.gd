extends Control
class_name ItemInfoPanel

@onready var item_icon: TextureRect =$Panel/Container/Item/Icon
@onready var item_name: Label = $Panel/Container/Item/Name
@onready var item_description: RichTextLabel = $Panel/Container/Item/Description

func show_item(item: Item) -> void:
	if not item:
		clear()
		return

	item_icon.texture = item.atlas_texture
	item_name.text = item.name
	item_description.text = item.description

func clear():
	item_icon.texture = null
	item_name.text = ""
	item_description.text = ""
