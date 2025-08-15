# NPC.gd
extends CharacterBody2D
class_name NPC

signal player_entered()
signal player_exited()

@export var display_name: String = "Unnamed NPC"
@export var dialogue_resource: DialogueResource
@export var start_node_id: String = "start"
@export var sell_items: Array[Item] = []
@export var accept_gift_item_ids: Array[String] = []

var cur_love: int = 0
var max_love: int = 100
var cur_trust: int = 0
var max_trust: int = 100
var cur_lust: int = 0
var max_lust: int = 100
var cur_hp : float = 100
var max_hp : float = 100
var cur_mp : float = 0
var max_mp : float = 0
var cur_sta : float = 100
var max_sta : float = 100


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
		
	if not is_connected("player_exited", Callable(self, "_on_player_exited")):
		connect("player_exited", Callable(self, "_on_player_exited"))
		
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
		print("🚪 Player exited detection area")
		emit_signal("player_exited")

func _on_player_entered():
	print("💬 _on_player_entered từ NPC:", display_name)
	print("📦 dialogue_resource = ", dialogue_resource)
	if dialogue_resource:
		print("📜 Bắt đầu hội thoại cho %s (node: %s)" % [display_name, start_node_id])
		DialogueManager.start(dialogue_resource, self, start_node_id)
	else:
		push_warning("⚠ NPC '%s' chưa gán dialogue_resource." % display_name)

func _on_player_exited():
	print("👋 Player rời khỏi vùng của NPC:", display_name)
	if DialogueManager.active and DialogueManager.npc_node == self:
		print("🔕 Kết thúc hội thoại vì player đã rời vùng")
		DialogueManager.end()


func _on_option_selected(option: Dictionary):
	if DialogueManager.npc_node != self:
		return

	var event: String = option.get("event", "")
	match event:
		"buy_sell":
			print("🛍️ Mở Shop từ NPC:", display_name)
			PlayerUi.show_shop(self)
			DialogueManager.end()
		"talk":
			pass
		"bye":
			DialogueManager.end()
