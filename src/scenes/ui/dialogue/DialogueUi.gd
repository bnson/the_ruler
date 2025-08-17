extends Control
class_name DialogueUi

signal dialogue_advance
signal dialogue_option_chosen(option_data: Dictionary)

@export var option_button_scene: PackedScene

@onready var speaker_label = $Panel/VBoxContainer/SpeakerLabel
@onready var text_label = $Panel/VBoxContainer/TextLabel
@onready var options_container = $Panel/VBoxContainer/OptionsContainer

var is_dialogue_active: bool = false
var base_panel_size: Vector2
var base_options_container_size: Vector2

func _ready():
	hide()
	
	base_panel_size = $Panel.custom_minimum_size
	base_options_container_size = options_container.custom_minimum_size
	
	DialogueManager.connect("dialogue_started", _on_dialogue_started)
	DialogueManager.connect("dialogue_ended", _on_dialogue_ended)
	DialogueManager.connect("dialogue_option_selected", _on_dialogue_option_selected)

func _on_dialogue_started(speaker: String, text: String, options: Array):
	if is_dialogue_active:
		print("Dialogue already active. Ignoring new dialogue.")
		return
	
	is_dialogue_active = true
	show()
	speaker_label.text = speaker

	if text:
		text_label.text = text
	else:
		text_label.visible = false

	if options.is_empty():
		options_container.visible = false
		queue_free_children(options_container)
		await get_tree().process_frame
		await _wait_for_click()
		emit_signal("dialogue_advance")
	else:
		show_options(options)

func show_options(options: Array) -> void:
	var option_count = options.size()
	queue_free_children(options_container)
	options_container.visible = true
	#options_container.columns = 2 if option_count > 3 else 1
	options_container.columns = 1
	
	for opt in options:
		var btn := option_button_scene.instantiate()
		btn.text = opt.get("text", "...")
		btn.pressed.connect(func(): _on_option_pressed(opt))
		options_container.add_child(btn)
	
	# Cập nhật kích thước Panel theo VBoxContainer
	var speaker_label_size = Vector2(0, speaker_label.get_combined_minimum_size().y)
	var text_label_size = Vector2(0, text_label.get_combined_minimum_size().y)
	var options_container_size = options_container.get_combined_minimum_size()
	var padding_size = Vector2(10, 20)
	$Panel.custom_minimum_size = speaker_label_size + text_label_size + options_container_size + padding_size


func _on_option_pressed(opt: Dictionary) -> void:
	options_container.visible = false # Ngăn bấm tiếp
	emit_signal("dialogue_option_chosen", opt)

func _on_dialogue_option_selected(_npc, _opt):
	queue_free_children(options_container)
	options_container.visible = false	

func _on_dialogue_ended() -> void:
	is_dialogue_active = false
	hide()

func _wait_for_click() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return

func queue_free_children(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()
	await get_tree().process_frame
