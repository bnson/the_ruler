class_name SoundToggleButton extends TextureButton


@export var bus_name: StringName = "Master"

@onready var sound_toggle_button = $"."  # chính là self
var bus_index: int = -1

# Texture cho các trạng thái
var tex_off = preload("res://assets/textures/ui/buttons/Sound_Off.png")
var tex_off_hover = preload("res://assets/textures/ui/buttons/Sound_Off_Hover.png")
var tex_on = preload("res://assets/textures/ui/buttons/Sound_On.png")
var tex_on_hover = preload("res://assets/textures/ui/buttons/Sound_On_Hover.png")

func _ready():
	print("Sound toggle button ready...")
	bus_index = AudioServer.get_bus_index(bus_name)

	toggle_mode = true
	texture_normal = tex_off
	texture_hover = tex_off_hover
	texture_pressed = tex_on

	if bus_index == -1:
		push_warning("Audio bus '%s' not found. Sound toggle disabled." % bus_name)
		disabled = true
		return

	set_pressed_no_signal(not AudioServer.is_bus_mute(bus_index))
	toggled.connect(on_toggled)

func on_toggled(btn_pressed: bool) -> void:
	if bus_index == -1:
		return
	AudioServer.set_bus_mute(bus_index, not btn_pressed)
	update_texture()

func _process(_delta: float) -> void:
	update_texture()

func update_texture():
	if button_pressed:
		if get_rect().has_point(get_local_mouse_position()):
			texture_pressed = tex_on_hover
		else:
			texture_pressed = tex_on
	else:
		if get_rect().has_point(get_local_mouse_position()):
			texture_normal = tex_off_hover
		else:
			texture_normal = tex_off
