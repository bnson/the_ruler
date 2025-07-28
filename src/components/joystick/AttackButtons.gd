extends Control

func _ready():
	$Attack.pressed.connect(func(): simulate_action("attack"))
	$Skill1.pressed.connect(func(): simulate_action("skill1"))
	$Skill2.pressed.connect(func(): simulate_action("skill2"))
	$Dash.pressed.connect(func(): simulate_action("dash"))
	$Block.pressed.connect(func(): simulate_action("block"))

func simulate_action(action_name: String, duration := 0.1):
	Input.action_press(action_name)
	await get_tree().create_timer(duration).timeout
	Input.action_release(action_name)
