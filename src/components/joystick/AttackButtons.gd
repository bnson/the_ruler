extends Control
class_name AttackButtons

signal attack_triggered

@onready var attack_button := $AttackButton
@onready var cooldown_timer := $CooldownTimer

var can_attack := true

func _ready() -> void:
	print("Attack buttons ready...")
	attack_button.pressed.connect(_on_attack_button_pressed)
	attack_button.gui_input.connect(_on_attack_gui_input)
	cooldown_timer.timeout.connect(_on_cooldown_finished)

func _on_attack_button_pressed() -> void:
	if can_attack:
		can_attack = false
		print("Attack triggered!")
		emit_signal("attack_triggered")
		cooldown_timer.start()

func _on_attack_gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch and event.pressed:
		if event.index != 0:  # tránh xung đột với Joystick
			print("AttackButton received touch at index: ", event.index)
			_on_attack_button_pressed()

func _on_cooldown_finished() -> void:
	can_attack = true
