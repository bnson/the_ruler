class_name PlayerSpawn
extends Marker2D


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	visible = false
	PlayerManager.set_player_position(global_position)
