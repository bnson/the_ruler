class_name ItemEffectHeal
extends ItemEffect

@export var heal_percent : float = 1.0  # 1 nghĩa là 1%
@export var audio_stream : AudioStream

func use() -> bool:
	var stats = PlayerManager.player.stats
	
	if stats.current_hp > 0 and stats.current_hp < stats.max_hp:
		var percent: float = clamp(heal_percent, 0.0, 100.0)
		var heal_amount: int = floor(stats.max_hp * (percent / 100.0))
		stats.current_hp = min(stats.current_hp + heal_amount, stats.max_hp)
		AudioManager.play_sfx(audio_stream, 0.1)
		return true
	
	return false
