extends Interactable
class_name Honeydew

const HEIGHT_OFFSET: float = 0.1
const DROP_SPREAD: float = 0.1

var carried: bool = false

@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	assert(collision_shape != null, "collision_shape missing!")
	super._ready()
	global_position.y = HEIGHT_OFFSET


func set_carried(on: bool) -> void:
	carried = on
	can_interact = not carried
	collision_shape.disabled = carried
	if (not carried):
		global_position.x += randf_range(-DROP_SPREAD, DROP_SPREAD)
		global_position.y = HEIGHT_OFFSET
		global_position.z += randf_range(-DROP_SPREAD, DROP_SPREAD)
