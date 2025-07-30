extends Node

# ✅ Bật/tắt toàn bộ debug
var DEBUG := false

# ✅ Bật/tắt ghi log ra file
var WRITE_TO_FILE := false

# ✅ Đường dẫn file log
const LOG_PATH := "user://debug_log.txt"

# ✅ Bật/tắt theo nhóm
var DEBUG_GROUPS := {
	"General": true,
	"Enemy": true,
	"Player": true,
	"Combat": true,
	"UI": true,
	"Item": true,
	"Skill": true,
	"System": true,
}

func debug_log(message: String, source: String = "General", group: String = "General") -> void:
	_log("Debug", message, source, group)

func debug_warn(message: String, source: String = "General", group: String = "General") -> void:
	_log("Warning", message, source, group)

func debug_error(message: String, source: String = "General", group: String = "General") -> void:
	_log("Error", message, source, group)

func _log(level: String, message: String, source: String, group: String) -> void:
	if not DEBUG or (group != "" and not DEBUG_GROUPS.get(group, false)):
		return

	var full_message := _format_log(level, source, group, message)

	match level:
		"Debug":
			print(full_message)
		"Warning":
			push_warning(full_message)
		"Error":
			push_error(full_message)

	if WRITE_TO_FILE:
		_write_to_file(full_message)

func _format_log(level: String, source: String, group: String, message: String) -> String:
	var prefix := "[%s]" % level
	if group != "":
		prefix += "[%s]" % group
	prefix += "[%s]" % source
	return "%s %s" % [prefix, message]

func _write_to_file(text: String) -> void:
	var file := FileAccess.open(LOG_PATH, FileAccess.WRITE_READ)
	if file:
		file.seek_end()
		file.store_line(text)
		file.close()

func connect_signal_once(emitter: Object, signal_name: String, target: Callable, node_name: String = "", category: String = "General") -> void:
	if not emitter.is_connected(signal_name, target):
		emitter.connect(signal_name, target)
		if node_name != "":
			debug_log("Connected signal '%s'." % signal_name, node_name, category)
