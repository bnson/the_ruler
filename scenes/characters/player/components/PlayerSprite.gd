extends Sprite2D

const FRAME_COUNT : int = 128

@onready var weapons := {
	"below": $WeaponSpriteBelow,
	"above": $WeaponSpriteAbove
}

func _process( _delta: float ) -> void:
	weapons["below"].frame = frame
	weapons["above"].frame = frame + FRAME_COUNT
	pass
