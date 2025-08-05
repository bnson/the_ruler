extends Control
class_name DialogueUi

signal dialogue_advance
signal dialogue_option_chosen(option_data: Dictionary)

@export var option_button_scene: PackedScene

@onready var speaker_label = $Panel/VBoxContainer/SpeakerLabel
@onready var text_label = $Panel/VBoxContainer/TextLabel
@onready var options_container = $Panel/VBoxContainer/OptionsContainer

func _ready():
	hide()
	DialogueManager.connect("dialogue_started", _on_dialogue_started)
	DialogueManager.connect("dialogue_ended", _on_dialogue_ended)
	DialogueManager.connect("dialogue_option_selected", _on_dialogue_option_selected)

func _on_dialogue_started(speaker: String, text: String, options: Array):
	show()
	speaker_label.text = speaker
	text_label.text = text
	#options_container.queue_free_children()
	queue_free_children(options_container)

	if options.is_empty():
		options_container.visible = false
		await get_tree().process_frame
		await _wait_for_click()
		emit_signal("dialogue_advance")
	else:
		show_options(options)

func show_options(options: Array) -> void:
	options_container.visible = true
	#options_container.queue_free_children()
	queue_free_children(options_container)

	for opt in options:
		#var btn := Button.new()
		
		var btn := option_button_scene.instantiate()
		btn.text = opt.get("text", "...")
		btn.pressed.connect(func(): _on_option_pressed(opt))
		options_container.add_child(btn)

func _on_option_pressed(opt: Dictionary) -> void:
	emit_signal("dialogue_option_chosen", opt)

func _on_dialogue_option_selected(_opt): 
	#options_container.queue_free_children()
	queue_free_children(options_container)
	options_container.visible = false

func _on_dialogue_ended() -> void:
	hide()

func _wait_for_click() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return

func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		child.queue_free()
