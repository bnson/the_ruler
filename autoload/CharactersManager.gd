# CharactersManager.gd
extends Node

var characters = {
	"Player": preload("res://characters/player/Player.tscn"),
	"Slime": preload("res://characters/enemies/slime/Slime.tscn"),
	# Thêm các nhân vật khác tại đây
}

func get_character(character_name: String) -> PackedScene:
	return characters.get(character_name)
