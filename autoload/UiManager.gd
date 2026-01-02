# UiManager.gd
extends Node

# ======================================================
# Autoload Singleton — Quản lý toàn bộ UI trong game
# ======================================================
# Tham chiếu đến các lớp UI chính
var ui_layer: UiLayer = null

#=======================================================
# Đăng ký UI (gọi từ Main.gd)
func register_ui(_ui_layer: UiLayer) -> void:
	ui_layer = _ui_layer
	print("[UiManager] UI layers registered successfully.")

#=======================================================
func set_player_stats(stats: PlayerStats) -> void:
	if ui_layer and ui_layer.hud_panel:
		ui_layer.hud_panel.set_player_stats(stats)

#=======================================================
# 🎮 Truy cập joystick trực tiếp
func get_joystick_vector() -> Vector2:
	return ui_layer.joystick_panel.get_direction()

#=======================================================
func btn_attack_is_pressed() -> bool:
	return ui_layer.action_panel.btn_attack.is_pressed()
	
func btn_attack_is_just_pressed() -> bool:
	if ui_layer.action_panel.btn_attack.is_pressed():
		ui_layer.action_panel.btn_attack.release_focus()
		return true
	return false
	
