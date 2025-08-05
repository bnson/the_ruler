extends Control

@export var slot_scene: PackedScene

@onready var general_grid: GridContainer = $Panel/TabContainer/General/MarginContainer/HBoxContainer/GridContainer
@onready var special_grid: GridContainer = $Panel/TabContainer/Special/MarginContainer/HBoxContainer/GridContainer
@onready var description_general_label: RichTextLabel = $Panel/TabContainer/General/MarginContainer/HBoxContainer/Panel/MarginContainer/DescriptionLabel
@onready var description_special_label: RichTextLabel = $Panel/TabContainer/Special/MarginContainer/HBoxContainer/Panel/MarginContainer/DescriptionLabel

func _ready():
	GameState.connect("inventory_changed", Callable(self, "_refresh"))
	_refresh()

func _refresh():
	# Xoá slot cũ ở cả hai vùng
	for child in general_grid.get_children():
		child.queue_free()
	for child in special_grid.get_children():
		child.queue_free()

	var inventory = GameState.player.inventory
	var count_general := 0
	var count_special := 0

	for id in inventory.items.keys():
		var data = inventory.items[id]
		var slot = slot_scene.instantiate()
		#slot.get_node("TextureButton/Icon").texture = data["item"].atlas_texture
		#slot.get_node("TextureButton/Quantity").text = str(data["quantity"])
		
		# Giả sử item có thuộc tính is_unique
		if data["item"].is_unique:
			special_grid.add_child(slot)
			count_special += 1
			#slot.set_item(data["item"], data["quantity"])
			#slot.connect("slot_clicked", Callable(self, "show_item_description"))
		else:
			general_grid.add_child(slot)
			count_general += 1
			#slot.set_item(data["item"], data["quantity"])
			#slot.connect("slot_clicked", Callable(self, "show_item_description"))
			
		slot.set_item(data["item"], data["quantity"])
		slot.connect("slot_clicked", Callable(self, "_on_slot_clicked"))
		

	# Thêm slot trống cho đủ max_slots của common gird
	for i in range(inventory.max_slots - count_general):
		var slot = slot_scene.instantiate()
		#slot.get_node("TextureButton/Icon").texture = null
		#slot.get_node("TextureButton/Quantity").text = ""
		general_grid.add_child(slot)
		slot.set_item(null, 0)

	# Thêm slot trống cho đủ max_slots của special gird
	for i in range(inventory.max_slots - count_special):
		var slot = slot_scene.instantiate()
		#slot.get_node("TextureButton/Icon").texture = null
		#slot.get_node("TextureButton/Quantity").text = ""
		special_grid.add_child(slot)
		slot.set_item(null, 0)


func _on_slot_clicked(clicked_slot):
	description_general_label.text = ""
	description_special_label.text = ""
	
	# Bỏ highlight tất cả slot trong general_grid
	for slot in general_grid.get_children():
		if slot.has_method("set_selected"):
			slot.set_selected(slot == clicked_slot)

	# Bỏ highlight tất cả slot trong special_grid
	for slot in special_grid.get_children():
		if slot.has_method("set_selected"):
			slot.set_selected(slot == clicked_slot)

	# Hiển thị mô tả
	var item = clicked_slot.current_item
	show_item_description(item)


func show_item_description(item: Item):
	if item:
		if item.is_unique:
			description_special_label.text = item.description
		else:
			description_general_label.text = item.description
	else:
		description_general_label.text = ""
		description_special_label.text = ""

func _on_button_pressed() -> void:
	visible = false
