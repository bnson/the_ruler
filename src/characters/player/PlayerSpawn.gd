### 📄 PlayerSpawn.gd
extends Marker2D

func _ready():
	if Engine.is_editor_hint(): return
	$Sprite2D.visible = false

	Global.attach_player_to(get_parent(), global_position)
