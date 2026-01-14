class_name InteractionMenu
extends Control

@export var button_scene: PackedScene

@onready var title_label = $Margin/Main/Margin/Panel/Margin/VBox/TitleLabel
@onready var interactions_container = $Margin/Main/Margin/Panel/Margin/VBox/InteractionsContainer


func _ready():
	pass

func open(interactions: Array[Dictionary]):
	queue_free_children(interactions_container)
	interactions_container.visible = true
	interactions_container.columns = 1
	
	for interaction in interactions:
		var btn := button_scene.instantiate()
		btn.text = interaction.get("name", "...")
		interactions_container.add_child(btn)
	
		show()

func close():
	hide()

func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
	await get_tree().process_frame
