# NPCState.gd
extends Resource
class_name NPCState

var name: String
var love: int
var trust: int
var favorite_gifts: Array[String] = []
var given_gifts: Array[String] = []

func receive_gift(item_name: String) -> void:
	if item_name in favorite_gifts:
		love += 5
		trust += 3
	else:
		love += 1
		trust += 1
	given_gifts.append(item_name)
