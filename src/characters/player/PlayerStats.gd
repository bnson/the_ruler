### 📄 PlayerStats.gd
extends BaseStats
class_name PlayerStats

signal stats_changed
signal current_hp_changed(new_value)
signal current_mp_changed(new_value)
signal current_sta_changed(new_value)
signal level_changed(new_level)
signal experience_changed(new_exp)

func _on_stat_updated(stat_name: String) -> void:
    stats_changed.emit()
    match stat_name:
        "current_hp": current_hp_changed.emit(current_hp)
        "current_mp": current_mp_changed.emit(current_mp)
        "current_sta": current_sta_changed.emit(current_sta)
        "level": level_changed.emit(level)
        "experience": experience_changed.emit(experience)
        _:
            pass

func gain_experience(amount: int) -> void:
    experience += amount
    var leveled_up := false
    while experience >= get_exp_to_next_level(level):
        experience -= get_exp_to_next_level(level)
        _level_up()
        leveled_up = true
    if not leveled_up:
        stats_changed.emit()

func _level_up() -> void:
    level += 1
    max_hp += 10
    current_hp = max_hp
    max_mp += 5
    current_mp = max_mp
    max_sta += 8
    current_sta = max_sta
