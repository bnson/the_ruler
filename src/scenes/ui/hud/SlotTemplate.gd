### 📄 SlotTemplate.gd
extends Panel

signal slot_clicked(item: Item)

@onready var selected_panel: Panel = $PanelSelected
@onready var icon: TextureRect = $TextureButton/Icon
@onready var quantity_label: Label = $TextureButton/Quantity

var current_item: Item = null

func _ready():
	assert(icon, "❌ SlotTemplate: 'icon' node không tìm thấy! Kiểm tra đường dẫn $TextureButton/Icon.")
	assert(quantity_label, "❌ SlotTemplate: 'quantity_label' node không tìm thấy.")


func set_item(item: Item, quantity: int):
	current_item = item
	set_selected(false)
	
	if icon and quantity_label:
		if item:
			print("AAAAAAAAAAAA")
			icon.texture = item.atlas_texture
			quantity_label.text = str(quantity)
		else:
			print("BBBBBBBBBBBB")
			icon.texture = null
			quantity_label.text = ""
	else:
		print("CCCCCCCCCCC")

func set_selected(selected: bool) -> void:
	if selected_panel:
		selected_panel.visible = selected

func _on_texture_button_pressed() -> void:
	emit_signal("slot_clicked", self)
