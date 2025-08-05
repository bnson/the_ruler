extends Panel

signal slot_clicked(item: Item)

@onready var selected_panel: Panel = $PanelSelected
@onready var icon: TextureRect = $TextureButton/Icon
@onready var quantity_label: Label = $TextureButton/Quantity

var current_item: Item = null

func set_item(item: Item, quantity: int):
	current_item = item
	set_selected(false)
	
	if item:
		icon.texture = item.atlas_texture
		quantity_label.text = str(quantity)
	else:
		icon.texture = null
		quantity_label.text = ""

func set_selected(selected: bool) -> void:
	selected_panel.visible = selected

func _on_texture_button_pressed() -> void:
	emit_signal("slot_clicked", self)
