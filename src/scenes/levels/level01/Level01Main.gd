extends Node


func _ready() -> void:
	print("Level 1 ready...")
	if $PlayerSpawn:
		call_deferred("_attach_player_later")
	else:
		push_error("PlayerSpawn chưa sẵn sàng!")

	PlayerUi.visible = true
	DayNightController.visible = false

func _process(delta: float) -> void:
	pass
