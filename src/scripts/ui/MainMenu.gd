extends Node2D

@onready var splash_screen: Control = $CanvasLayer/SplashScreen
@onready var menu_container: Control = $CanvasLayer/MenuContainer

@onready var button_new: Button = $CanvasLayer/MenuContainer/ButtonNew
@onready var button_continue: Button = $CanvasLayer/MenuContainer/ButtonContinue

func _ready() -> void:
	menu_container.visible = false
	splash_screen.splash_finished.connect(_on_splash_finished)

	# Tự động kết nối âm thanh cho tất cả nút trong menu
	for child in menu_container.get_children():
		if child is Button:
			_connect_button_sounds(child)
	
	button_new.pressed.connect(_on_new_game_pressed)

func _on_splash_finished() -> void:
	splash_screen.queue_free()
	menu_container.visible = true
	
	if AudioManager:
		AudioManager.play_bgm("bgm_waves")

func _on_new_game_pressed() -> void:
	AudioManager.play_sfx("sfx_button_click")
	#get_tree().change_scene_to_file("res://scenes/levels/Level_01/Level_01_Main.tscn")
	#SceneManager.change_scene("res://scenes/levels/Level_01/Level_01_Main.tscn")
	SceneManager.change_scene_with_fade("res://scenes/levels/Level_01/Level_01_Main.tscn", $FadeScene/CanvasLayer)


func _connect_button_sounds(button: Button) -> void:
	button.mouse_entered.connect(func(): AudioManager.play_sfx("sfx_button_focus"))
	button.pressed.connect(func(): AudioManager.play_sfx("sfx_button_click"))
