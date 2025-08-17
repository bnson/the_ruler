### 📄 PlayerUi.gd
extends CanvasLayer

@onready var player_info_ui: Control = $MarginContainer2/PlayerInfoUi
@onready var inventory_ui: Control = $CenterContainer3/InventoryUI
@onready var dialogue_ui: DialogueUi = $CenterContainer4/DialogueUi
@onready var shop_ui: Control = $MarginContainer3/ShopUi

@onready var joystick : Joystick = $CenterContainer1/Joystick
@onready var attack_buttons : AttackButtons = $CenterContainer2/AttackButtons

var inventory_visible := false
var player_info_visible := false


func _ready():
	# Kết nối dialogue signal
	dialogue_ui.connect("dialogue_advance", Callable(DialogueManager, "show_next"))
	dialogue_ui.connect("dialogue_option_chosen", Callable(DialogueManager, "select_option"))	

func _process(_delta: float) -> void:
	pass

func _input(event):
	if event.is_action_pressed("ui_inventory"):
		toggle_inventory()
	elif event.is_action_pressed("ui_player_info"):
		toggle_player_info()

func toggle_inventory():
	inventory_visible = !inventory_visible
	inventory_ui.visible = inventory_visible
	
func toggle_player_info():
	player_info_visible = !player_info_visible
	player_info_ui.visible = player_info_visible
	
func show_shop(npc: NPC):
	shop_ui.open_shop(npc)
