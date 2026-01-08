class_name GoldDisplay
extends Control

@export var show_separator: bool = true     # định dạng 1_234_567

@onready var value_label: Label = $Main/HBox/Value

func _ready():
	# Kết nối signal từ InventoryManager (Autoload)
	InventoryManager.connect("inventory_changed", Callable(self, "_on_inventory_changed"))
	_on_inventory_changed()

func _on_inventory_changed():
	value_label.text = "%s" % [format_number(InventoryManager.get_gold())]

func format_number(n: int) -> String:
	if !show_separator:
		return str(n)
	# Tạo separator theo nhóm 3 số: 1,234,567
	var s := str(abs(n))
	var out := ""
	while s.length() > 3:
		out = "," + s.substr(s.length() - 3, 3) + out
		s = s.substr(0, s.length() - 3)
	out = s + out
	if n < 0:
		out = "-" + out
	return out
