extends CanvasLayer
class_name DialogueUi

signal dialogue_advance
signal dialogue_option_chosen(option_data: Dictionary)

@onready var speaker_label = %SpeakerLabel
@onready var text_label = %TextLabel
@onready var options_container = %OptionsContainer

func _ready():
	hide()
	DialogueManager.connect("dialogue_ended", _on_dialogue_ended)
	DialogueManager.connect("dialogue_option_selected", _on_dialogue_option_selected)

func show_entry(entry: Dictionary) -> void:
	show()
	speaker_label.text = entry.get("speaker", "")
	text_label.text = entry.get("text", "")
	options_container.visible = false
	options_container.queue_free_children()
	# Đợi nhấn để tiếp
	await get_tree().process_frame
	await _wait_for_click()
	emit_signal("dialogue_advance")

func show_options(options: Array) -> void:
	options_container.visible = true
	options_container.queue_free_children()
	for opt in options:
		var btn := Button.new()
		btn.text = opt.get("text", "...")
		btn.pressed.connect(func(): _on_option_pressed(opt))
		options_container.add_child(btn)

func _on_option_pressed(opt: Dictionary) -> void:
	emit_signal("dialogue_option_chosen", opt)

func _on_dialogue_ended() -> void:
	hide()

func _on_dialogue_option_selected(_opt): 
	options_container.queue_free_children()
	options_container.visible = false

func _wait_for_click() -> void:
	while true:
		await get_tree().process_frame
		if Input.is_action_just_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			return
