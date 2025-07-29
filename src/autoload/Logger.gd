extends Node

# ✅ Bật/tắt toàn bộ debug
var DEBUG := false

# ✅ Bật/tắt ghi log ra file
var WRITE_TO_FILE := false

# ✅ Đường dẫn file log
const LOG_PATH := "user://debug_log.txt"

# ✅ Bật/tắt theo nhóm
var DEBUG_GROUPS := {
	"Enemy": false,
	"Player": true,
	"Combat": false,
	"UI": true,
	"Item": false,
	"Skill": false
}

func debug_log(source: String, message: String, group: String = "") -> void:
	if not DEBUG or (group != "" and not DEBUG_GROUPS.get(group, false)):
		return

	var prefix := "[Debug]"
	if group != "":
		prefix += "[%s]" % group
	prefix += "[%s]" % source
	var full_message := "%s %s" % [prefix, message]

	print(full_message)
	if WRITE_TO_FILE:
		_write_to_file(full_message)

func debug_warn(source: String, message: String, group: String = "") -> void:
	if not DEBUG or (group != "" and not DEBUG_GROUPS.get(group, false)):
		return

	var prefix := "[Warning]"
	if group != "":
		prefix += "[%s]" % group
	prefix += "[%s]" % source
	var full_message := "%s %s" % [prefix, message]

	push_warning(full_message)
	if WRITE_TO_FILE:
		_write_to_file(full_message)

func debug_error(source: String, message: String, group: String = "") -> void:
	if not DEBUG or (group != "" and not DEBUG_GROUPS.get(group, false)):
		return

	var prefix := "[Error]"
	if group != "":
		prefix += "[%s]" % group
	prefix += "[%s]" % source
	var full_message := "%s %s" % [prefix, message]

	push_error(full_message)
	if WRITE_TO_FILE:
		_write_to_file(full_message)

func _write_to_file(text: String) -> void:
	var file := FileAccess.open(LOG_PATH, FileAccess.WRITE_READ)
	if file:
		file.seek_end()
		file.store_line(text)
		file.close()

func connect_signal_once(emitter: Object, signal_name: String, target: Callable, node_name: String = "", category: String = "") -> void:
	if not emitter.is_connected(signal_name, target):
		emitter.connect(signal_name, target)
		if node_name != "":
			debug_log(node_name, "Connected signal '%s'." % signal_name, category)
