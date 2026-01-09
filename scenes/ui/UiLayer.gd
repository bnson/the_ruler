class_name UiLayer
extends CanvasLayer

#========================================================
@onready var joystick_panel: JoystickPanel = $BottomLeftUi/JoystickPanel
@onready var action_panel: ActionPanel = $BottomRightUi/ActionPanel
@onready var hud_panel: HudPanel = $TopLeftUi/HudPanel
@onready var inventory_panel: InventoryPanel = $CenterUi/InventoryPanel
@onready var player_profile: PlayerProfile = $CenterUi/PlayerProfile

#========================================================
func _ready():
	pass

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
