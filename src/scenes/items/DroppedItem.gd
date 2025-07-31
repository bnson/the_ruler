extends RigidBody2D
class_name DroppedItem

var item: Item
var amount: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $PickupArea

func _ready():
	# Sau 0.5 giây khóa vật thể để nó đứng yên
	await get_tree().create_timer(0.5).timeout
	freeze = true  # thay cho MODE_STATIC	
	
	# Cho phép item được nhặt
	if area:   # tránh lỗi null
		area.body_entered.connect(_on_body_entered)
	else:
		push_error("PickupArea không tồn tại trong DroppedItem.tscn")

func set_item(new_item: Item, count := 1):
	item = new_item
	amount = count
	if sprite:
		sprite.texture = item.atlas_texture

func is_dropped_item() -> bool:
	return true

func get_item_data() -> Dictionary:
	return {"item": item, "amount": amount}

func _on_body_entered(body: Node):
	if body.is_in_group("Player"):
		body.add_item_to_inventory(item, amount)
		queue_free()
		
func _physics_process(delta):
	linear_velocity = linear_velocity.move_toward(Vector2.ZERO, 200 * delta)
		
