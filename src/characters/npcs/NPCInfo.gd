# NPCInfo.gd
extends Control
class_name NPCInfo

@export var npc_state: NPCState

@onready var name_label := $VBoxContainer/NameLabel
@onready var love_label := $VBoxContainer/LoveLabel
@onready var trust_label := $VBoxContainer/TrustLabel
@onready var favorite_list := $VBoxContainer/FavoriteGiftList
@onready var given_list := $VBoxContainer/GivenGiftList

func _ready():
	if npc_state == null:
		push_error("⚠ NPCInfo: npc_state chưa được gán.")
		return

	if npc_state.stats and not npc_state.stats.stats_changed.is_connected(_update_info):
		npc_state.stats.stats_changed.connect(_update_info)

	_update_info()

	favorite_list.clear()
	for gift in npc_state.favorite_gifts:
		favorite_list.add_item(gift)

	given_list.clear()
	for gift in npc_state.given_gifts:
		given_list.add_item(gift)

func _update_info() -> void:
	name_label.text = "Tên: " + npc_state.stats.name
	love_label.text = "Tình cảm: " + str(npc_state.stats.love)
	trust_label.text = "Tin tưởng: " + str(npc_state.stats.trust)
