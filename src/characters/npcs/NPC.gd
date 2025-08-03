# NPC.gd
extends CharacterBody2D
class_name NPC

@export var display_name: String = "Unnamed NPC"
@export var dialogue_resource: DialogueResource
@export var start_node_id: String = "start"
@export var sell_items: Array[Item] = []
@export var accept_gift_item_ids: Array[String] = []

var love: int = 0
var trust: int = 0

signal player_entered()
signal player_exited()

func _ready():
	print("🟢 NPC Ready:", display_name)

	if not $CollisionShape2D or $CollisionShape2D.shape == null:
		push_warning("⚠ NPC '%s' thiếu hoặc không có shape trong CollisionShape2D." % display_name)

	if not $DetectionArea or not $DetectionArea.get_node("CollisionShape2D"):
		push_warning("⚠ NPC '%s' thiếu hoặc không có Area2D để phát hiện Player." % display_name)

	# ✅ Kết nối đúng vào Area2D con
	$DetectionArea.connect("body_entered", Callable(self, "_on_body_entered"))
	$DetectionArea.connect("body_exited", Callable(self, "_on_body_exited"))

	# Kết nối signal nội bộ
	if not is_connected("player_entered", Callable(self, "_on_player_entered")):
		connect("player_entered", Callable(self, "_on_player_entered"))

	# Nhận tín hiệu lựa chọn từ DialogueManager
	if DialogueManager and not DialogueManager.is_connected("dialogue_option_selected", Callable(self, "_on_option_selected")):
		DialogueManager.connect("dialogue_option_selected", Callable(self, "_on_option_selected"))

func _on_body_entered(body: Node) -> void:
	print("🚶 NPC _on_body_entered:", body.name)
	if body.is_in_group("Player"):
		print("🎯 NPC phát player_entered")
		emit_signal("player_entered")

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		emit_signal("player_exited")

func _on_player_entered():
	print("💬 _on_player_entered từ NPC:", display_name)
	print("📦 dialogue_resource = ", dialogue_resource)
	if dialogue_resource:
		print("📜 Bắt đầu hội thoại cho %s (node: %s)" % [display_name, start_node_id])
		DialogueManager.start(dialogue_resource, self, start_node_id)
	else:
		push_warning("⚠ NPC '%s' chưa gán dialogue_resource." % display_name)

func _on_option_selected(option: Dictionary):
	if DialogueManager.npc_node != self:
		return

	var event: String = option.get("event", "")
	match event:
		"buy":
			if sell_items.size() > 0:
				var item := sell_items[0]
				GameState.player.inventory.add_item(item)
				love += 1
				trust += 1
		"gift":
			if accept_gift_item_ids.size() > 0:
				var gift_id := accept_gift_item_ids[0]
				if GameState.player.inventory.get_quantity(gift_id) > 0:
					GameState.player.inventory.remove_item(gift_id)
					love += 5
					trust += 3
		"chat":
			love += 1
			trust += 1
		"bye":
			DialogueManager.end()
