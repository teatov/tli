extends Interactable
class_name Honeydew

const HEIGHT_OFFSET: float = 0.1


func _ready() -> void:
	global_position.y = HEIGHT_OFFSET
