extends Node


func _ready():
	Global.attach_player_to($SceneContainer, $PlayerSpawn.global_position)
	# Hiện UI toàn cục
	PlayerUi.visible = true
	DayNightController.visible = false
