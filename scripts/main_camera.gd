extends Camera3D

const MOVE_SPEED: float = 2
const ZOOM_SPEED: float = 0.25
## How many pixels the mouse needs to be away
## from the screen edge to move the camera.
const EDGE_THRESHOLD: float = 10

@export var zoom_in_height: float = 1
@export var zoom_in_fov: float = 60
@export var zoom_in_angle: float = -0.1 * PI

@export var zoom_out_height: float = 3
@export var zoom_out_fov: float = 70
@export var zoom_out_angle: float = -0.25 * PI

var mouse_position: Vector2 = Vector2()
## 0 = zoomed in. 1 = zoomed out.
var zoom_value: float = 0.25

func _process(delta: float) -> void:
	handle_movement(delta)
	handle_zoom()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse_position = (event as InputEventMouseMotion).position
	
	if event is InputEventMouseButton:
		var button_event := event as InputEventMouseButton
		if button_event.pressed:
			if button_event.button_index == MOUSE_BUTTON_WHEEL_UP:
				zoom_value -= ZOOM_SPEED
			elif button_event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				zoom_value += ZOOM_SPEED
			zoom_value = clamp(zoom_value, 0, 1)

func handle_movement(delta: float) -> void:
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

func handle_zoom() -> void:
	fov = lerp(zoom_in_fov, zoom_out_fov, zoom_value)
	rotation.x = lerp(zoom_in_angle, zoom_out_angle, zoom_value)
	position.y = lerp(zoom_in_height, zoom_out_height, zoom_value)
