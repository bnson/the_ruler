class_name ItemInfoPanel
extends Control

@onready var item_icon: TextureRect = $MainPanel/Margin/VBox/HBox/ItemIcon
@onready var item_name: Label = $MainPanel/Margin/VBox/HBox/VBox/ItemName
@onready var item_price: Label = $MainPanel/Margin/VBox/HBox/VBox/HBox/ItemPrice
@onready var item_description: RichTextLabel = $MainPanel/Margin/VBox/ItemDescription
@onready var gold_icon: TextureRect = $MainPanel/Margin/VBox/HBox/VBox/HBox/GoldIcon

func _ready() -> void:
	clear()

func show_item(item: ItemData, price_override: int = -1) -> void:
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
