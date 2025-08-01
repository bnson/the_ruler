# AmiceGrover.gd
extends NPC

func _ready():
       display_name = "Amice Grover"
       var data_res = preload("res://dialogues/amice_dialogue_data.gd")
       dialogue_data = data_res.data
       sell_items = [ItemDatabase.items["apple"], ItemDatabase.items["potion"]]
       accept_gift_item_ids = ["apple"]

       connect("player_entered", Callable(self, "_on_player_entered"))
       DialogueManager.connect("dialogue_option_selected", Callable(self, "_on_option_selected"))

func _on_player_entered() -> void:
       DialogueManager.start(dialogue_data, self)

func _on_option_selected(option_data: Dictionary) -> void:
       if DialogueManager.npc_node != self:
               return
       var event_name := option_data.get("event", "")
       match event_name:
               "buy":
                       if sell_items.size() > 0:
                               var item := sell_items[0]
                               GameState.player.inventory.add_item(item)
                               love += 1
                               trust += 1
               "sell":
                       if sell_items.size() > 0:
                               var item_id := sell_items[0].id
                               if GameState.player.inventory.get_quantity(item_id) > 0:
                                       GameState.player.inventory.remove_item(item_id)
                                       trust += 1
               "gift":
                       var gift_id := accept_gift_item_ids[0]
                       if GameState.player.inventory.get_quantity(gift_id) > 0:
                               GameState.player.inventory.remove_item(gift_id)
                               love += 5
                               trust += 3
               "chat":
                       love += 1
                       trust += 1
