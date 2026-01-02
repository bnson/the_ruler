class_name UiLayer
extends CanvasLayer

#========================================================
@onready var joystick_panel: JoystickPanel = $BottomLeftUi/JoystickPanel
@onready var action_panel: ActionPanel = $BottomRightUi/ActionPanel
@onready var hud_panel: HudPanel = $TopLeftUi/HudPanel
@onready var inventory_panel: InventoryPanel = $CenterUi/InventoryPanel

#========================================================
func _ready():
	pass

#========================================================
func _input(event):
	if event.is_action_pressed("inventory_panel"):
		toggle_inventory()

func toggle_inventory():
	if inventory_panel.visible:
		inventory_panel.visible = false
	else:
		inventory_panel.visible = true
