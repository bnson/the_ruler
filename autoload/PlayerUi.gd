extends CanvasLayer

@onready var health_bar: ProgressBar = $Panel/HealthBar
@onready var mana_bar: ProgressBar = $Panel/ManaBar
@onready var exp_bar: ProgressBar = $Panel/ExpBar
@onready var level_label: Label = $Panel/LevelLabel
@onready var avatar_tree: AnimationTree = $Panel/Avatar/AnimationTree


func _ready():
	_apply_style(health_bar, Color(1, 0, 0, 0.6), Color(0.2, 0.2, 0.2, 0.4), Color(0.8, 0, 0))
	_apply_style(mana_bar, Color(0, 0, 1, 0.6), Color(0.2, 0.2, 0.2, 0.4), Color(0, 0, 0.8))
	_apply_style(exp_bar, Color(1, 1, 0, 0.6), Color(0.2, 0.2, 0.2, 0.4), Color(0.8, 0.8, 0))

func _process(_delta: float) -> void:
	if PlayerData:
		# Cập nhật avatar
		_update_avatar_state()
		
		#--
		health_bar.max_value = PlayerData.max_hp
		health_bar.value = PlayerData.hp

		mana_bar.max_value = PlayerData.max_sp
		mana_bar.value = PlayerData.sp

		exp_bar.max_value = PlayerData.experience_to_next_level
		exp_bar.value = PlayerData.experience

		level_label.text = "Level: %d" % PlayerData.level

func _update_avatar_state():
	var tired_ratio = 1.0 - float(PlayerData.hp) / float(PlayerData.max_hp)
	avatar_tree.set("parameters/EmotionBlend/blend_position", tired_ratio)



func _apply_style(bar: ProgressBar, fill_color: Color, bg_color: Color, border_color: Color) -> void:
	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fill_color
	fill_style.corner_radius_top_left = 8
	fill_style.corner_radius_top_right = 8
	fill_style.corner_radius_bottom_left = 8
	fill_style.corner_radius_bottom_right = 8
	fill_style.border_width_left = 2
	fill_style.border_width_top = 2
	fill_style.border_width_right = 2
	fill_style.border_width_bottom = 2
	fill_style.border_color = border_color
	bar.add_theme_stylebox_override("fill", fill_style)

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = bg_color
	bg_style.corner_radius_top_left = 8
	bg_style.corner_radius_top_right = 8
	bg_style.corner_radius_bottom_left = 8
	bg_style.corner_radius_bottom_right = 8
	bg_style.border_width_left = 2
	bg_style.border_width_top = 2
	bg_style.border_width_right = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = border_color
	bar.add_theme_stylebox_override("background", bg_style)
