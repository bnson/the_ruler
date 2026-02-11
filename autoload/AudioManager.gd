# AudioManager.gd
extends Node

# Dùng để phát nhạc nền
var bgm_player: AudioStreamPlayer
# Dùng để phát hiệu ứng âm thanh
var sfx_player: AudioStreamPlayer

# Danh sách âm thanh preload sẵn (có thể mở rộng)
var audio_files := {
	"bgm_waves": preload("res://assets/sounds/bgm/bgm_waves.mp3"),
	"sfx_button_focus": preload("res://assets/sounds/sfx/sfx_menu_focus.wav"),
	"sfx_button_click": preload("res://assets/sounds/sfx/sfx_menu_select.wav")
}

func _ready():
	# Tạo AudioStreamPlayer cho BGM
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "BGMPlayer"
	bgm_player.bus = "Music"  # Đảm bảo bạn có Audio Bus tên "Music"
	add_child(bgm_player)

	# Tạo AudioStreamPlayer cho SFX
	sfx_player = AudioStreamPlayer.new()
	sfx_player.name = "SFXPlayer"
	sfx_player.bus = "SFX"  # Đảm bảo bạn có Audio Bus tên "SFX"
	add_child(sfx_player)

# Phát hiệu ứng âm thanh
func play_sfx(audio, volume := 1.0):
	var stream
	
	if typeof(audio) == TYPE_STRING:
		stream = audio_files.get(audio)
	else:
		stream = audio
	
	if stream is AudioStream:
		sfx_player.stream = stream
		sfx_player.volume_db = linear_to_db(clamp(volume, 0.0, 1.0))
		sfx_player.play()
	else:
		push_warning("SFX không hợp lệ hoặc không tìm thấy: " + str(audio))

# Phát nhạc nền (tự động dừng nhạc cũ nếu đang phát)
func play_bgm(audio_name: String):
	if audio_files.has(audio_name):
		if bgm_player.playing:
			bgm_player.stop()
		bgm_player.stream = audio_files[audio_name]
		bgm_player.play()
	else:
		push_warning("BGM not found: " + audio_name)

# Dừng nhạc nền
func stop_bgm():
	if bgm_player.playing:
		bgm_player.stop()

func mute():
	var master := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master, true)
	
func unmute():
	var master := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master, false)
