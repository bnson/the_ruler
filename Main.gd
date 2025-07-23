extends Node

@onready var current_scene: Node = $CurrentScene

# Danh sách autoload cần kiểm tra
const REQUIRED_AUTOLOADS := [
	"AudioManager"
]

func _ready() -> void:
	_check_autoloads()
	# Load scene đầu tiên (ví dụ: MainMenu)
	_load_initial_scene("res://scenes/ui/MainMenu.tscn")
	# Ẩn UI toàn cục
	PlayerUi.visible = false  
	

func _check_autoloads() -> void:
	for autoload_name in REQUIRED_AUTOLOADS:
		if typeof(get_node_or_null("/root/" + autoload_name)) == TYPE_NIL:
			push_error("❌ Autoload '%s' is missing! Check Project Settings → Autoload." % name)
		else:
			print("✅ Autoload '%s' is available." % autoload_name)

func _load_initial_scene(path: String) -> void:
	var scene = load(path).instantiate()
	current_scene.add_child(scene)
