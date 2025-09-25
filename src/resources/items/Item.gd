class_name Item extends Resource

@export var id: String
@export var name: String
@export_multiline var description: String
@export var type: String
@export var price: int = 1
@export var is_unique: bool = false
@export var atlas_texture: AtlasTexture

@export_category("Item Use Effects")
@export var effects : Array[ItemEffect]

func use() -> bool:
	if effects.size() == 0:
		return false

	for e in effects:
		print("Item effect...")
		e.use()
		
	return true
