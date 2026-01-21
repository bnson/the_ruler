class_name ChatBox
extends Control

@onready var npc_full_name_label: Label = $Main/Margin/HBox/PanelLeft/Margin/VBox/HBox/NpcFullNameLabel
@onready var npc_level_label: Label = $Main/Margin/HBox/PanelLeft/Margin/VBox/HBox/NpcLevelLabel

@onready var npc_title_label: Label = $Main/Margin/HBox/PanelRight/VBox/PanelTop/Margin/VBox/NpcTitleLabel
@onready var npc_response: RichTextLabel = $Main/Margin/HBox/PanelRight/VBox/PanelTop/Margin/VBox/NpcResponse

@onready var player_title_label: Label = $Main/Margin/HBox/PanelRight/VBox/PanelBottom/Margin/VBox/PlayerTitleLabel
@onready var player_choices_container: GridContainer = $Main/Margin/HBox/PanelRight/VBox/PanelBottom/Margin/VBox/PlayerChoicesContainer

var npc_interaction: Npc


func handle_interaction(npc: Npc) -> void:
	npc_interaction = npc
	npc_full_name_label.text = npc_interaction.first_name + " " + npc_interaction.last_name
	npc_level_label.text = "Level: " + str(npc_interaction.level)
	npc_title_label.text = npc_interaction.first_name + " response"
	
	player_title_label.text = PlayerManager.player.first_name + " choices"
	
	show()

func _render_ask_choices() -> void:
	pass

func _on_close_button_pressed() -> void:
	hide()
