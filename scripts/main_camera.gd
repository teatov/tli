extends Camera3D

const MOVE_SPEED: float = 2
## How many pixels the mouse needs to be away
## from the screen edge to move the camera.
const EDGE_THRESHOLD: float = 10

var mouse_position: Vector2 = Vector2()

func _process(delta: float) -> void:
	var viewport_size := get_viewport().get_visible_rect().size

	var move_input := Vector2()

	# Horizontal
	if (mouse_position.x <= EDGE_THRESHOLD):
		move_input.x = -1
	elif (mouse_position.x >= viewport_size.x - EDGE_THRESHOLD - 1):
		move_input.x = 1
	else:
		move_input.x = 0

	# Vertical
	if (mouse_position.y <= EDGE_THRESHOLD):
		move_input.y = -1
	elif (mouse_position.y >= viewport_size.y - EDGE_THRESHOLD - 1):
		move_input.y = 1
	else:
		move_input.y = 0

	var direction := (
			Vector3(move_input.x, 0, move_input.y)
			.rotated(Vector3.UP, rotation.y)
	)

	var velocity := direction * MOVE_SPEED
	position += velocity * delta

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = (event as InputEventMouseMotion).position
