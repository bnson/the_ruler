extends Resource
class_name AmiceGroverState

var name: String = "Amice Grover"
var love: int = 0
var trust: int = 0
var favorite_gifts: Array[String] = ["Tea", "Sewing Kit"]
var given_gifts: Array[String] = []

func receive_gift(item_name: String) -> void:
	if item_name in favorite_gifts:
		love += 5
		trust += 3
	else:
		love += 1
		trust += 1
	given_gifts.append(item_name)
