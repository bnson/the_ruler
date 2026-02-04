class_name Main
extends Node

#==============================================================
@onready var ui_layer = $UiLayer
@onready var fade_layer = $FadeLayer
@onready var scene_container = $SceneContainer


#==============================================================
func _ready():
	# Đăng ký các layer với UiManager
	UiManager.register_ui(ui_layer)
	# Load game
	SaveManager.new_game(scene_container, fade_layer)
	#SaveManager.load_game(scene_container, fade_layer)
	# Bật auto-save định kỳ
	SaveManager.auto_save_start()
