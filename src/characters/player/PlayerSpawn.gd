extends Node

func _ready():
	if not Engine.is_editor_hint():
		$Sprite2D.visible = false
