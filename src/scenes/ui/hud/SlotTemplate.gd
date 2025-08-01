extends TextureButton

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $Quantity

func set_item(item: Item, quantity: int):
	if item:
		icon.texture = item.atlas_texture
		quantity_label.text = str(quantity)
	else:
		icon.texture = null
		quantity_label.text = ""
