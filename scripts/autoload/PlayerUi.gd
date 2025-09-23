### 📄 PlayerUi.gd
extends CanvasLayer

@onready var dialogue_ui: DialogueUi = $CenterContainer/DialogueUi
@onready var player_info_ui: Control = $CenterContainer/PlayerInfoUi
@onready var npc_info_ui: NPCInfo = $CenterContainer/NPCInfo
@onready var inventory_ui: Control = $CenterContainer/InventoryUI
@onready var shop_ui: Control = $CenterContainer/ShopUi
@onready var npc_chat_ui: NPCChatUi = $CenterContainer/NPCChatUi
@onready var joystick : Joystick = $BottomLeftContainer/Joystick
@onready var attack_buttons : AttackButtons = $BottomRightContainer/AttackButtons

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
	#inventory_visible = !inventory_visible
	#inventory_ui.visible = inventory_visible	
	if inventory_ui.visible:
		inventory_ui.visible = false
	else:
		inventory_ui.visible = true

func toggle_player_info():
	#player_info_visible = !player_info_visible
	#player_info_ui.visible = player_info_visible
	if player_info_ui.visible:
		player_info_ui.visible = false
	else:
		player_info_ui.visible = true
	
func show_shop(npc: NPC):
	shop_ui.open_shop(npc)

func show_npc_info(npc: NPC):
	if npc == null:
		return
	npc_info_ui.open(npc)

func show_npc_chat(npc: NPC) -> void:
	if npc == null:
		return
	npc_chat_ui.open(npc)
	
