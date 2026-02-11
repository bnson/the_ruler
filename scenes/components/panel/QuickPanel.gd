extends Node

#================================================
@onready var sound_btn: TextureButton = $Main/Margin/VBox/SoundBtn

#================================================
var sound_on_texture = preload("res://assets/ui/buttons/menu/sound_on.png")
var sound_on_hover_texture = preload("res://assets/ui/buttons/menu/sound_on_hover.png")
var sound_off_texture = preload("res://assets/ui/buttons/menu/sound_off.png")
var sound_off_hover_texture = preload("res://assets/ui/buttons/menu/sound_off_hover.png")

#================================================
func _on_sound_btn_toggled(toggled_on: bool) -> void:
	if toggled_on:
		sound_btn.texture_normal = sound_on_texture
		sound_btn.texture_hover = sound_on_hover_texture
		AudioManager.unmute()
	else:
		sound_btn.texture_normal = sound_off_texture
		sound_btn.texture_hover = sound_off_hover_texture
		AudioManager.mute()
	
