class_name InteractionMenu
extends Control

signal interaction_chosen(npc: Npc)

@export var button_scene: PackedScene

@onready var title_label = $Margin/Main/Margin/Panel/Margin/VBox/TitleLabel
@onready var interactions_container = $Margin/Main/Margin/Panel/Margin/VBox/InteractionsContainer


func _ready():
	pass

func open(npc: Npc):
	queue_free_children(interactions_container)
	interactions_container.visible = true
	interactions_container.columns = 1
	
	for interaction in npc.interactions:
		var btn := button_scene.instantiate()
		btn.text = interaction.get("name", "...")
		btn.pressed.connect(func(): on_button_pressed(npc, interaction))
		interactions_container.add_child(btn)
	
		show()

func close():
	hide()

func on_button_pressed(npc: Npc, interaction: Dictionary):
	interactions_container.visible = false
	emit_signal("interaction_chosen", npc, interaction)

func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
	await get_tree().process_frame
