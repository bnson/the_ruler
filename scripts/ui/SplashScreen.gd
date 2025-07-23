extends Control

signal splash_finished

@onready var animation_player: AnimationPlayer = $Logo/AnimationPlayer

func _ready() -> void:
	animation_player.animation_finished.connect(_on_animation_finished)
	animation_player.play("show_logo")

func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "show_logo":
		splash_finished.emit()
