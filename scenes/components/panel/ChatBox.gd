class_name ChatBox
extends Control

#===========================================================
@export var button_flat_yellow_scene: PackedScene

#===========================================================
@onready var npc_name_label: Label = $Main/Margin/VBox/HBoxTop/Panel/Margin/HBox/NpcNameLabel
@onready var npc_level_label: Label = $Main/Margin/VBox/HBoxTop/Panel/Margin/HBox/NpcLevelLabel
@onready var title_label: Label = $Main/Margin/VBox/HBoxCenter/PanelRight/VBox/PanelTop/Margin/VBox/TitleLabel
@onready var chat_box: RichTextLabel = $Main/Margin/VBox/HBoxCenter/PanelRight/VBox/PanelTop/Margin/VBox/ChatBox
@onready var player_title_label: Label = $Main/Margin/VBox/HBoxBottom/PanelBottom/Margin/VBox/PlayerTitleLabel
@onready var player_choices_container: GridContainer = $Main/Margin/VBox/HBoxBottom/PanelBottom/Margin/VBox/PlayerChoicesContainer
@onready var mood_label: Label = $Main/Margin/VBox/HBoxCenter/PanelLeft/Margin/VBox/MoodLabel
@onready var trust_label: Label = $Main/Margin/VBox/HBoxTop/HBox/PanelLeft/Margin/HBox/TrustLabel
@onready var love_label: Label = $Main/Margin/VBox/HBoxTop/HBox/PanelLeft/Margin/HBox/LoveLabel
@onready var lust_label: Label = $Main/Margin/VBox/HBoxTop/HBox/PanelLeft/Margin/HBox/LustLabel

#===========================================================
var npc_interaction: Npc

#===========================================================
func handle_interaction(npc: Npc) -> void:
	npc_interaction = npc
	npc_name_label.text = npc_interaction.first_name
	npc_level_label.text = "Level: " + str(npc_interaction.level)
	player_title_label.text = PlayerManager.player.first_name + " choices"
	
	mood_label.text = npc_interaction.current_mood
	
	render_root_menu()
	update_stat_labels()
	
	show()

func update_stat_labels() -> void:
	trust_label.text = "%0.3f" % (npc_interaction.stats.trust)
	love_label.text = "%0.3f" % (npc_interaction.stats.love)
	lust_label.text = "%0.3f" % (npc_interaction.stats.lust)

func render_root_menu() -> void:
	clear_player_choices_container()
	var items := npc_interaction.get_root_menu_items()
	for item in items:
		var btn = button_flat_yellow_scene.instantiate()
		btn.text = String(item.get("label", item.get("id", "")))
		
		var cat_id := String(item.get("id", ""))
		btn.pressed.connect(func():
			on_root_category_selected(cat_id)
			pass
		)
		player_choices_container.add_child(btn)

func on_root_category_selected(category_id: String) -> void:
	match category_id:
		"ask":
			render_ask_choices()
			pass
		"stay_silent":
			on_stay_silent_selected()
			pass
		_:
			pass


func on_stay_silent_selected() -> void:
	#clear_player_choices_container()
	chat_box.text = ""
	chat_box.text = "[b]You:[/b] (You stay silently.)\n"
	
	var result := npc_interaction.evaluate_stay_silent()
	var who := npc_interaction.first_name
	
	chat_box.append_text(
		"[b][color=darkblue]%s:[/color][/b] %s"
		% [who, result.get("npc_response", "")]
	)
	
	update_stat_labels()

func render_ask_choices() -> void:
	clear_player_choices_container()

	var ask_options := npc_interaction.get_ask_choices_mixed()
	for opt in ask_options:
		var btn: Button = button_flat_yellow_scene.instantiate()
		btn.add_theme_font_size_override("font_size", 12)
		btn.text = opt.get("text", "???")
		var choice_id := String(opt.get("id"))
		btn.pressed.connect(func():
			on_ask_choice_selected(choice_id, btn.text)
		)
		player_choices_container.add_child(btn)

func on_ask_choice_selected(choice_id: String, text_chosen: String) -> void:
	# Hiện câu của player trước
	chat_box.text = ""
	chat_box.text = "[b]You:[/b] " + text_chosen + "\n"
	var result := npc_interaction.evaluate_ask_choice(choice_id)
	var who := npc_interaction.first_name
	chat_box.append_text("[b][color=darkblue]" + who + ":[/color][/b] " + String(result.get("npc_response", "")))
	update_stat_labels()

func _on_close_button_pressed() -> void:
	hide()

func clear_player_choices_container() -> void:
	for c in player_choices_container.get_children():
		c.queue_free()
