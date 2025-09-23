extends Control
class_name ItemInfoPanel

@onready var item_icon : TextureRect = $Panel/Container/VBoxContainer/Item/Icon
@onready var item_name : Label = $Panel/Container/VBoxContainer/Item/VBoxContainer/Name
@onready var item_price : Label = $Panel/Container/VBoxContainer/Item/VBoxContainer/HBoxContainer/Price
@onready var item_description : RichTextLabel = $Panel/Container/VBoxContainer/Description
@onready var gold_icon : TextureRect = $Panel/Container/VBoxContainer/Item/VBoxContainer/HBoxContainer/GoldIcon


func _ready() -> void:
	clear()

func show_item(item: Item, price_override: int = -1) -> void:
	if item:
		item_icon.texture = item.atlas_texture
		item_name.text = item.name
		item_description.text = item.description
		
		item_price.text = str(item.price)
		if price_override >= 0:
			item_price.text = str(price_override)
		
		item_description.visible = true
		gold_icon.visible = true
	else:
		clear()

func clear():
	item_icon.texture = null
	item_name.text = ""
	item_price.text = ""
	item_description.text = ""
	item_description.visible = false
	gold_icon.visible = false
