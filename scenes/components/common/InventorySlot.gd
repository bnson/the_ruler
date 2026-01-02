class_name InventorySlot
extends Control

signal slot_clicked(slot)

@onready var highlight: Panel = $Highlight
@onready var icon: TextureRect = $IconButton/Icon
@onready var quantity: Label = $IconButton/Quantity

var current_item: ItemData = null

func _ready():
	assert(icon, "❌ SlotTemplate: 'icon' node không tìm thấy!")
	assert(quantity, "❌ SlotTemplate: 'quantity_label' node không tìm thấy!")
	if highlight:
		highlight.visible = false

func set_item(item: ItemData, itemQuantity: int):
	current_item = item
	set_highlight(false)

	if item:
		icon.texture = item.atlas_texture
		quantity.text = str(itemQuantity)
	else:
		icon.texture = null
		quantity.text = ""

func set_highlight(isHighlight: bool) -> void:
	if highlight:
		highlight.visible = isHighlight

func _on_icon_button_pressed() -> void:
	emit_signal("slot_clicked", self)
