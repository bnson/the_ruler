class_name UiLayer
extends CanvasLayer

#========================================================
@onready var joystick_panel: JoystickPanel = $BottomLeftUi/JoystickPanel
@onready var action_panel: ActionPanel = $BottomRightUi/ActionPanel
@onready var hud_panel: HudPanel = $TopLeftUi/HudPanel
@onready var inventory_panel: InventoryPanel = $CenterUi/InventoryPanel
@onready var player_profile: PlayerProfile = $CenterUi/PlayerProfile
@onready var interaction_menu: InteractionMenu = $CenterUi/InteractionMenu
@onready var shop_ui: ShopUi = $CenterUi/ShopUi

#========================================================
func _ready():
	interaction_menu.interaction_chosen.connect(on_interaction_chosen)
	pass

#========================================================
func on_interaction_chosen(npc: Npc, interaction: Dictionary) -> void:
	# Tắt menu tương tác
	interaction_menu.hide()
	
	var action = interaction.get("action", "")
	print("Action: ", action)
	match action:
		"open_shop":
			shop_ui.handle_interaction(npc)
		"open_chat":
			pass
		_:
			print("Action không hỗ trợ:", interaction)

#========================================================
func _input(event):
	if event.is_action_pressed("inventory_panel"):
		toggle_inventory()
	if event.is_action_pressed("player_profile"):
		toggle_player_profile()

func toggle_inventory():
	if inventory_panel.visible:
		inventory_panel.visible = false
	else:
		inventory_panel.visible = true
		
func toggle_player_profile():
	if player_profile.visible:
		player_profile.visible = false
	else:
		player_profile.visible = true
