### 📄 PlayerUi.gd
extends CanvasLayer

@onready var inventory_ui: Control = $CenterContainer3/InventoryUI
@onready var dialogue_ui: DialogueUi = $CenterContainer4/DialogueUi
@onready var player_info_ui: Control = $MarginContainer2/PlayerInfoUi

var inventory_visible := false
var player_info_visible := false


func _ready():
	dialogue_ui.connect("dialogue_advance", Callable(DialogueManager, "show_next"))
	dialogue_ui.connect("dialogue_option_chosen", Callable(DialogueManager, "select_option"))	

func _process(_delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_inventory"):
		toggle_inventory()
	if event.is_action_pressed("ui_player_info"):
		toggle_player_info()

func toggle_inventory():
	inventory_visible = not inventory_visible
	inventory_ui.visible = inventory_visible
	
func toggle_player_info():
	player_info_visible = not player_info_visible
	player_info_ui.visible = player_info_visible
