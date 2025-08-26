# Save System

The `SaveManager` autoload serializes the player state, all NPC states, inventory, position and in-game time to `user://savegame.json` (C:\Users\Admin\AppData\Roaming\Godot\app_userdata\The_Ruler). The game loads this data automatically on startup and performs an automatic save every in-game hour.

## Usage

```gdscript
SaveManager.save_game()    # Manual save
SaveManager.load_game()    # Manual load (auto-load happens on startup)
var ts = SaveManager.get_save_timestamp()  # When the save was created
```

The save file includes the player's global position and a timestamp (`saved_at`) using the system clock.

`NpcStateManager` keeps a registry of all `NPCState` resources. NPC scenes register themselves on `_ready`, so adding new NPC types only requires giving them a unique `npc_id`.
