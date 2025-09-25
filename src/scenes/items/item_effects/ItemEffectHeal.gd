class_name  ItemEffectHeal extends ItemEffect

@export var heal_amount : int = 1
@export var sound : AudioStream

func use() -> void:
	var playerStats = GameState.player.stats
	print("Run item effect heal")
	if playerStats.current_hp > 0:
		playerStats.current_hp += heal_amount
