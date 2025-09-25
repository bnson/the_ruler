class_name  ItemEffectHeal extends ItemEffect

@export var heal_amount : int = 1
@export var sound : AudioStream

var playerState : PlayerState

func user() -> void:
	if playerState.stats.current_hp > 0:
		playerState.stats.current_hp = max(0, playerState.stats.current_hp + heal_amount)
