# CharactersManager.gd
extends Node

var characters = {
	"Player": preload("res://scenes/characters/player/Player.tscn"),
	"Slime": preload("res://scenes/characters/enemies/slime/Slime.tscn"),
	"Amice": preload("res://scenes/characters/npcs/amice_grover/AmiceGrover.tscn")
	# Thêm các nhân vật khác tại đây
}

func get_character(character_name: String) -> PackedScene:
	return characters.get(character_name)
