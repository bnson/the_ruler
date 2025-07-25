# CharactersManager.gd
extends Node

var characters = {
	"Player": preload("res://src/characters/player/Player.tscn"),
	"Slime": preload("res://src/characters/enemies/slime/Slime.tscn"),
	# Thêm các nhân vật khác tại đây
}

func get_character(character_name: String) -> PackedScene:
	return characters.get(character_name)
