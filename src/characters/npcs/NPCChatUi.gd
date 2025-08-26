### 📄 NPCChatUi.gd 
extends Control
class_name NPCChatUi

@export var slot_scene: PackedScene

@onready var npc_name: Label = $Panel/Margin/HBox/NpcPanel/Margin/Container/Header/NameValue
@onready var npc_level: Label = $Panel/Margin/HBox/NpcPanel/Margin/Container/Header/LevelValue
@onready var npc_portrait: TextureRect = $Panel/Margin/HBox/NpcPanel/Margin/Container/Body/Portrait

@onready var vitals_container := $Panel/Margin/HBox/NpcPanel/Margin/Container/Footer
@onready var love_progress_bar : ProgressBar = vitals_container.get_node("Love/Progress/Bar")
@onready var trust_progress_bar : ProgressBar = vitals_container.get_node("Trust/Progress/Bar")
@onready var lust_progress_bar : ProgressBar = vitals_container.get_node("Lust/Progress/Bar")
@onready var love_progress_value : Label = vitals_container.get_node("Love/Progress/Value")
@onready var trust_progress_value : Label = vitals_container.get_node("Trust/Progress/Value")
@onready var lust_progress_value : Label = vitals_container.get_node("Lust/Progress/Value")

@onready var gift_item_grid: GridContainer = $Panel/Margin/HBox/VBox/GiftPanel/VBoxContainer/Panel/MarginContainer/ScrollContainer/GridContainer
@onready var dialogue_box: RichTextLabel = $Panel/Margin/HBox/VBox/ChatPanel/Margin/VBoxContainer/DialogueBox

const GIFT_MAX_SLOTS := 10
const LOVE_PER_GIFT := 1

var current_npc: NPC


func open(npc: NPC) -> void:
	current_npc = npc
	npc_name.text = npc.display_name
	npc_level.text = str(int(npc.state.stats.level))
	_update_stats()
	if current_npc and current_npc.state and current_npc.state.stats:
		var stats : NPCStats = current_npc.state.stats
		if not stats.affection_changed.is_connected(_on_affection_changed):
			stats.affection_changed.connect(_on_affection_changed)
	if not GameState.is_connected("inventory_changed", Callable(self, "_refresh_gifts")):
		GameState.connect("inventory_changed", Callable(self, "_refresh_gifts"))
	_refresh_gifts()
	visible = true

func close() -> void:
	if GameState.is_connected("inventory_changed", Callable(self, "_refresh_gifts")):
		GameState.disconnect("inventory_changed", Callable(self, "_refresh_gifts"))
	if current_npc and current_npc.state and current_npc.state.stats:
		var stats : NPCStats = current_npc.state.stats
		if stats.affection_changed.is_connected(_on_affection_changed):
			stats.affection_changed.disconnect(_on_affection_changed)
	current_npc = null
	visible = false

func _refresh_gifts() -> void:
	for child in gift_item_grid.get_children():
		child.queue_free()

	var inventory = GameState.player.inventory
	var count := 0
	
	for data in inventory.get_all_items():
		if count >= GIFT_MAX_SLOTS:
			break
		var slot = slot_scene.instantiate()
		gift_item_grid.add_child(slot)
		slot.set_item(data["item"], data["quantity"])
		slot.connect("slot_clicked", Callable(self, "_on_gift_slot_clicked"))
		count += 1

	for i in range(GIFT_MAX_SLOTS - count):
		var slot = slot_scene.instantiate()
		gift_item_grid.add_child(slot)
		slot.set_item(null, 0)

func _on_gift_slot_clicked(slot) -> void:
	if slot.current_item == null or current_npc == null:
		return

	var item : Item = slot.current_item
	if GameState.player.inventory.remove_item(item, 1):
		current_npc.add_stat("love", LOVE_PER_GIFT)
		dialogue_box.text = "Gave %s" % item.name
		_update_stats()
		_refresh_gifts()

func _on_affection_changed(_love: float, _trust: float, _lust: float) -> void:
	_update_stats()

func _update_stats() -> void:
	if current_npc == null:
		return
	var stats : NPCStats = current_npc.state.stats
	love_progress_bar.max_value = stats.max_love
	love_progress_bar.value = stats.love
	trust_progress_bar.max_value = stats.max_trust
	trust_progress_bar.value = stats.trust
	lust_progress_bar.max_value = stats.max_lust
	lust_progress_bar.value = stats.lust
	love_progress_value.text = "%d / %d" % [stats.love, stats.max_love]
	trust_progress_value.text = "%d / %d" % [stats.trust, stats.max_trust]
	lust_progress_value.text = "%d / %d" % [stats.lust, stats.max_lust]

func _on_close_button_pressed() -> void:
	close()
